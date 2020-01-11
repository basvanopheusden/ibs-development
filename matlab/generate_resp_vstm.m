function resp=generate_resp_vstm(stim,theta,ind)
%GENERATE_RESP_VSTM Generate observer's responses for VSTM model.

if nargin < 3 || isempty(ind); ind = (1:size(stim,1))'; end

s1=stim(ind,1:6);       % Orientations for first display
s2=stim(ind,7:12);      % Orientations for second display
kappa=exp(-2*theta(1)); % Concentration parameter for sensory noise
lambda=theta(2);        % Lapse rate

% Noisy sensory measurements
x1=s1+circ_vmrnd(0,kappa,size(s1));
x2=s2+circ_vmrnd(0,kappa,size(s2));

% Use MAX decision rule
[~,resp]=max(abs(circ_dist(x1,x2)),[],2);

% Uniform random lapses
lapse_trials=find(rand(size(resp))<lambda);
resp(lapse_trials)=randi(size(s1,2),1,length(lapse_trials));

end