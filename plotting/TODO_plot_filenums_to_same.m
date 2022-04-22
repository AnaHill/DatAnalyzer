%% TEE funktioksi:
% nyt APP:sin riviltä ~240 alkaen
% painikkeen alla
% function PlotDataButtonPushed(app, event)

%(noin rivi 240)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else % plot all filenums to same figure
                [fig_parameters] = cal_subfig_parameters(cols);
                sub_fig_rows=fig_parameters(1);
                sub_fig_cols=fig_parameters(2);
                extra_in_x_axis = 0.2; % for peak numbers
                
                if plotting_data_columns_to_same == 0
                    data_with_legend = [];
                    legs = cell(length(filenum),length(cols)); 
                else % all plots to one figure without subplots
                    legs = [];
                    data_with_legend = [];
                end
                for kk = 1:length(filenum)
                    file_index = filenum(kk);
                    if kk == 1
                        fig_full;
                    end
                    % assuming data length (#rows) to be same in each data column in one file index
                    time = 0:1/datainfo.framerate(file_index):...
                        (length(dat{file_index}.data(:,1))-1)/datainfo.framerate(file_index);
                    for pp = 1:length(cols)
                        col_index = cols(pp);
                        try
                            leg_start = ['File#', num2str(file_index),'(t=',...
                                num2str(round(datainfo.measurement_time.time_sec(file_index)/3600,1)),'h)'];
                        catch
                            leg_start = ['File#', num2str(file_index)];
                        end
                        if plotting_data_columns_to_same == 0 || length(cols) < 2
                            % if all data columns are plotted to same figure --> no subplots needed
                            % otherwise, plot subplots based on amount of chosen datacolumns 
                            subplot(sub_fig_rows,sub_fig_cols,pp)
                            if isfield(datainfo,'MEA_electrode_numbers')
                                title(['El#',num2str(datainfo.MEA_electrode_numbers(col_index))]);
                            else
                                title(['Col#',num2str(datainfo.datacol_numbers(col_index))]);
                            end
                            data_with_legend(kk,pp) = plot_data_with_linestyle(dat{file_index}.data(:,col_index),time);
                            % legend can be shorter as subplot title tells data column info
                            legs{kk,pp} = [leg_start];% ,', file_index=',num2str(file_index)];
                        else % no subplots: include el/col# in legend
                            data_with_legend(end+1) = plot_data_with_linestyle(dat{file_index}.data(:,col_index),time);
                            if isfield(datainfo,'MEA_electrode_numbers')
                                legs{end+1} = [leg_start,': El#',num2str(datainfo.MEA_electrode_numbers(col_index))];
                            else
                                legs{end+1} = [leg_start,': Col#',num2str(datainfo.datacol_numbers(col_index))];
                            end
                            
                        end
                        hold all
  
                        
                        if bpm_found == 1 % plotting possible peaks
                            try
                                peak_times = time(datbpm{file_index,1}.peak_locations_high{col_index});
                                peak_values = datbpm{file_index,1}.peak_values_high{col_index};
                                plot(peak_times, peak_values,'ro')
                                highpeak_amount = length(peak_values);
                                % if include peak numbers in plot
                                if plotting_peak_numbers == 1
                                    text(peak_times+extra_in_x_axis,peak_values,...
                                        num2str((1:numel(peak_times))'))
                                end
                            catch %  ('no high peaks found')
                                highpeak_amount = 0;
                            end
                            try
                                peak_times = time(datbpm{file_index,1}.peak_locations_low{col_index});
                                peak_values = datbpm{file_index,1}.peak_values_low{col_index};
                                plot(peak_times, peak_values,'x','color',[0 .5 0.])
                                lowpeak_amount = length(peak_values);
                                % if include peak numbers in plot
                                if plotting_peak_numbers == 1
                                    text(peak_times+extra_in_x_axis,peak_values,...
                                        num2str((1:numel(peak_times))'))
                                end
                            catch %  ('no low peaks found')
                                lowpeak_amount = 0;
                            end
                        end % end: % plotting possible peaks
                        axis tight
                    end
                end
                sgtitle([datainfo.experiment_name, ' - ', datainfo.measurement_name],...
                    'interpreter','none','fontsize',12)
                if plotting_data_columns_to_same == 0
                    % each subplots with own legends
                    for pp = 1:length(cols)
                        subplot(sub_fig_rows,sub_fig_cols,pp)
                        legend(data_with_legend(:,pp), legs(:,pp), 'location', 'best','interpreter','none')
                    end
                    
                else
                    legend(data_with_legend, legs, 'location', 'best','interpreter','none')
                end
                zoom on
            end % end_: plot all filenums to same figure