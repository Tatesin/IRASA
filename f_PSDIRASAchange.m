function [BigChangeODOR_ON, BigChangeODOR_OFF, BigChangeSHAM_ON, ...
    BigChangeSHAM_OFF] = f_PSDIRASAchange(BigODOR_ON,BigODOR_IRASA_ON,...
    BigODOR_OFF,BigODOR_IRASA_OFF, BigSHAM_ON,BigSHAM_IRASA_ON,BigSHAM_OFF,BigSHAM_IRASA_OFF, prepdirPW)
% Calculate percentage change from fractal component
% Gives a structure for each condition, with one structure by subject with
% channels x frequencies

BigChangeODOR_ON = [];
BigChangeODOR_OFF = [];
for i = 1:length(BigODOR_ON)
    BigChangeODOR_ON(i).data  = (BigODOR_ON(i).data.powspctrm-...
        BigODOR_IRASA_ON(i).data.powspctrm)./BigODOR_IRASA_ON(i).data.powspctrm+1;
    BigChangeODOR_OFF(i).data = (BigODOR_OFF(i).data.powspctrm-...
        BigODOR_IRASA_OFF(i).data.powspctrm)./BigODOR_IRASA_OFF(i).data.powspctrm+1;
end
save(fullfile(prepdirPW,'BigChangeODOR_ON'),'BigChangeODOR_ON');
save(fullfile(prepdirPW,'BigChangeODOR_OFF'),'BigChangeODOR_OFF');

BigChangeSHAM_ON = [];
BigChangeSHAM_OFF = [];
for i = 1:length(BigSHAM_ON)
    BigChangeSHAM_ON(i).data  = (BigSHAM_ON(i).data.powspctrm-...
        BigSHAM_IRASA_ON(i).data.powspctrm)./BigSHAM_IRASA_ON(i).data.powspctrm+1;
    BigChangeSHAM_OFF(i).data = (BigSHAM_OFF(i).data.powspctrm-...
        BigSHAM_IRASA_OFF(i).data.powspctrm)./BigSHAM_IRASA_OFF(i).data.powspctrm+1;
end
save(fullfile(prepdirPW,'BigChangeSHAM_ON'),'BigChangeSHAM_ON');
save(fullfile(prepdirPW,'BigChangeSHAM_OFF'),'BigChangeSHAM_OFF');