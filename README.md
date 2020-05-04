# csc-273-team-5-psi

To run, just use:
`make report`

This will run:
`make psi`
and
`make synth`

To get a shell after synthesis run:
`make synth_shell`


The make recipe for `psi` will run testbench for the psi module, generating a `sim/psi` executable and a `sim/psi.urgReport` of code coverage.

The make recipe for `synth` will run through synthesis for psi module, it will generate a log of the output in `synth/psi.log` and reports in `synth/reports/psi_report*`.
