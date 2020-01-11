function [theta_inf,output_vec]=infer_theta(model,method,stim,resp,settings)
%INFER_THETA Optimization run for a single problem set.

% Set default options for BADS optimization algorithm
badsopts = bads('defaults');
badsopts.UncertaintyHandling = ~strcmp(method,'exact');
badsopts.NoiseFinalSamples = 0;
badsopts.MaxFunEvals = 500;
% badsopts.NonlinearScaling = 'off';

% Extract settings
Nsamples = settings.Nsamples;

mult_hiprec = 10;

switch method
    case 'ibs'
        Nreps = Nsamples;
        Ntrials = size(stim,1);
        thresh = settings.thresh*Ntrials;
        fun=@(x) estimate_nll_ibs(model,stim,resp,x,Nreps,thresh);
        fun_hiprec=@(x) estimate_nll_ibs(model,stim,resp,x,Nreps*mult_hiprec,thresh);
    case 'fixed'
        fun = @(x) estimate_nll_fixed1(model,stim,resp,x,Nsamples);
        fun_hiprec = @(x) estimate_nll_fixed1(model,stim,resp,x,Nsamples,mult_hiprec);
    case 'fixedb'
        fun = @(x) estimate_nll_fixed2(model,stim,resp,x,Nsamples);
        fun_hiprec = @(x) estimate_nll_fixed2(model,stim,resp,x,Nsamples,mult_hiprec);
    case 'exact'
        fun=@(x) estimate_nll_exact(model,stim,resp,x,0);     
        fun_hiprec=@(x) estimate_nll_exact(model,stim,resp,x,1);
    otherwise
        error(['Unknown method ''' method '''.']);
end

% Initialize estimation function if needed
fun([]);

% Define grid of starting points
lb = settings.lb;
ub = settings.ub;
plb = settings.plb;
pub = settings.pub;
nvars = numel(pub);

switch nvars
    case 1; x0 = linspace(pb,pub,4)';
    case 2
        for j = 1:4
            x0(j,:)=plb+(pub-plb).*[1+mod(j-1,2),1+mod(floor((j-1)/2),2)]/3;
        end
    case 3
        for j = 1:8
            x0(j,:) = plb+(pub-plb).*[1+mod(j-1,2),1+mod(floor((j-1)/2),2),1+mod(floor((j-1)/4),2)]/3;
        end
end

% Perform optimization from each starting point
Nopts = size(x0,1);
x_best = zeros(Nopts,nvars);
nLL = zeros(Nopts,1);
nLL_sd = zeros(Nopts,1);

Nbench = 3;

if Nbench > 0; bench_timing = bench(Nbench); end   % Measure computer speed
t0 = tic;
for iOpt = 1:Nopts
    x_best(iOpt,:) = bads(fun,x0(iOpt,:),lb,ub,plb,pub,[],badsopts);
    
    % Evaluate candidate solution with higher precision
    [nLL(iOpt),nLL_sd(iOpt)] = fun_hiprec(x_best(iOpt,:));
end
t_tot = toc(t0);
if Nbench > 0; bench_timing = [bench_timing; bench(Nbench)]; end  % Measure computer speed

% Compute summed benchmark time (only numerical benchmarks)
if Nbench > 0
    bench_t = sum(sum(bench_timing(:,1:4)));
else
    bench_t = 0;
end

% Get best solution
[~,idx_best] = min(nLL);
theta_inf = x_best(idx_best,:);
nLL_best = nLL(idx_best);
nLL_sd_best = nLL_sd(idx_best);

% Get function output (this also resets the function counters)
[~,~,output]=fun([]);

% Correct number of effective function calls to account for high prec
if strcmp(method,'ibs') || strcmp(method,'fixed') || strcmp(method,'fixedb')
    output.funcalls = output.funcalls + Nopts*(mult_hiprec-1);
end

output_vec = [nLL_best,nLL_sd_best,output.samples_used,output.reps_used,output.funcalls,t_tot,bench_t];

end
