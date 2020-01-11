function [nll,nll_sd,output]=estimate_nll_ibs(model,stim,resp_real,theta,Nreps,thresh)
%ESTIMATE_NLL_IBS Negative log likelihood estimation via inverse binomial sampling.

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

if nargin < 6 || isempty(thresh); thresh = Inf; end

nll_vec = zeros(1,Nreps);
if nargout > 1; nll_var_vec = zeros(1,Nreps); end
Ntrials = size(resp_real,1);

% Loop over IBS repetitions (multiple IBS runs)
for iRep=1:Nreps
    resp = NaN(Ntrials,1);
    tries = zeros(Ntrials,1); % How often you have sampled each trial
    ind = true(Ntrials,1); % Trials where you haven't matched resp_real yet
    n = sum(ind); %number of trials left
    
    while n>0 && nll_vec(iRep)<thresh
        resp(ind) = feval(['generate_resp_' model],stim,theta,ind);
        ind = any(resp~=resp_real,2);
        tries = tries+ind;
        nll_vec(iRep) = nll_vec(iRep) + sum(1./tries(ind));
        n=sum(ind);
    end
    
    % Compute estimate of the variance if requested
    if nargout > 1
        K = tries+1;
        Ktab = -(psi(1,1:max(K(:)))' - psi(1,1));
        nll_var_vec(iRep) = sum(Ktab(K));
    end
    
    samples_used = samples_used + mean(tries+1);
end

funcalls = funcalls + 1;
reps_used = reps_used + Nreps;

nll = mean(nll_vec);
if nargout > 1
    nll_sd = sqrt(mean(nll_var_vec)/Nreps);
end

if nargout > 2
    output.samples_used = samples_used;
    output.reps_used = reps_used;    
    output.funcalls = funcalls;
end

end