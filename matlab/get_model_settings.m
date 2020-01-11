function settings = get_model_settings(model)
%GET_MODEL_SETTINGS Get settings for a given model.

b = 40;

switch model
    case 'psycho'
        settings.lb = [log(0.1) -2 0.01];
        settings.ub = [log(10) 2 1];
        settings.plb = [log(0.1) -1 0.01];
        settings.pub = [log(5) 1 0.2];
        settings.theta_real = [ ...
            [linspace(settings.plb(1),settings.pub(1),b)', 0.1*ones(b,1), 0.1*ones(b,1)]; ...
            [log(2)*ones(b,1), linspace(settings.plb(2),settings.pub(2),b)', 0.1*ones(b,1)]; ...
            [log(2)*ones(b,1), 0.1*ones(b,1), linspace(settings.plb(3),settings.pub(3),b)'] ...
            ];
        settings.thresh = log(2);
        settings.params = {'sigma','bias','lapse'};
        settings.logflag = [1,0,0];
        settings.methods = {'ibs','fixed','fixedb','exact'};
        settings.samples{1} = [1 2 3 5 10 15 20 35 50];
        settings.samples{2} = [1 2 3 5 10 15 20 35 50 100];
        settings.samples{3} = [1 2 3 5 10 15 20 35 50 100];
        settings.samples{4} = 0;
        
    case 'vstm'
        settings.lb = [log(0.05) 0.01];
        settings.ub = [log(2) 1];
        settings.plb = [log(0.1) 0.01];
        settings.pub = [log(1) 0.5];
        settings.theta_real = [ ...
            [linspace(settings.plb(1),settings.pub(1),b)', 0.03*ones(b,1)]; ...
            [log(0.3)*ones(b,1), linspace(settings.plb(2),settings.pub(2),b)'] ...
            ];
        settings.thresh = log(6);        
        settings.params = {'sigma','lapse'};
        settings.logflag = [1,0];
        settings.samples{1} = [1 2 3 5 10 15 20];
        settings.samples{2} = [1 2 3 5 10 15 20 35 50 100];
        settings.samples{3} = 0;
    
    case 'fourinarow'
        settings.lb = [0.01 0 log(0.01)];
        settings.ub = [10 1 log(5)];
        settings.plb = [1 0 log(0.2)];
        settings.pub = [10 0.5 log(3)];
        settings.theta_real = [ ...
            [linspace(settings.plb(1),settings.pub(1),b)', 0.2*ones(b,1), log(ones(b,1))]; ...
            [5*ones(b,1), linspace(settings.plb(2),settings.pub(2),b)', log(ones(b,1))]; ...
            [5*ones(b,1), 0.2*ones(b,1), linspace(settings.plb(3),settings.pub(3),b)'] ...
            ];
        settings.thresh = 3;
        settings.params = {'theta','delta','sigma'};
        settings.logflag = [0,0,1];
        settings.samples{1} = [1];
        settings.samples{2} = [1 2 3 5 10 15 20 35 50];
        settings.samples{3} = NaN;
        
    case 'global'
        settings.methods = {'ibs','fixed','fixedb','exact'};
        settings.Ndata = 100;
        settings.fontsize = 18;
        settings.axesfontsize = 14;
        settings.color = [0 0.8 0.8; 0.8 0.8 0; 0.6 0.6 0.2; 0 0 0];
        
    otherwise
        error(['Unknown MODEL ''' model '''. Models are: ''psycho'', ''vstm'', ''fourinarow'', or ''global'' for global settings.']);
end

end