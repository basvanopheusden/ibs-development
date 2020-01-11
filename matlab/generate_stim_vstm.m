function stim=generate_stim_vstm(Ntrials)
%GENERATE_STIM_VSTM Generate stimuli for VSTM model.

Ntargets=6;
s1=2*pi*rand(Ntrials,Ntargets);
% Without loss of generality for our simulations, we assume that change 
% happens on the first element of the stimulus vector
change_real = ones(1,Ntrials);
% In a real experiment stimulus location would be shuffled
% change_real=randi(Ntargets,1,Ntrials);
ind=sub2ind(size(s1),1:Ntrials,change_real);
s2=s1;
s2(ind)=s2(ind)+circ_vmrnd(0,1,Ntrials)';
stim=[s1 s2];

end