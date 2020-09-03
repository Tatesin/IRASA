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
rootdir = 'C:\Users\rreis\OneDrive\Documentos\Ranga Lab\Sleep Study\DataGermany\detrended'; %Folder with .set and .fdt
datadir = 'C:\Users\rreis\OneDrive\Documentos\Ranga Lab\Sleep Study\Fieldtrip_study';
prepdir = fullfile(datadir,'detrended\0.1-40Hz_OffOn-IRASA'); %Folder where the data will be saved
mkdir(prepdir)

%% Creat list with .set to use
cd(rootdir);
allinfo = dir('*ON.set'); %for OFF-ON epoched data

%% Run and plot IRASA

eeglab nogui

n2 = 1;
for n = 1:length(allinfo)
    %% Convert to Fieldtrip
    EEG             = pop_loadset('filename',allinfo(n).name,'filepath',rootdir); %Load epoched OFF-ON data
%     EEG_baseline    = pop_select(EEG, 'time', [-10 0]);
    EEG_off         = pop_select(EEG, 'time', [-15 0]);
    EEG_on          = pop_select(EEG, 'time', [0 15]);
    
    EEG1 = eeglab2fieldtrip(EEG,'preprocessing','none');
%     EEG_baseline1 = eeglab2fieldtrip(EEG_baseline,'preprocessing','none');
    EEG_off1 = eeglab2fieldtrip(EEG_off,'preprocessing','none');
    EEG_on1 = eeglab2fieldtrip(EEG_on,'preprocessing','none');
    
    %% IRASA
    cd(prepdir);
    freq = 0.1:0.1:40;
    freq_str = '0.1-40Hz';
    [frac_on, frac_off, orig_on, orig_off] = f_runIRASA(EEG_on1, EEG_off1, freq);
    
    name = erase(allinfo(n).name,'.set');
    save(fullfile(prepdir,strcat(name,'_TF',freq_str,'_IRASA_ON.mat')),'frac_on');
    save(fullfile(prepdir,strcat(name,'_TF',freq_str,'_IRASA_OFF.mat')),'frac_off');
    save(fullfile(prepdir,strcat(name,'_TF',freq_str,'_ON.mat')),'orig_on');
    save(fullfile(prepdir,strcat(name,'_TF',freq_str,'_OFF.mat')),'orig_off');
    
    %% Plot the fractal component and the power spectrum
    line_width = 2;
    figure; plot(freq, mean(frac_on.powspctrm), ...
        'linewidth', line_width, 'color', [0 0 0])
    hold on; plot(freq, mean(frac_off.powspctrm), ...
        'linewidth', line_width, 'color', [.6 .6 .6])
    hold on; plot(freq, mean(orig_on.powspctrm), ...
        'linewidth', line_width, 'color', [1 0 0])
    hold on; plot(freq, mean(orig_off.powspctrm), ...
        'linewidth', line_width, 'color', [0 0.6 0])
    legend('Fractal component ON', 'Fractal component OFF', 'PSD ON', 'PSD OFF');
    title(allinfo(n).name(1:17))
    % saveas(gcf,strcat(name,'_IRASA.jpg'));
    
    % % Plot the full-width half-maximum of the oscillatory components
    % f    = fit(osci.freq', mean(osci.powspctrm)', 'gauss3');
    % avg  = f.b1;
    % sd  = f.c1/sqrt(2)*2.3548;
    % alpha_fwhm = [avg-sd/2 avg+sd/2];
    % yl   = get(gca, 'YLim');
    % p = patch([alpha_fwhm flip(alpha_fwhm)], [yl(1) yl(1) yl(2) yl(2)], [.9 .9 .9]);
    % uistack(p, 'bottom');
    % avg  = f.b3;
    % sd  = f.c3/sqrt(2)*2.3548;
    % beta_fwhm = [avg-sd/2 avg+sd/2];
    % yl   = get(gca, 'YLim');
    % p = patch([beta_fwhm flip(beta_fwhm)], [yl(1) yl(1) yl(2) yl(2)], [.9 .9 .9]);
    % uistack(p, 'bottom');
    % legend('FWHM alpha', 'FWHM beta', 'Fractal component', 'Power spectrum','Difference spectrum');
    % xlabel('Frequency'); ylabel('Power');
    % set(gca, 'YLim', yl);
    
    % saveas(gcf,strcat(name(1:6),'_IRASA.jpg'));
    
    n2 = n2 + 1;
end

%% Visualize IRASA by individual subjects (PSD vs Frequency)
% clc
% clear all
close all

% Archives list
cd(prepdir);
allinfo = dir('*IRASA_OFF.mat');

for n = 1:length(allinfo)
    name = erase(allinfo(n).name,'IRASA_OFF.mat');
    %need 4 .mat files for each subject and condition: IRASA_ON, IRASA_OFF, ON, OFF
    [change_ON, change_OFF] = f_calcIRASAchange(name, prepdir); %channels x frequencies
    
    line_width = 2;
    %Plot individual subject
    figure; plot(frac_on.freq, mean(change_ON), ... %plot average of all channels
        'linewidth', line_width, 'color', [0 0 0])
    hold on; plot(frac_off.freq, mean(change_OFF), ... %plot average of all channels
        'linewidth', line_width, 'color', [.6 .6 .6])
    
    legend('ON Period', 'OFF Period');
    %     saveas(gcf,strcat(allinfo(n).name(1:17),'_OffOn_change.jpg'));
end

%% Folder for averaging over subjects
cd(prepdir);

prepdirPW = fullfile(pwd,'PwStructures');
mkdir(prepdirPW)

%% Structure creation for each condition

% Odor
allinfo_odor_ON  = dir(strcat('*Odor*','Hz_ON.mat'));
allinfo_odor_OFF = dir(strcat('*Odor*','Hz_OFF.mat'));

% Sham
allinfo_sham_ON  = dir(strcat('*Sham*','Hz_ON.mat'));
allinfo_sham_OFF = dir(strcat('*Sham*','Hz_OFF.mat'));
% 

[BigODOR_ON, BigODOR_IRASA_ON, BigODOR_OFF, BigODOR_IRASA_OFF,...
    BigSHAM_ON, BigSHAM_IRASA_ON, BigSHAM_OFF, BigSHAM_IRASA_OFF...
    ] = f_createStructures(allinfo_odor_ON, allinfo_odor_OFF, allinfo_sham_ON,...
    allinfo_sham_OFF, prepdirPW);

%% Changes with respect to IRASA

[BigChangeODOR_ON, BigChangeODOR_OFF, BigChangeSHAM_ON, ...
    BigChangeSHAM_OFF] = f_PSDIRASAchange(BigODOR_ON,BigODOR_IRASA_ON,...
    BigODOR_OFF,BigODOR_IRASA_OFF, BigSHAM_ON,BigSHAM_IRASA_ON,BigSHAM_OFF,...
    BigSHAM_IRASA_OFF, prepdirPW);

%% Average IRASA: Visualization
% cd(prepdirPW);
% 
% % clc
% % clear
% % close all
% 
% % allinfo_change = dir('*Change*.mat');
% % 
% % for j = 1:length(allinfo_change)
% %     load(fullfile(pwd,allinfo_change(j).name))
% % end
% 
% % all_chan = [1:109];
% % frontal_chan = [8, 9, 12, 13, 14, 17, 7, 10, 4, 15, 3];
% % central_chan = [5, 6, 94, 45, 25, 69, 11, 100, 24, 93, 30, 44, 68, 76];
% % 
% % channels = all_chan;
% 
% m=1;
% for i = 1:length(BigODOR_OFF)
%     odor_off  = BigODOR_OFF(i).data.powspctrm;
%     odor2_off = mean(odor_off,1); %average across channels
%     odoravg_off(m,:) = odor2_off;
%     
%     odor_on  = BigODOR_ON(i).data.powspctrm;
%     odor2_on = mean(odor_on,1); %average across channels
%     odoravg_on(m,:) = odor2_on;
%     
%     odor_irasa  = BigODOR_IRASA_ON(i).data.powspctrm;
%     odor2_irasa = mean(odor_irasa,1); %average across channels
%     odoravg_irasa(m,:) = odor2_irasa;
%     
%     sham_off  = BigSHAM_OFF(i).data.powspctrm;
%     sham2_off = mean(sham_off,1); %average across channels
%     shamavg_off(m,:) = sham2_off;
%     
%     sham_on  = BigSHAM_ON(i).data.powspctrm;
%     sham2_on = mean(sham_on,1); %average across channels
%     shamavg_on(m,:) = sham2_on;
%     
%     sham_irasa  = BigSHAM_IRASA(i).data.powspctrm;
%     sham2_irasa = mean(sham_irasa,1); %average across channels
%     shamavg_irasa(m,:) = sham2_irasa;
%     
%     m=m+1;
% end
% 
% freq = 0.1:0.1:20;
% fig_title = 'Cue with IRASA';
% xMeassure = 'Frequency [Hz]';
% yMeassure = 'PSD / Fractal Component';
% condition1 = 'Cue On';
% condition2 = 'IRASA';
% data1 = odoravg_on;
% data2 = odoravg_irasa;
% x_axis = freq;
% color = '-r';
% y_axis = [0 1000];
% 
% figure; plot(freq, mean(odoravg_irasa), ...
%     'linewidth', 3, 'color', [0 0 0])
% hold on; plot(freq, mean(odoravg_on), ...
%     'linewidth', 3, 'color', [1 0 0])
% hold on; plot(freq, mean(odoravg_off), ...
%     'linewidth', 3, 'color', [0 1 0])
% % hold on; plot(orig.freq, mean(orig.powspctrm), ...
% %   'linewidth', 3, 'color', [.6 .6 .6])
% % hold on; plot(osci.freq, mean(osci.powspctrm), ...
% %   'linewidth', 3, 'color', [1 0 0])
% set(gca, 'xscale','log', 'yscale', 'log')
% legend('Fractal component', 'Cue On', 'Cue Off');
% xlabel('log (Frequency [Hz])'); ylabel('log (PSD)');
% saveas(gcf,'IRASA_loglog.jpg');

%% Changes from Fractal Component: Calculate averages for selected subjects and channels
% cd(prepdirPW);

clc
clear
close all

night = 'Cue'; % Cue or Placebo
allinfo_change = dir('*Change*.mat');

for j = 1:length(allinfo_change)
    load(fullfile(pwd,allinfo_change(j).name))
end

%Subjects with only fast or slow and fast spindle bands or all
fast_subj = [7 9 11 13 15 16 17 18 19 20 21 22];
slow_subj = [1 2 3 4 5 6 8 10 12 14 23];
all_subj  = 1:23;

all_chan = [1:109];
frontal_chan = [8, 9, 12, 13, 14, 17, 7, 10, 4, 15, 3];
central_chan = [5, 6, 94, 45, 25, 69, 11, 100, 24, 93, 30, 44, 68, 76];

subjects = slow_subj;
channels = central_chan;

[odoravg_on, odoravg_off, shamavg_on, shamavg_off] = f_changesavg(...
    BigChangeODOR_ON,BigChangeODOR_OFF, BigChangeSHAM_ON, BigChangeSHAM_OFF,subjects,channels);

% figure;
% [~,edges] = histcounts(log10(hist_odoron), 10);
% histogram(hist_odoron,10.^edges)
% set(gca, 'xscale','log')
% line('XData',[1.67 1.67],'YData',[0 4], 'LineStyle','--', 'LineWidth', 1);
% xlabel('Fast/Slow spindles'); ylabel('Counts');
% saveas(gcf,strcat('fastoverslow_hist_odoron.jpg'));

%% Changes from Fractal Component: Visualization

freq = 0.1:0.1:40;
if isequal(subjects,all_subj)
    fig_title1 = 'All subjects';
elseif isequal(subjects,fast_subj)
    fig_title1 = 'Subjects with only fast spindles';
elseif isequal(subjects,slow_subj)
    fig_title1 = 'Subjects with slow and fast spindles';
end
if isequal(channels,all_chan)
    fig_title2 = 'All channels';
elseif isequal(channels,frontal_chan)
    fig_title2 = 'Frontal channels';
elseif isequal(channels,central_chan)
    fig_title2 = 'Central channels';
end
fig_title = strcat(fig_title1,' - ', fig_title2);
xMeassure = 'Frequency [Hz]';
yMeassure = 'PSD / Fractal Component';
condition1 = strcat(night,' On');
condition2 = strcat(night,' Off');
data1 = odoravg_on;
data2 = odoravg_off;
x_axis = freq;
if strcmp(night, 'Cue')
    color = '-r';
elseif strcmp(night, 'Placebo')
    color = '-b';
end
y_axis = [0 9];
dash_line = 1;

if isequal(subjects,all_subj)
    subj = 'all';
elseif isequal(subjects,fast_subj)
    subj = 'fast';
elseif isequal(subjects,slow_subj)
    subj = 'slow';
end
if isequal(channels,all_chan)
    chan = 'allchan';
elseif isequal(channels,frontal_chan)
    chan = 'fronchan';
elseif isequal(channels,central_chan)
    chan = 'centchan';
end
f_plotmeanSD(fig_title,xMeassure,yMeassure,condition1,condition2,data1,data2,x_axis,color, y_axis, dash_line)
saveas(gcf,strcat('PSDoverFractal_',subj,'_',chan,'_',night,'ONvs',night,'OFF.jpg'));

% figure; plot(freq, mean(odoravg_on), ...
%     'linewidth', 3, 'color', [1 0 0])
% hold on; plot(freq, mean(odoravg_off), ...
%     'linewidth', 3, 'color', [0 0 0])
% 
% % hold on; plot(freq, mean(shamavg_on), ...
% %     'linewidth', 3, 'color', [0 0 0])
% % hold on; plot(freq, mean(shamavg_off), ...
% %     'linewidth', 3, 'color', [0.6 0.6 0.6])
% 
% hold on; plot(freq, odoravg_on, ...
%     'linewidth', 0.1, 'linestyle', ':', 'color', [1 0 0])
% hold on; plot(freq, odoravg_off, ...
%     'linewidth', 0.1, 'linestyle', ':', 'color', [0 0 0])
% 
% % hold on; plot(freq, shamavg_on, ...
% %     'linewidth', 0.1, 'linestyle', ':', 'color', [0 0 0])
% % hold on; plot(freq, shamavg_off, ...
% %     'linewidth', 0.1, 'linestyle', ':', 'color', [0.6 0.6 0.6])
% legend('Cue ON', 'Cue OFF') %, 'Sham ON', 'Sham OFF');
% xlabel(xMeassure); ylabel(yMeassure);
% saveas(gcf,'PSD_slowsubjects_odorONvsodorOFF.jpg');
