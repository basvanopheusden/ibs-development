# Inverse Binomial Sampling (IBS) developer repository

This is the working repository for the article *Unbiased and efficient log-likelihood estimation with inverse binomial sampling* [[1](#reference)]. The MATLAB and Python scripts in this repository allow to reproduce all the results and figures reported in the paper (see below).

If you are interested in using IBS, please find user-friendly and fast implementations and tutorials here: https://github.com/lacerbi/ibs

## Code

To visualize the results and reproduce the figures in the paper:

- `ibs_plots.ipynb` is a Jupyter notebook that reproduces almost all figures in the paper (excluding the task design figures);
- `ibs_task_figures.ipynb` is a Jupyter notebook that reproduces the figures in the paper for the orientation discrimination and change localization tasks.

All the analyses were run in Matlab (see code in `./matlab` folder). In particular, to run the analyses call:
```
> recover_theta(model,method,proc_id,Ns);
```
where:

- `model` is the model used for the analyses (`'psycho'` for psychometric function, `'vstm'` for change localization, `'fourinarow'` for the four-in-a-row game);
- `method` is the method used to estimate the log-likelihood (`'exact'` for analytical or numerically exact likelihood, `'fixed'` for fixed-sampling, `'ibs'` for IBS);
- `proc_id` is the task id, and determines which dataset is analyzed (`proc_id` is an integer that takes values in 1-120 for `psycho` and `fourinarow` models, and 1-80 for `vstm`);
- `Ns` is the number of samples for `fixed` method, or the number of repeats for `ibs`.

To rerun the analyses:

- `batch_ibs.sh` is a batch script to run the analyses on a computer cluster (using [Slurm](https://slurm.schedmd.com/sbatch.html));


## Reference

1. van Opheusden\*, B., Acerbi\*, L. & Ma, W.J. (2020). Unbiased and efficient log-likelihood estimation with inverse binomial sampling. *PLoS Computational Biology* 16(12): e1008483. (* equal contribution) ([link](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1008483))

### License

The IBS-related code in this repository (but not necessarily other toolboxes) is released under the terms of the [MIT License](https://github.com/basvanopheusden/ibs-development/blob/master/LICENSE).
