#!/usr/bin/bash
# Jake Wimberley, 2015-07-22
# Automate Bufrgruven (http://strc.comet.ucar.edu/software/bgruven/)
# to regularly generate Bufkit profiles.
# Bufrgruven must be configured appropriately, in order to make the output go
# to the right location.
# Run this script on a cron every 15 minutes.

# path to exe
BUFRGRUVEN=/home/jcw/bufrgruven/bufr_gruven.pl
# IDs as defined in the *_stations files, with NO SPACES therein
STATIONS=KGSP,KAND,KCAE,KOGB,KAGS,KCHS
# where to write logs
LOGDIR=/home/jcw/log/makeBufkit
SCRIPTLOG=makeBufkit.log


if [[ `pgrep -c makeBufkit.sh` -gt 1 ]]
then
	NOW=`date`
	echo "  ($NOW: Another instance of the script tried to start)" >> $LOGDIR/$SCRIPTLOG
	exit 1
fi

date >> $LOGDIR/$SCRIPTLOG

mkdir -p $LOGDIR

# do all others, which use the same station list
for DATASET in nam gfs3 rap hrrr sref hrwarw hrwnmm nam4km
do
	$BUFRGRUVEN --dset $DATASET --stations $STATIONS --noascii > $LOGDIR/$DATASET.out 2>&1
	if [[ `grep Success $LOGDIR/$DATASET.out` ]]
	then
		echo "  $DATASET" >> $LOGDIR/$SCRIPTLOG
	fi
done

# remove old log entries
tail -n 500 $LOGDIR/$SCRIPTLOG > $LOGDIR/$SCRIPTLOG.new
mv $LOGDIR/$SCRIPTLOG.new $LOGDIR/$SCRIPTLOG
