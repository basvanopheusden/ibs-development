function results = load_results(model,type)
%LOAD_RESULTS Load results file for a given model.

if nargin < 2 || isempty(type); type = 'theta'; end

mypath = fileparts(mfilename('fullpath'));
basepath = [mypath filesep '..' filesep '..' filesep 'results' filesep model filesep];

settings = get_model_settings(model);

globals = get_model_settings('global');
Ndata = globals.Ndata;
methods = globals.methods;
samples = settings.samples;

switch type
    case 'theta'; Ncols = size(settings.theta_real,2);        
    case 'output'; Ncols = 7;
    otherwise; error('Unknown TYPE. Use ''theta'' or ''output''.');
end

results.model = model;
results.type = type;

for iMethod = 1:numel(methods)
    method = methods{iMethod};
    
    for iSamples = 1:numel(samples{iMethod})
        ss = samples{iMethod}(iSamples);
        
        if ss == 0; subfolder = method; else; subfolder = [method num2str(ss)]; end
        folder = [basepath subfolder];
        fprintf('%s... ',subfolder);
        
        if ~exist(folder,'file'); fprintf('not found\n'); continue; end
        
        Nsettings = size(settings.theta_real,1);
        results.(subfolder) = NaN(Ndata,Ncols,Nsettings);         
        
        for iFile = 1:Nsettings
            filename = [type '_' model '_' method '_' num2str(iFile) '.txt'];
            fullfile = [folder filesep filename];
            if exist(fullfile,'file')
                mat = dlmread(fullfile);
                results.(subfolder)(1:size(mat,1),:,iFile) = mat;
            end
        end
        
        frac = sum(isfinite(results.(subfolder)(:))) / numel(results.(subfolder)(:));
        fprintf('%.2f%% completed\n',frac*100);
        
    end
    
    
end


end