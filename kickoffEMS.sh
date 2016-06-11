#!/bin/bash
# Jake Wimberley, 2013-07-26
# This wraps the cron wrapper script of the WRF EMS in order to facilitate
# the retrieval of old model output, as well as log files from previous runs
# (of particular value for troubleshooting). The start and end times are logged
# via files, so that an 'ls -l' in $savedir allows one to quickly see how long
# each run took.

# So, the only cron entry to run WRF EMS should be this script.
# It accepts one command line argument, the name of the EMS "run".

# Directory in which to keep the archive of data and logs
savedir=/home/wrf/pastruns
# Number of days to keep log files (whatever is in runs/[runName]/log)
keepdaysLog=7
# Number of days to keep output data (whatever is in runs/[runName]/emsprd)
keepdaysPrd=1
# Top-level dir of the EMS installation
wrfemsDir=/home/wrf/wrfems/

# end config

runName=$1

mkdir -p $savedir
# make sure that the -d argument reflects frequency of WRF runs
datestrOLD=`date -d'6 hours ago' +%Y%m%d_%H%M`
datestrNEW=`date +%Y%m%d_%H%M`
tar -czf $savedir/$datestrOLD.log.tgz -C $wrfemsDir/runs/$runName log
tar -czf $savedir/$datestrOLD.prd.tgz -C $wrfemsDir/runs/$runName emsprd
find $savedir -name "*.log.tgz" -mtime +$keepdaysLog -delete
find $savedir -name "*time*" -mtime +$keepdaysLog -delete
find $savedir -name "*.prd.tgz" -mtime +$keepdaysPrd -delete

touch $savedir/${datestrNEW}timeAstart
$wrfemsDir/strc/ems_bin/ems_autorun-wrapper.csh --rundir $wrfemsDir/runs/$runName >& /$wrfemsDir/logs/ems_autorun.log 2>&1
touch $savedir/${datestrNEW}timeZend
