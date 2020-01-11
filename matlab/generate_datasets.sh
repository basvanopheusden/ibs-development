#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=6GB
#SBATCH --job-name=gen
#SBATCH --mail-type=END
#SBATCH --output=ibs_%j.out

PROJECT_FOLDER="ibs-dev"

#model=psycho
#model=vstm
model=fourinarow

module purge
module load matlab/2018a

echo $model

echo "addpath('$SCRATCH/${PROJECT_FOLDER}/matlab/'); generate_datasets('${model}'); exit;" | matlab -nodisplay

echo "Done"