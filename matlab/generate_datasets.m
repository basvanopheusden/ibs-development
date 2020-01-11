function generate_datasets(model,Ndata)
%GENERATE_DATASETS Generate batch of fake datasets for a given model.

% Number of fake datasets to generate for each parameter setting
if nargin < 2 || isempty(Ndata); Ndata = 100; end

rng(0); % Fix random seed (although might change depending on hardware)

% Add required folders
mypath = fileparts(mfilename('fullpath'));
addpath([mypath filesep 'datasets']);
if strcmp(model,'vstm'); addpath([mypath filesep 'CircStat2012a']); end

switch model
    case 'psycho';      Ntrials = 600;
    case 'vstm';        Ntrials = 400;
    case 'fourinarow';  Ntrials = 100;
    otherwise;          error(['Unknown model ''' model '''.']);
end

settings = get_model_settings(model);
Nparams = size(settings.theta_real,1);

for iParams = 1:Nparams
    fprintf('%d/%d...',iParams,Nparams);
    filename = [mypath filesep 'datasets' filesep 'data_' model '_s' num2str(iParams) '.mat'];
    
    if exist(filename,'file')
        fprintf(' Data file already exists, skip.');
    else    
        theta_real = settings.theta_real(iParams,:);    
        for j = 1:Ndata
            stim_all{j} = feval(['generate_stim_' model],Ntrials);
            resp_all{j} = feval(['generate_resp_' model],stim_all{j},theta_real,1:Ntrials);
        end
        save(filename,'stim_all','resp_all','theta_real');
    end    
    fprintf('\n');
end
    
end