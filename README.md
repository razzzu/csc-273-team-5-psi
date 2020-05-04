# csc-273-team-5-psi

To run, just use:
`make report`

This will run:
`make psi`
and
`make synth`

To get a shell after synthesis run:
`make synth_shell`

The make recipe for `report` will run everything, sim and synthesis and put the output of all into `report.txt`.

The make recipe for `psi` will run testbench for the psi module, generating a simv as the `sim/psi` executable along with an output log of the test in `sim/psi_sim_results.log` and the directory `sim/psi.urgReport` of code coverage.

The make recipe for `synth` will run through synthesis for psi module, it will generate a log of the synthesis output in `synth/psi.log` and reports in `synth/reports/psi_report*`.
