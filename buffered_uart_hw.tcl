# 
# buffered_uart "UART (RS232C) with FIFO buffers"
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module buffered_uart
# 
set_module_property DESCRIPTION ""
set_module_property NAME buffered_uart
set_module_property VERSION 16.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Interface Protocols/Serial"
set_module_property AUTHOR kimu_shu
set_module_property DISPLAY_NAME "UART (RS232C) with FIFO buffers"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL buffered_uart
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file buffered_uart.vhd VHDL PATH hdl/buffered_uart.vhd TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter DEVICE_FAMILY string
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true
set_parameter_property DEVICE_FAMILY ENABLED false
set_parameter_property DEVICE_FAMILY VISIBLE false

add_parameter CLOCK_FREQ integer
set_parameter_property CLOCK_FREQ UNITS hertz
set_parameter_property CLOCK_FREQ SYSTEM_INFO {CLOCK_RATE s1}
set_parameter_property CLOCK_FREQ HDL_PARAMETER true
set_parameter_property CLOCK_FREQ ENABLED false
set_parameter_property CLOCK_FREQ VISIBLE false

add_parameter BAUDRATE INTEGER 115200
set_parameter_property BAUDRATE DEFAULT_VALUE 115200
set_parameter_property BAUDRATE DISPLAY_NAME BAUDRATE
set_parameter_property BAUDRATE TYPE INTEGER
set_parameter_property BAUDRATE UNITS None
set_parameter_property BAUDRATE HDL_PARAMETER true

add_parameter DATA_BITS INTEGER 8
set_parameter_property DATA_BITS DEFAULT_VALUE 8
set_parameter_property DATA_BITS DISPLAY_NAME DATA_BITS
set_parameter_property DATA_BITS TYPE INTEGER
set_parameter_property DATA_BITS UNITS None
set_parameter_property DATA_BITS HDL_PARAMETER true

add_parameter RXFIFO_DEPTH INTEGER 128
set_parameter_property RXFIFO_DEPTH DEFAULT_VALUE 128
set_parameter_property RXFIFO_DEPTH DISPLAY_NAME RXFIFO_DEPTH
set_parameter_property RXFIFO_DEPTH TYPE INTEGER
set_parameter_property RXFIFO_DEPTH UNITS None
set_parameter_property RXFIFO_DEPTH HDL_PARAMETER true

add_parameter TXFIFO_DEPTH INTEGER 128
set_parameter_property TXFIFO_DEPTH DEFAULT_VALUE 128
set_parameter_property TXFIFO_DEPTH DISPLAY_NAME TXFIFO_DEPTH
set_parameter_property TXFIFO_DEPTH TYPE INTEGER
set_parameter_property TXFIFO_DEPTH UNITS None
set_parameter_property TXFIFO_DEPTH HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point s1
# 
add_interface s1 avalon end
set_interface_property s1 addressUnits WORDS
set_interface_property s1 associatedClock clock
set_interface_property s1 associatedReset reset
set_interface_property s1 bitsPerSymbol 8
set_interface_property s1 burstOnBurstBoundariesOnly false
set_interface_property s1 burstcountUnits WORDS
set_interface_property s1 explicitAddressSpan 0
set_interface_property s1 holdTime 0
set_interface_property s1 linewrapBursts false
set_interface_property s1 maximumPendingReadTransactions 0
set_interface_property s1 maximumPendingWriteTransactions 0
set_interface_property s1 readLatency 1
set_interface_property s1 readWaitStates 0
set_interface_property s1 readWaitTime 0
set_interface_property s1 setupTime 0
set_interface_property s1 timingUnits Cycles
set_interface_property s1 writeWaitTime 0
set_interface_property s1 ENABLED true
set_interface_property s1 EXPORT_OF ""
set_interface_property s1 PORT_NAME_MAP ""
set_interface_property s1 CMSIS_SVD_VARIABLES ""
set_interface_property s1 SVD_ADDRESS_GROUP ""

add_interface_port s1 avs_address address Input 2
add_interface_port s1 avs_read read Input 1
add_interface_port s1 avs_readdata readdata Output 16
add_interface_port s1 avs_write write Input 1
add_interface_port s1 avs_writedata writedata Input 16
set_interface_assignment s1 embeddedsw.configuration.isFlash 0
set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point irq
# 
add_interface irq interrupt end
set_interface_property irq associatedAddressablePoint s1
set_interface_property irq associatedClock clock
set_interface_property irq associatedReset reset
set_interface_property irq bridgedReceiverOffset 0
set_interface_property irq bridgesToReceiver ""
set_interface_property irq ENABLED true
set_interface_property irq EXPORT_OF ""
set_interface_property irq PORT_NAME_MAP ""
set_interface_property irq CMSIS_SVD_VARIABLES ""
set_interface_property irq SVD_ADDRESS_GROUP ""

add_interface_port irq ins_irq irq Output 1


# 
# connection point uart
# 
add_interface uart conduit end
set_interface_property uart associatedClock ""
set_interface_property uart associatedReset ""
set_interface_property uart ENABLED true
set_interface_property uart EXPORT_OF ""
set_interface_property uart PORT_NAME_MAP ""
set_interface_property uart CMSIS_SVD_VARIABLES ""
set_interface_property uart SVD_ADDRESS_GROUP ""

add_interface_port uart coe_rxd export Input 1
add_interface_port uart coe_txd export Output 1
add_interface_port uart coe_rts export Output 1
add_interface_port uart coe_cts export Input 1

