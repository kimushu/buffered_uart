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
    sp->causes |= (IORD_BUFFERED_UART_STATUS(base) & BUFFERED_UART_STATUS_CAUSES_MSK);
    IOWR_BUFFERED_UART_INTR(base, IORD_BUFFERED_UART_INTR(base) & ~(sp->causes));
    ALT_SEM_POST(sp->sem);
}

void buffered_uart_init(buffered_uart_state *sp, alt_u32 irq_controller_id, alt_u32 irq)
{
    int error = ALT_SEM_CREATE(&sp->sem, 0);

    if (!error) {
        // Register interrupt handler
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
        alt_ic_isr_register(irq_controller_id, irq, buffered_uart_irq, sp, 0x0);
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
    alt_irq_enable_all(context);

    do {
        ALT_SEM_PEND(sp->sem, 0);
    } while ((sp->causes & BUFFERED_UART_STATUS_TXE_MSK) == 0);

    return 0;
}

int buffered_uart_close_fd(alt_fd *fd)
{
    buffered_uart_dev *dev = (buffered_uart_dev *)fd->dev;
    return buffered_uart_close(&dev->state, fd->fd_flags);
}

int buffered_uart_read(buffered_uart_state *sp, char *ptr, int len, int flags)
{
    alt_irq_context context;
    alt_u32 base = sp->base;
    int actual = 0;

    while (len > 0) {
        alt_u32 data = IORD_BUFFERED_UART_DATA(base);

        if (data & BUFFERED_UART_DATA_RXE_MSK) {
            if (flags & O_NONBLOCK) {
                if (actual == 0) {
                    return -EWOULDBLOCK;
                }
                break;
            }
            context = alt_irq_disable_all();
            sp->causes &= ~BUFFERED_UART_STATUS_RXNE_MSK;
            IOWR_BUFFERED_UART_INTR(base, IORD_BUFFERED_UART_INTR(base) | BUFFERED_UART_INTR_RXNE_MSK);
            alt_irq_enable_all(context);

            do {
                ALT_SEM_PEND(sp->sem, 0);
            } while ((sp->causes & BUFFERED_UART_STATUS_RXNE_MSK));
        } else {
            *ptr++ = (char)(data & 0xff);
            --len;
            ++actual;
        }
    }

    return actual;
}

int buffered_uart_read_fd(alt_fd *fd, char *ptr, int len)
{
    buffered_uart_dev *dev = (buffered_uart_dev *)fd->dev;
    return buffered_uart_read(&dev->state, ptr, len, fd->fd_flags);
}

int buffered_uart_write(buffered_uart_state *sp, const char *ptr, int len, int flags)
{
    alt_irq_context context;
    alt_u32 status;
    alt_u32 base = sp->base;
    int actual = 0;

    while (len > 0) {
        context = alt_irq_disable_all();
        status = IORD_BUFFERED_UART_STATUS(base);
        if ((status & BUFFERED_UART_STATUS_TXF_MSK) == 0) {
            IOWR_BUFFERED_UART_DATA(base, *ptr++);
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
            alt_irq_enable_all(context);

            do {
                ALT_SEM_PEND(sp->sem, 0);
            } while ((sp->causes & BUFFERED_UART_STATUS_TXNF_MSK));
        }
    }

    return actual;
}

int buffered_uart_write_fd(alt_fd *fd, const char *ptr, int len)
{
    buffered_uart_dev *dev = (buffered_uart_dev *)fd->dev;
    return buffered_uart_write(&dev->state, ptr, len, fd->fd_flags);
}

int buffered_uart_ioctl(buffered_uart_state *sp, int req, void *arg)
{
    return -ENOTSUP;
}

int buffered_uart_ioctl_fd(alt_fd *fd, int req, void *arg)
{
    buffered_uart_dev *dev = (buffered_uart_dev *)fd->dev;
    return buffered_uart_ioctl(&dev->state, req, arg);
}