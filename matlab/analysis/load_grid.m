function results = load_grid(model,method,Nsamples)
%LOAD_GRID Load grid of log likelihood estimates for a given model and method.

if nargin < 3; Nsamples =[]; end

mypath = fileparts(mfilename('fullpath'));
basepath = [mypath filesep '..' filesep '..' filesep 'results' filesep model filesep];

settings = get_model_settings(model);

globals = get_model_settings('global');
Ndata = globals.Ndata;

if isempty(Nsamples)
    switch method
        case 'exact'; Nsamples = 0;
        case 'ibs'; Nsamples = 50;
        case 'fixed'; Nsamples = 100;
        otherwise; error(['Unknown method ''' method '''.']);            
    end
end

results.model = model;
results.method = method;
results.Nsamples = Nsamples;

if Nsamples == 0; subfolder = method; else; subfolder = [method num2str(Nsamples)]; end
folder = [basepath subfolder];

Nsettings = size(settings.theta_real,1);

for iFile = 1:Nsettings
    filename = ['grid_' model '_' method '_' num2str(iFile) '.txt'];
    fullfile = [folder filesep filename];
    if exist(fullfile,'file')
        mat = dlmread(fullfile);
        results.nLL_grid(1:size(mat,1),:,iFile) = mat;
        results.nLL_grid(size(mat,1)+1:Ndata,:,iFile) = NaN;
    end
end

% Define grid
Ngrid = size(results.nLL_grid,2);
lb = settings.lb;
ub = settings.ub;
nvars = numel(lb);

for ii = 1:nvars; xx{ii} = linspace(lb(ii),ub(ii),ceil(Ngrid.^(1/nvars))); end
results.xx = xx;
results.params_grid = combvec(xx{:})';


%frac = sum(isfinite(results.(subfolder)(:))) / numel(results.(subfolder)(:));
%fprintf('%.2f%% completed\n',frac*100);    

end