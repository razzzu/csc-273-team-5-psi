F64 = -full64
VCS = vcs $(F64) +lint=all
COV = -cm fsm+line+tgl+cond
VFLAGS = -debug_access
null  :=
space := $(null) #

PSI_FIXTURE_FILES = testbench/psi_fixture.v design/dma_beh/dma_beh.v design/experiments/beh_fifo.v
PSI_FILES = design/psi.v design/pi/*.v design/si/*.v design/fifo/*.v

# to add a new target just follow this template if you want a `make <command>`
# <command>: <directories>/<filename>
# <directories>/<filename>: [<dependant file> [<dependant file> ...]]
	# <command>
	# vcs -full64 +lint=all -o <directories>/<filename> +incdir+<directory of files to search `include>[+<another directory>[+...]]+ <files testing>

# <directory/to/simv>: <testbench/file> [<dependant/file1> [<dependant/file2> ...]]
#	What is $(subst $(space),+,$(dir $^)): takes all dependancies, $^, and for each $(space) replace with a +
#	What is $<: Is the leftmost dependant file, in this case the testbench file
#	What is $@: The name of the rule, so the expected output
# 	$(VCS) $(VFLAGS) $(COV) -o $@ +incdir+$(subst $(space),+,$(dir $^)) $<
# 	$@ $(COV) -cm_log $@.cm.log
# ifneq "$(COV)" ""
# 	urg $(F64) -dir $@.vdb -report $@.urgReport
# endif

# dc_shell -no_gui -x "source synth/serial_com.scr; exit" -output_log_file synth/serial_com.log

report: report.txt
	echo "report finished, no coverage in the text file since coverage is html"

report.txt: sim/psi synth
	echo "// Group 5: Raj & Ethan" > report.txt

	echo "" >> report.txt
	echo " -- DESIGN CODE --" >> report.txt
	for i in $(PSI_FILES); do \
		echo " -- DESIGN FILE: $$i --" >> report.txt; \
		echo "" >> report.txt; \
		cat $$i >> report.txt; \
		echo "" >> report.txt; \
	done

	echo "" >> report.txt
	echo " -- TESTBENCH CODE --" >> report.txt
	for i in $(PSI_FIXTURE_FILES); do \
		echo " -- TESTBENCH FILE/CODE: $$i --" >> report.txt; \
		echo "" >> report.txt; \
		cat $$i >> report.txt; \
		echo "" >> report.txt; \
	done

	echo "" >> report.txt
	echo " -- SIMULATION RESULTS --" >> report.txt
	cat sim/psi_sim_results.log >> report.txt

	echo "" >> report.txt
	echo " -- SYNTHESIS SCRIPT --" >> report.txt
	echo "" >> report.txt
	cat synth/psi.scr >> report.txt
	for i in synth/reports/*.txt; do \
		echo "$$i" >> report.txt; \
		echo "" >> report.txt; \
		cat $$i >> report.txt; \
		echo "" >> report.txt; \
	done
synth:
	dc_shell -no_gui -x "source synth/psi.scr; check_design; exit" -output_log_file synth/psi.log

synth_shell:
	dc_shell -no_gui -x "source synth/psi.scr;" -output_log_file synth/psi.log

psi: sim/psi

simple_fifo: sim/simple_fifo

fifo: sim/fifo

sync: sim/sync_test

psi: sim/psi

pi: sim/pi_test

si: sim/serial_com

sim/psi: $(PSI_FIXTURE_FILES)  $(PSI_FILES)
	$(VCS) $(VFLAGS) $(COV) -o $@ +incdir+$(subst $(space),+,$(dir $^)) $<
	$@ $(COV) | tee $@_sim_results.log
ifneq "$(COV)" ""
	urg $(F64) -dir $@.vdb -report $@.urgReport
endif
# 	vcs -full64 -o sim/psi +incdir+./design/+./design/dma_beh/+./design/pi/+./design/si/+./design/fifo/ 

sim/fifo: design/fifo/fifo.v testbench/simple_fifo_fixture.v
	vcs -full64 +lint=all -o sim/fifo +incdir+./design/fifo/ testbench/fifo_fixture.v

	# $(VCS) $(VFLAGS) $(COV) -o $@ +incdir+./design/fifo/ testbench/simple_fifo_fixture.v
sim/simple_fifo: testbench/simple_fifo_fixture.v design/fifo/simple_fifo.v
	$(VCS) $(VFLAGS) $(COV) -o $@ +incdir+$(subst $(space),+,$(dir $^)) $<
	$@ $(COV)
ifneq "$(COV)" ""
	urg $(F64) -dir $@.vdb -report $@.urgReport
endif

sim/sync_test: design/experiments/sync_ptr_2_clk.v design/fifo/sync_ptr.v testbench/sync_fixture.v
	vcs -full64 +lint=all -o sim/sync_test +incdir+./design/fifo/+./design/experiments testbench/sync_fixture.v

sim/pi_test: design/pi/com_fsm.v design/pi/par_com.v design/dma_beh/dma_beh.v design/fifo/fifo.v testbench/pi_fixture.v
	vcs -debug_access -full64 -o sim/pi_test +incdir+./design/pi/+./design/dma_beh/+./design/fifo/ testbench/pi_fixture.v

sim/serial_com: testbench/serial_com_fixture.v design/si/serial_com.v
	$(VCS) $(VFLAGS) $(COV) -o $@ +incdir+$(subst $(space),+,$(dir $^)) $<
	$@ $(COV) -cm_log $@.cm.log
ifneq "$(COV)" ""
	urg $(F64) -dir $@.vdb -report $@.urgReport
endif

.PHONY: clean synth synth_shell

clean:
	find sim -mindepth 1 ! -name .gitignore -delete
	find synth -mindepth 1 ! \( -name .gitignore -or -name \*scr \) -and ! -type d -delete
	find . -maxdepth 1 \( -name command.log -or -name default.svf \) -delete
	rm -rf csrc work WORK* report.txt
