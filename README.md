# Inverse Binomial Sampling (IBS) developer repository

This is the working repository for the article *Unbiased and efficient log-likelihood estimation with inverse binomial sampling* [[1](#reference)]. The MATLAB and Python scripts in this repository allow to reproduce all the results and figures reported in the paper (see below).

If you are interested in using IBS, please find user-friendly and fast implementations and tutorials here: https://github.com/lacerbi/ibs

## Code

- `ibs_plots.ipynb` is a Jupyter notebook that reproduces almost all figures in the paper (excluding the task design figures);
- `ibs_task_figures.ipynb` is a Jupyter notebook that reproduces the figures in the paper for the orientation discrimination and change localization tasks;
- `batch_ibs.sh` is a batch script to run the analyses on a computer cluster (using [Slurm](https://slurm.schedmd.com/sbatch.html));
- All the analyses were run in Matlab (see code in `./matlab` folder).

## Reference

1. van Opheusden\*, B., Acerbi\*, L. & Ma, W.J. (2020). Unbiased and efficient log-likelihood estimation with inverse binomial sampling. *PLoS Computational Biology* 16(12): e1008483. (* equal contribution) ([link](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1008483))

### License

The IBS-related code in this repository (but not necessarily other toolboxes) is released under the terms of the [MIT License](https://github.com/basvanopheusden/ibs-development/blob/master/LICENSE).
