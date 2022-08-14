function data_filtered = filter_data(data, fs, filter_type, filter_parameters,plot_result)
% function data_filtered = filter_data(data, fs, filter_type, filter_parameters, plot_result)
% default filter: low pass
% Examples: 
% file_ind = randi(DataInfo.files_amount,1); 
% data = DataPeaks_mean{file_ind, 1}.data(:,1); fs = DataInfo.framerate(file_ind);
    % low pass filtering data
    % data_filtered = filter_data(data, fs);
    % data_filtered = filter_data(data, fs,[],[],'yes');
narginchk(1,5)
nargoutchk(0,1)
% assumes that each column in data is separate
% low pass filter: default frequency is 200

%% defaults and checks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if data is column-wise
datasize=size(data);
if datasize(1) < datasize(2)
    disp('Transponse row vectors to columns: data = data')
    data = data';
    datasize = size(data);
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
        case 'moving_median'
            filter_parameters = 20; % window size
        case 'moving_average'
            filter_parameters = 20; % window size
        otherwise
            error('Check filter type!')
    end
end

% default: not plotting results
if nargin < 5 || isempty(plot_result)
    plot_result = 'no';
end


%% filtering data
fp = filter_parameters; % shorter term
switch filter_type
    case 'lowpass_iir'
        data_filtered = lowpass(data,fp(1),fs,...
            'ImpulseResponse','iir','Steepness',fp(2));
        text_to_disp = ['Lowpass IIR filter with frequency = ',...
            num2str(fp(1)),' and steepness = ', num2str(fp(2))];
    case 'moving_median'
        % filter_parameters = 20; % window size
        data_filtered = movmedian(data,fp);
        text_to_disp = ['Moving median filter, windowsize = ', num2str()];
    case 'moving_average'
        % filter_parameters = 20; % window size
        b = (1/fp)*ones(1,fp); %        a = 1;
        data_filtered = filter(b,1,data);
        text_to_disp = ['Moving average filter, windowsize = ', num2str()];
end

disp(text_to_disp)

% plot result if chosen
if strcmp(plot_result,'yes')
   fig_full, plot(data,'.'), hold all, plot(data_filtered,'r') 
   title(text_to_disp,'interpreter','none'), zoom on
   %sgtitle(['Filtering',10,text_to_disp])
end

end