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
rootdir = 'C:\Users\rreis\OneDrive\Documentos\Ranga Lab\Sleep Study\DataGermany\EEGLABfiltered_Off_On_200Hz\NREM'; %Folder with .set and .fdt
datadir = 'C:\Users\rreis\OneDrive\Documentos\Ranga Lab\Sleep Study\Fieldtrip_study';
prepdir = fullfile(datadir,'filtered_Off_On_200Hz\NREM'); %Folder where the data will be saved
mkdir(prepdir)

%% Creat list with .set to use
cd(rootdir);
allinfo = dir('*.set'); %for OFF-ON '*ON.set' epoched data

%% Run and plot IRASA
cd(prepdir);
eeglab nogui

% n2 = 1;

spindle_max = [];
for n = 20 %1:length(allinfo)
    %% Convert to Fieldtrip
    EEG             = pop_loadset('filename',allinfo(n).name,'filepath',rootdir); %Load epoched OFF-ON data
    subject = allinfo(n).name(1:6);

    EEG1 = eeglab2fieldtrip(EEG,'preprocessing','none');

%% IRASA for spindle band detection

	spec_freq = [1 40]; % let's not ask the user (to make sure the spindle range is included in this range)
	
    % Cut into small segments (improves and smoothens spectral estimates)
	cfg_tmp						= [];
	cfg_tmp.length				= 4;  % cut data into segments of this length (in sec)
	cfg_tmp.overlap				= 0;  % with this overlap
	EEG1				    	= ft_redefinetrial(cfg_tmp, EEG1);
	
	% Calculate spectra
	cfg_tmp						= [];
	cfg_tmp.foi					= spec_freq(1):0.05:spec_freq(2);
	cfg_tmp.method				= 'irasa';
	cfg_tmp.pad					= 'nextpow2';
	fra_nrem					= ft_freqanalysis(cfg_tmp, EEG1);
	
	cfg_tmp.method 				= 'mtmfft';
	cfg_tmp.taper 				= 'hanning';
	mix_nrem					= ft_freqanalysis(cfg_tmp, EEG1);

	% Calculate the oscillatory component by subtracting the fractal from the
	% mixed component
	cfg_tmp						= [];
	cfg_tmp.parameter			= 'powspctrm';
	cfg_tmp.operation			= 'subtract';
	osc_nrem					= ft_math(cfg_tmp, mix_nrem, fra_nrem);
	
	% Use percent change for even more obvious peaks
	cfg_tmp.operation			= 'divide';
	rel_nrem					= ft_math(cfg_tmp, osc_nrem, fra_nrem);
	
	output.spectrum.fra_nrem	= fra_nrem.powspctrm;
	output.spectrum.mix_nrem	= mix_nrem.powspctrm;
	output.spectrum.osc_nrem	= osc_nrem.powspctrm;
	output.spectrum.rel_nrem	= rel_nrem.powspctrm;
	output.spectrum.freq		= fra_nrem.freq; % add frequency vector
	
    %% PSD figures
    figure
    subplot(3,1,1)
    plot(output.spectrum.freq, output.spectrum.fra_nrem(1,:)), hold on
    plot(output.spectrum.freq, output.spectrum.mix_nrem(1,:))
    title('Original and Fractal component');
    xlabel('Frequency [Hz]');
    ylabel('PSD');
    subplot(3,1,2)
    plot(output.spectrum.freq, output.spectrum.osc_nrem(1,:))
    title('Oscillatory component')
    xlabel('Frequency [Hz]');
    ylabel('PSD');
    subplot(3,1,3)
    plot(output.spectrum.freq, output.spectrum.rel_nrem(1,:))
    title('Relative meassure');
    xlabel('Frequency [Hz]');
    ylabel('Oscillatory/Fractal components');
    sgtitle(strcat('Subject ', subject(4:6)));
    saveas(gcf,strcat(subject,'_PSDs.jpg'));
    
    %% Spindle band detection
    
    all_chan = [1:109];
    frontal_chan = [8, 9, 12, 13, 14, 17, 7, 10, 4, 15, 3];
    central_chan = [5, 6, 94, 45, 25, 69, 11, 100, 24, 93, 30, 44, 68, 76];
      
    fig_title = strcat('Subject ',subject(4:6));
    xMeassure = 'Frequency [Hz]';
    yMeassure = 'Oscillatory / Fractal Component';
    condition1 = 'Frontal Channels';
    condition2 = 'Central Channels';
    data1 = output.spectrum.rel_nrem(frontal_chan, 1:150);
    data2 = output.spectrum.rel_nrem(central_chan, 1:150);
    data1_avg = mean(data1(:,37:57)); % 8.01-11.91 Hz
    data2_avg = mean(data2(:,58:78)); % 12.11-16.02 Hz
    [~,max_slow]=max(data1_avg);
    max_slow = max_slow+36;
    [~,max_fast]=max(data2_avg);
    max_fast = max_fast+57;
    x_axis = output.spectrum.freq(1:150);
    color1 = '-b';
    color2 = '-m';
    dash_line = [];
    
    f_plotmeanSD(fig_title,xMeassure,yMeassure,condition1,condition2,data1,...
        data2,x_axis,color1, color2, dash_line)
    
    y_axis = ylim;
    line('XData',[8 8],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    line('XData',[12 12],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    line('XData',[16 16],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    line('XData',[output.spectrum.freq(max_slow) output.spectrum.freq(max_slow)],...
        'YData',y_axis, 'LineWidth', 1.5, 'color', 'b');
    line('XData',[output.spectrum.freq(max_fast) output.spectrum.freq(max_fast)],...
        'YData',y_axis, 'LineWidth', 1.5, 'color', 'm');
    legend({condition1,condition2});
    allChildren = get(gca, 'Children');                % list of all objects on axes
    displayNames = get(allChildren, 'DisplayName');    % list of all legend display names
    % Remove object associated with "data1" in legend
    delete(allChildren(strcmp(displayNames, 'data1')))
    hold on;
    saveas(gcf,strcat(subject,'_spindlebands.jpg'));
    
    spindle_max(n).slow = output.spectrum.freq(max_slow);
    spindle_max(n).fast = output.spectrum.freq(max_fast);
    
    save(fullfile(prepdir,strcat(subject,'_IRASA.mat')),'output');
    save(fullfile(prepdir,'Max_spindlebands.mat'),'spindle_max');

end

%% Spindle band detection All in one
cd(prepdir)
allinfo_spindle = dir('*IRASA.mat');
load('C:\Users\rreis\OneDrive\Documentos\Ranga Lab\Sleep Study\Max_spindlebands_byEye.mat')
mid_band = spindle_max;
spindle_max = [];
all_chan = [1:109];
% frontal_chan = [8, 9, 12, 13, 14, 17, 7, 10, 4, 15, 3]; %old clusters
% central_chan = [5, 6, 94, 45, 25, 69, 11, 100, 24, 93, 30, 44, 68, 76];
frontal_chan = [2, 3, 7, 8, 9, 12, 13, 14, 15, 17, 18, 19, 109]; %new clusters
central_chan = [5, 6, 11, 23, 24, 25, 29, 30, 35, 44, 45, 68, 69, 76, 82, 92, 93, 94, 99, 100];

figure;
for p = 1:length(allinfo_spindle)
    load(allinfo_spindle(p).name)
    subject = allinfo_spindle(p).name(1:6);
    
    fig_title = strcat('Subject ',subject(4:6));
    xMeassure = 'Frequency [Hz]';
    yMeassure = 'Oscillatory / Fractal Component';
    condition1 = 'Frontal Channels';
    condition2 = 'Central Channels';
    data1 = output.spectrum.rel_nrem(frontal_chan, 1:150);
    data2 = output.spectrum.rel_nrem(central_chan, 1:150);
    data1_avg = mean(data1(:,37:57)); % 8.01-11.91 Hz
    data2_avg = mean(data2(:,58:78)); % 12.11-16.02 Hz
    [~,max_slow]=max(data1_avg);
    max_slow = max_slow+36;
    [~,max_fast]=max(data2_avg);
    max_fast = max_fast+57;
    x_axis = output.spectrum.freq(1:150);
    color1 = '-b';
    color2 = '-m';
    dash_line = [];
    
    display_fig = 'on';   % 'on' or 'off'
    savefig = 0;           % binario 1 = guardar, 0 = no guardar
    % t = 2;                 % COMPARE FREQS (1) OR TASKS (2)
    error = 'SD';         % define error
    x1 = 0; % events line plots in seconds
    
    % view      % pvalue or fdr
    
    %----------------------------------------------------------------------
    Title_roi = fig_title;
    %     figure
    subplot(4,6,p)
    %         f_plotmeanSD(fig_title,xMeassure,yMeassure,condition1,condition2,data1,...
    %         data2,x_axis,color1, color2, dash_line)
    
    %% Load data
    % grupo = [condition1 ' and ' condition2 ' - Mean ' freq ' Z-score - SEM - ROI ' roi ];
    grupo = Title_roi;
    
    
    c1 = data1; % Vector de Condicion 1
    c2 = data2; %Vector de Condicion 2
    
    
    %% Plot configuration
    
    Xt = x_axis;%EjeX; % Time o EjeX
    
    figure1 = grupo;
    % figure%('visible',display_fig,'position', [0, 0, 1000, 500]); hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p1 = shadedErrorBar(Xt,c1,{@mean,@std}, 'lineprops',color1);hold on;
    p2 = shadedErrorBar(Xt,c2,{@mean,@std}, 'lineprops',color2);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xlabel([xMeassure],'FontSize',12,'FontWeight','bold')
    % ylabel([yMeassure],'FontSize',12,'FontWeight','bold')
    %%%%%%%%%%%%%%%%%%%%%%%%%% AXIS SCALE %%%%
    % ylim([y_axis(1) y_axis(2)])
    xlim ([x_axis(1) x_axis(end)])
    
    title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
    h = title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
    P = get(h,'Position');
    %set(h,'Position',[P(1) P(2)+0.1 P(3)])
    
    ax = gca; % current axes
    ax.XTickMode = 'manual';
    ax.TickDirMode = 'manual';
    ax.TickDir = 'in';
    ax.XColor = 'black';
    ax.YColor = 'black';
    set(gca,'LineWidth',1,'Fontsize',10,'clipping', 'on')
    
    if dash_line ==1
        linea = ones(size(x_axis));
        hold on; line('XData',x_axis,'YData',linea, 'LineStyle','--', 'LineWidth', 1);
    elseif dash_line == 0
        linea = zeros(size(x_axis));
        hold on; line('XData',x_axis,'YData',linea, 'LineStyle','--', 'LineWidth', 1);
    end
    box on;
    
    y_axis = ylim;
    %     line('XData',[8 8],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    line('XData',[12 12],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    line('XData',[16 16],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    %     line('XData',[output.spectrum.freq(max_slow) output.spectrum.freq(max_slow)],...
    %         'YData',y_axis, 'LineWidth', 1.5, 'color', 'b');
    %     line('XData',[output.spectrum.freq(max_fast) output.spectrum.freq(max_fast)],...
    %         'YData',y_axis, 'LineWidth', 1.5, 'color', 'm');
    if strcmp(prepdir(end-6:end),'placebo')
        line('XData',[mid_band(p+23).fast-1.5 mid_band(p+23).fast-1.5],...
            'YData',y_axis, 'LineWidth', 1.5, 'color', 'm');
        line('XData',[mid_band(p+23).fast+1.5 mid_band(p+23).fast+1.5],...
            'YData',y_axis, 'LineWidth', 1.5, 'color', 'm');
    else
        line('XData',[mid_band(p).fast-1.5 mid_band(p).fast-1.5],...
            'YData',y_axis, 'LineWidth', 1.5, 'color', 'm');
        line('XData',[mid_band(p).fast+1.5 mid_band(p).fast+1.5],...
            'YData',y_axis, 'LineWidth', 1.5, 'color', 'm');
    end
    %     legend({condition1,condition2});
    %     allChildren = get(gca, 'Children');                % list of all objects on axes
    %     displayNames = get(allChildren, 'DisplayName');    % list of all legend display names
    %     % Remove object associated with "data1" in legend
    %     delete(allChildren(strcmp(displayNames, 'data1')))
    xlim([5 20]);
    xticks([5 10 15 20]);
    hold on;

end
%     sgtitle('Spindle band detection - Oscillatory component');
%     saveas(gcf,strcat('Allsubj_detectedspindlebands_newclusters.jpg'));
    
    %% Spindle band detection: Subject by subject
    cd(prepdir)
    allinfo_spindle = dir('*IRASA.mat');
    spindle_max = [];
    
    for p = length(allinfo_spindle):-1:1
        load(allinfo_spindle(p).name)
        subject = allinfo_spindle(p).name(1:6);
    all_chan = [1:109];
    frontal_chan = [8, 9, 12, 13, 14, 17, 7, 10, 4, 15, 3];
    central_chan = [5, 6, 94, 45, 25, 69, 11, 100, 24, 93, 30, 44, 68, 76];
    
    fig_title = strcat('Subject ',subject(4:6));
    xMeassure = 'Frequency [Hz]';
    yMeassure = 'Oscillatory / Fractal Component';
    condition1 = 'Frontal Channels';
    condition2 = 'Central Channels';

    data1 = output.spectrum.rel_nrem(frontal_chan, 1:150);
    data2 = output.spectrum.rel_nrem(central_chan, 1:150);
    data1_avg = mean(data1(:,37:57)); % 8.01-11.91 Hz
    data2_avg = mean(data2(:,58:78)); % 12.11-16.02 Hz
    [~,max_slow]=max(data1_avg);
    max_slow = max_slow+36;
    [~,max_fast]=max(data2_avg);
    max_fast = max_fast+57;
    x_axis = output.spectrum.freq(1:150);
    color1 = '-b';
    color2 = '-m';
    dash_line = [];
    
    
    display_fig = 'on';   % 'on' or 'off'
    savefig = 0;           % binario 1 = guardar, 0 = no guardar
    % t = 2;                 % COMPARE FREQS (1) OR TASKS (2)
    error = 'SD';         % define error
    x1 = 0; % events line plots in seconds
    
    % view      % pvalue or fdr
    
    %----------------------------------------------------------------------
    Title_roi = fig_title;
    figure;
    %         f_plotmeanSD(fig_title,xMeassure,yMeassure,condition1,condition2,data1,...
    %         data2,x_axis,color1, color2, dash_line)
    
    %% Load data
    % grupo = [condition1 ' and ' condition2 ' - Mean ' freq ' Z-score - SEM - ROI ' roi ];
    grupo = Title_roi;
    
    
    c1 = data1; % Vector de Condicion 1
    c2 = data2; %Vector de Condicion 2
    
    
    %% Plot configuration
    
    Xt = x_axis;%EjeX; % Time o EjeX
    
    figure1 = grupo;
    % figure%('visible',display_fig,'position', [0, 0, 1000, 500]); hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p1 = shadedErrorBar(Xt,c1,{@mean,@std}, 'lineprops',color1);hold on;
    p2 = shadedErrorBar(Xt,c2,{@mean,@std}, 'lineprops',color2);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xlabel([xMeassure],'FontSize',12,'FontWeight','bold')
    % ylabel([yMeassure],'FontSize',12,'FontWeight','bold')
    %%%%%%%%%%%%%%%%%%%%%%%%%% AXIS SCALE %%%%
    % ylim([y_axis(1) y_axis(2)])
    xlim ([x_axis(1) x_axis(end)])
    
    title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
    h = title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
    P = get(h,'Position');
    %set(h,'Position',[P(1) P(2)+0.1 P(3)])
    
    ax = gca; % current axes
    ax.XTickMode = 'manual';
    ax.TickDirMode = 'manual';
    ax.TickDir = 'in';
    ax.XColor = 'black';
    ax.YColor = 'black';
    set(gca,'LineWidth',1,'Fontsize',10,'clipping', 'on')
    
    if dash_line ==1
        linea = ones(size(x_axis));
        hold on; line('XData',x_axis,'YData',linea, 'LineStyle','--', 'LineWidth', 1);
    elseif dash_line == 0
        linea = zeros(size(x_axis));
        hold on; line('XData',x_axis,'YData',linea, 'LineStyle','--', 'LineWidth', 1);
    end
    box on;
    
    y_axis = ylim;
    xlim ([8 16])
    grid on
    xticks([8:0.25:16])
    
    line('XData',[8 8],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    line('XData',[12 12],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    line('XData',[16 16],'YData',y_axis, 'LineWidth', 1, 'LineStyle','--');
    line('XData',[output.spectrum.freq(max_slow) output.spectrum.freq(max_slow)],...
        'YData',y_axis, 'LineWidth', 1.5, 'color', 'b');
    line('XData',[output.spectrum.freq(max_fast) output.spectrum.freq(max_fast)],...
        'YData',y_axis, 'LineWidth', 1.5, 'color', 'm');
    %     legend({condition1,condition2});
%     allChildren = get(gca, 'Children');                % list of all objects on axes
%     displayNames = get(allChildren, 'DisplayName');    % list of all legend display names
%     % Remove object associated with "data1" in legend
%     delete(allChildren(strcmp(displayNames, 'data1')))
    hold on;
%     saveas(gcf,strcat(subject,'_spindlebands.jpg'));

    spindle_max(p).slow = output.spectrum.freq(max_slow);
    spindle_max(p).fast = output.spectrum.freq(max_fast);

    end
    
