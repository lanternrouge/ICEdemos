
This example demonstrates how to compute the finite sample and/or
asymptotic properties of an estimator using a modern cluster.
Because estimating data for individual data sets is independent,
we can perform these jobs in parallel using the cluster's job 
manager.  This study consists of three main parts:

Generate.R    : generate synthetic data
Estimate.R    : estimate each individual dataset
Analyze.R     : analyze results 

The experiments consist of n = 10, 100, 1000, and 10,000 observations.
Each experiment consists of 100 replications for each number of observations.
Synthetic is stored as follows:

  data +
       |
       +- nObs10    / synthetic.{1..100}.txt
       |
       +- nObs100   / synthetic.{1..100}.txt
       |
       +- nObs1000  / synthetic.{1..100}.txt
       |
       +- nObs10000 +
                    |
                    +- synthetic.1.txt
                    |
                    +- synthetic.2.txt
                    .
                    .
                    .
                    +- synthetic.100.txt


Note:  in order to pass command line arguments to these scripts they
must be run with --args as follows:

R --no-save [ --silent ] < Generate.R --args truthFile resultsDir
R --no-save [ --silent ] < Estimate.R --args nObs repID resultsDir
R --no-save [ --silent ] < Analyze.R  --args truthFile resultsDir

truthFile       : file with true parameter values
nObs            : number of observations to generate
repID           : number of synthetic dataset to generate (1..100)
resultsDir      : root of tree in which to write the results
dataFile        : data to estimate OLS on

The --silent will surpress echoing of the R commands which are executed.

