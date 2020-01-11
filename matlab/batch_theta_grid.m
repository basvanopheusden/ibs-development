function batch_theta_grid(model,method,proc_id,Nsamples,Ndatasets,Ngrid)
%BATCH_THETA_GRID Run batch evaluation of log likelihood on a grid.

if nargin < 4; Nsamples = []; end
if nargin < 5; Ndatasets = []; end
if nargin < 6; Ngrid = []; end

settings = get_model_settings(model);
settings.Nsamples = Nsamples;
settings.Ngrid = Ngrid;

% Add required folders
mypath = fileparts(mfilename('fullpath'));
addpath([mypath filesep 'datasets']);
if strcmp(model,'vstm'); addpath([mypath filesep 'CircStat2012a']); end

grid_filename = ['grid_' model '_' method '_' num2str(proc_id) '.txt'];

% If output file already exist, continue from previous run
nLL_grid = [];
if exist(grid_filename,'file')
    try
        nLL_grid = dlmread(grid_filename);
    catch
        % File(s) corrupted, need to restart from scratch
    end
end

% Loop over simulated datasets
iStart = size(nLL_grid,1)+1;

% Load fake datasets for given model and parameter setting
datafile = [mypath filesep 'datasets' filesep 'data_' model '_s' num2str(proc_id) '.mat'];
data = load(datafile);
if isempty(Ndatasets); Ndatasets = numel(data.stim_all); end

for i=iStart:Ndatasets
    rng(i);
    stim=data.stim_all{i};
    resp=data.resp_all{i};
    nLL_grid(i,:) = ...
        eval_theta_grid(model,method,stim,resp,settings);
    dlmwrite(grid_filename,nLL_grid,'Delimiter','\t')
end
  
end
