%% IRASA analysis

% Paths
path(pathdef)
clc
clear all
close all

addpath('C:\Users\rreis\OneDrive\Documentos\Ranga Lab\fieldtrip-20200607'); %Fieldtrip Toolbox
addpath('C:\Users\rreis\OneDrive\Documentos\Ranga Lab\Sleep Study\Fieldtrip_study'); %Folder with scripts
ft_defaults
addpath(genpath('C:\Users\rreis\OneDrive\Documentos\Ranga Lab\eeglab2019_1')); %EEGLAB Toolbox

% Create path and new directories
rootdir = 'C:\Users\rreis\OneDrive\Documentos\Ranga Lab\Sleep Study\DataGermany\EEGLABfiltered_Off_On_200Hz\Trials'; %Folder with .set and .fdt
datadir = 'C:\Users\rreis\OneDrive\Documentos\Ranga Lab\Sleep Study\Fieldtrip_study';
prepdir = fullfile(datadir,'filtered_Off_On_200Hz\Trials'); %Folder where the data will be saved
mkdir(prepdir)

%% Creat list with .set to use
cd(rootdir);
allinfo = dir('*Odor.set'); %for OFF-ON '*ON.set' epoched data

%% Run IRASA
cd(prepdir);
eeglab nogui

% n2 = 1;

for subj = 1:length(allinfo)
    %% Convert to Fieldtrip
    EEG_cue      = pop_loadset('filename',allinfo(subj).name,'filepath',rootdir); %Load epoched OFF-ON data
    EEG_sham     = pop_loadset('filename',strcat(allinfo(subj).name(1:end-8),'Sham.set'),'filepath',rootdir);
    
    subject      = allinfo(subj).name(1:6);    
    
    cue_data     = eeglab2fieldtrip(EEG_cue,'preprocessing','none');
    sham_data    = eeglab2fieldtrip(EEG_sham,'preprocessing','none');

%% -- Spectrum
    % Calculate the spectrum every X seconds 
    time_wnd = 3; %length in seconds
    t_max    = 31-time_wnd;
    %-----Cue odor----------------------------
    
    cfg = [];
    dataCue = [];
    for i = 1:t_max
        cfg.toilim = [i-16 i-16+time_wnd]
        dataCue{i} = ft_redefinetrial(cfg, cue_data);
        
    end
 
    %-----Sham odor----------------------------
    
    cfg = [];
    dataSham = [];
    for i = 1:t_max
        cfg.toilim = [i-16 i-16+time_wnd]
        dataSham{i} = ft_redefinetrial(cfg, sham_data);
        
    end
  
    %--------
    
%     cfg								= [];
%     cfg.length						= 4;
%     cfg.overlap						= .9;
%     data_pos						= ft_redefinetrial(cfg, data_pos);
%     data_pre						= ft_redefinetrial(cfg, data_pre);
    
    %% Estimate fractal component
    
    freqs				= 0.5:.05:30;
    
    cfg					= [];
    cfg.foi				= freqs;
    cfg.method			= 'irasa';
    cfg.pad				= 'nextpow2';
    
    fracCue_total             = ft_freqanalysis(cfg, cue_data);
    fracSham_total            = ft_freqanalysis(cfg, sham_data);
 
    %-----Cue odor----------------------------
    fracCue = [];
    for t = 1:t_max
        fracCue{t}					= ft_freqanalysis(cfg, dataCue{t});
    end

    %-----Sham odor----------------------------
    fracSham = [];
    for t = 1:t_max
        fracSham{t}					= ft_freqanalysis(cfg, dataSham{t});
    end 
    
    %% Estimate mixed (normal) power spectrum
    cfg.method 						= 'mtmfft';
    cfg.taper 						= 'hanning';
    
    %-----Cue odor----------------------------
    mixCue = [];
    for t = 1:t_max
        mixCue{t}					= ft_freqanalysis(cfg, dataCue{t});
    end

    %-----Sham odor----------------------------
    mixSham = [];
    for t = 1:t_max
        mixSham{t}					= ft_freqanalysis(cfg, dataSham{t});
    end 
    
    
    %% Calculate the oscillatory component by subtracting the fractal from the
    % mixed component
    cfg								= [];
    cfg.parameter					= 'powspctrm';
    cfg.operation					= 'subtract';
    
    %----- Cue odor ----------------------------
    for t = 1:t_max
       osciCue_total{t} = ft_math(cfg, mixCue{t}, fracCue_total);
       osciCue{t}       = ft_math(cfg, mixCue{t}, fracCue{t});
    end
    
    %----- Sham odor ----------------------------
    for t = 1:t_max
       osciSham_total{t} = ft_math(cfg, mixSham{t}, fracSham_total);
       osciSham{t}       = ft_math(cfg, mixSham{t}, fracSham{t});
    end
    
    %% Use percent change for even more obvious peaks
    cfg.operation			= 'divide';
    
    %----- Cue odor ----------------------------
    for t = 1:t_max
        percCue_total{subj,t} = ft_math(cfg, osciCue_total{t}, fracCue_total);
        percCue{subj,t}       = ft_math(cfg, osciCue{t}, fracCue{t});
    end
    
    %----- Sham odor ----------------------------
    for t = 1:t_max
        percSham_total{subj,t} = ft_math(cfg, osciSham_total{t}, fracSham_total);
        percSham{subj,t} = ft_math(cfg, osciSham{t}, fracSham{t});
    end

        
end


    
%% Plot for each subjects
all_chan = [1:109];
% frontal_chan = [8, 9, 12, 13, 14, 17, 7, 10, 4, 15, 3];
% central_chan = [5, 6, 94, 45, 25, 69, 11, 100, 24, 93, 30, 44, 68, 76];
frontal_chan = [2, 3, 7, 8, 9, 12, 13, 14, 15, 17, 18, 19, 109];
central_chan = [5, 6, 11, 23, 24, 25, 29, 30, 35, 44, 45, 68, 69, 76, 82, 92, 93, 94, 99, 100];

for subj = 1:length(allinfo)
    
    filename = allinfo(subj).name;
    %----- separate for frontal and central electrodes
%     [fron_chans,indx_f] = intersect(percCue_15pre{subj}.label,frontal_channels);
%     [cent_chans,indx_c] = intersect(percCue_15pre{subj}.label,central_channels);
%     
    %%Plots
    %------ For Frontal channels------------------------------
    channels = frontal_chan;
    figure('Position',[3.4,263.4,1532.8,420.0000000000001])
    sgtitle('Oscillatory relative to fractal component Cue (red) vs. Sham (black) spectra Frontal Channels')
    
    for t = 1:t_max
        subplot(2,ceil(t_max/2),t)
        
        plot(percCue_total{subj,t}.freq, ...
            squeeze(mean(percCue_total{subj,t}.powspctrm(channels,:),1)), 'r'), ...
            hold on
        plot(percSham_total{subj,t}.freq, ...
            squeeze(mean(percSham_total{subj,t}.powspctrm(channels,:),1)), 'k'), ...
            xlim([freqs(1) freqs(end)])
        title(strcat(num2str(t-16),' to ',num2str(t-16+time_wnd),' sec'))
    end
    
    saveas(gcf,strcat('IRASA_3sec-total_Frontal_',filename(1:6),'.png'))
    
    
    %------ For Central Channels ------------------------------
    channels = central_chan;
    figure('Position',[3.4,263.4,1532.8,420.0000000000001])
    sgtitle('Oscillatory relative to fractal component Cue (red) vs. Sham (black) spectra Central Channels')
    
    for t = 1:t_max
        subplot(2,ceil(t_max/2),t)
        
        plot(percCue_total{subj,t}.freq, ...
            squeeze(mean(percCue_total{subj,t}.powspctrm(channels,:),1)), 'r'), ...
            hold on
        plot(percSham_total{subj,t}.freq, ...
            squeeze(mean(percSham_total{subj,t}.powspctrm(channels,:),1)), 'k'), ...
            xlim([freqs(1) freqs(end)])
        title(strcat(num2str(t-16),' to ',num2str(t-16+time_wnd),' sec'))
    end
    
    saveas(gcf,strcat('IRASA_3sec-total_Central_',filename(1:6),'.png'))
    
    close all
end

%% Plot for All subjects
all_chan = [1:109];
% frontal_chan = [8, 9, 12, 13, 14, 17, 7, 10, 4, 15, 3];
% central_chan = [5, 6, 94, 45, 25, 69, 11, 100, 24, 93, 30, 44, 68, 76];
frontal_chan = [2, 3, 7, 8, 9, 12, 13, 14, 15, 17, 18, 19, 109];
central_chan = [5, 6, 11, 23, 24, 25, 29, 30, 35, 44, 45, 68, 69, 76, 82, 92, 93, 94, 99, 100];

for t = 1:t_max
    Frontal_CueAll{t}  = [];
    Frontal_ShamAll{t} = [];
    Central_CueAll{t}  = [];
    Central_ShamAll{t} = [];
    Allchan_CueAll{t}  = [];
    Allchan_ShamAll{t}  = [];
end


for subj = 1:length(allinfo)
    
    %----- separate for frontal and central electrodes
%     [fron_chans,indx_f] = intersect(percCue_15pre{subj}.label,frontal_channels);
%     [cent_chans,indx_c] = intersect(percCue_15pre{subj}.label,central_channels);
    
    %%Plots
    %------ For Frontal channels------------------------------
    for t = 1:t_max
        Frontal_Cue{t}  = squeeze(mean(percCue_total{subj,t}.powspctrm(frontal_chan,:),1));
        Frontal_Sham{t} = squeeze(mean(percSham_total{subj,t}.powspctrm(frontal_chan,:),1));
        Frontal_CueAll{t} = cat(1,Frontal_CueAll{t},Frontal_Cue{t});
        Frontal_ShamAll{t} = cat(1,Frontal_ShamAll{t},Frontal_Sham{t});
    end

    %------ For Central channels------------------------------
    
    for t = 1:t_max
        Central_Cue{t}  = squeeze(mean(percCue_total{subj,t}.powspctrm(central_chan,:),1));
        Central_Sham{t} = squeeze(mean(percSham_total{subj,t}.powspctrm(central_chan,:),1));
        Central_CueAll{t} = cat(1,Central_CueAll{t},Central_Cue{t});
        Central_ShamAll{t} = cat(1,Central_ShamAll{t},Central_Sham{t});
    end
    
     %------ For All channels------------------------------
    
    for t = 1:t_max
        Allchan_Cue{t}  = squeeze(mean(percCue_total{subj,t}.powspctrm(all_chan,:),1));
        Allchan_Sham{t} = squeeze(mean(percSham_total{subj,t}.powspctrm(all_chan,:),1));
        Allchan_CueAll{t} = cat(1,Allchan_CueAll{t},Allchan_Cue{t});
        Allchan_ShamAll{t} = cat(1,Allchan_ShamAll{t},Allchan_Sham{t});
    end
    
end

%%
%------ For Frontal channels------------------------------
figure('Position',[3.4,263.4,1532.8,420.0000000000001])
sgtitle('Oscillatory relative to fractal component Cue (red) vs. Sham (black) spectra Frontal Channels')

for t = 1:t_max
    subplot(2,ceil(t_max/2),t)
    SEM_temp_Cue = std(Frontal_CueAll{t},[],1)/sqrt(size(Frontal_CueAll{t},1));
    MEAN_temp_Cue = mean(Frontal_CueAll{t},1);
    shadedplot(percCue_total{subj,t}.freq, ...
        MEAN_temp_Cue-SEM_temp_Cue/2, MEAN_temp_Cue+SEM_temp_Cue/2,...
        'r','none');
    alpha(.2)
    hold on
    plot(percCue_total{subj,t}.freq, ...
        MEAN_temp_Cue,'r')
    
    hold on
    SEM_temp_Sham = std(Frontal_ShamAll{t},[],1)/sqrt(size(Frontal_ShamAll{t},1));
    MEAN_temp_Sham = mean(Frontal_ShamAll{t},1);
    shadedplot(percSham_total{subj,t}.freq, ...
        MEAN_temp_Sham-SEM_temp_Sham/2, MEAN_temp_Sham+SEM_temp_Sham/2,...
        'k','none');
    alpha(.2)
    hold on
    plot(percSham_total{subj,t}.freq, ...
        MEAN_temp_Sham,'k')
    ylim([-1 3])
    title(strcat(num2str(t-16),' to ',num2str(t-16+time_wnd),' sec'))
end

saveas(gcf,strcat('IRASA_3sec-total_Frontal_','All','.png'))


%------ For Central Channels ------------------------------

figure('Position',[3.4,263.4,1532.8,420.0000000000001])
sgtitle('Oscillatory relative to fractal component Cue (red) vs. Sham (black) spectra Central Channels')

for t = 1:t_max
    subplot(2,ceil(t_max/2),t)
    SEM_temp_Cue = std(Central_CueAll{t},[],1)/sqrt(size(Central_CueAll{t},1));
    MEAN_temp_Cue = mean(Central_CueAll{t},1);
    shadedplot(percCue_total{subj,t}.freq, ...
        MEAN_temp_Cue-SEM_temp_Cue/2, MEAN_temp_Cue+SEM_temp_Cue/2,...
        'r','none');
    alpha(.2)
    hold on
    plot(percCue_total{subj,t}.freq, ...
        MEAN_temp_Cue,'r')
    
    hold on
    SEM_temp_Sham = std(Central_ShamAll{t},[],1)/sqrt(size(Central_ShamAll{t},1));
    MEAN_temp_Sham = mean(Central_ShamAll{t},1);
    shadedplot(percSham_total{subj,t}.freq, ...
        MEAN_temp_Sham-SEM_temp_Sham/2, MEAN_temp_Sham+SEM_temp_Sham/2,...
        'k','none');
    alpha(.2)
    hold on
    plot(percSham_total{subj,t}.freq, ...
        MEAN_temp_Sham,'k')
    ylim([-1 3])
    title(strcat(num2str(t-16),' to ',num2str(t-16+time_wnd),' sec'))
end

saveas(gcf,strcat('IRASA_3sec-total_Central_','All','.png'))

%% Plot Time-Frequency

times = [(-15+time_wnd/2):1:(15-time_wnd/2)];
t_baseline = times(11:13);
freq  = percCue_total{subj,t}.freq;

Allchan_time = [];
Allchan_mat  = [];
Baseline_all_time = [];
Baseline_all_mat  = [];
Central_time = [];
Central_mat  = [];
Baseline_central_time = [];
Baseline_central_mat  = [];
Frontal_time = [];
Frontal_mat  = [];
Baseline_frontal_time = [];
Baseline_frontal_mat  = [];
b = 1;
for tb = 11:13
    Baseline_all_time{b}     = squeeze(mean(Allchan_CueAll{tb},1));
    Baseline_all_mat(b,:)    = (Baseline_all_time{b});
    Baseline_central_time{b} = squeeze(mean(Central_CueAll{tb},1));
    Baseline_central_mat(b,:)= (Baseline_central_time{b});
    Baseline_frontal_time{b} = squeeze(mean(Frontal_CueAll{tb},1));
    Baseline_frontal_mat(b,:)= (Baseline_frontal_time{b});
    b = b+1;
end
Baseline_all_mat     = Baseline_all_mat';
Baseline_all     	 = mean(Baseline_all_mat,2);
Baseline_central_mat = Baseline_central_mat';
Baseline_central     = mean(Baseline_central_mat,2);
Baseline_frontal_mat = Baseline_frontal_mat';
Baseline_frontal     = mean(Baseline_frontal_mat,2);

for t = 1:t_max
    Allchan_time{t} = squeeze(mean(Allchan_CueAll{t},1));
    Allchan_mat(t,:)= (Allchan_time{t});
    Central_time{t} = squeeze(mean(Central_CueAll{t},1));
    Central_mat(t,:)= (Central_time{t});
    Frontal_time{t} = squeeze(mean(Frontal_CueAll{t},1));
    Frontal_mat(t,:)= (Frontal_time{t});
end
Allchan_mat = Allchan_mat';
Central_mat = Central_mat';
Frontal_mat = Frontal_mat';

Allchan_base = Allchan_mat-Baseline_all;
Central_base = Central_mat-Baseline_central;
Frontal_base = Frontal_mat-Baseline_frontal;

figure; pcolor(times,freq, Allchan_base); shading interp;
colorbar; title 'Cue - All Subjects - All channels'; ylabel 'Frequency [Hz]'; %caxis([-20 20]);
xlabel 'Time [s]'; 
y_axis = ylim;
xlim([-3 13.5]); ylim([y_axis(1) 20]); 
line('XData',[0 0],'YData',ylim, 'LineWidth', 1, 'LineStyle','--');

saveas(gcf,strcat('IRASA_3sec-total-base_Allchan_','All_TF2','.png'))

figure; pcolor(times,freq, Central_base); shading interp;
colorbar; title 'Cue - All Subjects - Central channels'; ylabel 'Frequency [Hz]'; %caxis([-20 20]);
xlabel 'Time [s]'; 
y_axis = ylim;
xlim([-3 13.5]); ylim([y_axis(1) 20]); 
line('XData',[0 0],'YData',ylim, 'LineWidth', 1, 'LineStyle','--');

saveas(gcf,strcat('IRASA_3sec-total-base_Centralchan_','All_TF2','.png'))

figure; pcolor(times,freq, Frontal_base); shading interp;
colorbar; title 'Cue - All Subjects - Frontal channels'; ylabel 'Frequency [Hz]'; %caxis([-20 20]);
xlabel 'Time [s]'; 
y_axis = ylim;
xlim([-3 13.5]); ylim([y_axis(1) 20]); 
line('XData',[0 0],'YData',ylim, 'LineWidth', 1, 'LineStyle','--');

saveas(gcf,strcat('IRASA_3sec-total-base_Frontalchan_','All_TF2','.png'))
