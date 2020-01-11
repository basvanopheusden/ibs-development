function [nll,nll_sd,output]=estimate_nll_fixed2(model,stim,resp_real,theta,Nsamples,Nreps)
%ESTIMATE_NLL_FIXED2 Negative log likelihood estimation via fixed sampling.
% (Uses rectified correction to avoid zeros.)

persistent samples_used;
persistent reps_used;
persistent funcalls;

if isempty(samples_used)
    samples_used = 0;
    reps_used = 0;
    funcalls = 0;
end
if nargin < 4 || isempty(theta)
    nll = []; nll_sd = [];
    output.samples_used = samples_used;
    output.reps_used = reps_used;
    output.funcalls = funcalls;
    samples_used = 0;
    reps_used = 0;
    funcalls = 0;
    return;
end

if nargin < 6 || isempty(Nreps); Nreps = 1; end

Ntrials = size(resp_real,1);
m = zeros(Ntrials,1);
minsample = 1/2;

Neff = Nsamples*Nreps;
for iSample = 1:Neff
    resp = feval(['generate_resp_' model],stim,theta,1:Ntrials);
    m = m + all(resp==resp_real,2);
end

% Estimate p with rectified correction
p = max(m,minsample)/Neff;

nll = -sum(log(p));

if nargout > 1
    % Estimate SD via bootstrap
    p_eff = m/Neff;    
    nll_bootstrap = [];    
    Niters=5;
    Nbootperiter=10;  
    for iBoot = 1:Niters
        m_bootstrap = binornd(Neff,repmat(p_eff,[1,Nbootperiter]));
        p_bootstrap = max(m_bootstrap,minsample)/Neff;
        nll_bootstrap = [nll_bootstrap, -sum(log(p_bootstrap),1)];
    end
    nll_sd = std(nll_bootstrap);
end

samples_used = samples_used + Neff;
funcalls = funcalls + 1;
reps_used = reps_used + Nreps;

if nargout > 2
    output.samples_used = samples_used;
    output.reps_used = reps_used;    
    output.funcalls = funcalls;
end