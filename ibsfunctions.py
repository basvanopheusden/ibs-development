import numpy as np
import matplotlib.pyplot as plt
import os.path

Npars = {'psycho': 120,'vstm' : 80,'fourinarow' : 120}
par_names = {'psycho' : ['sigma','mu','lambda'], 'vstm' : ['1/kappa','lambda'], 'fourinarow': ['theta','delta','sigma']}
models = ['psycho','vstm','fourinarow']
methods = {'psycho' : ['ibs','fixed','exact'], 'vstm': ['ibs','fixed','exact'], 'fourinarow' : ['ibs','fixed']}
Nsamples = {'psycho' :
            {'ibs' : [1,2,3,5,10,15,20,35,50],
             'fixed' : [1,2,3,5,10,15,20,35,50,100],
             'exact' : [0]
            },
            'vstm' : 
            {'ibs' : [1,2,3,5,10,20],
             'fixed' : [1,2,3,5,10,15,20,35,50,100],
             'exact' : [0]
            },
            'fourinarow' : 
            {'ibs' : [1],
             'fixed' : [1,2,3,5,10,15,20,35,50]
            }
           }


def get_filename(model,method,filetype,Ns,i,direc,addendum=''):
    if method=='exact':
        return direc + model + '/exact/' + filetype + '_' + model + '_' + method + '_' + str(i) + '.txt'
    else:
        return direc + model + '/' + method + str(Ns) + addendum + '/' + filetype + '_' + model + '_' + method + '_' + str(i) + '.txt'

def load_samples(model,Ns,i,direc):
    fname = get_filename(model,'ibs','output',Ns,i,direc)
    if os.path.isfile(fname):
        x = np.loadtxt(fname)
        return x[:,2]/x[:,4]
    else:
        return np.full(shape=[100,],fill_value=np.nan)

def load_nll_best(model,method,Ns,i,direc):
    fname = get_filename(model,method,'nll',Ns,i,direc)
    if os.path.isfile(fname):
        x = np.loadtxt(fname)
        if x.shape[0]==100:
            return x
        else:
            return np.vstack([x,np.full(shape=[100-x.shape[0],2],fill_value=np.nan)])
    else:
        return np.full(shape=[100,2],fill_value=np.nan)    
    
def load_theta(model,method,Ns,i,direc):
    fname = get_filename(model,method,'theta',Ns,i,direc)
    return np.loadtxt(fname) if os.path.isfile(fname) else np.full(shape=[100,len(par_names[model])],fill_value=np.nan)
    
def get_means(theta):
    try:
        means = np.mean(np.array(theta),axis=2)
    except:
        means = np.array([[np.mean(tt,axis=0) for tt in t] for t in theta])
    return means

def get_stds(theta):
    try:
        stds = np.std(np.array(theta),axis=2)
    except:
        stds = np.array([[np.std(tt,axis=0) for tt in t] for t in theta])
    return stds

def get_absdevs(theta,theta_real):
    try:
        absdevs = np.mean(np.abs(np.array(theta)-theta_real[None,:,None,:]),axis=2)
    except:
        absdevs = np.array([[np.mean(np.abs(tt-treal),axis=0) for tt,treal in zip(t,theta_real)] for t in theta])
    return absdevs
    
def plot_param_recovery(model,method):
    fig,ax = plt.subplots()
    for i,pname in enumerate(par_names[model]):
        ax.plot(theta_real[model][40*i:40*(i+1),i],means[model][method][:,40*i:40*(i+1),i].T,'.-')
        ax.plot(theta_real[model][40*i:40*(i+1),i],theta_real[model][40*i:40*(i+1),i],'-k')
        ax.set_xlabel(pname)
        ax.set_ylabel(pname)
        fig.savefig(fig_direc + 'rmse_' + model + '_' + pname.replace('1/','') + '.pdf')
        plt.show()
        
def plot_rmses(model,samples_used,rmses):
    for i,pname in enumerate(par_names[model]):
        fig,ax = plt.subplots()
        ax.plot(np.nanmean(np.nanmean(samples_used[model],axis=1),axis=1),np.nanmean(rmses[model]['ibs'][:,40*i:40*(i+1),i],axis=1),'.-',label='IBS')
        ax.plot(Nsamples[model]['fixed'],np.nanmean(rmses[model]['fixed'][:,40*i:40*(i+1),i],axis=1),'.-',label='fixed')
        if 'exact' in methods[model]:
            ax.axhline(np.nanmean(rmses[model]['exact'][:,40*i:40*(i+1),i]),color='black')
        ax.legend()
        ax.set_xlabel('Samples used')
        ax.set_ylabel('rmse(' + pname.replace('1/','') +')')
        fig.savefig(fig_direc + 'rmse_' + model + '_' + pname.replace('1/','') + '.pdf')
        plt.show()

def plot_absdevs(model):
    for i,pname in enumerate(par_names[model]):
        fig,ax = plt.subplots()
        ax.plot(np.nanmean(np.nanmean(samples_used[model],axis=1),axis=1),np.nanmean(absdevs[model]['ibs'][:,40*i:40*(i+1),i],axis=1),'.-',label='IBS')
        ax.plot(Nsamples[model]['fixed'],np.nanmean(absdevs[model]['fixed'][:,40*i:40*(i+1),i],axis=1),'.-',label='fixed')
        if 'exact' in methods[model]:
            ax.axhline(np.nanmean(absdevs[model]['exact'][:,40*i:40*(i+1),i]),color='black')
        ax.set_xlabel('Samples used')
        ax.set_ylabel('mads(' + pname.replace('1/','') +')')
        ax.legend()
        fig.savefig(fig_direc + 'mads_' + model + '_' + pname.replace('1/','') + '.pdf')
        plt.show()
        
def plot_mean_and_std(model,i,x,save_plot=False):
    k = len(methods[model])

    fig,ax = plt.subplots()
    
    for k,(method,ns) in enumerate(x):
        j = np.nonzero(np.array(Nsamples[model][method])==ns)[0]
        if len(j)>0:
            j=j[0]
            label = method + (' ' + str(ns) if method=='fixed' else (' {:.2f}'.format(np.mean(samples_used[model][j])) if method=='ibs' else ''))
            ax.errorbar(x = theta_real[model][40*i:40*(i+1),i],
                         y = means[model][method][j][40*i:40*(i+1),i],
                         yerr = stds[model][method][j][40*i:40*(i+1),i]*((np.arange(0,40)+k)%len(x)==0),
                        label = label)
        else:
            print('Not found:',model,method,ns)

    ax.plot(theta_real[model][40*i:40*(i+1),i],theta_real[model][40*i:40*(i+1),i],'-k')
    pname = par_names[model][i]
    ax.set_xlabel(pname)
    ax.set_ylabel(pname)
    ax.legend()
    fig.savefig(fig_direc + 'parameter_recovery_'  + pname.replace('1/','') + '.pdf')
    plt.show()
    
def plot_nll_best(model,i,x,save_plot=False):
    fig,ax = plt.subplots()    
        
    for k,(method,ns) in enumerate(x):
        j = np.nonzero(np.array(Nsamples[model][method])==ns)[0]
        if len(j)>0:
            j=j[0]
            L = np.array(nll_best[model][method][j][40*i:40*(i+1)])[:,:,0]
            L_exact = np.array(nll_best[model][method][j][40*i:40*(i+1)])[:,:,1]
            label = method + (' ' + str(ns) if method=='fixed' else (' {:.2f}'.format(np.mean(samples_used[model][j])) if method=='ibs' else ''))
            ax.errorbar(x = theta_real[model][40*i:40*(i+1),i],y=np.mean(L_exact-L,axis=1),yerr=np.std(L_exact-L,axis=1)/np.sqrt(L.shape[1]),label = label)
        else:
            print('Not found:',model,method,ns)

    plt.axhline(0,color='black')
    pname = par_names[model][i]
    ax.set_xlabel(pname)
    ax.set_ylabel('Log-likelihood loss')
    ax.legend()
    if save_plot:
        fig.savefig(fig_direc + 'nll_best_'  + pname.replace('1/','') + '.pdf')
    plt.show()
    
def plot_loglik_loss(model):
    fig,ax = plt.subplots()
    ax.plot(np.nanmean(np.nanmean(samples_used[model],axis=1),axis=1),np.nanmean(np.array(np.diff(nll_best[model]['ibs'])),axis=(1,2)),'.-',label='IBS')
    ax.plot(Nsamples[model]['fixed'],np.nanmean(np.array(np.diff(nll_best[model]['fixed'])),axis=(1,2)),'.-',label='fixed')
    ax.legend()
    ax.set_xlabel('Samples used')
    ax.set_ylabel('Loglik loss')
    ax.set_ylim([-25,0])
    fig.savefig(fig_direc + 'loglik_loss.pdf')
    plt.show()