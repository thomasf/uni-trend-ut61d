List of tools that I have collected and modified to work with the Uni-T UT61D DMM

he2325u/he2325u
	Reads data from a Uni-T UT61 series DMM using the USB interface.
	Written by Rainer Wetzel, modified by me to suit my needs.
	I've set the baudrate to 19230 which is the baudrate that works with UT61D.
	Change that in he2325u.cpp and recompile if you need another baudrate.
	I've also modified the handling of the serial data a bit to suit the protocol of the B,C,D models.

he2325u/suspend.HE2325U.sh
	Turn off powersave for the he2325u HID device.
	It's not possible to connect to the device on some systems unless this is used
	By Ralf Burger.

dmmut61bcd/dmmut61bcd.pl
	Perl based parser for raw data from UT61B, UT61C, UT61D originally written by H.P. Stroebel
	Pipe data from a UT61 reader to dmmut61bcd to format it to human readable format
	Example: he2325u | dmmut61bcd.pl

startdmm.sh
	Example script that modifies the power settings of the he2325u and then starts
	the he2325u application and pipes the data through dmmut61bcd.


Per Bengtsson
May 2012

