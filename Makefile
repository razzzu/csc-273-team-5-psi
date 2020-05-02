# to add a new target just follow this template if you want a `make <command>`
# <command>: <directories>/<filename>
# <directories>/<filename>: [<dependant file> [<dependant file> ...]]
	# <command>
	# vcs -full64 +lint=all -o <directories>/<filename> +incdir+<directory of files to search `include>[+<another directory>[+...]]+ <files testing>

simple_fifo: sim/simple_fifo

fifo: sim/fifo

sync: sim/sync_test

pi: sim/pi_test

serial_com: sim/serial_com

sim/fifo: design/fifo/fifo.v testbench/simple_fifo_fixture.v
	vcs -full64 +lint=all -o sim/fifo +incdir+./design/fifo/ testbench/fifo_fixture.v

sim/simple_fifo: design/fifo/simple_fifo.v testbench/simple_fifo_fixture.v
	vcs -full64 +lint=all -o sim/simple_fifo +incdir+./design/fifo/ testbench/simple_fifo_fixture.v

sim/sync_test: design/experiments/sync_ptr_2_clk.v design/fifo/sync_ptr.v testbench/sync_fixture.v
	vcs -full64 +lint=all -o sim/sync_test +incdir+./design/fifo/+./design/experiments testbench/sync_fixture.v

sim/pi_test: design/pi/com_fsm.v design/pi/par_com.v design/dma_beh/dma_beh.v design/fifo/fifo.v testbench/pi_fixture.v
	vcs -debug_access -full64 -o sim/pi_test +incdir+./design/pi/+./design/dma_beh/+./design/fifo/ testbench/pi_fixture.v

sim/serial_com: design/si/serial_com.v testbench/serial_com_fixture.v
	vcs -full64 +lint=all -debug_access -o sim/serial_com +incdir+./design/si/ testbench/serial_com_fixture.v

clean:
	find sim -mindepth 1 ! -name .gitignore -delete
	rm -rf csrc