function plot_param_errs(type,model,output_results)

if isfield(model,'model') && isfield(model,'type') && strcmp(model.type,'theta')
    theta_results = model;
    model = theta_results.model;
else
    theta_results = load_results(model,'theta');    
end

if nargin < 3 || isempty(output_results)
    output_results = load_results(model,'output');        
end

settings = get_model_settings(model);
width = 1;

Nparams = size(settings.theta_real,2);

globals = get_model_settings('global');
fontsize = globals.fontsize;
axesfontsize = globals.axesfontsize;
Ndata = globals.Ndata;
methods = globals.methods;
samples = settings.samples;

h = []; legtext = []; xxmax = 0;

for iMethod = 1:numel(methods)
    method = methods{iMethod};
        
    xx = []; errmat = []; errmat_sd = [];
    maxerr = zeros(1,Nparams);
    
    for iSamples = 1:numel(samples{iMethod})
        ss = samples{iMethod}(iSamples);
        
        if ss == 0; subfield = method; else; subfield = [method num2str(ss)]; end        
        if ~isfield(theta_results,subfield); continue; end
            
        mat = theta_results.(subfield);
        
        for iParam = 1:Nparams
            ind = (1:40)+40*(iParam-1);
            submat = squeeze(mat(:,iParam,ind));
            theta_real(1,:) = settings.theta_real(ind,iParam);
                        
            if strcmp(method,'ibs')
                temp = squeeze(output_results.(subfield)(:,:,ind));
                xx(iParam,iSamples) = nansum(nansum(temp(:,3,:)))/nansum(nansum(temp(:,5,:)));
            else
                xx(iParam,iSamples) = settings.samples{iMethod}(iSamples);
            end
            
            switch type
                case 'rmse'
                    temp = bsxfun(@minus,submat,theta_real).^2;                    
                    errmat(iParam,iSamples) = sqrt(nanmean(temp(:)));
                    errmat_sd(iParam,iSamples) = 0.5*(stderr(temp(:)))/errmat(iParam,iSamples);
                case 'mads'
                    temp = abs(bsxfun(@minus,submat,theta_real));
                    errmat(iParam,iSamples) = nanmean(temp(:));
                    errmat_sd(iParam,iSamples) = stderr(temp(:));
            end
            maxerr(iParam) = max([maxerr(iParam),errmat(iParam,:)]);            
            xxmax = max([xxmax;xx(:)]);
        end
    end
    
    errmat_sd
    
    for iParam = 1:Nparams                    
        subplot(1,width*Nparams,(iParam-1)*width + (1:width));
        
        if size(xx,2) == 1
            xx = [xx,ceil(xxmax/10)*10*ones(size(xx))];
            errmat = repmat(errmat,[1,2]);
        end

        if strcmp(method,'exact'); marker = 'none'; else; marker = 'o'; end
        
        fill([xx(iParam,:) fliplr(xx(iParam,:))],[errmat(iParam,:)-errmat_sd(iParam,:),fliplr(errmat(iParam,:)+errmat_sd(iParam,:))],...
            globals.color(iMethod,:),'EdgeColor','none','FaceAlpha',0.5);        
        hold on;
        
        temph = plot(xx(iParam,:),errmat(iParam,:),'-',...
            'Color',globals.color(iMethod,:),'LineWidth',2,'Marker',marker,...
            'MarkerFaceColor',globals.color(iMethod,:),'MarkerEdgeColor','none');
        hold on;
        if iParam == Nparams
            h(iMethod) = temph;
            legtext{end+1} = method;
        end

        if iMethod == 2
            set(gca,'TickDir','out','Fontsize',axesfontsize);
            set(gcf,'Color','w');
            box off;
            xlabel(['Samples used'],'Fontsize',fontsize);
            ylabel(upper(type),'Fontsize',fontsize);
            
            if settings.logflag(iParam)
                titlestring = ['log ' settings.params{iParam}];
            else
                titlestring = settings.params{iParam};
            end
            title(titlestring,'Fontsize',fontsize);

            xlim([0,ceil(xxmax/10)*10]);
            ylim([0,maxerr(iParam)]);
        end

        % plot([xx(1),xx(end)],[xx(1),xx(end)],'k-','LineWidth',1);
    end
    
    subplot(1,width*Nparams,(Nparams-1)*width + (1:width));
    hl = legend(h,legtext{:});
    set(hl,'box','off','Location','northeast','FontSize',axesfontsize);
    
end



end