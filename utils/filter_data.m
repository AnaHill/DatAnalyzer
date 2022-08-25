function data_filtered = filter_data(data, fs, filter_type, filter_parameters, ...
    plot_result, print_filter)
% function data_filtered = filter_data(data, fs, filter_type, filter_parameters, plot_result,print_filter)
% assumes that each column in data is separate
% filters; to add more filter options, see e.g. smoothdata options
% https://se.mathworks.com/help/matlab/ref/smoothdata.html#bvhejau-method
    % lowpass_iir (default): low pass filter with freq = 200 Hz
        % lowpass(data,200,fs,'ImpulseResponse','iir','Steepness',0.95);
    % moving_average
    % moving_median
    % sgolay
    % rlowess
%
% Examples: 
% file_ind = randi(DataInfo.files_amount,1); 
% data = DataPeaks_mean{file_ind, 1}.data(:,1); fs = DataInfo.framerate(file_ind);
    % low pass filtering data
    % data_filtered = filter_data(data, fs);
    % data_filtered = filter_data(data, fs,[],[],'yes'); % plot result
    % data_filtered = filter_data(data, fs,[],[500 0.95],'yes'); % low_pass iir with f=500Hz
% using raw data
% file_ind = randi(DataInfo.files_amount,1); file_ind = 1; 
% row_indexes = 1.3745e6:1.377e6; % figure, plot( Data{file_ind, 1}.data(row_indexes,:))
% data = Data{file_ind, 1}.data(row_indexes,:);
% data_filtered = filter_data(data, fs,[],[],'yes');
% data_filtered = filter_data(data, fs,'moving_average',[],'yes');
% data_filtered = filter_data(data, fs,'moving_median',[],'yes');
% data_filtered = filter_data(data, fs,'moving_mad',[],'yes');
% data_filtered = filter_data(data, fs,'sgolay',[],'yes'); % sgolay, estimating windowsize
% data_filtered = filter_data(data, fs,'rlowess',[],'yes'); Smoothdata with rlowess method chosen.
% for fpd analysis, best filters seem to be 
% lowpass_iir (default) and rlowess, e.g. compare with default values
% data_filtered = filter_data(data, fs,[],[],'yes'); data_filtered = filter_data(data, fs,'rlowess',[],'yes');
% axis([1000 1250 4e-4 5.5e-4]),  axis([700 900 6.3e-4 7.3e-4]), axis([600 2e3 1e-4 3e-4])
narginchk(1,6)
nargoutchk(0,1)

%% Check inputs and set parameters
% check if data is column-wise
datasize=size(data);
if datasize(1) < datasize(2)
    disp('Transponse row vectors to columns: data = data')
    data = data';
end

% fs: 1 Hz if not given
if nargin < 2 || isempty(fs)
    warning('No fs found, set fs = 1 Hz')
    fs = 1;
end
if length(fs) > 1
    disp('Given more than one fs value: take minimum of fs')
    fs = [min(fs(:))];
end

% filter default: low pass filter with f=200Hz and steepness 0.95
% lowpass(data,200,fs,'ImpulseResponse','iir','Steepness',0.95);
if nargin < 3 || isempty(filter_type)
    filter_type = 'lowpass_iir'; 
end

% if not given, set default filter parameters based on chosen filter type
if nargin < 4 || isempty(filter_parameters)
    switch filter_type 
        case 'lowpass_iir'
            % set frequency to 200 Hz and steepness to 0.95
            % lowpass(data,200,fs,'ImpulseResponse','iir','Steepness',0.95);
            filter_parameters = [200 0.95];     
        case 'moving_average'
            filter_parameters = 20; % window size
        case 'moving_median'
            filter_parameters = 50; % window size
        case 'sgolay'
            disp('Smoothdata with sgolay method chosen, estimating windowsize')
        case 'rlowess'
            % disp('Smoothdata with rlowess method chosen.')
            filter_parameters = 50; % window size
        otherwise
            error('Check filter type!')
    end
end

% default: not plotting results
if nargin < 5 || isempty(plot_result)
    plot_result = 'no';
end

% default: print/display filter parameters
if nargin < 6 || isempty(print_filter)
    print_filter = 'yes';
end


%% filtering data
fp = filter_parameters; % shorter term for code below
switch filter_type
    case 'lowpass_iir'
        data_filtered = lowpass(data,fp(1),fs,...
            'ImpulseResponse','iir','Steepness',fp(2));
        text_to_disp = ['Lowpass IIR filter with frequency = ',...
            num2str(fp(1)),' and steepness = ', num2str(fp(2))];
    case 'moving_average'
        b = (1/fp(1))*ones(1,fp(1)); 
        data_filtered = filter(b,1,data);
        text_to_disp = ['Moving average filter, windowsize = ', num2str(fp(1))];
    case 'moving_median'       
        data_filtered = movmedian(data,fp(1));
        text_to_disp = ['Moving median filter, windowsize = ', num2str(fp(1))];
    case 'sgolay'
        [data_filtered,windowsize] = smoothdata(data,'sgolay');
        text_to_disp = [...
            'Smoothed with Savitzky-Golay (sgolay) method, approximated windowsize = ',...
            windowsize];
        disp(['Sgolay aprroxiated window size: ',num2str(windowsize)])
    case 'rlowess'
        [data_filtered,windowsize] = smoothdata(data,'rlowess',fp(1));
        text_to_disp = ['Smoothed with robust Lowess method (rlowess), window size: ',...
            num2str(windowsize)];
end
if ~strcmp(print_filter,'no')
    % if user has not specifically chosen not to display filter parameters
    disp(['Data filtered: ',text_to_disp])
end

% plot result if chosen
if strcmp(plot_result,'yes')
   try 
       fig_full
   catch
       figure
   end
   plot(data,'.'), hold all
   hold all, set(gca,'ColorOrderIndex',1),
   plot(data_filtered, 'linewidth',1)
   title(text_to_disp,'interpreter','none'), 
   zoom on
   axis tight
   xlabel('Index')
   ylabel('Value')
end

end