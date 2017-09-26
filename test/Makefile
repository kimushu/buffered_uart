TOP_MODULE = buffered_uart
SUB_MODULES =

.PHONY: compile
compile: work
	vcom $(foreach m,$(TOP_MODULE) $(SUB_MODULES),../hdl/$(m).vhd) test_$(TOP_MODULE).vhd

.PHONY: test
test: compile
	vsim test_$(TOP_MODULE)

.PHONY: wave
wave:
	vsim test_$(TOP_MODULE) -do wave.do

work:
	vlib work

.PHONY: clean
clean:
	rm -rf work
