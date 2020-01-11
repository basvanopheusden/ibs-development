function plot_grid(grid,dataset,iparam)
%PLOT_GRID Plot grid of negative log likelihoods (assuming 2-D).

globals = get_model_settings('global');
fontsize = globals.fontsize;
axesfontsize = globals.axesfontsize;

settings = get_model_settings(grid.model);

[nLL_min,idx] = min(squeeze(grid.nLL_grid(dataset,:,iparam)));

x1 = grid.xx{1};
x2 = grid.xx{2};
z = reshape(grid.nLL_grid(dataset,:,iparam),[numel(x1),numel(x2)])';

zmax = max(z(:));

theta_real = settings.theta_real(iparam,:);

surf(x1,x2,z,'EdgeColor','none'); hold on;
view([0 90]);
colorbar;

zstar = interp2(x1,x2,z,theta_real(1),theta_real(2));
h(1) = scatter3(theta_real(1),theta_real(2),zmax,'gx');   % True parameter

nLL_min
theta_min = grid.params_grid(idx,:)

zstar = interp2(x1,x2,z,theta_min(1),theta_min(2));
h(2) = scatter3(theta_min(1),theta_min(2),zmax,'ro');   % Landscape minimum

xlim([min(x1),max(x1)]);
ylim([min(x2),max(x2)]);

xlabel([settings.params{1}],'Fontsize',fontsize);
ylabel([settings.params{2}],'Fontsize',fontsize);

box off;
axis square;
set(gca,'TickDir','out','Fontsize',axesfontsize);
set(gcf,'Color','w');

ticks = [0.001,0.003,0.01,0.03,0.1,0.3,1,3,10];
tt = []; for ii = 1:numel(ticks); tt{ii} = num2str(ticks(ii)); end
if settings.logflag(1)
    set(gca,'XTick',log(ticks),'XTickLabel',tt);
end
if settings.logflag(2)
    set(gca,'YTick',log(ticks),'YTickLabel',tt);
end

if grid.Nsamples == 0
    method = grid.method;
else
    method = [grid.method num2str(grid.Nsamples)];
end

title(['nLL landscape, ' grid.model ' model (' method ')'],'Fontsize',fontsize);

hl = legend(h,'Generating parameters','Landscape minimum');
set(hl,'box','off','Location','bestoutside','Fontsize',axesfontsize);

end