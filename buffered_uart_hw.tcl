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
add_parameter DEVICE_FAMILY STRING "Unknown"
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true
set_parameter_property DEVICE_FAMILY ENABLED false
set_parameter_property DEVICE_FAMILY VISIBLE false

add_parameter DIVIDER_BITS INTEGER 1
set_parameter_property DIVIDER_BITS DERIVED true
set_parameter_property DIVIDER_BITS HDL_PARAMETER true
set_parameter_property DIVIDER_BITS VISIBLE false

add_parameter DIVIDER_INIT INTEGER 1
set_parameter_property DIVIDER_INIT DERIVED true
set_parameter_property DIVIDER_INIT HDL_PARAMETER true
set_parameter_property DIVIDER_INIT VISIBLE false

add_parameter DIVIDER_FIXED INTEGER 0
set_parameter_property DIVIDER_FIXED DERIVED true
set_parameter_property DIVIDER_FIXED HDL_PARAMETER true
set_parameter_property DIVIDER_FIXED VISIBLE false

add_parameter RTSCTS_ENABLE INTEGER 0
set_parameter_property RTSCTS_ENABLE DERIVED true
set_parameter_property RTSCTS_ENABLE HDL_PARAMETER true
set_parameter_property RTSCTS_ENABLE VISIBLE false

add_parameter CLOCK_FREQ INTEGER 0
set_parameter_property CLOCK_FREQ DISPLAY_NAME "Clock"
set_parameter_property CLOCK_FREQ UNITS Hertz
set_parameter_property CLOCK_FREQ SYSTEM_INFO {CLOCK_RATE clock}
set_parameter_property CLOCK_FREQ HDL_PARAMETER false
set_parameter_property CLOCK_FREQ ENABLED false

add_parameter LIST_BAUD INTEGER 115200
set_parameter_property LIST_BAUD DISPLAY_NAME "Baudrate"
set_parameter_property LIST_BAUD DISPLAY_UNITS "bps"
set_parameter_property LIST_BAUD ALLOWED_RANGES {"0:Custom" "9600" "19200" "38400" "57600" "115200" "230400" "460800" "921600"}
set_parameter_property LIST_BAUD HDL_PARAMETER false

add_parameter CUSTOM_BAUD INTEGER 115200
set_parameter_property CUSTOM_BAUD DISPLAY_NAME "Custom baudrate"
set_parameter_property CUSTOM_BAUD UNITS BitsPerSecond
set_parameter_property CUSTOM_BAUD HDL_PARAMETER false

add_parameter BAUD_ERROR FLOAT Inf
set_parameter_property BAUD_ERROR DERIVED true
set_parameter_property BAUD_ERROR DISPLAY_NAME "Error"
set_parameter_property BAUD_ERROR DISPLAY_UNITS "%"
set_parameter_property BAUD_ERROR HDL_PARAMETER false
set_parameter_property BAUD_ERROR ENABLED false

add_parameter FIXED_BAUD BOOLEAN true
set_parameter_property FIXED_BAUD DISPLAY_NAME "Fixed baudrate"
set_parameter_property FIXED_BAUD HDL_PARAMETER false

add_parameter MANUAL_DIV_BITS INTEGER 8
set_parameter_property MANUAL_DIV_BITS DISPLAY_NAME "Divider bits"
set_parameter_property MANUAL_DIV_BITS UNITS None
set_parameter_property MANUAL_DIV_BITS HDL_PARAMETER false
set_parameter_property MANUAL_DIV_BITS ALLOWED_RANGES 1:16

add_parameter DATA_BITS INTEGER 8
set_parameter_property DATA_BITS DISPLAY_NAME "Data bits"
set_parameter_property DATA_BITS UNITS None
set_parameter_property DATA_BITS HDL_PARAMETER true

add_parameter RX_DEPTH_BITS INTEGER 7
set_parameter_property RX_DEPTH_BITS DISPLAY_NAME "RX FIFO depth"
set_parameter_property RX_DEPTH_BITS HDL_PARAMETER true
set_parameter_property RX_DEPTH_BITS ALLOWED_RANGES {"2:4 words" "3:8 words" "4:16 words" "5:32 words" "6:64 words" "7:128 words" "8:256 words" "9:512 words" "10:1024 words" "11:2048 words" "12:4096 words" "13:8192 words" "14:16384 words" "15:32768 words" "16:65536 words" "17:131072 words"}

add_parameter TX_DEPTH_BITS INTEGER 7
set_parameter_property TX_DEPTH_BITS DISPLAY_NAME "TX FIFO depth"
set_parameter_property TX_DEPTH_BITS HDL_PARAMETER true
set_parameter_property TX_DEPTH_BITS ALLOWED_RANGES {"2:4 words" "3:8 words" "4:16 words" "5:32 words" "6:64 words" "7:128 words" "8:256 words" "9:512 words" "10:1024 words" "11:2048 words" "12:4096 words" "13:8192 words" "14:16384 words" "15:32768 words" "16:65536 words" "17:131072 words"}

add_parameter USE_RTSCTS BOOLEAN true
set_parameter_property USE_RTSCTS DISPLAY_NAME "Use RTS/CTS"
set_parameter_property USE_RTSCTS HDL_PARAMETER false


# 
# display items
# 

add_display_item {} {Basic settings} GROUP
add_display_item {} {Baudrate settings} GROUP

add_display_item {Basic settings} DATA_BITS PARAMETER
add_display_item {Basic settings} USE_RTSCTS PARAMETER
add_display_item {Basic settings} RX_DEPTH_BITS PARAMETER
add_display_item {Basic settings} TX_DEPTH_BITS PARAMETER

add_display_item {Baudrate settings} CLOCK_FREQ PARAMETER
add_display_item {Baudrate settings} LIST_BAUD PARAMETER
add_display_item {Baudrate settings} CUSTOM_BAUD PARAMETER
add_display_item {Baudrate settings} BAUD_ERROR PARAMETER
add_display_item {Baudrate settings} FIXED_BAUD PARAMETER
add_display_item {Baudrate settings} MANUAL_DIV_BITS PARAMETER
add_display_item {Baudrate settings} INFO_BAUD TEXT ""


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
set_interface_property s1 addressAlignment NATIVE
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
set_interface_property s1 readLatency 0
set_interface_property s1 readWaitStates 1
set_interface_property s1 readWaitTime 1
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
set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice 1


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

add_interface_port uart coe_rxd rxd Input 1
add_interface_port uart coe_txd txd Output 1


# 
# connection point uart
# 
add_interface flow conduit end
set_interface_property flow associatedClock ""
set_interface_property flow associatedReset ""
set_interface_property flow ENABLED true
set_interface_property flow EXPORT_OF ""
set_interface_property flow PORT_NAME_MAP ""
set_interface_property flow CMSIS_SVD_VARIABLES ""
set_interface_property flow SVD_ADDRESS_GROUP ""

add_interface_port flow coe_rts rts Output 1
add_interface_port flow coe_cts cts Input 1


# 
# Callbacks
# 

set_module_property ELABORATION_CALLBACK elaboration_callback
proc elaboration_callback {} {
    # Switch flow control export
    set useRtsCts [get_parameter_value USE_RTSCTS]
    set_interface_property flow ENABLED $useRtsCts
    set_parameter_value RTSCTS_ENABLE [expr $useRtsCts == "true"]

    # Switch custom baudrate
    set listBaud [get_parameter_value LIST_BAUD]
    set customBaud [get_parameter_value CUSTOM_BAUD]
    if {$listBaud == 0} {
        set baud $customBaud
    } else {
        set baud $listBaud
    }
    set_parameter_property CUSTOM_BAUD ALLOWED_RANGES ""
    set_parameter_property CUSTOM_BAUD VISIBLE [expr $listBaud == 0]

    # Switch divider bits
    set fixedBaud [expr [get_parameter_value FIXED_BAUD] == "true"]
    set_parameter_property MANUAL_DIV_BITS VISIBLE [expr !$fixedBaud]
    set_parameter_value DIVIDER_FIXED $fixedBaud

    # Calculate min/max baud
    set clockFreq [get_parameter_value CLOCK_FREQ]
    set info ""
    set baudErr "NaN"
    if {$clockFreq == 0} {
        send_message Error "Clock frequency is unknown"
    } else {
        if {$fixedBaud} {
            set divBits 16
        } else {
            set divBits [get_parameter_value MANUAL_DIV_BITS]
        }
        set divMax [expr (2 ** $divBits) - 1]
        set minBaud [expr int(ceil($clockFreq / 4.0 / ($divMax + 1)))]
        set maxBaud [expr int(floor($clockFreq / 4.0 / (1 + 1)))]
        if { $minBaud <= $baud && $baud <= $maxBaud } {
            set divVal [expr int(round($clockFreq / 4.0 / $baud)) - 1]
            set_parameter_value DIVIDER_INIT $divVal

            if {$fixedBaud} {
                set divBits [expr int(ceil(log($divVal + 1) / log(2)))]
            }
            set_parameter_value DIVIDER_BITS $divBits

            set actBaud [expr $clockFreq / 4.0 / ($divVal + 1)]
            set baudErr [expr round(($actBaud / $baud - 1) * 10000) / 100.0]
            if {abs($baudErr) > 3.0} {
                send_message Warning "Baudrate error is too large (${baudErr}%)."
            }
        } else {
            send_message Error "Baudrate is out of range: $minBaud-$maxBaud"
        }
        set info "Info: Baudrate range is $minBaud-$maxBaud"
        if {$listBaud == 0} {
            set_parameter_property CUSTOM_BAUD ALLOWED_RANGES $minBaud:$maxBaud
        }
    }
    set_parameter_value BAUD_ERROR $baudErr
    set_display_item_property INFO_BAUD TEXT "<html>$info</html>"
}

set_module_property VALIDATION_CALLBACK validate_callback
proc validate_callback {} {
    # Define macros for BSP
    set_module_assignment embeddedsw.CMacro.DATA_BITS [get_parameter_value DATA_BITS]
    set_module_assignment embeddedsw.CMacro.DIVIDER_BITS [get_parameter_value DIVIDER_BITS]
    set_module_assignment embeddedsw.CMacro.FIXED_BAUD [get_parameter_value DIVIDER_FIXED]
    set_module_assignment embeddedsw.CMacro.RX_DEPTH_BITS [get_parameter_value RX_DEPTH_BITS]
    set_module_assignment embeddedsw.CMacro.TX_DEPTH_BITS [get_parameter_value TX_DEPTH_BITS]
}
