onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DUT1
add wave -noupdate /test_buffered_uart/dut1/clk
add wave -noupdate /test_buffered_uart/dut1/reset
add wave -noupdate /test_buffered_uart/dut1/avs_address
add wave -noupdate /test_buffered_uart/dut1/avs_read
add wave -noupdate -radix hexadecimal /test_buffered_uart/dut1/avs_readdata
add wave -noupdate /test_buffered_uart/dut1/avs_write
add wave -noupdate -radix hexadecimal /test_buffered_uart/dut1/avs_writedata
add wave -noupdate /test_buffered_uart/dut1/ins_irq
add wave -noupdate -expand -group dut1.rx /test_buffered_uart/dut1/coe_rxd
add wave -noupdate -expand -group dut1.rx /test_buffered_uart/dut1/coe_rts
add wave -noupdate -expand -group dut1.rx /test_buffered_uart/dut1/rx_state_reg
add wave -noupdate -expand -group dut1.rx /test_buffered_uart/dut1/rx_step0_reg
add wave -noupdate -expand -group dut1.rx /test_buffered_uart/dut1/rx_step2_reg
add wave -noupdate -expand -group dut1.tx /test_buffered_uart/dut1/coe_txd
add wave -noupdate -expand -group dut1.tx /test_buffered_uart/dut1/coe_cts
add wave -noupdate -expand -group dut1.tx /test_buffered_uart/dut1/tx_state_reg
add wave -noupdate -expand -group dut1.tx /test_buffered_uart/dut1/tx_step0_reg
add wave -noupdate -expand -group dut1.tx /test_buffered_uart/dut1/tx_step2_reg
add wave -noupdate -divider DUT2
add wave -noupdate /test_buffered_uart/dut2/clk
add wave -noupdate /test_buffered_uart/dut2/reset
add wave -noupdate /test_buffered_uart/dut2/avs_address
add wave -noupdate /test_buffered_uart/dut2/avs_read
add wave -noupdate -radix hexadecimal /test_buffered_uart/dut2/avs_readdata
add wave -noupdate /test_buffered_uart/dut2/avs_write
add wave -noupdate -radix hexadecimal /test_buffered_uart/dut2/avs_writedata
add wave -noupdate /test_buffered_uart/dut2/ins_irq
add wave -noupdate -expand -group dut2.rx /test_buffered_uart/dut2/coe_rxd
add wave -noupdate -expand -group dut2.rx /test_buffered_uart/dut2/coe_rts
add wave -noupdate -expand -group dut2.rx /test_buffered_uart/dut2/rx_state_reg
add wave -noupdate -expand -group dut2.rx /test_buffered_uart/dut2/rx_step0_reg
add wave -noupdate -expand -group dut2.rx /test_buffered_uart/dut2/rx_step2_reg
add wave -noupdate -expand -group dut2.tx /test_buffered_uart/dut2/coe_txd
add wave -noupdate -expand -group dut2.tx /test_buffered_uart/dut2/coe_cts
add wave -noupdate -expand -group dut2.tx /test_buffered_uart/dut2/tx_state_reg
add wave -noupdate -expand -group dut2.tx /test_buffered_uart/dut2/tx_step0_reg
add wave -noupdate -expand -group dut2.tx /test_buffered_uart/dut2/tx_step2_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {429581464 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {404782571 ps} {564784470 ps}
