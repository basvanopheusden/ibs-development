function L=compute_nll_vstm(stim,resp,theta,Nx,testflag)
%COMPUTE_NLL_VSTM Average negative log likelihood of VSTM data.

% Grid size for numerical integration
if nargin < 4 || isempty(Nx); Nx = 1e3; end

% Perform unit test
if nargin < 5 || isempty(testflag); testflag = false; end

if testflag     % Unit test - numerical log likelihood vs. IBS estimate
    L = nll_test(stim,resp,theta,Nx);    
    return;
end

kappa=exp(-2*theta(1)); % Concentration parameter for sensory noise
lambda=theta(2);        % Lapse rate

x1 = linspace(-pi,pi,Nx);       % Change location
x2 = linspace(-pi,pi,Nx+1);    % Not-change location
x3 = linspace(-pi,pi,Nx+2);
dx1 = x1(2)-x1(1);
dx2 = x2(2)-x2(1);
dx3 = x3(2)-x3(1);

% Differences in orientations between displays
deltas = circ_dist(stim(:,1:6),stim(:,7:12));

% Densities of differences of two von Mises random variables (equal kappa)
kz1 = sqrt(2*kappa^2*(1+cos(-deltas(:,1)-x1)));
kz2(1,1,:) = sqrt(2*kappa^2*(1+cos(-x2)));
kz3(1,1,1,:) = sqrt(2*kappa^2*(1+cos(-x3)));
px_s1 = exp(log(besseli(0,kz1,1))-2*log(besseli(0,kappa,1))+kz1-2*kappa)/(2*pi);
px_s2 = exp(log(besseli(0,kz2,1))-2*log(besseli(0,kappa,1))+kz2-2*kappa)/(2*pi);
px_s3 = exp(log(besseli(0,kz3,1))-2*log(besseli(0,kappa,1))+kz3-2*kappa)/(2*pi);

% Integral over decision rule
dist_x1 = abs(circ_dist(x1,0));
dist_x2(1,1,:) = abs(circ_dist(x2,0));
x1gtx2 = qtrapz(px_s1.*qtrapz(px_s2.*(dist_x1 > dist_x2),3).^5,2)*dx1*dx2^5;

dist_x3(1,1,1,:) = abs(circ_dist(x3,0));

%x2gtx3 = qtrapz(px_s2 .* ...
%    qtrapz(px_s1.*(dist_x1 < dist_x2),2) ...
%    .* qtrapz(px_s3.*(dist_x2 > dist_x3),4).^4 ...
%    ,3)*dx1*dx2*dx3^4;

% Need to split the computation here to avoid memory overflow
idx = unique([1:50:size(stim,1)+1,size(stim,1)+1]);
x2gtx3 = zeros(size(stim,1),1);
for i = 1:numel(idx)-1
    ii = idx(i):idx(i+1)-1;        
    x2gtx3(ii) = qtrapz(px_s2 .* ...
        qtrapz(px_s1(ii,:).*(dist_x1 < dist_x2),2) ...
        .* qtrapz(px_s3.*(dist_x2 > dist_x3),4).^4 ...
        ,3)*dx1*dx2*dx3^4;
end
    
% Log probability of correct and incorrect response
log_pr1 = log(x1gtx2);
log_pr2p = log(x2gtx3);

L = zeros(size(resp));
L(resp == 1) = log((1-lambda).*exp(log_pr1(resp==1)) + lambda/6);
L(resp ~= 1) = log((1-lambda).*exp(log_pr2p(resp~=1)) + lambda/6);

L = -sum(L);

end

%--------------------------------------------------------------------------
function L = nll_test(stim,resp,theta,Nx)
%NLL_TEST Compute average log likelihood with different methods

Ntrials = size(stim,1);

nll_exact = compute_nll_vstm(stim,resp,theta,Nx);

fun = @(params,dmat) generate_resp_vstm(dmat,params);
options = ibslike('defaults');
options.Nreps = 1e3;
[nll_ibs,var_ibs] = ibslike(fun,theta,resp,stim,options);

L = [nll_exact,nll_ibs];

fprintf('Exact nLL: %.3f. IBS nLL: %.3f +/- %.3f.\n',nll_exact,nll_ibs,sqrt(var_ibs));

end

