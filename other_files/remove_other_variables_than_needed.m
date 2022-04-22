disp('Clearing other variables than needed')
disp('Keeping following variables: ')
disp(['Data DataInfo Data_BPM Data_BPM_summary ',...
    'Data_o2 DataPeaks DataPeaks_mean DataPeaks_summary'])

clearvars -except ...
    Data DataInfo Data_BPM Data_BPM_summary ...
    Data_o2 DataPeaks DataPeaks_mean DataPeaks_summary

disp('Workspace cleared')
