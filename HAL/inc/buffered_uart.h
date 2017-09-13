#ifndef __BUFFERED_UART_H__
#define __BUFFERED_UART_H__

#include "alt_types.h"
#include "sys/alt_dev.h"
#include "os/alt_sem.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct buffered_uart_state_s {
    alt_u32 base;
    volatile alt_u16 causes;
    ALT_SEM(sem);
} buffered_uart_state;

#ifndef ALT_USE_DIRECT_DRIVERS

typedef struct buffered_uart_dev_s {
    alt_dev dev;
    buffered_uart_state state;
} buffered_uart_dev;

extern int buffered_uart_close_fd(alt_fd *fd);
extern int buffered_uart_read_fd(alt_fd *fd, char *ptr, int len);
extern int buffered_uart_write_fd(alt_fd *fd, const char *ptr, int len);
extern int buffered_uart_ioctl_fd(alt_fd *fd, int req, void *arg);

#endif  /* !ALT_USE_DIRECT_DRIVERS */

extern void buffered_uart_init(buffered_uart_state *sp, alt_u32 irq_controller_id, alt_u32 irq);

#define BUFFERED_UART_STATE_INSTANCE_INITIALIZER(name) \
    { \
        name##_BASE, \
        0, \
    }

#define BUFFERED_UART_STATE_INSTANCE(name, state) \
    buffered_uart_state state = \
        BUFFERED_UART_STATE_INSTANCE_INITIALIZER(name)

#define BUFFERED_UART_STATE_INIT(name, state) \
    buffered_uart_init(&state, name##_IRQ_INTERRUPT_CONTROLLER_ID, name##_IRQ)

#define BUFFERED_UART_DEV_INSTANCE(name, dev) \
    buffered_uart_dev dev = { \
        { \
            ALT_LLIST_ENTRY, \
            name##_NAME, \
            NULL,   /* open */  \
            buffered_uart_close_fd, \
            buffered_uart_read_fd, \
            buffered_uart_write_fd, \
            NULL,   /* lseek */ \
            NULL,   /* fstat */ \
            buffered_uart_ioctl_fd, \
        }, \
        BUFFERED_UART_STATE_INSTANCE_INITIALIZER(name) \
    }

#define BUFFERED_UART_DEV_INIT(name, d) \
    do { \
        BUFFERED_UART_STATE_INIT(name, d.state); \
        alt_dev_reg(&d.dev); \
    } while (0)

#ifdef ALT_USE_DIRECT_DRIVERS

# define BUFFERED_UART_INSTANCE(name, state) \
    BUFFERED_UART_STATE_INSTANCE(name, state)
# define BUFFERED_UART_INIT(name, state) \
    BUFFERED_UART_STATE_INIT(name, state)

#else   /* !ALT_USE_DIRECT_DRIVERS */

# define BUFFERED_UART_INSTANCE(name, dev) \
    BUFFERED_UART_DEV_INSTANCE(name, dev)
# define BUFFERED_UART_INIT(name, dev) \
    BUFFERED_UART_DEV_INIT(name, dev)

#endif  /* !ALT_USE_DIRECT_DRIVERS */

#ifdef __cplusplus
}   /* extern "C" */
#endif

#endif  /* __BUFFERED_UART_H__ */
