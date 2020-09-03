function [odoravg_on, odoravg_off, shamavg_on, shamavg_off] = f_changesavg(...
    BigChangeODOR_ON,BigChangeODOR_OFF, BigChangeSHAM_ON, BigChangeSHAM_OFF,subjects,channels)
%Calculate the average of the changes from de fractal component over
%selected channels

m =1;
% hist_odoron= [];
for i = subjects
    odor_on  = BigChangeODOR_ON(i).data(channels,:);
    odor2_on = mean(odor_on,1); %average across selected channels
    odoravg_on(m,:) = odor2_on;
%     slow_odoron = mean(odor2_on(95:105));
%     fast_odoron = mean(odor2_on(130:140));
%     hist_odoron(i) = fast_odoron/slow_odoron;

    odor_off  = BigChangeODOR_OFF(i).data(channels,:);
    odor2_off = mean(odor_off,1); %average across selected channels
    odoravg_off(m,:) = odor2_off;
    %     slow_odoroff = mean(odor2_off(95:105));
    %     fast_odoroff = mean(odor2_off(130:140));
    %     hist_odoroff(i) = fast_odoroff/slow_odoroff;
    
    sham_on  = BigChangeSHAM_ON(i).data(channels,:);
    sham2_on = mean(sham_on,1); %average across selected channels
    shamavg_on(m,:) = sham2_on;
    
    sham_off  = BigChangeSHAM_OFF(i).data(channels,:);
    sham2_off = mean(sham_off,1); %average across selected channels
    shamavg_off(m,:) = sham2_off;
    
%     dif_odoron_odoroff(m,:) = odor2_on-odor2_off;
%     dif_odoron_shamon(m,:)  = odor2_on-sham2_off;
    m=m+1;
end