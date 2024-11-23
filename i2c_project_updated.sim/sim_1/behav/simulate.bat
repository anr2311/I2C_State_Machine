@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.3\\bin
call %xv_path%/xsim i2c_master_tb_new_behav -key {Behavioral:sim_1:Functional:i2c_master_tb_new} -tclbatch i2c_master_tb_new.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
