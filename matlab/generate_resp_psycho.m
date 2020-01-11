function resp=generate_resp_psycho(stim,theta,ind)
%GENERATE_RESP_PSYCHO Generate responses for psychometric function model.

if nargin < 3 || isempty(ind); ind = (1:size(stim,1))'; end

sigma=exp(theta(1));
bias=theta(2);
lambda=theta(3);
stim=stim(ind);
x=stim+normrnd(0,sigma,size(stim));
resp=rand(size(stim))>(lambda/2+(1-lambda)*(x>bias));
    
end