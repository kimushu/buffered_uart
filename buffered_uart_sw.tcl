#
# buffered_uart "UART (RS232C) with FIFO buffers"
#

create_driver buffered_uart_driver

set_sw_property hw_class_name buffered_uart
set_sw_property min_compatible_hw_version 16.1
set_sw_property version 1.2

set_sw_property auto_initialize true
set_sw_property bsp_subdirectory drivers

set_sw_property isr_preemption_supported true
set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"

# Source files
add_sw_property c_source HAL/src/buffered_uart.c
add_sw_property include_source HAL/inc/buffered_uart.h
add_sw_property include_source inc/buffered_uart_regs.h

# Supported BSP types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# Software settings
add_sw_setting boolean_define_only system_h_define guard_write_conflict BUFFERED_UART_GUARD_WRITE_CONFLICT false "Enable guard of write conflicts. This blocks all interrupts during write."

# End of file
