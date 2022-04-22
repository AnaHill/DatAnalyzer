function [Data_BPM] = run_peak_find_with_Rule(Data, DataInfo, Data_BPM,...
    Rule,filenumbers, datacolumns, data_multiply, plotting_results)
% function [Data_BPM] = run_peak_find_with_Rule...
% (Data,DataInfo, Data_BPM, Rule,filenumbers, datacolumns, data_multiply, plotting_results)
narginchk(3,8) 
nargoutchk(0,1)

% set defaults if not all function inputs are given
if nargin < 4 || isempty(Rule)
    disp('Check if DataInfo has rules, ask to used them or not')
    use_datainfo_rule = 0;
    if isfield(DataInfo, 'Rule')
        disp('TODO: ask if using rules found in DataInfo')
        % if yes
        use_datainfo_rule = 1;    
    end
    if use_datainfo_rule == 1
        Rule = DataInfo.Rule;
    else
        disp('TODO: set rules if not defined')
        disp('TODO: ask if default or user input rules are used')
        % if default chosen
        use_default_rules=1;
        if use_default_rules == 1         % set default values    
            disp('Now default rules')
            DataInfo.Rule = set_default_filetype_rules_for_peak_finding;
            Rule = DataInfo.Rule;
        end
    end
end
% Ask filenumbers  
if nargin < 5 || isempty(filenumbers)
    disp(['Total files: ',num2str(DataInfo.files_amount)])  
    filenumbers =  input('Please input filenumbers, give them inside []:');
%   filenumbers =  [1:DataInfo.files_amount]';
end
if nargin < 6 ||  isempty(datacolumns)
    disp(['Total data columns: ',num2str(length(Data{filenumbers(1),1}.data(1,:)))])  
    datacolumns =  input('Please input datacolumns, give them inside []:');
    % datacolumns =  1:length(Data{filenumbers(1),1}.data(1,:));
end    
% setting data_multiply, if 1, high peaks are found
% if -1 -> data will be converted (data * -1), and therefore finding low
% peaks
if nargin < 7 || isempty(data_multiply)
  data_multiply =  1; % 1= high peaks
end    

if nargin <8 || isempty(plotting_results)
    plotting_results = 1;
end

tempBPM = find_peaks_in_loop...
    (Data, DataInfo, Rule, filenumbers,datacolumns,data_multiply);

for pp = 1:length(filenumbers)
    for kk = 1:length(datacolumns)
        col_ind  = datacolumns(kk);
        if isfield(tempBPM{(pp),1},'peak_values_low')
            Data_BPM{filenumbers(pp),1}.peak_values_low(col_ind) = ...
                tempBPM{(pp),1}.peak_values_low(kk);          
        end
        if isfield(tempBPM{(pp),1},'peak_locations_low')
            Data_BPM{filenumbers(pp),1}.peak_locations_low(col_ind) = ...
                tempBPM{pp,1}.peak_locations_low(kk);          
        end    
        if isfield(tempBPM{(pp),1},'peak_widths_low')
            Data_BPM{filenumbers(pp),1}.peak_widths_low(col_ind) = ...
                tempBPM{pp,1}.peak_widths_low(kk);          
        end  
        if isfield(tempBPM{(pp),1},'peak_values_high')
            Data_BPM{filenumbers(pp),1}.peak_values_high(col_ind) = ...
                tempBPM{pp,1}.peak_values_high(kk);          
        end
        if isfield(tempBPM{(pp),1},'peak_locations_high')
            Data_BPM{filenumbers(pp),1}.peak_locations_high(col_ind) = ...
                tempBPM{pp,1}.peak_locations_high(kk);          
        end    
        if isfield(tempBPM{(pp),1},'peak_widths_high')
            Data_BPM{filenumbers(pp),1}.peak_widths_high(col_ind) = ...
                tempBPM{pp,1}.peak_widths_high(kk);          
        end   
            
    end
    if plotting_results == 1
        PLOT_DataWithPeaks(Data,Data_BPM,filenumbers(pp),datacolumns)     
    end
end
if plotting_results ~= 1
    disp('Peaks changed, not plotted')
end

% remove_other_variables_than_needed

