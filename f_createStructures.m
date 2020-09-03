function [BigODOR_ON, BigODOR_IRASA_ON, BigODOR_OFF, BigODOR_IRASA_OFF,...
    BigSHAM_ON, BigSHAM_IRASA_ON, BigSHAM_OFF, BigSHAM_IRASA_OFF]...
    = f_createStructures(allinfo_odor_ON, allinfo_odor_OFF, allinfo_sham_ON, allinfo_sham_OFF, prepdirPW)

%Odor ON
for h = 1:length(allinfo_odor_ON)
    load(fullfile(pwd,allinfo_odor_ON(h).name))
    BigODOR_ON(h).data = orig_on;
    save(fullfile(prepdirPW,strcat('BigODOR_ON')),'BigODOR_ON');
    
    load(fullfile(pwd,strcat(allinfo_odor_ON(h).name(1:end-6),'IRASA_ON.mat')))
    BigODOR_IRASA_ON(h).data = frac_on;
    save(fullfile(prepdirPW,strcat('BigODOR_IRASA_ON')),'BigODOR_IRASA_ON');
    
end

%Odor OFF
for h = 1:length(allinfo_odor_OFF)
    load(fullfile(pwd,allinfo_odor_OFF(h).name))
    BigODOR_OFF(h).data = orig_off;
    save(fullfile(prepdirPW,strcat('BigODOR_OFF')),'BigODOR_OFF');
    
    load(fullfile(pwd,strcat(allinfo_odor_OFF(h).name(1:end-7),'IRASA_OFF.mat')))
    BigODOR_IRASA_OFF(h).data = frac_off;
    save(fullfile(prepdirPW,strcat('BigODOR_IRASA_OFF')),'BigODOR_IRASA_OFF');
    
end

%Sham ON
for h = 1:length(allinfo_sham_ON)
    load(fullfile(pwd,allinfo_sham_ON(h).name))
    BigSHAM_ON(h).data = orig_on;
    save(fullfile(prepdirPW,strcat('BigSHAM_ON')),'BigSHAM_ON');
    
    load(fullfile(pwd,strcat(allinfo_sham_ON(h).name(1:end-6),'IRASA_ON.mat')))
    BigSHAM_IRASA_ON(h).data = frac_on;
    save(fullfile(prepdirPW,strcat('BigSHAM_IRASA_ON')),'BigSHAM_IRASA_ON');
    
end

%Sham OFF
for h = 1:length(allinfo_sham_OFF)
    load(fullfile(pwd,allinfo_sham_OFF(h).name))
    BigSHAM_OFF(h).data = orig_off;
    save(fullfile(prepdirPW,strcat('BigSHAM_OFF')),'BigSHAM_OFF');
    
    load(fullfile(pwd,strcat(allinfo_sham_OFF(h).name(1:end-7),'IRASA_OFF.mat')))
    BigSHAM_IRASA_OFF(h).data = frac_off;
    save(fullfile(prepdirPW,strcat('BigSHAM_IRASA_OFF')),'BigSHAM_IRASA_OFF');
    
end