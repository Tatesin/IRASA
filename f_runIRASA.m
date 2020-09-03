function [frac_on, frac_off, orig_on, orig_off] = f_runIRASA(EEG_on, EEG_off, freq)
% Function to run IRASA and Multitaper method

% EEG_on & EEG_off = EEG sets for ON and OFF periods in fieldtrip format
% freq = frequencies to use for the IRASA and Multitaper method i.e.
% 0.1:0.1:20
% frac_on & frac_off = fractal components of the on and off periods
% (calculated with IRASA)
% orig_on & orig_off = Power Spectral Densities of the on and off periods

cfg               = [];
cfg.foi           = freq;
cfg.taper         = 'hanning';
cfg.pad           = 'nextpow2';
cfg.keeptrials    = 'yes';
cfg.method        = 'irasa'; %IRASA
frac_r_on = ft_freqanalysis(cfg, EEG_on); 
frac_r_off = ft_freqanalysis(cfg, EEG_off); 
cfg.method        = 'mtmfft'; %Multitaper method
orig_r_on = ft_freqanalysis(cfg, EEG_on); 
orig_r_off = ft_freqanalysis(cfg, EEG_off);

frac_s_on = {}; 
frac_s_off = {}; 
orig_s_on = {};
orig_s_off = {};
for rpt = 1:size(frac_r_on.trialinfo,1)
    cfg               = [];
    cfg.trials        = rpt;
    cfg.avgoverrpt    = 'yes';
    frac_s_on{end+1} = ft_selectdata(cfg, frac_r_on);
    frac_s_off{end+1} = ft_selectdata(cfg, frac_r_off);
    orig_s_on{end+1} = ft_selectdata(cfg, orig_r_on);
    orig_s_off{end+1} = ft_selectdata(cfg, orig_r_off);
end
frac_a_on = ft_appendfreq([], frac_s_on{:});
frac_a_off = ft_appendfreq([], frac_s_off{:});
orig_a_on = ft_appendfreq([], orig_s_on{:});
orig_a_off = ft_appendfreq([], orig_s_off{:});

% average across trials
cfg               = [];
cfg.trials        = 'all';
cfg.avgoverrpt    = 'yes';
% cfg.channel       = sensorimotor;
frac_on  = ft_selectdata(cfg, frac_a_on);
frac_off = ft_selectdata(cfg, frac_a_off);
orig_on  = ft_selectdata(cfg, orig_a_on);
orig_off = ft_selectdata(cfg, orig_a_off);

