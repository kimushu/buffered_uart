#include "buffered_uart.h"
#include "buffered_uart_regs.h"
#include "sys/alt_irq.h"
#include <fcntl.h>

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void buffered_uart_irq(void *context)
#else
static void buffered_uart_irq(void *context, alt_u32 id)
#endif
{
    buffered_uart_state *sp = (buffered_uart_state *)context;
    alt_u32 base = sp->base;
    alt_irq_context irq_context;
    int i;

    sp->causes |= (IORD_BUFFERED_UART_STATUS(base) & BUFFERED_UART_STATUS_CAUSES_MSK);
    IOWR_BUFFERED_UART_INTR(base, IORD_BUFFERED_UART_INTR(base) & ~(sp->causes));

    irq_context = alt_irq_disable_all();
    for (i = sp->waiters; i > 0; --i) {
        ALT_SEM_POST(sp->sem);
    }
    alt_irq_enable_all(irq_context);
}

void buffered_uart_init(buffered_uart_state *sp, alt_u32 irq_controller_id, alt_u32 irq)
{
    int error;

    // Initialize sync object
    error = ALT_SEM_CREATE(&sp->sem, 0);

    if (!error) {
        // Clear buffer
        IOWR_BUFFERED_UART_STATUS(sp->base, BUFFERED_UART_STATUS_CLR_MSK);

        // Register interrupt handler
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
        alt_ic_isr_register(irq_controller_id, irq, buffered_uart_irq, sp, NULL);
#else
        alt_irq_register(irq, sp, buffered_uart_irq);
#endif

        // Enable interrupt
        IOWR_BUFFERED_UART_INTR(sp->base, BUFFERED_UART_INTR_IRQE_MSK);
    }
}

int buffered_uart_close(buffered_uart_state *sp, int flags)
{
    alt_irq_context context;
    alt_u32 base = sp->base;

    if (IORD_BUFFERED_UART_STATUS(base) & BUFFERED_UART_STATUS_TXE_MSK) {
        return 0;
    } else if (flags & O_NONBLOCK) {
        return -EWOULDBLOCK;
    }

    context = alt_irq_disable_all();
    sp->causes &= ~BUFFERED_UART_STATUS_TXE_MSK;
    IOWR_BUFFERED_UART_INTR(base, IORD_BUFFERED_UART_INTR(base) | BUFFERED_UART_INTR_TXE_MSK);
    ++sp->waiters;
    alt_irq_enable_all(context);

    do {
        ALT_SEM_PEND(sp->sem, 0);
    } while ((sp->causes & BUFFERED_UART_STATUS_TXE_MSK) == 0);

    context = alt_irq_disable_all();
    --sp->waiters;
    alt_irq_enable_all(context);

    return 0;
}

int buffered_uart_read(buffered_uart_state *sp, char *ptr, int len, int flags)
{
    alt_irq_context context;
    alt_u32 base = sp->base;
    int actual = 0;
    int paired = (sp->dataMask > 0xff);

    if (paired) {
        len /= 2;
    }
    while (len > 0) {
        alt_u16 data = IORD_BUFFERED_UART_DATA(base);

        if (data & BUFFERED_UART_DATA_RXE_MSK) {
            if (actual > 0) {
                break;
            } else {
                if (flags & O_NONBLOCK) {
                    return -EWOULDBLOCK;
                }
            }
            context = alt_irq_disable_all();
            sp->causes &= ~BUFFERED_UART_STATUS_RXNE_MSK;
            IOWR_BUFFERED_UART_INTR(base, IORD_BUFFERED_UART_INTR(base) | BUFFERED_UART_INTR_RXNE_MSK);
            ++sp->waiters;
            alt_irq_enable_all(context);

            do {
                ALT_SEM_PEND(sp->sem, 0);
            } while ((sp->causes & BUFFERED_UART_STATUS_RXNE_MSK) == 0);

            context = alt_irq_disable_all();
            --sp->waiters;
            alt_irq_enable_all(context);
        } else {
            *((alt_u8 *)ptr++) = (data & 0xff);
            if (paired) {
                *((alt_u8 *)ptr++) = (data >> 8);
            }
            --len;
            ++actual;
        }
    }

    return paired ? (actual * 2) : actual;
}

int buffered_uart_write(buffered_uart_state *sp, const char *ptr, int len, int flags)
{
    alt_irq_context context;
    alt_u32 status;
    alt_u32 base = sp->base;
    int actual = 0;
    int paired = (sp->dataMask > 0xff);

    if (paired) {
        len /= 2;
    }
    while (len > 0) {
        context = alt_irq_disable_all();
        status = IORD_BUFFERED_UART_STATUS(base);
        if ((status & BUFFERED_UART_STATUS_TXF_MSK) == 0) {
            alt_u16 value = *((alt_u8 *)ptr++);
            if (paired) {
                value |= *((alt_u8 *)ptr++) << 8;
            }
            IOWR_BUFFERED_UART_DATA(base, value);
            alt_irq_enable_all(context);
            --len;
            ++actual;
        } else if (flags & O_NONBLOCK) {
            alt_irq_enable_all(context);
            if (actual == 0) {
                return -EWOULDBLOCK;
            }
            break;
        } else {
            sp->causes &= ~BUFFERED_UART_STATUS_TXNF_MSK;
            IOWR_BUFFERED_UART_INTR(base, IORD_BUFFERED_UART_INTR(base) | BUFFERED_UART_INTR_TXNF_MSK);
            ++sp->waiters;
            alt_irq_enable_all(context);

            do {
                ALT_SEM_PEND(sp->sem, 0);
            } while ((sp->causes & BUFFERED_UART_STATUS_TXNF_MSK) == 0);

            context = alt_irq_disable_all();
            --sp->waiters;
            alt_irq_enable_all(context);
        }
    }

    return paired ? (actual * 2) : actual;
}

int buffered_uart_ioctl(buffered_uart_state *sp, int req, void *arg)
{
    return -ENOTSUP;
}

#ifndef ALT_USE_DIRECT_DRIVERS

int buffered_uart_close_fd(alt_fd *fd)
{
    buffered_uart_dev *dev = (buffered_uart_dev *)fd->dev;
    return buffered_uart_close(&dev->state, fd->fd_flags);
}

int buffered_uart_read_fd(alt_fd *fd, char *ptr, int len)
{
    buffered_uart_dev *dev = (buffered_uart_dev *)fd->dev;
    return buffered_uart_read(&dev->state, ptr, len, fd->fd_flags);
}

int buffered_uart_write_fd(alt_fd *fd, const char *ptr, int len)
{
    buffered_uart_dev *dev = (buffered_uart_dev *)fd->dev;
    return buffered_uart_write(&dev->state, ptr, len, fd->fd_flags);
}

int buffered_uart_ioctl_fd(alt_fd *fd, int req, void *arg)
{
    buffered_uart_dev *dev = (buffered_uart_dev *)fd->dev;
    return buffered_uart_ioctl(&dev->state, req, arg);
}

#endif  /* !ALT_USE_DIRECT_DRIVERS */
