function recover_theta(model,method,proc_id,Nsamples,Ndatasets)
%RECOVER_THETA Run batch parameter recovery for given set parameters.

if nargin < 4; Nsamples = []; end
if nargin < 5; Ndatasets = []; end

settings = get_model_settings(model);
settings.Nsamples = Nsamples;

% Add required folders
mypath = fileparts(mfilename('fullpath'));
addpath([mypath filesep 'bads']);
addpath([mypath filesep 'datasets']);
if strcmp(model,'vstm'); addpath([mypath filesep 'CircStat2012a']); end

% Loop over iterations
theta_filename = ['theta_' model '_' method '_' num2str(proc_id) '.txt'];
output_filename = ['output_' model '_' method '_' num2str(proc_id) '.txt'];

% If output file already exist, continue from previous run
theta_inf = []; output_vec = [];
if exist(theta_filename,'file') && exist(output_filename,'file')
    try
        theta_inf = dlmread(theta_filename);
        output_vec = dlmread(output_filename);
    catch
        % File(s) corrupted, need to restart from scratch
    end
end

% Loop over simulated datasets
iStart = size(theta_inf,1)+1;

% Load fake datasets for given model and parameter setting
datafile = [mypath filesep 'datasets' filesep 'data_' model '_s' num2str(proc_id) '.mat'];
data = load(datafile);
if isempty(Ndatasets); Ndatasets = numel(data.stim_all); end

for i=iStart:Ndatasets
    rng(i);
    stim=data.stim_all{i};
    resp=data.resp_all{i};
    [theta_inf(i,:),output_vec(i,:)] = ...
        infer_theta(model,method,stim,resp,settings);
    dlmwrite(theta_filename,theta_inf,'Delimiter','\t')
    dlmwrite(output_filename,output_vec,'Delimiter','\t')
end
  
end
