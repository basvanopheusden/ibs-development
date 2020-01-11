#!/bin/bash
#SBATCH --nodes=1
#SBATCH --array=1-120
#SBATCH --cpus-per-task=1
#SBATCH --time=48:00:00
#SBATCH --mem=6GB
#SBATCH --job-name=ibs
#SBATCH --mail-type=END
#SBATCH --output=ibs_%j.out

PROJECT_FOLDER="ibs-dev"

#model=psycho
#model=vstm
model=fourinarow

proc_id=${SLURM_ARRAY_TASK_ID}

#method=ibs
method=fixed
#method=fixed
#method=fixedb
#method=exact
Nsamples=100

if [ $method = "exact" ]; then
    workdir=$SCRATCH/${PROJECT_FOLDER}/results/${model}/${method}
else
    workdir=$SCRATCH/${PROJECT_FOLDER}/results/${model}/${method}${Nsamples}
fi

module purge
module load matlab/2018a

mkdir $SCRATCH/${PROJECT_FOLDER}/results
mkdir $SCRATCH/${PROJECT_FOLDER}/results/${model}
mkdir $workdir
cd $workdir

echo $model $method $Nsamples $proc_id

echo "addpath('$SCRATCH/${PROJECT_FOLDER}/matlab/'); recover_theta('${model}','${method}',${proc_id},${Nsamples}); exit;" | matlab -nodisplay

echo "Done"

