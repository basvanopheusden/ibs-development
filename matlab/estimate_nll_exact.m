function [nll,nll_sd,output]=estimate_nll_exact(model,stim,resp,theta,hiprec_flag)
%ESTIMATE_NLL_EXACT 'Exact' negative log likelihood computation
% (analytical or numerical)

persistent funcalls;
if isempty(funcalls)
    funcalls = 0;
end
if nargin < 4 || isempty(theta)
    nll = []; nll_sd = [];
    output.samples_used = 0;
    output.reps_used = 0;
    output.funcalls = funcalls;
    funcalls = 0;
    return;
end

% High-precision computation
if nargin < 5 || isempty(hiprec_flag); hiprec_flag = false; end

switch model
    case 'psycho'
        nll = compute_nll_psycho(stim,resp,theta);
    case 'vstm'
        if hiprec_flag; Nx = 4e3; else; Nx = 3e3; end        
        nll = compute_nll_vstm(stim,resp,theta,Nx);
    otherwise
        error('Unsupported model with ''exact'' method.');
end

nll_sd = 0;
funcalls = funcalls + 1;

if nargout > 2
    output.samples_used = 0;
    output.reps_used = 0;
    output.funcalls = funcalls;
end

end