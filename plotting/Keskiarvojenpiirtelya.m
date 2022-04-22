% yksinkertainen testailu sopivinen s‰‰ntˆjen etsimiseksi
filenum=1; col = 1; montako=5;
filenum=sort(unique(randi(DataInfo.files_amount,montako,1)));
filenum=unique([1:10:DataInfo.files_amount, DataInfo.files_amount])
% filenum=1; col = 1; 
minimiarvot=zeros(DataInfo.files_amount,length(DataInfo.datacol_numbers));
for pp = 1:DataInfo.files_amount
    minimiarvot(pp,:) = min(DataPeaks_mean{pp, 1}.data);
end
% jos negatiivisia low peaks-->
% minimiraja = max(max(minimiarvot))
% minimirajat = (max(minimiarvot))
% [rind, cind] = find(minimiarvot == minimiraja)
% [rind, cind] = find(minimiarvot == minimiraja)


col=1:length(DataInfo.datacol_numbers);
%filenum = rind
hfigs = []; 
for pp = 1:length(filenum)
    fig_full;
    hfigs(end+1,1) = hfig;
    % plot(DataPeaks_mean{filenum(pp), 1}.data(:,col))
    fs = DataInfo.framerate(filenum(pp));
    points = max(size(DataPeaks_mean{filenum(pp), 1}.data(:,col)));
    time = 0:1/fs:(points-1)/fs;
    plot(time, DataPeaks_mean{filenum(pp), 1}.data(:,col))
%     for kk = 1:length(col)
%         % plot(DataPeaks.data{filenum,col}),hold all, 
%         % plot(DataPeaks_mean{filenum, 1}.data(:,col),'k--','linewidth',2)
% %         plot(DataPeaks_mean{filenum(pp), 1}.data(:,col))
%         
%     end
    sgtitle(['File#',num2str([filenum(pp)]),' and cols#',num2str([col])])
    xlabel('Time (sec)'),  ylabel('Measurement (V)'),  axis tight
    zoom on
end
for kk=length(hfigs):-1:1
    figure(hfigs(kk,1))
end

%%
kerroin = 1.5; % 2
time_to_find = [0 abs(DataPeaks.time_range_from_peak(1)*kerroin)];

for kk=length(hfigs):-1:1
    figure(hfigs(kk,1))
    xlim([0 0.4]+abs(DataPeaks.time_range_from_peak(1)))
    axis auto
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TODO Onko en‰‰ j‰rkevi‰
fs=DataInfo.framerate(1); col=1;
try
    dat = DataPeaks_summary.peaks{1, col}; 
catch    
    col = length(DataInfo.datacol_numbers);
    dat = DataPeaks_summary.peaks{1, col}; 
end

fig_full 
sgtitle(DataInfo.measurement_name,'interpreter','none')
subplot(211)
% plot(dat.file_index, 1e3*(dat.secondp_loc-dat.firstp_loc)/fs), 
hold all
try 
    plot(dat.file_index, DataPeaks_summary.t_depolarization_ms(:,col)),
catch % 2021/10 edit
   plot(dat.file_index, DataPeaks_summary.depolarization_time(:,col)*1e3);
end
title('Ekan piikin leveys')
ylabel('Leveys (ms)'),xlabel('Tiedosto nro'), axis tight

subplot(212)
plot(dat.file_index, dat.firstp_val),
hold all
try
    plot(dat.file_index, dat.secondp_val),
    plot(dat.file_index, dat.firstp_val-dat.secondp_val),
catch % 2021/10 edit
    
end
title('Piikin j‰nnitearvo')
ylabel('J‰nnite (V)'),xlabel('Tiedosto nro')
legend('Eka piikki','Alapiikki','Amplitudi (eka-ala)'), axis tight
for pp = 1:2
    subplot(2,1,pp)
%     xlabel([xlabel_text])
    try
        Data_o2.data(Data_o2.measurement_time.datafile_index);
        yyaxis right
        plot(dat.file_index,Data_o2.data(Data_o2.measurement_time.datafile_index),'--')
        ylabel('O2 (kPa)') %         ylabel('O2 (%)')
        legend('Eka piikki','Alapiikki','Amplitudi (eka-ala)','O2'), 
        axis tight
    catch
    end

    axis tight
end
%% KESKIARVOJEN piirtoja

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot signal average
% function [] = plot_signal_average(DataPeaks_mean, plot_confidence_level,...
%     confidence_level, file_index_to_analyze, datacolumns)
% plot_signal_average
% plot_signal_average(DataPeaks_mean)
plot_signal_average(DataPeaks_mean,1)
if ~isempty(unique(sort(Data_BPM_summary.irregular_beating_table.File_index)))
    irreg_file_index = unique(sort(Data_BPM_summary.irregular_beating_table.File_index));
    index_to_plot=unique([1:10:irreg_file_index(end) irreg_file_index(end)]);
    for zz = index_to_plot
        plot_signal_average(DataPeaks_mean,1,99,zz)
    end
end
%% Esimerkki: 95% conf level, valitse
cols = 1
peak_num=0 % 2;%3;

filu_nrot = DataInfo.hypoxia.start_time_index-1
% filu_nrot=5
plot_signal_average(DataPeaks_mean,1,confidence_lev,filu_nrot,cols,1)
%%
% filu_nro = DataInfo.hypoxia.end_time_index + 4
% 
% filu_nro=DataInfo.files_amount-20; 
% % filu_nro=DataInfo.files_amount; 
% 
% cols=1:length(DataInfo.datacol_numbers)

% 
% filu_nrot = [DataInfo.hypoxia.start_time_index-1 DataInfo.hypoxia.end_time_index + 4 ...
%     DataInfo.files_amount-20 DataInfo.files_amount]
% filu_nrot(end+1)=38
% filu_nrot = sort(unique(filu_nrot))
% 
% filu_nrot = [1 26 28 37 39 48 55 76 89]
% filu_nrot = filu_nrot([2,3,5,6])

filu_nrot=5



confidence_lev = 1.96;
peak_num=0 % 2;%3;
% peak_num = sort(unique(randi([1,5],[1,5])))
% peak_num = 
% % randomilla
% % filu_nro = randi([1,DataInfo.files_amount]);
% peak_num_amount = round(randi([1,DataPeaks_mean{filu_nro}.N(col)])/10);
% if peak_num_amount  == 1
%     peak_num_amount  = 2;
% end


% plot_signal_average(DataPeaks_mean,1,confidence_lev,filu_nro)
% plot_signal_average(DataPeaks_mean,1,confidence_lev,filu_nro,col)

plot_signal_average(DataPeaks_mean,1,confidence_lev,filu_nrot,cols,1)
% plot_signal_average(DataPeaks_mean,[],[],filu_nrot,cols,1)
%% laskemista
% filu_nrot = [DataInfo.hypoxia.start_time_index-1 DataInfo.hypoxia.end_time_index + 4 ...
%     DataInfo.files_amount-20 DataInfo.files_amount]
hw = [13.39 17.27 14.48 12.73]
rd = 0.15-[.1327 .08 .08 .08] *1e-3;

hw/hw(1)
rd/rd(1)
%%
% dat = DataPeaks.data{filu_nro,col}(:,peak_num);
% fs = DataInfo.framerate(filu_nro); time = 0:1/fs:(length(dat)-1)/fs;
amount_peaks = median(DataPeaks_mean{1, 1}.N);

[fig_parameters] = cal_subfig_parameters(cols);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
subplot(sub_fig_rows,sub_fig_cols,fig_parameters(3)-1)    

try
    hold all, plot(time, dat),
    if length(peak_num) < amount_peaks
        legend(['Avg from ',num2str(amount_peaks),' peaks'],...
            ['confidence level: ',num2str(confidence_lev) '%'],...
            ['Peak(s)# ',num2str(peak_num)])
    else
        legend(['Avg from ',num2str(amount_peaks),' peaks'],...
            ['confidence level: ',num2str(confidence_lev) '%'],...
            ['All peak(s)'])
    end

catch
    legend(['Avg from ',num2str(amount_peaks),' peaks'],...
        ['confidence level: ',num2str(confidence_lev) '%'])
end


%% esimerkkikuva
confidence_lev = 1.96;
filu_nro=117%29; 
col=5
peak_num = 2;%3;
% randomilla
% filu_nro = randi([1,DataInfo.files_amount]);
peak_num_amount = round(randi([1,DataPeaks_mean{filu_nro}.N(col)])/10);
if peak_num_amount  < 2
    peak_num_amount  = 2;
end
try
    peak_num=1:min(size( DataPeaks.data{filu_nro,col}));
catch
    peak_num=1:min(size( DataPeaks.data{filu_nro,1}));
end
%
%peak_num = 15:25

peak_num = sort(unique(randi([1,5],[1,5])))

plot_signal_average(DataPeaks_mean,1,confidence_lev,filu_nro)
dat = DataPeaks.data{filu_nro,col}(:,peak_num);

fs = DataInfo.framerate(filu_nro); time = 0:1/fs:(length(dat)-1)/fs;
amount_peaks = min(size(DataPeaks.data{filu_nro,col}));

[fig_parameters] = cal_subfig_parameters(1:length(DataInfo.datacol_numbers));
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
subplot(sub_fig_rows,sub_fig_cols,col)    
hold all, plot(time, dat), 
if length(peak_num) < amount_peaks
    legend(['Avg from ',num2str(amount_peaks),' peaks'],...
        ['confidence level: ',num2str(confidence_lev) '%'],...
        ['Peak(s)# ',num2str(peak_num)])
else
   legend(['Avg from ',num2str(amount_peaks),' peaks'],...
    ['confidence level: ',num2str(confidence_lev) '%'],...
    ['All peak(s)']) 
end
%%
% confidence_lev = 95;
confidence_lev = 1.96;
if confidence_lev == 1.96
    conf_perc = 95;
else
    conf_perc = 99;
end

%%% fiksattu vai random
randomilla = 1; % laita 1 jos randomilla
randomilla = 0;
% 
col=1
% col=1
filu_nro=10 % 44
peak_num=0; 22

filu_nro=42 % 44

peak_num

if randomilla == 1
    %%% randomilla
    col = randi([1,length(DataInfo.datacol_numbers)]);
    filu_nro = randi([1,DataInfo.files_amount]);
    peak_num_amount = ceil(randi([1,DataPeaks_mean{filu_nro}.N(col)])/10);
    clear peak_num
    try
        peak_num=1:min(size( DataPeaks.data{filu_nro,col}));
    catch
        peak_num=1:min(size(DataPeaks.data{filu_nro,1}));
    end
    peak_num = sort(unique(randi([1, length(peak_num)],[1,peak_num_amount])));
end

dat_temp = DataPeaks_mean{filu_nro, 1}.data;
fs = DataInfo.framerate(filu_nro); time = 0:1/fs:(length(dat_temp)-1)/fs;

%%%%%%%%%
plot_signal_average(DataPeaks_mean,1,confidence_lev,filu_nro)
if any(peak_num) > 0
    dat = DataPeaks.data{filu_nro,col}(:,peak_num);
    amount_peaks = min(size(DataPeaks.data{filu_nro,col}));
    % [fig_parameters] = cal_subfig_parameters(1:length(DataInfo.datacol_numbers));
    % sub_fig_rows=fig_parameters(1);
    % sub_fig_cols=fig_parameters(2);
    % subplot(sub_fig_rows,sub_fig_cols,col)    
    hold all, plot(time, dat), 
    if length(peak_num) < amount_peaks
        legend(['Avg from ',num2str(amount_peaks),' peaks'],...
            ['confidence level: ',num2str(conf_perc) '%'],...
            ['Peak(s)# ',num2str(peak_num)])
    else
       legend(['Avg from ',num2str(amount_peaks),' peaks'],...
        ['confidence level: ',num2str(conf_perc) '%'],...
        ['All peak(s)']) 
    end
else
    legend(['Avg from ',num2str(DataPeaks_mean{filu_nro, 1}.N),' peaks'],...
        ['confidence level: ',num2str(conf_perc) '%'])
    
end
    
% xlim([.095 0.113])
%% %%% lis‰t‰‰n lˆydetyt piikin alut/loput
ind = DataPeaks_summary.peaks_start_and_end_indexes{1,col}.file_index(filu_nro);
index_p_se= DataPeaks_summary.peaks_start_and_end_indexes{1,col}(ind,:);
dat = DataPeaks_mean{filu_nro, 1}.data;
hold all, 
plot(time(index_p_se.signal_start),dat(index_p_se.signal_start),'ro')
% plot(time(index_p_se.signal_end),dat(index_p_se.signal_end),'ro')
plot(time(index_p_se.first_peak_end),dat(index_p_se.first_peak_end),'x','color',[0 .5 0])
xlim([time(index_p_se.signal_start)*.99 time(index_p_se.first_peak_end)*1.01])
xlim([time(index_p_se.signal_start) time(index_p_se.first_peak_end)*1.0])
% xlim([time(index_p_se.signal_start)*.9 time(index_p_se.first_peak_end)*1.1])

grid
%%%% lis‰t‰‰n leveys

t_le = DataPeaks_summary.t_depolarization_ms(filu_nro)*1e-3;

line([time(index_p_se.signal_start) time(index_p_se.signal_start)+t_le],...
    [dat(index_p_se.signal_start) dat(index_p_se.first_peak_end)],...
    'linestyle','--','color',[.4 .4 .4])
axis([time(index_p_se.signal_start)*.99 (time(index_p_se.signal_start)+t_le)*1.01 0 Inf])

x = mean([time(index_p_se.signal_start) time(index_p_se.signal_start)+t_le]);
y = [dat(index_p_se.signal_start)*.1 dat(index_p_se.signal_start)*0.9];
% annotation('textarrow',[x,x],[y],'String','piikin leveys')

yb = [dat(index_p_se.signal_start)*0.99];
% dim = [0.5 yb 0.5 yb];
% str = 'Straight Line Plot from 1 to 10';
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
str = ['Piikin leveys: ~',num2str(round(t_le*1e3,1)), ' ms'];
text(x(1),yb(1),str,'fontsize',12,'FontWeight','bold')
%% NSI sama std:ll‰
fig_full, errorbar(time, DataPeaks_mean{filu_nro, 1}.data(:,col),...
    DataPeaks_mean{filu_nro, 1}.data_std(:,col))
hold all, plot(time, dat), 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
