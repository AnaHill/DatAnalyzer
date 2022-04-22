function measurement_electrode_numbers = ...
    read_wanted_electrodes_of_measurement(exp_name, meas_name,electrode_layout)
% function measurement_electrode_numbers =  read_wanted_electrodes_of_measurement(exp_name, meas_name,electrode_layout)
% READ_LIST_OF_WANTED_ELECTRODES
% read list of (previously chosen) electrodes for the current measurement
% if empty, ask should all electrodes to be chosen or empty list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
narginchk(2,3)
nargoutchk(1,1)

if nargin < 3
    [electrode_layout] = read_MEA_electrode_layout();
end


measurement_electrode_numbers = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEW long measurement on 2020 / 09
if strcmp(exp_name,'15-180920 long hypoxia experiments')
    if strcmp(meas_name,'mea21001a')
       measurement_electrode_numbers = [44, 71, 75, 84];
    elseif strcmp(meas_name,'mea21001b')
       measurement_electrode_numbers = [25, 36, 55, 62, 71];
    elseif strcmp(meas_name,'mea21002a')
       measurement_electrode_numbers = [45, 56, 64, 82];
    end
end
if strcmp(exp_name,'Exp_11311_EURCCS_p32_180820')
    if strcmp(meas_name,'mea21001a')
       measurement_electrode_numbers = [44, 71, 75, 84];
    elseif strcmp(meas_name,'mea21001b')
       measurement_electrode_numbers = [25, 36, 55, 62, 71];
    elseif strcmp(meas_name,'mea21002a')
       measurement_electrode_numbers = [45, 56, 64, 82];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACUTE Hypoxia
% Acute hypoxia experiments 2807-050820
if strcmp(exp_name,'MEA hypoxia 04602wt_p26_6_020720_28-290720') 
    if strcmp(meas_name,'mea21001a')
       measurement_electrode_numbers = []; % no good data
    elseif strcmp(meas_name,'mea21001b')
       measurement_electrode_numbers = [37];
    end
end
if strcmp(exp_name,'MEA hypoxia 11311EURCSS_p25_2_020720_03-040820') 
    if strcmp(meas_name,'mea21001a')
       measurement_electrode_numbers = [55];
    elseif strcmp(meas_name,'mea21001b')
       measurement_electrode_numbers = [];
    elseif strcmp(meas_name,'mea21002a')
       measurement_electrode_numbers = [61];
    elseif strcmp(meas_name,'mea21002b')
       measurement_electrode_numbers = [];
    end
end
if strcmp(exp_name,'04602wt_p26_6_020720_MEAlitepO2_28-290720') 
    measurement_electrode_numbers = [55]; 
end
if strcmp(exp_name,'04602wt_p26_6_020720_MEAlitepO2_29-300720') 
    measurement_electrode_numbers = [26, 28, 33]; 
end

% acute hypoxia 2020-2021
% mea21001b
%     tuttu vahva signaali: 27, 43, 56, 82 (kääntäen)
%     tuttu heikompi signaali: 17 (kääntäen), 72, 86
%     erilainen vahva signaali: 42, 53, 64
% mea21002a
%     tuttu vahva signaali: 12, 13, 17, 43
%     tuttu heikompi signaali: 14, 52, 68
if strcmp(exp_name,'Acute SM 11311_EURCCS_p26_4_280920 271020') 
    if strcmp(meas_name,'mea21001a')
       measurement_electrode_numbers = [];
       disp('no electrodes for mea21001a')
    elseif strcmp(meas_name,'mea21001b')
       measurement_electrode_numbers = [17, 27, 42, 43, 53, 56, 64, 72, 82, 86];
    elseif strcmp(meas_name,'mea21002a')
       measurement_electrode_numbers = [61];
    elseif strcmp(meas_name,'mea21002b')
       measurement_electrode_numbers = [12,13,14,17,43,68];
       disp('no electrodes for mea21002b')
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%TODO: vanhemmat mittaukset tähän

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if no electrodes were found: asking all or none
if isempty(measurement_electrode_numbers)
    warning('No information related to electrodes found with given experimental info')
    warning('With given experiment &  measurement names')
    warning([exp_name, ' &  ', meas_name])
    disp('Checking if manually given electrodes numbers in function call')
    try 
        measurement_electrode_numbers = evalin('caller','manual_mea_electrode_choose');
        choice_electrodeNumbers = 'Pass';
        if isempty(measurement_electrode_numbers)
            disp('No electrodes chosen')
             choice_electrodeNumbers= questdlg('Which electrodes are used?',...
                'Which electrodes', 'All','Choose','None','All');
        end
    catch
        choice_electrodeNumbers= questdlg('Which electrodes are used?',...
            'Which electrodes', 'All','Choose','None','All');
    end
    % filename_list = evalin('caller','filename_list');
    switch choice_electrodeNumbers
        case 'Choose'
            [indx,tf] = listdlg('PromptString',{'Select electrodes.'},...
                 'ListString',num2str(electrode_layout.electrode_number),'ListSize',[300 600]);
            if isempty(indx)
                measurement_electrode_numbers = electrode_layout.electrode_number;
                disp('Nothing selected, choosing all data files.')
            else
                measurement_electrode_numbers = electrode_layout.electrode_number(indx);
            end
        case 'All'
            measurement_electrode_numbers=electrode_layout.electrode_number;
        case 'None'
            measurement_electrode_numbers=[];
            disp('No electrodes chosen')
        case 'Pass'
            disp('Input function given electrodes.')

    end
end

%%%%%%%%%%%%%%%%%
disp('Reading electrodes')
disp(['Experiment: ',exp_name])
disp(['Measurement: ',meas_name])
disp(['Chosen electrodes are: ',num2str(measurement_electrode_numbers(:)')])








%% vanhat, muuta sopisiviksi
% if strcmp(dataset_name,'Martta')
%     MEA_wanted_electrodes.d230719.date = '230719';
%     MEA_wanted_electrodes.d230719.mea21001a = [14, 25, 26, 27, 28, 32, 37, 41, 42, 51, 55, 57, 58, 64, 65, 75, 76, 77, 85, 86, 87]';
%     MEA_wanted_electrodes.d230719.mea21001b = [14, 16, 17, 23, 25, 26, 28, 33, 43, 53, 56, 63, 64, 65, 73, 85]';
%     MEA_wanted_electrodes.d230719.mea21002a = [17, 24, 26, 27, 31, 33, 41, 44, 45, 63, 75, 76, 77, 78]';
%     MEA_wanted_electrodes.d230719.mea21002b = [12, 14, 25, 32, 34, 42, 44, 51, 62, 64, 71, 75, 83]';

%     MEA_wanted_electrodes.d250919.date = '250919';
%     MEA_wanted_electrodes.d250919.mea21001a = [12, 13, 14, 23, 24, 33, 34, 35, 36, 38, 42, 43, 44, 45, 46, 47, 48, 55, 56, 58, 62, 66, 77]';
%     MEA_wanted_electrodes.d250919.mea21001b = [13, 16, 21, 23, 24, 25, 26, 32, 34, 35, 36, 47, 53, 54, 62]';
%     MEA_wanted_electrodes.d250919.mea21002a = [13, 26, 27, 32, 33, 34, 36, 37, 38, 44, 45, 46, 48, 55, 56, 57, 58, 64, 65, 68, 72, 76]';
%     MEA_wanted_electrodes.d250919.mea21002b = [12, 21, 23, 25, 26, 32, 33, 34, 35, 38, 41, 43, 45, 47, 52, 54, 55, 56, 58, 61, 62, 64, 67, 71]';
%     % uudemmat 250919 mittauksen datat
%     MEA_wanted_electrodes.d250919.mea21001a = []; % Ei hyvä kun ilma ei kiertänyt
%     MEA_wanted_electrodes.d250919.mea21001b = [13, 31, 32, 48, 54, 62]'; % 62 erikseen
%     MEA_wanted_electrodes.d250919.mea21002a = [13, 26, 32, 33, 44, 45, 48, 56, 64]';
%     MEA_wanted_electrodes.d250919.mea21002b = [12, 23, 26, 47, 61, 62, 64]'; % 61 erikseen

%     MEA_wanted_electrodes.d270619.date = '270619';
%     MEA_wanted_electrodes.d270619.mea21001a = [14, 17, 23, 26, 27, 28, 31, 32, 34, 35, 38, 41, 43, 44, 45, 48, 51, 52, 53, 54, 56, 57, 58, 61, 62, 66, 74, 77, 82, 85]';
%     MEA_wanted_electrodes.d270619.mea21001b = [12, 14, 16, 17, 22, 23, 24, 25, 26, 27, 28, 31, 34, 35, 36, 37, 38, 41, 43, 44, 45, 47, 51, 55, 56, 63, 65, 66, 75, 83]';
%     MEA_wanted_electrodes.d270619.mea21002a = [28, 31, 37, 41, 46, 51, 54, 71, 74, 82, 83]';
%     MEA_wanted_electrodes.d270619.mea21002b = [12, 13, 16, 21, 22, 23, 25, 27, 32, 33, 35, 36, 42, 43, 44, 45, 46, 52, 53, 54, 56, 61, 62, 65, 72, 75]';

%     MEA_wanted_electrodes.d020320.date = '020320'; % 2020_03_02';
%     MEA_wanted_electrodes.d020320.mea21001b = [13, 16, 24, 33, 68]';
%     MEA_wanted_electrodes.d020320.mea21002b = [21, 28, 31, 51]';
%     MEA_wanted_electrodes.d020320.mealitepO2measurement = [26, 27, 28, 61]';
    
%     % Akuuttihypoksia kesä 2020 ->
%     MEA_wanted_electrodes.d280720.date = '280720'; 
%     MEA_wanted_electrodes.d280720.mea21001a = all_electrodes;
%     MEA_wanted_electrodes.d280720.mea21001b = [37]';
%     MEA_wanted_electrodes.d280720.mealitepO2 = [1,55]';
%     MEA_wanted_electrodes.d280720.mealitepO2_2 = [26, 28, 33]';
    
%     MEA_wanted_electrodes.d030820.date = '030820'; 
%     MEA_wanted_electrodes.d030820.mea21001a = 55;
%     MEA_wanted_electrodes.d030820.mea21001b = [all_electrodes];
%     MEA_wanted_electrodes.d030820.mea21002a = 61;
%     MEA_wanted_electrodes.d030820.mea21002b = [all_electrodes];    

% elseif strcmp(dataset_name,'Martta_parhaat_elektrodit')
% 230719
% 	MEA21001a: 14, 25, 26, 27, 28
% 	MEA21001b: 14, 16, 17, 25, 26
% 	MEA21002a: 17, 24, 26, 27
% 250919
% 	MEA21001b: 13, 31, 32, 48, 54
% 	MEA21002a: 13, 26, 32, 33
% 	MEA21002b: 12, 23, 26, 47
% 020320
% 	MEA21001b: 13, 24, 33, 68
% 	MEA21002b: 21, 28, 31, 51
% 	MEAlite: 26, 27, 28, 61     
%     MEA_wanted_electrodes.d230719.date = '230719';
%     MEA_wanted_electrodes.d230719.mea21001a = [14, 25, 26, 27, 28]';
%     MEA_wanted_electrodes.d230719.mea21001b = [14, 16, 17, 25, 26]';
%     MEA_wanted_electrodes.d230719.mea21002a = [17, 24, 26, 27]';
% %     MEA_wanted_electrodes.d230719.mea21002b = [3]';
%     MEA_wanted_electrodes.d250919.date = '250919';
% %     MEA_wanted_electrodes.d250919.mea21001a = []; % Ei hyvä kun ilma ei kiertänyt
%     MEA_wanted_electrodes.d250919.mea21001b = [13, 31, 32, 48, 54]';
%     MEA_wanted_electrodes.d250919.mea21002a = [13, 26, 32, 33]';
%     MEA_wanted_electrodes.d250919.mea21002b = [12, 23, 26, 47]'; 
% 
% %     MEA_wanted_electrodes.d270619.date = '270619';
% %     MEA_wanted_electrodes.d270619.mea21001a = [14, 17, 23, 26, 27, 28, 31, 32, 34, 35, 38, 41, 43, 44, 45, 48, 51, 52, 53, 54, 56, 57, 58, 61, 62, 66, 74, 77, 82, 85]';
% %     MEA_wanted_electrodes.d270619.mea21001b = [12, 14, 16, 17, 22, 23, 24, 25, 26, 27, 28, 31, 34, 35, 36, 37, 38, 41, 43, 44, 45, 47, 51, 55, 56, 63, 65, 66, 75, 83]';
% %     MEA_wanted_electrodes.d270619.mea21002a = [28, 31, 37, 41, 46, 51, 54, 71, 74, 82, 83]';
% %     MEA_wanted_electrodes.d270619.mea21002b = [12, 13, 16, 21, 22, 23, 25, 27, 32, 33, 35, 36, 42, 43, 44, 45, 46, 52, 53, 54, 56, 61, 62, 65, 72, 75]';
%     MEA_wanted_electrodes.d020320.date = '020320'; % 2020_03_02';
%     MEA_wanted_electrodes.d020320.mea21001b = [13,24, 33, 68]';
%     MEA_wanted_electrodes.d020320.mea21002b = [21, 28, 31, 51]';
%     MEA_wanted_electrodes.d020320.mealitepO2measurement = [26, 27, 28, 61]';  
% %     disp('Martta uudet elektrodit')
% elseif strcmp(dataset_name,'Demo3')
%     disp('TODO!')
% %     MEA_wanted_electrodes.d180619.date = '180619';
% %     MEA_wanted_electrodes.d180619.demo3_1 = [17,26,35]';
% %     
% %     MEA_wanted_electrodes.d040919.date = '040919';
% %     MEA_wanted_electrodes.d040919.demo3_13 = [86,87,65,74,75,76,85]';
% %             
% %     MEA_wanted_electrodes.d250919.date = '250919';
% %     MEA_wanted_electrodes.d250919.demo3_14 = [63,72, 82]';
% %     
% %     
% %     
% % 	% data = MEA_wanted_electrodes;
% % %     disp('Dataset:Demo3')
% end
%     disp(dataset_name)
%     data = MEA_wanted_electrodes;
%     fields = fieldnames(data);
%     dates = cell2dataset(['date';fields]);
%     ind = find(strcmp(experiment_name, dates.date),1);
%     fields2 = fieldnames(data.(dates.date{ind}));
%     info = cell2dataset(['info';fields2]);
%     ind2 = find(strcmp(meas_name, info.info),1);
%     wanted_electrodes  = data.(dates.date{ind}).(info.info{ind2});
%     disp(['Wanted electrodes are: ',num2str(wanted_electrodes(:)')])
% end
