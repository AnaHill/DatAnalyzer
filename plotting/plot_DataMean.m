function [] = plot_DataMean(DataMean, DataInfo, file_to_plot, datacolumns, zooming)
narginchk(1,5)
nargoutchk(0,0)

if nargin < 2 || isempty(DataInfo)
    DataInfo = evalin('base','DataInfo');
end
% default: all
if nargin < 3 || isempty(file_to_plot)
    file_to_plot = 1:length(DataMean);
end
% default: all (or first?) data column
if nargin < 4 || isempty(datacolumns)
%     datacolumns = 1; % first
    datacolumns = 1:length(DataMean{file_to_plot(1),1}.data(1,:));
end
% default: not zooming
if nargin < 5 || isempty(zooming)
    zooming = 0;
end

legs=[];
fig_full
for kk = 1:length(file_to_plot)
    pp=file_to_plot(kk);
    dat = DataMean{pp,1}.data(:,datacolumns);
    fs = DataInfo.framerate(pp);
    time = 0:1/fs:(length(dat)-1)/fs;
    % time = 0:1/DataMean{pp,1}.framerate:(length(dat)-1)/DataMean{pp, 1}.framerate;
    plot(time, dat)
    hold all
    try
        legs{end+1,1} = DataInfo.hypoxia.names{pp,1};
    catch
        try
            legs{end+1,1} = DataInfo.measurement_time.names{pp,1};
        catch
            legs{end+1,1} = DataMean{pp,1}.filename;
        end
    end
end
axis tight
if all(zooming == 0)
    % do not zoom
    
else
   xlim([zooming]) 
end
    

if length(legs) < 21
    legend(legs, 'interpreter','none','location','best')
else
    choice_incl_leg = questdlg(['Include legend as there are ',...
        num2str(length(legs)),'signals (long list in legend)?'],...
    'Include legend', 'Yes','No','Yes');
    switch choice_incl_leg
        case 'Yes'
            legend(legs, 'interpreter','none','location','best')
    end
    
    
end
