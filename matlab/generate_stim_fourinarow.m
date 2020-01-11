function stim=generate_stim_fourinarow(Ntrials)
%GENERATE_STIM_FOURINAROW Generate stimuli for four-in-a-row model.

% Stimuli are randomly selected from an existing dataset of stimuli
load('allstim_fourinarow.mat');
[~,ind] = unique(cellfun(@(x) uint64(x),stim),'rows');
stim = stim(ind,:);
stim = stim(randsample(size(stim,1),Ntrials),:);

end
