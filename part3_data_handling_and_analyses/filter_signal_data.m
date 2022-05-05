function [Data_filtered] = filter_signal_data(file_indexes, ... % compulsory
    Data, datacolumns, filter_window_sizes)
% function [Data_filtered] = filter_signal_data(file_indexes, Data, datacolumns, filter_window_sizes)
% ORG: function [Data_filtered] = filter_signal_data(Data, file_indexes,datacolumns, filter_window_sizes)
narginchk(1,4)
nargoutchk(0,1)

if nargin < 2 || isempty(Data)
    try
        Data = evalin('base','Data');
    catch
        error('No proper Data')
    end
end

try
    DataInfo = evalin('base', 'DataInfo');
catch
    error('No proper DataInfo')
end

% If not given, filtering all data columns (e.g. electrodes)
if nargin < 3 || isempty(datacolumns)
   try
       datacolumns =  1:length(DataInfo.datacol_numbers);
   catch
       error('no prober Data Information found')
   end
end    

% default: set default filtering methods if not given
if nargin < 4 || isempty(filter_window_sizes)
    % order of the first filter: moving median, for antipeaks
    n_order1 = 30; % ymed1 = medfilt1(rawdata,n_order1); 
    % second, moving mean filter for filtered signal, for flat peaks
    n_order_filt = 100; % ymed1_fil = smoothdata(ymed1,'movmean',n_order_filt);
else %TODO: paremmin, jos käyttäisi muita filtteritä
    if length(filter_window_sizes) == 2
        n_order1 = filter_window_sizes(1);
        n_order_filt = filter_window_sizes(2);        
    elseif length(filter_window_sizes) == 1
        n_order1 = filter_window_sizes;
        n_order_filt = 100;
    else
       error('Filter info not correct.') 
    end
end

%%
disp(['Filtering signal'])
% Data_filtered = Data{file_indexes,1};
for pp = 1:length(file_indexes)
    ind = file_indexes(pp);
    try
        fs = DataInfo.framerate(ind,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end
    Data_filtered{pp,1}.file_index = ind;
    try 
        Data_filtered{pp,1}.MEA_electrode_numbers = ...
            DataInfo.MEA_electrode_numbers(datacolumns);
    catch
        disp('No electrode number')
    end
    Data_filtered{pp,1}.yf_median_filter_order = n_order1;
    Data_filtered{pp,1}.yff_mov_mean_filter_order = n_order_filt;   
    Data_filtered{pp,1}.fs = fs;
    Data_filtered{pp,1}.filename = DataInfo.file_names{ind};
    Data_filtered{pp,1}.experiment_name = DataInfo.experiment_name;
    Data_filtered{pp,1}.measurement_time.time_sec = DataInfo.measurement_time.time_sec(ind);
    for kk = 1:length(datacolumns)
        col = datacolumns(kk);
        % filter raw data
        rawdata = Data{ind,1}.data(:,col);
        t = 0:1/fs:(length(rawdata)-1)/fs;
        t=t';
        ymed1 = medfilt1(rawdata,n_order1); 
        % figure, plot(t, [rawdata ymed1])
%         n_order_filt = 100;
        ymed1_filtered = smoothdata(ymed1,'movmean',n_order_filt);  
        % figure, plot(t, [rawdata ymed1 ymed1_filtered])
        
        % get derivative of filters
        % this is the "finite difference" derivative. 
        % Note it is  one element shorter than y and x
        ydiff1=diff(ymed1);
        ydiff2=diff(ymed1_filtered);
        tdiff=diff(t);
        % this is to assign yd an midway between two subsequent x
        td = (t(2:end)+t(1:(end-1)))/2;
        for hh = 1:length(tdiff)
            ymed1_der(hh,1) = ydiff1(hh) ./ tdiff(hh); %; diff(ymed1) ./diff(t);
            ymed1_fil_der(hh,1) = ydiff2(hh)./tdiff(hh);
        end
        Data_filtered{pp,1}.y(:,kk) = rawdata;
        Data_filtered{pp,1}.yf(:,kk) = ymed1;
        Data_filtered{pp,1}.yff(:,kk) = ymed1_filtered;
%         array2table([Data_filtered{1, 1}.yf Data_filtered{1, 1}.yff]);
        % derivatives
        Data_filtered{pp,1}.dyf(:,kk) = ymed1_der;
        Data_filtered{pp,1}.dyff(:,kk) = ymed1_fil_der;
        Data_filtered{pp,1}.time_derivative(:,kk) = td;
        
        % column_number
        Data_filtered{pp,1}.datacolumns(1,kk) = col;
        clear  ymed1_der  ymed1_fil_der
    end
    disp(['File#', num2str(ind),' filtered'])    
end
end

