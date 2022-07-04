#!/bin/bash -l
# Use the current working directory and current environment for this job.
#SBATCH -D ./
#SBATCH --export=ALL
# Define an output file - will contain error messages too
#SBATCH -o Gum-%j.out
# Define job name
#SBATCH -J Gum
#SBATCH -p nodes -N 1 -n 40
# This asks for 10 minutes of time.
#SBATCH -t 24:00:00
###SBATCH -t 00:30:00
###SBATCH --mem-per-cpu=8000M
# Insert your own username to get e-mail notifications
#SBATCH --mail-user=btipdp@bppt.go.id
#SBATCH --mail-type=ALL

# Load the necessary modules

module purge
source /opt/intel/oneapi/setvars.sh
module load xbeach/gumbira

#
# Should not need to edit below this line
#
echo =========================================================   
echo SLURM job: submitted  date = `date`      
date_start=`date +%s`

echo Executable file:                              
echo MPI parallel job.                                  
echo -------------  
echo Job output begins                                           
echo -----------------                                           
echo

hostname
echo $SLURM_JOB_NODELIST >nodelist
echo $SLURM_JOB_ID > Job_id

# If you use all of the slots specified in the -pe line above, you do not need
# to specify how many MPI processes to use - that is the default
# the ret flag is the return code, so you can spot easily if your code failed.

mpirun -np 40  xbeach

ret=$?

# If you only wanted to some of those slots, specify the precise number:
#mpirun  -np 12 $EXEC 
#ret=$?


echo   
echo ---------------                                           
echo Job output ends                                           
date_end=`date +%s`
seconds=$((date_end-date_start))
minutes=$((seconds/60))
seconds=$((seconds-60*minutes))
hours=$((minutes/60))
minutes=$((minutes-60*hours))
echo =========================================================   
echo SLURM job: finished   date = `date`   
echo Total run time : $hours Hours $minutes Minutes $seconds Seconds
echo =========================================================   
exit $ret
