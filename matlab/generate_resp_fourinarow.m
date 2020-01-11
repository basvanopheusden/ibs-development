function resp=generate_resp_fourinarow(stim,theta,ind)
%GENERATE_RESP_FOURINAROW Generate responses for four-in-a-row model.

if nargin < 3 || isempty(ind); ind = (1:size(stim,1))'; end

resp=generate_resp_fourinarow_mex(stim(ind,:)',pad_input(theta))';

end

%--------------------------------------------------------------------------
function theta = pad_input(theta)
%PAD_INPUT Add other fixed parameters for four-in-a-row model.

thresh = theta(1);
delta = theta(2);
sigma = exp(theta(3));
w = [0.90444; 0.45076; 3.4272; 6.1728]/sigma;
w_center = 0.60913/sigma;
lambda = 0.05;
c_act = 0.92498;
gamma = 0.02;
theta=[10000;  thresh; gamma; lambda; 1; 1; w_center; repmat(w,4,1); 0; c_act*repmat(w,4,1); 0; repmat(delta,17,1)];

end