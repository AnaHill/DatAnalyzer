function [] = plot_signal_upside_down(Data,Data_BPM, file_index,datacolumns)
%  plot_signal_upside_down(Data, Data_BPM, file_index,datacolumns)
%  plot_signal_upside_down(Data, Data_BPM, [1:25:110 120],[1:3])
%  plot_signal_upside_down(Data, [], [1:25:110 120],[1,3])

narginchk(1,4)
nargoutchk(0,0)
if nargin < 2 || isempty(Data_BPM)
    using_bpm = 0;
else
    using_bpm = 1;
end
if nargin < 3 || isempty(file_index)
    file_index = randi([1 length(Data)],1); 
end

if nargin < 4 || isempty(datacolumns)
    datacolumns = 1:length(Data{file_index(1),1}.data(1,:));
end
file_index = unique(sort(file_index));
datacolumns = unique(sort(datacolumns));
DataInfo=evalin('base','DataInfo');

%%% fig parameters
[fig_parameters] = cal_subfig_parameters(datacolumns);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
new_fig_number  = fig_parameters(3);
hfigs = []; 
for pp=1:length(file_index)
    filenum = file_index(pp);
    fig_full;
    hfigs(end+1,1) = hfig;
    try
        fs = DataInfo.framerate(filenum,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end    
    ts = 1/fs;   
    for zz = 1:length(datacolumns) 
        col_ind = datacolumns(zz);
        subplot(sub_fig_rows,sub_fig_cols,zz) 
        % INVERTING DATA
        dat = Data{filenum,1}.data(:,col_ind) * -1;
        time = 0:ts:(length(dat)-1)*ts;
        plot(time, dat), hold all, 
        sqtitle_text = ['Datafile#', num2str(file_index),', t=',...
            num2str(round(DataInfo.measurement_time.time_sec(filenum, 1)/3600,1)),...
            'h',10,DataInfo.file_names{filenum, 1}];
        sgtitle(sqtitle_text,'interpreter','none','fontsize',12)
        if using_bpm ~= 0
            title_text_high_peaks = ['High / low peaks: ',...
                num2str(length(Data_BPM{filenum,1}.peak_values_high{col_ind}))]; 
        end
        try 
            if isfield(DataInfo,'MEA_electrode_numbers')
                title_general_start = ['Electrode#',...
                    num2str(DataInfo.MEA_electrode_numbers(col_ind))];
            else
                title_general_start = ['Col#',...
                    num2str(DataInfo.datacol_numbers(col_ind))];
            end
        catch   % older
            try % mea
                title_general_start = ['Electrode#',...
                    num2str(Data{file_index,1}.MEA_electrode_numbers(col_ind))];
            catch % non-mea or old data
                try
                    title_general_start = ['Col#',...
                        num2str(Data{file_index,1}.datacolumns(col_ind))];
                catch % vanhat datat
                    title_general_start = ['Electrode#',...
                        num2str(Data{file_index,1}.data_MEA_electrode_number(col_ind))];
                end
            end
        end
        if using_bpm ~= 0
            title_general = [title_general_start,10,title_text_high_peaks];
        else
            title_general = [title_general_start];
        end
        if using_bpm ~= 0
            try
                ph = length(Data_BPM{filenum,1}.peak_values_high{col_ind,1});
            catch
                ph = 0;
            end
            try
                pl = length(Data_BPM{filenum,1}.peak_values_low{col_ind,1});
            catch
                pl = 0;
            end
            max_peak_number = max(ph,pl);          
            title_full = [title_general_start,10, ' Max Peaks:  ',...
                num2str(max_peak_number)];
        else
            title_full = [title_general_start];
        end
        title(title_full)
        axis tight
        clear title_full
    end

end

for kk=length(hfigs):-1:1
    figure(hfigs(kk,1))
end

end