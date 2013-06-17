#!/usr/bin/perl

#################################################################################################
#												#
#	swish_run.perl: run swish-e to create serarch database: TEST version			#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: Mar 27, 2013							#
#												#
#################################################################################################


#
#--- run the script
#

system("./SWISH_E/local/bin/swish-e -c ./SWISH_E/local/config/swish-e.conf");

#
#--- save the old database
#

system("mv /data/mta4/CUS/www/MAIL/index.swish-e      /data/mta4/CUS/www/MAIL/SWISH_E/");
system("mv /data/mta4/CUS/www/MAIL/index.swish-e.prop /data/mta4/CUS/www/MAIL/SWISH_E/");

#
#--- move the new ones to propoer places
#

system("mv /data/mta4/CUS/www/MAIL/temp_index.swish-e      /data/mta4/CUS/www/MAIL/index.swish-e");
system("mv /data/mta4/CUS/www/MAIL/temp_index.swish-e.prop /data/mta4/CUS/www/MAIL/index.swish-e.prop");

#
#--- notify the admin that the database is updated.
#

open(FH, "/home/cus/Logs/swish_run");
open(OUT, ">/data/mta4/CUS/www/MAIL/temp_mail_file");

#
#--- check whether the files are properly created.
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
$umon++;

$file1 = `ls -l /data/mta4/CUS/www/MAIL/index.swish-e`;
$file2 = `ls -l /data/mta4/CUS/www/MAIL/index.swish-e.prop`;
$file1_ok = 0;
$file2_ok = 0;

@atemp = split(/\s+/, $file1);
if($file1 =~ /head/){
        month_conv($atemp[5]);
        if($dmon == $umon && $atemp[6] == $umday){
                if($atemp[4] > 100000000){
                        $file1_ok = 1;
                }
        }
}else{
        month_conv($atemp[4]);
        if($dmon == $umon && $atemp[5] == $umday){
                if($atemp[3] > 100000000){
                        $file1_ok = 1;
                }
        }
}

@btemp = split(/\s+/, $file2);
if($file2 =~ /head/){
        month_conv($btemp[5]);
        if($dmon == $umon && $btemp[6] == $umday){
                if($btemp[4] > 100000000){
                        $file2_ok = 1;
                }
        }
}else{
        month_conv($btemp[4]);
        if($dmon == $umon && $btemp[5] == $umday){
                if($btemp[3] > 100000000){
                        $file2_ok = 1;
                }
        }
}

#----------------------------------------------------------------------------
#--- REMOVE THE FOLLOWING TWO LINES WHEN THIS IS MOVED TO A LIVE VERSION!!!!!
#----------------------------------------------------------------------------
$file1_ok = 1;
$file2_ok = 1;
#----------------------------------------------------------------------------

if($file1_ok > 0 && $file2_ok > 0){
	$chk = 0;
	OUTER:
	while(<FH>){
		chomp $_;
		if($_ =~ /total words/){
			$save_line = $_;
		}elsif($_ =~ /Elapsed time/){
			print OUT "swish-e updated the USINT email search database.\n\n";
			print OUT "$save_line\n";
			print OUT "$_\n\n";
			print OUT "if you like to check the log, go to /home/cus/Logs/swish_run.\n";
			$chk = 1;
			last OUTER;
		}
	}
	close(FH);
	if($chk == 0){
		print OUT "swish-e run detected some abnormality\n\n";
		print OUT "check the log: /home/cus/Logs/swish_run.\n";
	}
}else{
	print OUT "swish-e run detected some abnormality\n\n";
	print OUT "database files: index.swish-e and/or index.swish-eprop may not be\n";
	print OUT "created correctly. Check these files in /data/mta4/CUS/www/MAIL/\n\n";
	print OUT "check the log: /home/cus/Logs/swish_run.\n";
}
close(OUT);

$cus_email   = 'cus@head.cfa.harvard.edu';
$admin_email = 'isobe@head.cfa.harvard.edu';

if($chk == 0){
	system("cat /data/mta4/CUS/www/MAIL/temp_mail_file  |mailx -s\"Subject: swish-e run may have problems (linux)\n\" $admin_email");
}else{
	system("cat /data/mta4/CUS/www/MAIL/temp_mail_file  |mailx -s\"Subject: swish-e run: database updated\n\" -r$cus_email $admin_email");
}
system("rm /data/mta4/CUS/www/MAIL/temp_mail_file");


##########################################################################
### sub month_conv: convert month from letter to digit                ####
##########################################################################

sub month_conv{
	my($test);
	($test) = @_;
	chomp $_;
	if($test =~ /Jan/i){
		$dmon = 1;
	}elsif($test =~ /Feb/i){
		$dmon = 2;
	}elsif($test =~ /Mar/i){
		$dmon = 3;
	}elsif($test =~ /Apr/i){
		$dmon = 4;
	}elsif($test =~ /May/i){
		$dmon = 5;
	}elsif($test =~ /Jun/i){
		$dmon = 6;
	}elsif($test =~ /Jul/i){
		$dmon = 7;
	}elsif($test =~ /Aug/i){
		$dmon = 8;
	}elsif($test =~ /Sep/i){
		$dmon = 9;
	}elsif($test =~ /Oct/i){
		$dmon = 10;
	}elsif($test =~ /Nov/i){
		$dmon = 11;
	}elsif($test =~ /Dec/i){
		$dmon = 12;
	}
}
