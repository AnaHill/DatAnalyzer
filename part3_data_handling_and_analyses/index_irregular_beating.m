function [irregular_beating_table] = index_irregular_beating...
    (DataInfo,Data_BPM_summary, irregular_limit, filenumbers, datacolumns)
% function [irregular_beating_table] = index_irregular_beating...
%     (DataInfo,Data_BPM_summary, irregular_limit, filenumbers, datacolumns)


narginchk(0,5) 
nargoutchk(0,1)

if nargin < 1 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end
if nargin < 2 || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base','Data_BPM_summary');
    catch
        error('No proper Data_BPM_summary')
    end
end
if nargin < 3 || isempty(irregular_limit)
    irregular_limit = 0.1; % default 10% change
end
if nargin < 4 || isempty(filenumbers)
    filenumbers =  (1:DataInfo.files_amount)';
end
if nargin < 5 ||  isempty(datacolumns)
    datacolumns =  1:length(DataInfo.datacol_numbers);
end 

irregular_beating_indexes = [];
disp(['Finding irregulaties: irregular limit set to',10,...
    num2str(irregular_limit*100),'% of average peak distance'])
for pp = 1:length(filenumbers)
    index_file = filenumbers(pp);
    for kk = 1:length(datacolumns)
        index_col = datacolumns(kk);
        % modification 2021/08
        pd = Data_BPM_summary.peak_distances{index_file,index_col};
%         pd = Data_BPM_summary.peak_distances{index_file}(:,index_col);% peak distances
        
        pavg = Data_BPM_summary.peak_distances_avg(index_file, index_col);
        pupp = pavg*(1+irregular_limit);
        pdown = pavg*(1-irregular_limit);       
        if ~isempty(find(pd > pupp)) || ~isempty(find(pd < pdown))
            ind_out_range = [];
            if ~isempty(find(pd > pupp,1)) 
                ind_out_u = find(pd > pupp);
                ind_out_u = ind_out_u(:).';
                ind_out_range = [ind_out_range ind_out_u];
            end
            if ~isempty(find(pd < pdown,1))
                ind_out_d =  find(pd < pdown);
                ind_out_d = ind_out_d(:).';
                ind_out_range = [ind_out_range ind_out_d];
            end            
            ind_out_range = unique(ind_out_range);
            for zz = 1:length(ind_out_range)
                index_dis_number = ind_out_range(zz);
                % modifation 2021/08: now value_to_avg 
                try
                    value_to_avg = pd(index_dis_number)/pavg;
                catch
                   error('error happened') 
                end
                % value_to_avg = pd(index_dis_number)/pavg - 1;
                
                % as distance calculated with diff --> index 1 is between
                % peak 1&2 --> 
                index_peak_number = index_dis_number + 1; 
                irregular_beating_indexes(end+1,:) = ...
                    [index_file, index_col, index_peak_number, value_to_avg];    
            end
            fprintf(['File#',num2str(index_file),'/',num2str(length(filenumbers))])
            fprintf([': irregularity in ',...
                num2str(irregular_beating_indexes(end,:)),'\n'])
        else
            % fprintf(': no irregularity \n')
        end

        clear ind_out_u ind_out_d ind_out_range value_to_avg
        
        
% % %         if ~isempty(find(pd > pupp)) || ~isempty(find(pd < pdown))
% % %             ind_out_range = [];
% % %         end
% % %         if ~isempty(find(pd > pupp,1)) 
% % %             ind_out_u = find(pd > pupp);
% % %             ind_out_u = ind_out_u(:).';
% % %             ind_out_range = [ind_out_range ind_out_u];
% % %         end
% % %         if ~isempty(find(pd < pdown,1))
% % %             ind_out_d =  find(pd < pdown);
% % %             ind_out_d = ind_out_d(:).';
% % %             ind_out_range = [ind_out_range ind_out_d];
% % %         end
% % %         if ~isempty(find(pd > pupp)) || ~isempty(find(pd < pdown))
% % %             ind_out_range = unique(ind_out_range);
% % %             for zz = 1:length(ind_out_range)
% % %                 index_dis_number = ind_out_range(zz);
% % %                 value_to_avg = pd(index_dis_number)/pavg - 1;
% % %                 % as distance calculated with diff --> index 1 is between
% % %                 % peak 1&2 --> 
% % %                 index_peak_number = index_dis_number + 1; 
% % %                 irregular_beating_indexes(end+1,:) = ...
% % %                     [index_file, index_col, index_peak_number, value_to_avg];    
% % %             end
% % %             fprintf(['File#',num2str(index_file),'/',num2str(length(filenumbers))])
% % %             fprintf([': irregularity in ',...
% % %                 num2str(irregular_beating_indexes(end,:)),'\n'])
% % %         else
% % %             % fprintf(': no irregularity \n')
% % %         end
% % %         clear ind_out_u ind_out_d ind_out_range value_to_avg
    end
    
end
if isempty(irregular_beating_indexes)
    disp('No irregular beating found with given irregular beating limit')
    irregular_beating_table = [];
else
    irregular_beating_table = array2table(irregular_beating_indexes,...
        'VariableNames',{'File_index','DataColumn_index','Peaknumber','Value_to_avg'});
    disp('Irregularities found')
    %irregu_file_index = unique(Data_BPM_summary.irregular_beating_table.File_index) %(rows))
%     disp(num2str(irregular_beating_indexes))
%     disp('%%%%')
    disp(irregular_beating_table)
end

% try
%     rows = find(irregular_beating_table.DataColumn_index == col);
%     irregu_file_index = unique(Data_BPM_summary.irregular_beating_table.File_index(rows));
% catch
%     irregu_file_index = [];
% end
% disp(['%%%%%%%%%%%%%',10,'When irregularity level is ', ...
%     num2str(DataInfo.irregular_beating_limit*100) ,'% from average: ',10, ...
%     'Irregular beating(s) in ', num2str(length(irregu_file_index)),' / ',...
%     num2str(DataInfo.files_amount)])

end