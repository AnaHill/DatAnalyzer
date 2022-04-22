%% YKSITTÄISIÄ DataPeaks_mean + kohtia
% AJA ensin 
open('C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\plotting\Summarize_plot_DataPeaks_summary.m')
%%
% file_indexes =  [30 35 ]
% datacol_indexes = 3;
datacol_indexes = 1:length(DataInfo.datacol_numbers);
file_indexes =   [DataInfo.hypoxia.start_time_index DataInfo.hypoxia.end_time_index+5 DataInfo.files_amount-3]
file_indexes =   [DataInfo.hypoxia.start_time_index]

datacol_indexes = 1:5 % [1:2]
% file_indexes = 9% [6:7]
file_indexes = 1; datacol_indexes = 1;


% Martta: 'Acute_hypoxia_MEA21001a_HEB04602wt_p42_090321_MACS290321' 'MEA21001a'
% datacol_indexes = 1:5;
% datacol_indexes = randi([1,length(DataInfo.datacol_numbers)]);
% % file_indexes  = randi([1,DataInfo.files_amount]);
% how_many = 5;
% file_indexes  = randi([1, DataInfo.files_amount],[1,how_many]);
% file_indexes = sort(unique(file_indexes)); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
line_stylet = {'-','--','-.',':'};
mrs = 10; % markersize
% signal start, signalend, first peak end (if not signal end), flat peak location
mrc = {'b','r', [0 .5 0],'m','c'};
mr = {'o', 'sq','<','v'};
% mrc_e = {'r', [0 .5 0],	'b', 'c', 'm','y', 'k', 'w'};
mrc_e = {'r', [0 .5 0],	'b', 'c', 'm', 'k', [1 .5 0], [.4 .4 .4]};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fdat = [];fdatle = {};
ind = 0;
fig_full, hold all
for file_index = file_indexes
    for pp = 1:length(datacol_indexes)        
        ind = ind+1;
        col = datacol_indexes(pp);
        dat = DataPeaks_mean{file_index, 1}.data(:,col);
        if all(isnan(dat))
            disp(['DataPeaks_mean has no data in file index & data column: ',...
                num2str(file_index),'&', num2str(col)])
            continue
        end
        ind_signal = DataPeaks_summary.peaks_start_and_end_indexes{1,col};
        ind_peaks = DataPeaks_summary.peaks{1,col};
        try
            % colnum = DataInfo.MEA_electrode_numbers(col);
            fdatle{end+1} = ['File#',num2str(file_index),', ',DataInfo.datacol_names{col}];
        catch
            fdatle{end+1} = ['File#',num2str(file_index),', col#',num2str(col)];
        end
        
        if pp >= 1

            try
                fdat(end+1) = plot(dat,'linestyle',line_stylet{pp},'color', mrc_e{ind});
            catch
                try
                    ind = 1;
                    fdat(end+1) = plot(dat,'linestyle',line_stylet{pp},'color', mrc_e{ind});
                catch
                    plot(dat)
                end

            end           
        else
            try 
                plot(dat,'linestyle',line_stylet{pp},'color', mrc_e{ind});
            catch
                try
                    ind = 1;
                    plot(dat,'linestyle',line_stylet{pp},'color', mrc_e{ind});
                catch
                    plot(dat)
                end
            end
        end
        % signal start
        try
            plot(ind_signal.signal_start(file_index), ...
                dat(ind_signal.signal_start(file_index)),...
                'marker',mr{1},'markerfacecolor',mrc{1},'markersize', mrs+2,...
                'markeredgecolor',mrc_e{ind})
                        % 'markeredgecolor',mrc{1})
        catch
            ind = 1;
            plot(ind_signal.signal_start(file_index), ...
                dat(ind_signal.signal_start(file_index)),...
                'marker',mr{1},'markerfacecolor',mrc{1},'markersize', mrs+2,...
                'markeredgecolor',mrc_e{ind})
        end
        % signal end
        plot(ind_signal.signal_end(file_index), dat(ind_signal.signal_end(file_index)),...
            'marker',mr{2},'markerfacecolor',mrc{2},'markersize', mrs+2,...
            'markeredgecolor',mrc_e{ind})
        % first peak end: if not signal end
        if ind_signal.first_peak_end(file_index) ~= ...
                ind_signal.signal_end(file_index)
            plot(ind_signal.first_peak_end(file_index), ...
                dat(ind_signal.first_peak_end(file_index)),...
                'marker',mr{3},'markerfacecolor',mrc{3},'markersize', mrs, ...
                'markeredgecolor',mrc_e{ind})
        end
        try
            plot(ind_peaks.flatp_loc(file_index), ...
                dat(ind_peaks.flatp_loc(file_index)),...
                'marker',mr{4},'markerfacecolor',mrc{4},'markersize', mrs,...
                'markeredgecolor',mrc_e{ind})
        catch
            disp(['File#',num2str(file_index),', col#',num2str(col),' no flat peak'])
        end
    end
end
axis tight, legend(fdat,fdatle,'location','best')
grid on

%% KUIN YLLä, mutta kaikki pisteet samalla värillä kuin kyseinen viiva
datacol_indexes = 1:2 % [1:2]
file_indexes = [6:7]

datacol_indexes = 1:5 % [1:2]
file_indexes = [1:2]

datacol_indexes = 1;file_indexes = 1:20:141;

%%%%%%%%%
% colorOrder = get(gca, 'ColorOrder')
% color_index  = get(gca,'ColorOrderIndex')
line_stylet = {'-','--','-.',':'};
mrs = 10; % markersize
% signal start, signalend, first peak end (if not signal end), flat peak location
% mr = {'o', 'sq','<','v'};
mr = {'v','^','x','sq','<',};

% peak start peak end first peak end if not peak end
mr = {'>','<','^','v','sq','o',};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fdat = [];fdatle = {};

fig_full, 
ax = gca;hold on
% ax.ColorOrder
% ax.ColorOrderIndex
colors = ax.ColorOrder;
color_index  =  ax.ColorOrderIndex;

color_ind = 0;
for file_index = file_indexes
    ind = 0;
    color_ind = color_ind + 1;
    % update color
    try
        ax.ColorOrder(color_ind,:);
    catch
        color_ind = 1;
    end
    for pp = 1:length(datacol_indexes)        
        ind = ind+1;
        col = datacol_indexes(pp);
        dat = DataPeaks_mean{file_index, 1}.data(:,col);
%         disp(num2str([file_index, col,ax.ColorOrderIndex]))
        current_color = ax.ColorOrder(color_ind,:);
        if all(isnan(dat))
            disp(['DataPeaks_mean has no data in file index & data column: ',...
                num2str(file_index),'&', num2str(col)])
            continue
        end
        ind_signal = DataPeaks_summary.peaks_start_and_end_indexes{1,col};
        ind_peaks = DataPeaks_summary.peaks{1,col};
        try
            % colnum = DataInfo.MEA_electrode_numbers(col);
            fdatle{end+1} = ['File#',num2str(file_index),', ',DataInfo.datacol_names{col}];
        catch
            fdatle{end+1} = ['File#',num2str(file_index),', col#',num2str(col)];
        end
        try
            line_stylet{pp};
            ind = pp;
        catch
            ind = 1;
        end
        try
            fdat(end+1) = plot(dat,'linestyle',line_stylet{ind},'color', current_color);
        catch
            plot(dat)
        end               % signal start
        try
            plot(ind_signal.signal_start(file_index), ...
                dat(ind_signal.signal_start(file_index)),...
                'marker',mr{1},'markerfacecolor', current_color,'markersize', mrs+2,...
                'markeredgecolor', 'k')
        catch
        end
        % signal end
        try
            plot(ind_signal.signal_end(file_index), dat(ind_signal.signal_end(file_index)),...
                'marker',mr{2},'markerfacecolor', current_color,'markersize', mrs+2,...
                'markeredgecolor', 'k')
        catch
        end
        % first peak end: if not signal end
        if ind_signal.first_peak_end(file_index) ~= ...
                ind_signal.signal_end(file_index)
            plot(ind_signal.first_peak_end(file_index), ...
                dat(ind_signal.first_peak_end(file_index)),...
                'marker',mr{3},'markerfacecolor',current_color,'markersize', mrs, ...
                'markeredgecolor', 'k')
        end
        try
            plot(ind_peaks.flatp_loc(file_index), ...
                dat(ind_peaks.flatp_loc(file_index)),...
                'marker',mr{4},'markerfacecolor',current_color,'markersize', mrs,...
                'markeredgecolor', 'k')
        catch
            disp(['File#',num2str(file_index),', col#',num2str(col),' no flat peak'])
        end
    end
end
axis tight, legend(fdat,fdatle,'location','best')
grid on

%% YKSITTÄISIÄ DataPeaks_mean + kohtia
fdat = [];fdatle = {};
file_index =  28% :29% 42;
datacol_index = 2;
file_index =  71; datacol_index = 1;
file_index =  1; datacol_index = 1;

dat = DataPeaks_mean{file_index, 1}.data(:,datacol_index);
ind_signal = DataPeaks_summary.peaks_start_and_end_indexes{1,datacol_index};
ind_peaks = DataPeaks_summary.peaks{1,datacol_index};
fig_full, 
fdat(end+1) = plot(dat);fdatle{end+1} = ['File#',num2str(file_index)];
hold all
plot(ind_signal.signal_start(file_index), dat(ind_signal.signal_start(file_index)),'ro')
plot(ind_signal.signal_end(file_index), dat(ind_signal.signal_end(file_index)),'msq')
try
    plot(ind_signal.first_peak_end(file_index), dat(ind_signal.first_peak_end(file_index)),'gx')
catch
end
try
    plot(ind_peaks.flatp_loc(file_index), dat(ind_peaks.flatp_loc(file_index)),'ro')
catch
end

%%
file_index = 1;%  86% 43;
datacol_index = 1;
dat = DataPeaks_mean{file_index, 1}.data(:,col);
ind_signal = DataPeaks_summary.peaks_start_and_end_indexes{1,col};
ind_peaks = DataPeaks_summary.peaks{1,col};
fdat(end+1) = plot(dat);fdatle{end+1} = ['File#',num2str(file_index)];
hold all
plot(ind_signal.signal_start(file_index), dat(ind_signal.signal_start(file_index)),'ro')
plot(ind_signal.signal_end(file_index), dat(ind_signal.signal_end(file_index)),'msq')
plot(ind_signal.first_peak_end(file_index), dat(ind_signal.first_peak_end(file_index)),'gx')
plot(ind_peaks.flatp_loc(file_index), dat(ind_peaks.flatp_loc(file_index)),'ro')


file_index = 56 % 65% 56 % 83;
datacol_index = 1;
dat = DataPeaks_mean{file_index, 1}.data(:,col);
ind_signal = DataPeaks_summary.peaks_start_and_end_indexes{1,col};
ind_peaks = DataPeaks_summary.peaks{1,col};
fdat(end+1) = plot(dat);fdatle{end+1} = ['File#',num2str(file_index)];
hold all
plot(ind_signal.signal_start(file_index), dat(ind_signal.signal_start(file_index)),'ro')
plot(ind_signal.signal_end(file_index), dat(ind_signal.signal_end(file_index)),'msq')
plot(ind_signal.first_peak_end(file_index), dat(ind_signal.first_peak_end(file_index)),'gx')
plot(ind_peaks.flatp_loc(file_index), dat(ind_peaks.flatp_loc(file_index)),'ro')

axis tight, legend(fdat,fdatle,'location','best')
