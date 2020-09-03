function [change_ON, change_OFF] = f_calcIRASAchange(subject,foldername)
% Calculate percentage change from fractal component

load(strcat(foldername,'\',subject,'IRASA_OFF.mat'));
load(strcat(foldername,'\',subject,'IRASA_ON.mat'));
load(strcat(foldername,'\',subject,'OFF.mat'));
load(strcat(foldername,'\',subject,'ON.mat'));

change_ON  = (orig_on.powspctrm-frac_on.powspctrm)./frac_on.powspctrm+1; %channels x frequencies
%still thinking whether to add 1 at the end or not
change_OFF = (orig_off.powspctrm-frac_off.powspctrm)./frac_off.powspctrm+1;