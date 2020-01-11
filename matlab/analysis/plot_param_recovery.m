function plot_param_recovery(model)

if isfield(model,'model') && isfield(model,'type') && strcmp(model.type,'theta')
    results = model;
    model = results.model;
else
    results = load_results(model,'theta');    
end

settings = get_model_settings(model);

Nparams = size(settings.theta_real,2);

globals = get_model_settings('global');
fontsize = globals.fontsize;
axesfontsize = globals.axesfontsize;
Ndata = globals.Ndata;
methods = globals.methods;
samples = settings.samples;
Nrows = numel(methods);

for iMethod = 1:numel(methods)
    method = methods{iMethod};
    
    plotdiag = true(1,Nparams); % Plot diagonal once per panel
    
    for iParam = 1:Nparams; h{iParam} = []; legtext{iParam} = []; end
    ymin = Inf(1,Nparams); ymax = -Inf(1,Nparams);
    
    for iSamples = 1:numel(samples{iMethod})
        ss = samples{iMethod}(iSamples);
        
        if ss == 0; subfield = method; else; subfield = [method num2str(ss)]; end        
        if ~isfield(results,subfield); continue; end
            
        mat = results.(subfield);
        
        for iParam = 1:Nparams
            subplot(Nrows,Nparams,iParam + (iMethod-1)*Nparams);
            ind = (1:40)+40*(iParam-1);
            submat = squeeze(mat(:,iParam,ind));
            xx = settings.theta_real(ind,iParam);
                           
            if plotdiag(iParam)
                plot([xx(1),xx(end)],[xx(1),xx(end)],'k-','LineWidth',2);
                plotdiag(iParam) = false;
                hold on;
            end
            
            theta_mean = nanmean(submat,1);
            theta_sd = nanstd(submat,[],1);
            % errorbar(xx,theta_mean,theta_sd);
            temph = plot(xx,theta_mean,'-','LineWidth',1); hold on;
            h{iParam} = [h{iParam},temph];
            legtext{iParam}{end+1} = subfield;
            
            axis square;
            set(gca,'TickDir','out','Fontsize',axesfontsize);
            set(gcf,'Color','w');
            
            if settings.logflag(iParam)
                ticks = [0.001,0.003,0.01,0.03,0.1,0.3,1,3,10];
                tt = []; for ii = 1:numel(ticks); tt{ii} = num2str(ticks(ii)); end
                set(gca,'XTick',log(ticks),'XTickLabel',tt);
                set(gca,'YTick',log(ticks),'YTickLabel',tt);                
            end
            
            box off;
            xlabel(['true ' settings.params{iParam}],'Fontsize',fontsize);
            ylabel(['recovered ' settings.params{iParam}],'Fontsize',fontsize);            
            if iMethod == 1; title(settings.params{iParam},'Fontsize',fontsize); end
            
            ymin(iParam) = min(ymin(iParam),min(theta_mean));
            ymax(iParam) = max(ymax(iParam),max(theta_mean));
            
                        
            xlim([xx(1),xx(end)]);
            %ylim([xx(1),xx(end)]);            
            ylim([min(ymin(iParam),xx(1)),max(ymax(iParam),xx(end))]);            
        end
    end
    
    subplot(Nrows,Nparams,Nparams + (iMethod-1)*Nparams);
    hl = legend(h{iParam}(end:-1:1),legtext{iParam}{end:-1:1});
    set(hl,'box','off','Location','bestoutside','FontSize',axesfontsize);
        
end



end