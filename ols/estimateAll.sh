#!/bin/bash
#
# Estimate all datasets in a single script so I can test Analyze.R.
#

# Root of directory with data files
rootDir=./data

for nObs in 10 100 1000 10000
do
  echo Processing $nObs
  dataDir=nObs.${nObs}

  for dataFile in ${rootDir}/${dataDir}/synthetic.*
  do
    echo Estimating ${dataFile}
    repID=$(echo ${dataFile} | sed 's/.*\.\(.*\)\.txt/\1/' )
    R BATCH --no-save < Estimate.R --args ${nObs} ${repID} ${rootDir}
  done
done
