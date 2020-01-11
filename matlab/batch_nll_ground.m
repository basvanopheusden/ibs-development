function batch_nll_ground(model,method,proc_id,Nsamples)
%BATCH_NLL_GROUND Compute ground truth nLL for given set parameters.

if nargin < 4; Nsamples = []; end

settings = get_model_settings(model);
settings.Nsamples = Nsamples;

% Add required folders
mypath = fileparts(mfilename('fullpath'));
addpath([mypath filesep 'datasets']);
if strcmp(model,'vstm'); addpath([mypath filesep 'CircStat2012a']); end

% Read maximum-likelihood results from previous optimization runs
theta_filename = ['theta_' model '_' method '_' num2str(proc_id) '.txt'];
theta_inf = dlmread(theta_filename);

% Log likelihood file
nll_filename = ['nll_' model '_' method '_' num2str(proc_id) '.txt'];

% Read output from exact run
exact_output_filename = ['..' filesep 'exact' filesep 'output_' model '_exact_' num2str(proc_id) '.txt'];
exact_output = dlmread(exact_output_filename);
nll_exact = exact_output(:,1);

% If output file already exists, continue from previous run
nll_vec = [];
if exist(nll_filename,'file')
    try
        nll_vec = dlmread(nll_filename);
    catch
        % File corrupted, need to restart from scratch
    end
end

% Loop over simulated datasets
iStart = size(nll_vec,1)+1;

% Load fake datasets for given model and parameter setting
datafile = [mypath filesep 'datasets' filesep 'data_' model '_s' num2str(proc_id) '.mat'];
data = load(datafile);
Ndatasets = numel(data.stim_all);

for i=iStart:Ndatasets
    rng(i);
    stim=data.stim_all{i};
    resp=data.resp_all{i};    
    theta = theta_inf(i,:);
    
    % Evaluate high-precision ground truth negative log likelihood at best solution
    nll_vec(i,1) = estimate_nll_exact(model,stim,resp,theta,1);    
    
    % High-precision ground gruth negative log likelihood at ground-truth solution
    nll_vec(i,2) = nll_exact(i);    
    
    dlmwrite(nll_filename,nll_vec,'Delimiter','\t')
end
  
end
