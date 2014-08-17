#!/usr/bin/perl -s
# NOTE! This version has been modified to only take input from STDIN
# by Per Bengtsson  May 2012
#
####################################################################
#
# dmmut61b - display serial output from Uni-Trend UT61B DMM
# Version 0.4
# EXPERIMENTAL SOFTWARE !!! USE ON YOUR OWN RISK !!!
#
# Usage: see below for help, or call dmmut61b with -h option
# consult the source in case of problems, it is quite well
# documented
#
# Copyright 2010 Hans Peter Stroebel, hpstr@operamail.com
# http://hps.ininter.net
#
# License: GNU General Public License (GPL) v.3
# http://www.gnu.org/licenses/gpl.html
# In short: don`t claim you wrote it, leave the copyright intact,
# give it away, modify it to fit your wishes, use it for whatever
# you want, but keep it free and the source code available.
# 
#
# This software relies on the Device::SerialPort and Time::HiRes
# modules; Time::HiRes is only needed if you wish to display
# timestamps. Time::HiRes should be present in most mut the most
# bare default Perl installations
# Debian/Ubuntu users can find the Device::SerialPort module in
# the package libdevice-serialport-perl.
#
# It was tested under perl v5.8.8, on i386 Ubuntu 8.04LTS. It should
# run on most operating systems providing perl. It should run even
# on Win32 systems, but was not (and will be not) tested there.
# 
# dmmut61b is not optimized for efficency; if memory is a concern
# (e.g. on old computers), one could work with substr() instead of
# the flags array, and by printing directly values directly to
# STDOUT instead of assigning them to variables first.
#
#
# Special thanks to:
# Henrik Haftmann, http://www-user.tu-chemnitz.de/~heha/
# for having re-engineered and published the protocols at
# http://www-user.tu-chemnitz.de/~heha/hs_freeware/UNI-T/
#
#
# TODO - maybe...
# - serial timeout?
# - better telnet server? HTML?
#
# Versions:
#
# v0.4 added a very basic gnuplot option; public release
# v0.3 debugging (serial protocol)
#      added usage instructions (-h)
#      added experimental telnet wrapper
# v0.2 added -m,-n,-t,-csv,-u,-n options
#      switched to flag_bits array instead of substr
# v0.1 first running q&d hack
#
#################################################################################

# use strict - nah...

if ($h) { &usage; exit; }			# show help and exit

use Device::SerialPort; 			# Ubuntu/Debian: package libdevice-serialport-perl

if ($t) { use Time::HiRes qw(gettimeofday); }	# should be present in a default installation
						# if not present, -t option cannot be used

# initialisation of some variables 

# $d = "/dev/ttyS0" if (!$d);			# set default serial device
$counter = 0; 				# counter needed for several options
($min, $avg, $max) = 0 if ($m);

# set correct signs for degrees and micro prefix if desired
if ($l) { $deg = "°"; $micro = "µ" } else { $deg = "deg "; $micro = "u" }

$| = 1;						# autoflush STDOUT (for telnet server)
$SIG{'INT'} = 'sigint';				# catch INT signal

if ($p) { # plotting desired

	open (PLOT,"|/usr/bin/gnuplot -geometry 640x480 -noraise") ||
	# continue on error, without plotting
	warn("Cannot start plotter: $!\n") && undef $p;

	@values = "";
	$last_unit = undef;
	$last_prefix = undef;

}# end if


# Serial Settings 2400 baud 8N1 DTR+ RTS-
# $serial_port = Device::SerialPort->new($d) || die "Cannot open $d: $!"; 

# $serial_port->baudrate(2400); 
# $serial_port->databits(8);
# $serial_port->parity("none");
# $serial_port->stopbits(1); 

# $serial_port->stty_icanon;
# $serial_port->stty_icrnl(1);			# convert cr to new line 
# $serial_port->stty_opost; 			# ??

# $serial_port->purge_all();
# $serial_port->rts_active(0);
# $serial_port->dtr_active(1);

# $serial_port->write_settings;

# loop over readings
while () {

	$dmm_input = ""; # reset

	until ("" ne $dmm_input) {

		$dmm_input = <STDIN>; # poll until data ready
		die "Aborted without match\n" unless (defined $dmm_input);

	}#end until

	# Changed input length from 12 to 14 for STDIN input
	if (length($dmm_input) ne 14) { # reading is 14 bytes

		warn "Error: discarding reading with length !=14\n" if ($v);
		next; # discard the reading

	}# end if

	warn "$dmm_input\n" if ($v > 1);

	# Byte 1  Ziffer 1, ? bei OL
	# Byte 2  Ziffer 2
	# Byte 3  Ziffer 3
	# Byte 4  Ziffer 4
	# Byte 5  leer

	$value = "";		# reset
	$divisor = "";	# reset


	$value = substr($dmm_input,1,4);

	if ($value =~ /\?/) { 		# value OVERLOAD: byte 1 contains "?"

		# set a numerical value instead of OVERLOAD, better for doing graphs
		$value = 9999;
		warn "OVERLOAD\n" if ($v);

	} else { 		# (probably) numerical reading

		# the following division would fail if the reading is not numerical (=trashy),
		# or if the divisor (decimal) has not been set correctly
		# in this case discard the reading, and warn to stderr when verbose

		if ($value =~ /\D/) { 

			warn "Error: discarding non-numerical reading: $value\n" if ($v);
			next; # discard reading

		}# end if


		$divisor = substr($dmm_input,6,1);

		# Byte 6  Komma-Bitfeld, als Ziffer, '1'=0.000, '2'=00.00, '4'=000.0, '0'=0000
		if    ($divisor == 0) { $divisor =    1 } # 10e0
		elsif ($divisor == 4) { $divisor =   10 } # 10e-1
		elsif ($divisor == 2) { $divisor =  100 } # 10e-2
		elsif ($divisor == 1) { $divisor = 1000 } # 10e-3
		else {
			# unknown divisor would lead to division by zero
			warn "Error: discarding reading, unknown decimal position\n" if ($v);
			next; #discard reading

		}# end else

		# Byte 0 Vorzeichen
		# invert the divisor if reading is negative
		$divisor = $divisor * -1 if (substr($dmm_input,0,1) eq "-");

		$value = $value / $divisor;


	}# end else

	if ($r) { # skips most options, returns numerical reading only

		print "$value";	  # print without further analysis, \n comes later
		$counter++;	  # rise counter now (normally risen later, but we don`t arrive there)

		goto JUMPMARK;	  # jump near to end of loop instructions

	}# end if

	# unpack byte 7-10 into bits, and split them into an array

	@flag_bits = undef; # reset
	@flag_bits = split(//,unpack(B32,substr($dmm_input,7,4)));
	
	# Meaning of every bit, Haftmann
	# Bit Nr.		0	1	2	3	4	5	6	7			
	# Byte 7 Symbole	0	0	Auto	DC	AC	REL	HOLD	BG

	# Bit Nr.		8	9	10	11	12	13	14	15
	# Byte 8 Symbole	0	0	MAX	MIN	0	LowBat	n	0

	# Bit Nr.		16	17	18	19	20	21	22	23
	# Byte 9 Symbole	µ	m	k	M	Pieps	Diode	%	0

	# Bit Nr. 		24	25	26	27	28	29	30	31
	# Byte 10 Symbole	V	A	Ohm	0	Hz	F	°C	°F

	# initialize values, then set them according to flagbits

	$range = "";
	$acdc = "";
	$unit = "";
	$prefix = "";
	
	# Range: 1=auto, 0=manual 
	$range = ( $flag_bits[2] ? "auto" : "manual");

	$acdc = "DC" if		 ($flag_bits[3]);
	$acdc = "AC" if		 ($flag_bits[4]);

	$unit = "%" if 		($flag_bits[22]); # 1 = duty cycle
	$unit = "V" if		($flag_bits[24]); # 1 = voltage *not set by DMM?*
	$unit = "A" if		($flag_bits[25]); # 1 = current
	$unit = "Ohm" if	($flag_bits[26]); # 1 = resistance
	$unit = "Hz" if		($flag_bits[28]); # 1 = frequency
	$unit = "F" if		($flag_bits[29]); # 1 = capacity; Farad and prefixes not tested!!!
	$unit = "$deg" . "C" if	($flag_bits[30]); # 1 = temperature, deg/° Celsius
	$unit = "$deg" . "F" if	($flag_bits[31]); # 1 = temperature, deg/° Fahrenheit

	$prefix = "n" if	($flag_bits[14]); # 1 = nano		10e-9
	$prefix = "$micro" if	($flag_bits[16]); # 1 = micro / u / µ	10e-6
	$prefix = "m" if	($flag_bits[17]); # 1 = milli		10e-3
	$prefix = "k" if	($flag_bits[18]); # 1 = kilo		10e3
	$prefix = "M" if	($flag_bits[19]); # 1 = Mega		10e6

	# rest of bytes, 11 = bargraph, 12 & 13 not interesting
	#Byte 11 Laenge der Bargraf-Anzeige, 0..41, Bit 7 = Minuszeichen (der Bargraf-Anzeige)

	#Byte 12	0D	\r	0	0	0	0	1	1	0	1
	#Byte 13	0A	\n	0	0	0	0	1	0	1	0


	if ($m) { # do some math: min, avg, max

		# TODO: what if unit changes? MIN/MAX/AVG has to be resetted

		# memorize minimum for later, if necessary 
		if ($counter == 0) { $min = $value } # first reading = must be minimum

		else { # not the first reading, so we have to see

			$min = $value if ($value lt $min);

		} # end else


		# memorize maximum for later, if necessary 
		if ($counter == 0) { $max = $value } # first reading = must be maximum

		else { # not the first reading, so we have to see

			$max = $value if ($value gt $max);

		} # end else

		# calculate average, formula "stolen" from dmmut61e by Steffen Vogel
		# http://www.steffenvogel.de/2009/11/29/uni-trend-ut61e-digital-multimeter/
		# avarage = (sample * avarage + value) / ++sample;

		if ($counter == 0) { $avg = $value } # first reading = must be average

		else { # not the first reading, so we have to see

			$avg = ((($counter * $avg) + $value) / ($counter + 1));

		} # end else

	} # end if

	if ($t) { # create a time field

		($epochseconds, $microseconds) = gettimeofday; 
		($second, $minute, $hour) = localtime($epochseconds);

		# hour:minute:second.centiseconds (microseconds quite useless...)
		$t = sprintf("%02d:%02d:%02d.%02d", $hour, $minute, $second, ($microseconds/10000));

	}# end if


	# now let`s create output...

	# first line is a csv description, if -csv is given
	if (($csv) && ($counter == 0)) {

		#my $csv = "\""; # separator for csv field quoting

		print "Counter;" if ($c);
		print "HH:MM:SS.SS;" if ($t);
		print "Value;Unit;AC/DC;Range";	
		print ";MIN;AVG;MAX" if ($m);
		print ";Flags" if ($f);
		# no flag_bits for csv, as they go to STDERR
		print "\n";

	}# end if


	# rise counter
	$counter++; # 0 is reserved for csv description headline

	print "$counter;" if ($c);
	print "$t;" if ($t);

	# next 4 statements are default output
	print "$value;$prefix$unit;$acdc;$range";

	# end of standard output
	# from here on, other values have to produce their trailing ";" themselves

	printf (";MIN:%.3f;AVG:%.3f;MAX:%.3f", $min, $avg, $max) if ($m);

	if ($f) { # get some other flags

		# reset (can`t leave empty, as it is the switch as well, so use trailing slash)
		$f = ";"; 

		# every one of the following five modes seems to exclude the others
		# e.g. no REL/HOLD/MIN/MAX in BUZZ mode, and MIN excludes HOLD, and vice versa
		$f .= "REL" 	if ($flag_bits[5]);  # 1 = REL
		$f .= "HOLD" 	if ($flag_bits[6]);  # 1 = HOLD
		$f .= "MAX" 	if ($flag_bits[10]); # 1 = MAX		
		$f .= "MIN" 	if ($flag_bits[11]); # 1 = MIN
		$f .= "BUZZ" 	if ($flag_bits[20]); # 1 = continuity buzzer
		$f .= "DIODE"	if ($flag_bits[21]); # 1 = diode check

		# LOWBAT instead could be always present?
		# low battery warning, not not tested
		$f .= "*LOWBAT*" if ($flag_bits[13]); # 1 = low battery warning

		print "$f;";
		
	}# end if

	# only helpful for debugging, if ever
	warn "\n0 1 2 3 4 5 6 7 8 9 10111213141516171819202122232425262728293031\n@flag_bits\n" if ($v);

	JUMPMARK: # program jumps here when -r (only num reading) was requested

	print "\n"; # MS users might need "\r\n" instead "\n"?

	&plot() if ($p);

	# leave while() loop when desired counts are reached
	last if ($counter == $n);

	# sleep interval in seconds
	sleep $i if ($i =~ /\d/);

}# end while

sub plot {

	if ($last_prefix && $last_unit) { # they exist, so not the first reading

		# unit/prefix has changed since last reading, so discard old values
		# and begin a new graph
		undef @values if (($last_prefix ne $prefix) || ($last_unit ne $unit));

	}# end if

	# discard oldest value if reached 50
	shift(@values) if (@values == 50);

	# add the latest value to the end
	push(@values, $value);

	# write following output to plotter
	select(PLOT); $| = 1;

	# see the gnuplot manual for documentation
	# enter custom commands here
	print qq(	

		# gnuplot commands for a very basic plot
		reset
		set grid ytics
		set autoscale y
		set xrange [0:50]
	
		unit = "$prefix$unit"
		set ylabel unit

		plot '-' smooth unique with lines lw 2

	);# end print qq

	# pass values to gnuplot
	print "$_\n" foreach (@values);
	print "\ne\n";

	# return to standard output
	select(STDOUT); $| = 1;

	# memorize unit and prefix to compare with next cycle
	$last_prefix = $prefix; $last_unit = $unit;

}# end sub plot

sub sigint { # catch SIGINT

	#free the serial port, then go away (not used with STDIN)
	#undef $serial_port; 
	exit;

}# end sub sigint

sub usage {

print <<__END_OF_USAGE__;

dmmut61b - get readings from an UNI-T UT61B digital multimeter
	   do some formatting, and print to standard output

Usage: dmmut61b [options]

Options:
-h	  Display this help
-v(=2)	  be (more) verbose (to STDERR)
-d=dev	  use device as serial port (default: /dev/ttyS0)
-n=n	  do only x number of readings, then quit
-f	  show additional flags (MAX, MIN, HOLD, REL, BUZZ, DIODE)
-c	  show a numerical counter
-t	  show a timestamp (HH:MM:SS.centiseconds)
-m	  do some math: show minimum, average and maximum value
-csv	  first line contains field headers for csv spreadsheets
-l	  your locale setting allows correct symbols instead of
	  "deg" and "micro" to be displayed
-r 	  show only numerical reading (discards other options)
-i=n	  get a reading only every n seconds; if you need only every
	  n-th reading, use this option and double n (the DMM outputs
	  *circa* twice a second, so n=5 will get one reading of 10)
-p	  invoke gnuplot for graphing (better not use Autorange)

dmmut61b is experimental software; rely on your DMM display and not
on dmmut61b. Don`t rely especially on the MIN/AVG/MAX calculations;
when using them, avoid using AUTORANGE (set the RANGE manually, and
leave it there), and do not use special DMM functions (HOLD,REL, and
MIN/MAX), as the calculated values will get wrong.
If you need to do more than most basic math, use a spreadsheet or a
database to do the calculations.

Rotating the switch while dmmut61b is running can create some few
false readings.

You can redirect the output of dmmut61b to any file using shell
redirection. The field separator is ";", line termination is "\\n".
MS users might need to add "\\r" before the "\\n".

Remember to activate transmission on the DMM (Press REL >2 seconds)!

__END_OF_USAGE__
;
}#end sub usage
 

