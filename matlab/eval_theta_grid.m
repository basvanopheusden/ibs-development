function nLL_grid=eval_theta_grid(model,method,stim,resp,settings)
%EVAL_THETA_GRID Evaluate log likelihood on a grid.

Nsamples = settings.Nsamples;
if isfield(settings,'Ngrid') && ~isempty(settings.Ngrid)
    Ngrid = settings.Ngrid;
else
    Ngrid = 1e3;
end

switch method
    case 'ibs'
        Nreps = Nsamples;
        Ntrials = size(stim,1);
        thresh = settings.thresh*Ntrials;
        fun=@(x) estimate_nll_ibs(model,stim,resp,x,Nreps,thresh);
    case 'fixed'
        fun = @(x) estimate_nll_fixed1(model,stim,resp,x,Nsamples);
    case 'exact'
        fun=@(x) estimate_nll_exact(model,stim,resp,x,0);     
    otherwise
        error(['Unknown method ''' method '''.']);
end

% Initialize estimation function if needed
fun([]);

% Define grid
lb = settings.lb;
ub = settings.ub;
nvars = numel(lb);

for ii = 1:nvars; xx{ii} = linspace(lb(ii),ub(ii),ceil(Ngrid.^(1/nvars))); end
params_grid = combvec(xx{:})';
nLL_grid = zeros(size(params_grid,1),1);

% Evaluate log likelihood at each grid point
tick = ceil(size(params_grid,1)/20);
for i = 1:size(params_grid,1)
    nLL_grid(i) = fun(params_grid(i,:));
    if mod(i,tick) == 0; fprintf('%d... ', i); end
end
fprintf('\n');



end