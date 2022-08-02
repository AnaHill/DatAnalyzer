function [data] = remove_offset(data,DataInfo, ...
    baseline_time_range, baseline_index_start_and_stop,...
    file_index_to_analyze, datacolumns)
% function [data] = remove_offset(Data,DataInfo, ...
%     baseline_time_range, baseline_index_start_and_stop,...
%     file_index_to_analyze, datacolumns)
narginchk(1,6)
nargoutchk(0,1)


% Assuming data in data{file_index,1}.data(:,datacolumns) format
if nargin < 2 || isempty(DataInfo) 
    try
        DataInfo = evalin('base','DataInfo');
    catch
        error('No DataInfo')
    end
end   
% default: every file is analyzed
if nargin < 5 || isempty(file_index_to_analyze) 
    file_index_to_analyze = 1:DataInfo.files_amount;
end

fs = DataInfo.framerate(file_index_to_analyze(1));
% default amount of samples to calculate offset based on fs
if fs > 1e3 && fs <= 1e4
    as_def = 100; 
elseif fs > 1e4
    as_def = 1000; 
else
    as_def = round(fs/10);
end

% default range to calculate offset
% mean of first 100 samples
if (nargin < 3 || isempty(baseline_time_range)) && ...
    (nargin < 4|| isempty(baseline_index_start_and_stop))
    baseline_time_range = [0 as_def/fs]; 
    disp(['Calcuting offset from default settings, mean value from t: ',...
        num2str(baseline_time_range)])
    start_index = baseline_time_range(1)/fs+1;
    baseline_index_start_and_stop = [start_index start_index+as_def];
else
    disp(['Calculating value from time: ', num2str(baseline_time_range)])
    disp(['Indexes from ',num2str(baseline_index_start_and_stop(1)),' to ',...
        num2str(baseline_index_start_and_stop(2))])
end
baseline_time_range = unique(sort(baseline_time_range));
if length(baseline_time_range) < 2 
    def_time = .1;
    baseline_time_range = [baseline_time_range baseline_time_range+def_time];
else
    baseline_time_range = [min(baseline_time_range) max(baseline_time_range)];
end

% start and stop indexes
if nargin < 4 || isempty(baseline_index_start_and_stop)
    start_index = baseline_time_range(1)/fs+1;
    baseline_index_start_and_stop = [start_index start_index+as_def];
end

baseline_index_start_and_stop = unique(sort(baseline_index_start_and_stop));
if length(baseline_index_start_and_stop) < 2 
    baseline_index_start_and_stop = [baseline_index_start_and_stop ...
        baseline_index_start_and_stop+as_def];
else
    baseline_index_start_and_stop = [min(baseline_index_start_and_stop) ...
        max(baseline_index_start_and_stop)];
end


% default: all datacolumns analyzed
if nargin < 6 || isempty(datacolumns) 
    datacolumns = 1:length(DataInfo.datacol_numbers);
end



%% Calculate & remove offset (=mean value between baseline_index_start_and_stop) 
framerates = DataInfo.framerate;
bs = baseline_index_start_and_stop(1);
be = baseline_index_start_and_stop(end);

% initially, will ask if offset is removed even though 
% it would have been already removed earlier
choosing_to_remove_all_offsets_even_already_removed = 0;
do_not_ask_again = 0;

for kk = 1:length(file_index_to_analyze)
    file_index = file_index_to_analyze(kk);
    fs = framerates(file_index);   
	for pp = 1:length(datacolumns)
        col = datacolumns(pp);
        dat = data{file_index,1}.data(:,col);
        
        if choosing_to_remove_all_offsets_even_already_removed ~= 0           
            % if chosen, that remove all offsets, not asking even though
            % offset would have been removed beforehand
            % NOTICE: this might lead "incorrect" offset value, 
            % as new offset will be calculated from removed data
            remove_offset_from_single_data_and_update_Data;    
        
        else % check, abd ask if offset is removed even though it would exists         
            
            % check if Data has already removed_offset field; if does, ask
            try
                data{file_index,1}.removed_offset(col,1);
                if do_not_ask_again == 1
                    % disp('Not removing offset again')
                else
                    % if offset is removed beforehand, ask if remove again
                    promp_text = {'Offset already removed!',['Removed value: ',...
                        num2str(data{file_index,1}.removed_offset(col,1))'.'],...
                        'Remove again?'};
                    option_list = {...
                        'Yes, every time.',...
                        'Yes, this time only.',...
                        'Not this time.',...
                        'Never (and do not ask again).'}; 
                    [idx, tf] = listdlg('PromptString',promp_text,...
                        'ListString', option_list,'SelectionMode', 'Single', ...
                        'Initialvalue', 1,'ListSize',[300 100], ...
                        'Name', 'Removing offset');
                    if tf
                        choice_remove_offset_again = option_list{idx}; 
                    else
                        return % user canceled or closed dialog
                    end
                    switch choice_remove_offset_again
                        case 'Yes, every time.'
                            % not asking anymore; update variable
                            choosing_to_remove_all_offsets_even_already_removed = 1;
                            remove_offset_from_single_data_and_update_Data;
                        case 'Yes, this time only.'
                            % only remove this time and ask again
                            remove_offset_from_single_data_and_update_Data;
                        case  'Not this time.'
                            disp('Not removing offset this time.')
                        otherwise
                            do_not_ask_again = 1;
                            disp('Not removing any offset again.')
                    end           
                end
            % if no offset removed beforehand, remove it    
            catch 
                remove_offset_from_single_data_and_update_Data;
            end 
        
        end
        
    end
    
end

end
