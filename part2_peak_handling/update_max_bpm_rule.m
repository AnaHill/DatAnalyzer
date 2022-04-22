function [DataInfo] = update_max_bpm_rule(MaxBPM)
% function [DataInfo] = update_max_bpm_rule(MaxBPM)
narginchk(1,1)
nargoutchk(0,1)
DataInfo = evalin('base', 'DataInfo');

disp([10,'%%%%%%%%%%%%%%%%%%%%'])
disp('Updating Max BPM rule for peak finding')
DataInfo.Rule.MaxBPM = MaxBPM;

DataInfo.Rule.MinDist_frames = DataInfo.Rule.FrameRate * 60/DataInfo.Rule.MaxBPM;
DataInfo.Rule.MinDist_sec = DataInfo.Rule.MinDist_frames/DataInfo.Rule.FrameRate;
disp('Rule.MaxBPM, Rule.MinDist_frames and Rule.MinDist_sec updated')
disp(['Max BPM: ',num2str(DataInfo.Rule.MaxBPM) ])
disp(['Min distance (frames): ',num2str(DataInfo.Rule.MinDist_frames) ])
disp(['Min distance (sec): ',num2str(DataInfo.Rule.MinDist_sec),10 ])


