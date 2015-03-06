#!/usr/bin/perl

use Getopt::Long;

@smod = ();
$vcomm="";
@uname = ();
@uid = ();
$clkperiod = 5;
$cdly2 = "";
$debug = '';
$synthesis = '';
$toponly = '';


sub makesynscript{
open(sf,">","synthesis.script") or die "\n\n\nFAILED --- Couldn't open the synthesis script for editing\n";
printf sf "set link_library {/home/morris/PnRhw/tsmc018/signalstorm/osu018_stdcells.db /apps/synopsys/C-2009.06-SP2/libraries/syn/dw02.sldb /apps/synopsys/C-2009.06-SP2/libraries/syn/dw01.sldb }
set target_library {/home/morris/PnRhw/tsmc018/signalstorm/osu018_stdcells.db}
";
my $ix;
printf sf "read_verilog sfilt.v\n";
printf sf "current_design sfilt\ncheck_design";
printf sf "
set_drive 0 clk
set_drive 0 rst
set_dont_touch_network clk\n";
printf sf "create_clock clk -name clk -period %f\n",$clkperiod*0.95;
printf sf "set_propagated_clock clk
set_clock_uncertainty 0.25 clk
set_propagated_clock clk
set_output_delay 0.5 -clock clk [all_outputs]
set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port clk]] [get_port rst]]
";
printf sf 'set_driving_cell -lib_cell NAND2X1 $all_inputs_wo_rst_clk
set_input_delay 0.5 -clock clk $all_inputs_wo_rst_clk
';
my $outdelay = $clkperiod-1.5;
printf sf "set_max_delay $outdelay -to [all_outputs]
";
my $indelay = $clkperiod-1.5;
printf sf "set_max_delay $indelay";
printf sf ' -from $all_inputs_wo_rst_clk
set_fix_hold [ get_clocks clk ]
compile -map_effort medium
';
printf sf "create_clock clk -name clk -period %f\n",$clkperiod;
printf sf "set_propagated_clock clk
set_clock_uncertainty 0.25 clk
set_propagated_clock clk
update_timing
report -cell
report_timing -max_paths 10
write -hierarchy -format verilog -output sfilt_gates.v
write_sdc sfilt_gates.sdc
quit
";
close(sf);


}
($#ARGV >= 1 ) or die "Need the cycle time, and result name as parameters";
$clkperiod = $ARGV[0];
open(f,">",$ARGV[1]) or die "Couldn't open the output file";


$vcomm_name = $vcomm;
$vcomm_name=~ s/.v// ;

printf f "Starting the run of the synthesis poly5 PnR HW\n cycle time %s\n",$ARGV[0] or die "\n\n\n\nFAILED --- didn't write\n\n\n";
printf f "Run on %s", `date`;
printf f "%s on %s\n", $ENV{"USER"}, $ENV{"HOSTNAME"};
makesynscript;
system("dc_shell -f synthesis.script | tee synres.txt")==0 or die "\n\n\n\nFAILED --- synthesis failed";
printf f "synthesis ran\n";
system("grep '(MET)' synres.txt")==0 or die "\n\n\n\nFAILED --- Didn't find timing met condition";
system("grep -i error synres.txt")!=0 or die "\n\n\n\nFAILED --- synthesis contained errors";
system("grep -i latch synres.txt")!=0 or die "\n\n\n\nFAILED --- synthesis created latches";
system("grep -i violated synres.txt")!=0 or die "\n\n\n\nFAILED --- synthesis violated timing";
$tline = `grep Total synres.txt`;
chomp($tline);
@gates = split(" ",$tline);
$size = @gates[3];
printf f "Total gates %s\n", $size;
die "\n\n\nFAILED --- Number of gates too small, check warinings\n\n" if ($size < 30000.0);
printf f "Design synthesized OK\n";
system("rm command.log");
system("rm default.svf");
print "\n\nSynthesis results are in file synres.txt\n";
$aline = `/sbin/ifconfig | grep eth | grep Bcast`;
chomp($aline);
@astuff = split(" ",$aline);
printf f "%s\n",@astuff[1];
$mdx = `echo '$ENV{"USER"}' | md5sum`;
$mdy = `echo ~`;
chomp($mdy);
$mdz = `echo $mdy | md5sum`;
chomp($mdz);
printf f "<%s>\n",$mdz;
printf f "Completed %s", `date`;
close f;
print "Successful Completion of HW run\n";
printf "Run summary file is %s\n",$ARGV[2];
