# DatAnalyzer
Tools to load, visualize, and analyse data using MATLAB.  
_Please notice, that this readme is currently under development!_

The main philosophy of this program is to provide flexible, customizable semi-autonomous data analysis tools. Idea is, that all functionalities can be used either through GUI (DatAnalyzer App) or through MATLAB's command line (or scripts). The meaning of semi-autonomous here is that DatAnalyzer provides _i_) quite good automatic settings, for example to detect most of the peaks from large data-sets, and _ii_) flexible tools to manually modify these found peaks, for example deleting some incorrect ones or add individual missing peaks. More details are given in the following paper; if you find DatAnalyzer useful, please consider citing this: 
> Mäki, A.-J. (2023). Opinion: The correct way to analyze FP signals. Zenodo. https://doi.org/10.5281/zenodo.10205591

**Notice: currently, DatAnalyzer works best with MEA .h5 files**  
Before MEA data can be viewed or analyzed, measurement files must be converted to HDF5 (.h5) files. 
If using Multichannel Systems devices, this data conversion to .h5 files can be done using their MultiChannel Systems Data Manager software, available [here](https://www.multichannelsystems.com/software/multi-channel-datamanager#docs).

Snapshot below shows the opening page of the developed GUI.
![DatAnalyzer_GUI](doc_pics/DatAnalyzer_GUI.png)  
**Figure 1.** Main page of DatAnalyzer GUI. Highlighted parts are following: 1) plotting raw data and found peaks, 2) saving and loading, 3) load and process raw data, 4) findling and handling peaks, 5) analysis, 6) plotting final results.

## Installation
Prerequisites for DatAnalyzer
- MATLAB R2018B or newer


Installing files either cloning
```
git clone https://github.com/AnaHill/DatAnalyzer.git
```
Or choose Code --> Download ZIP --> unzip files to some folder in your computer. Snapshot below highlights these steps.  
![How to download codes](doc_pics/Download_zip.png)  
**Figure 2.** Downloading codes.

Add your folder (_with subfolder_!) to MATLAB's path (see snapshot below): Home tab --> Set Path --> Add with Subfolders  
![Set path](doc_pics/set_matlab_path.png)  
**Figure 3.** Setting DatAnalyzer folder for MATLAB path.

## Citations
DatAnalyzer has been developed at Tampere University (TAU) in [Micro- and Nanosystems Research Group](https://research.tuni.fi/mst/) (MST) lead by professor Pasi Kallio. 
It has partly developed during the collaboration project between MST and TAU's [Heart Group](https://research.tuni.fi/heart-group/) lead by professor Katriina Aalto-Setälä. 

It has been used at least in the following studies: 
> - Mäki, A.-J. (2023). Opinion: The correct way to analyze FP signals. Zenodo. https://doi.org/10.5281/zenodo.10205591
> - Lönnrot, A. et al. (2025). Patient-derived Lamin A/C mutant cardiomyocytes demonstrate altered electrophysiological characteristics and responses to hypoxia induced stress. _Next Research_, Vol. 2(3), 100640. https://doi.org/10.1016/j.nexres.2025.100640
> - Häkli, M. et al. (2022). Electrophysiological changes of human-induced pluripotent stem cell-derived cardiomyocytes during acute hypoxia and reoxygenation. _Stem Cells International_, Vol. 2022, 9438281. https://doi.org/10.1155/2022/9438281
> - Häkli, M. et al. (2021). Human induced pluripotent stem cell-based platform for modeling cardiac ischemia. _Scientific Reports_, Vol. 11(1), 4153. https://doi.org/10.1038/s41598-021-83740-w


## Example Data and tutorial for DatAnalyzer
_Notice: Example data used in the tutorial will be available later._ 
<!-- in[TBA](https://google.com)._ TODO #3:link --> 

This section introduces briefly DatAnalyzer. Basic steps are following
1) loading raw data
2) data exploration (plotting)
3) finding peaks
4) analyze

In the following example, MEA raw data (.h5 files) is loaded and analyzed. This dataset includes 129 .h5 files from 60 MEA electrodes measurement. In the example, only four previously chosen electrodes are used for the analysis.

### Load raw data
Go to _Load & process data_ tab to load data, where you can fill the following fields. Notice, that this is only recommendation, not compulsory, as these parameters will be asked again later during the loading process. The figure below shows which sections were filled 
- `experiment name`: MEA2020_03_02 (experimental name that can include several parallel measurements that arre separated with the next field)
- `measurement name`: MEA21002b (used to separate parallel experiments belonging to same experiment)
- `measurement date`: 2020_03_02 (starting day of the experiment) 

In addition, so-called "good MEA electrodes" were chosen beforehand to reduce the amount of data loaded. In this example, MEA electrodes 21, 28, 31, and 51 had a reasonable beating and were chosen for further analysis. _MEA Layout_ field, showed in Tutorial Figure 1, is now empty as a default electrode layout, Multichannels 60-MEA, is used. In case of other layout, you should load text file that has similar structure than file `mea_layouts\MEA_64_electrode_layout.txt`: first column indicates electode number, second _index_ points colummn in the raw data. Please also notice that currently, choose of the "good" electrodes is a manual process, which can be done in MATLAB or any other software beforehand. So-called automatical "good data recommender" have been developed separately but it had not yet been implemented in DatAnalyzer.

After the fields are filled, click _Read raw data_ button as shown in Tutorial Figure 1. For the start, choose folder where your data is located. During loading process, DatAnalyzer will ask several questions. Firstly, it asks that are all found data (files) or only some used. This can be used to pick only certain data files from the chosen folder. If you click _Choose_, you can pick which files are loaded as shown in the following figure (4b). Then, loading of raw data files is started, and finally, there should be two variables, Data and DataInfo, on the Workspace.


![loading_example_data](doc_pics/load_raw_data_process.png)
**Tutorial Figure 1.** Process of loading raw data: 1) setting initial parameters and clicking  _Read raw data_ button, 2) choosing raw data folder, 3) a screenshot of the command window listing files found on the folder, 4) using all the found files or choosing some of those; if latter chosen, window like presented in 4b) is provided to choose specific file(s), 5) a screenshot of reading process displayed on Command Window, and 6) finally, two variables (Data and DataInfo) are created on the Workscape.

During process, if will be asked "_Want to plot every 10th data?_". If chosen yes, it will be plot every 10th for fast checking. With this, first and last data are always plotted (as presented below in Tutorial Figure 2), resulting that in the example (with 129 files), totally 14 separate 2x2 subplot figures are plotted. 

![Plotting_every_10th](doc_pics/plotting_every_10th_process.png)
**Tutorial Figure 2.** Demonstration what data will be plotted if answere Yes to Plot fig question.

## Data exploration and plotting
Before finding peaks for further analysis, it is typically useful to manually check loaded data. The main parts are presented in Tutorial Figure 3.

![Plotting tools presented](doc_pics/plotting_tools.png)
**Tutorial Figure 3.** Plotting tools for data exploration: 1) choosing file numbers and data columns (electodes); if field `Datacolumns` is set to _All_, all columns will be plotted, but this can be changed by clicking _choose_, and writing wanted data column number(s) to appeared _columns_ field as shown in the inspect; 2) choosing, how chosen data are plotted, e.g. in separate or same figure. Examples will be given below; 3) choosing plot parameters (figure size and are found peaks included) and plotting data.

Next, some examples of how data can be plotted are given using options presented in part 2) in Tutorial Figure 3. Figures are using files numbered 1, 50, and 129 (last one), and all data columns, which is four different electrodes in this example. Notice, that in the following figures, the figure size is set to MATLAB's default size as highlighted in Tutorial Figure 4.

![Example raw plot1](doc_pics/plot_raw_example1.png)
**Tutorial Figure 4.** Example raw plot#1: when neither data columns or data files to same are not checked, three separate 2x2 subplots are plotted.

![Example raw plot2](doc_pics/plot_raw_example2.png)
**Tutorial Figure 5.** Example raw plot#2: when data columns to same are checked, three separate figures without subplots are plotted; each plot includes all four electode data separated by colors.

![Example raw plot3](doc_pics/plot_raw_example3.png)
**Tutorial Figure 6.** Example raw plot#3: when both data columns and files to same are checked, only one figure including all 12 signals (3 files * 4 electrodes) is plotted.

With the tools presented above, you can estimate what would be good rules to find the peaks. This will be explained in next section.

### Find peaks
This part involves includes the most of the required manual work in the whole analysis process. I strongly believe, that it is very difficult, if not even impossible, to totally automatize this step so that it would handle all the possible field potential signals. This is because signal amplitudes, frequencies, signal-to-noise ratios, and signal forms varies greatly between different measurements, electrodes, used hardware set-up. (e.g. used amplifier), and so on. More correctly each individual peak is defined will improve the following analysis. Therefore, DatAnalyzer is designed to take the following semi-autonomous approach so that the user can easily:
1) find peaks in batch mode from all the files and datacolumns (i.e. electrodes), or only find peaks for specific data files and/or data colummns addressed by the user
2) find/add invidual missing peaks on specific locations (file, datacolumn, time range)
3) remove specific, typically incorrect, peaks

To demonstrate above statements, we will first find low peaks from each data file. Looking raw data that was presented in the previous section, we estimated that minimum peak amplitude could be set to 5e-5 (V, i.e. 50 µV), and max beating frequency Max BPM to 40 beats-per-minute as shown in Tutorial Figure 7. With these parameters, we will find quite many correct peaks as shown in Tutorial Figure 8, however, some manual tuning is needed as shown in Tutorial Figure 9.

![Example peak find plot1](doc_pics/find_peaks_1.png)
**Tutorial Figure 7.** Finding peaks: intial run to batch all signals. Properties are set in 1), where filenums, data columns, and peak rules are set. Peak finding is started with find_peaks_with_rules button. After processed, Data_BPM variable should be created on MATLAB Workspace as shown in 2). Next, in 3) six different files (file numbers 1, 31, 61, 91, 121, and 129) are plotted. 
<!-- These figures are discussed in more detail in the following figures.  -->



![Example peak find plot2](doc_pics/find_peaks_2.png)
**Tutorial Figure 8.** Example plot (data file number 31) showing raw signal with found peaks.

![Example peak find plot3](doc_pics/find_peaks_3.png)
**Tutorial Figure 9.** Example plot (data file number 1) where one peak was not originally found as highlighted in 1) and 2). This peak can be found using GUI as demonstrated in 3): finding local maxima (in absolut term) on proper time range.


### Analyze peaks
Peak analysis can be performed after peaks are correctly found. This is demonstrated in Tutorial Figure 9, which shows steps to create variables `Data_BPM_summary`, `DataPeaks`, `DataPeaks_mean`, and finally `DataPeaks_summary`. After that, using `Plot DataPeaks_summary` found in _Plotting_ tab can be used to plot the final results.

![Analysis plot1](doc_pics/analysis_1.png)
**Tutorial Figure 9.** Signal analysis: highlighting buttons that are used to create 1) `Data_BPM_summary` , 2) `DataPeaks`, 3) `DataPeaks_mean`, and 4) `DataPeaks_summary`.

![Analysis plot2](doc_pics/analysis_2.png)
**Tutorial Figure 10.** Plotting `DataPeaks_summary` to summarize beating rate (BPM), signal amplitude (mV), and corrected field potential duration (FPDc) on one figure.

## Code structure
```text 
DatAnalyzer
│   DatAnalyzer.mlapp
│   DatAnalyzer_main.m
│   MEA_data_analysis_main.m
│   README.md
│
├───doc_pics
│       analysis_1.png
│       analysis_2.png
│       Choose_data_files.png
│       DatAnalyzer_GUI.png
│       Download_zip.png
│       find_peaks_1.png
│       find_peaks_2.png
│       find_peaks_3.png
│       load_raw_data_process.png
│       plotting_every_10th_process.png
│       plotting_tools.png
│       plot_raw_example1.png
│       plot_raw_example2.png
│       plot_raw_example3.png
│       question_plotting_every_10th.png
│       set_matlab_path.png
│
├───mea_layouts
│       MEA_64_electrode_layout.txt
│
├───part1_raw_data_handling
│       choose_files.m
│       convert_begin_string_in_filename_to_datetime.m
│       convert_end_string_in_filename_to_datetime.m
│       create_DataInfo_framerate_using_get_h5info.m
│       create_DataInfo_start.m
│       create_Data_and_DataInfo_from_mea_data.m
│       create_Data_from_h5files.m
│       create_time_names_for_DataInfo.m
│       find_MEA_electrode_index.m
│       find_MEA_electrode_number_from_datacol_index.m
│       get_Data_and_DataInfo_from_MEA_in_loop.m
│       get_files.m
│       get_h5info.m
│       get_h5_framerate.m
│       list_files.m
│       load_raw_mea_data_to_Data_and_DataInfo.m
│       read_chosen_mea_electrode_data.m
│       read_h5_to_data.m
│       read_hypoxia_info.m
│       read_mea_data_MAIN.m
│       read_MEA_electrode_layout.m
│       read_o2_data_to_DataInfo.m
│       read_raw_mea_file.m
│       read_wanted_electrodes_of_measurement.m
│       remove_offset.m
│       remove_offset_from_single_data_and_update_Data.m
│       set_experimental_names.m
│       set_initial_names.m
│       update_DataInfo.m
│
├───part2_peak_handling
│   │   add_first_peak_from_low_peak_signal.m
│   │   add_local_max_from_low_peak.m
│   │   add_max_value_as_high_peak_from_low_peak.m
│   │   add_min_value_as_low_peak_from_high_peak.m
│   │   add_peaks_from_other.m
│   │   add_peak_with_time.m
│   │   check_peak_distance_from_edges.m
│   │   define_other_peaks_from_main_peaks.m
│   │   delete_all_peaks.m
│   │   delete_peaks_above_value.m
│   │   delete_peaks_below_value.m
│   │   delete_peaks_with_peaknumber.m
│   │   delete_peaks_with_time.m
│   │   find_main_peak_before_antipeak.m
│   │   find_peaks_in_loop.m
│   │   find_peaks_in_loop_from_time_range.m
│   │   find_peak_start_or_end.m
│   │   index_peak_numbers_in_time_range.m
│   │   modify_individual_peak.m
│   │   run_check_edges.m
│   │   set_default_filetype_rules_for_peak_finding.m
│   │   set_signal_type.m
│   │   trim_peaks_values_and_locations.m
│   │   update_max_bpm_rule.m
│   │
│   └───findpeak_functions_from_others
│           findpeaksG.m
│           findpeaksx.m
│           find_peaks_in_loop_peakfinder.m
│           gaussfit.m
│           ipeak.m
│           peakfinder.m
│
├───part3_data_handling_and_analyses
│       calculate_and_check_fft.m
│       check_and_plot_irregular_data.m
│       check_irregular_data.m
│       create_BPM_summary.m
│       create_hypoxia_time_names.m
│       filter_signal_data.m
│       find_indexes_in_given_time_range.m
│       include_peak_distance_matrix_to_Data_BPM_summary.m
│       index_irregular_beating.m
│       run_hypoxia_info_to_DataInfo.m
│       set_hypoxia_info_to_DataInfo_with_datetime.m
│       should_high_peak_data_be_used.m
│       turn_signal_and_Data_BPM.m
│       update_Data_BPM.m
│       update_Data_BPM_peaks_with_low_or_high_peaks.m
│       update_Data_BPM_single_file.m
│
├───part4_datamean_analyses
│       check_peak_forms.m
│       fpd1_find_first_peak_and_depolarization_amplitude.m
│       fpd2_find_fp_start_and_depolarization_time.m
│       fpd3_find_repolarization_peak.m
│       fpd4_find_fp_end_and_calculate_fpd.m
│       fpd_find_low_peaks.m
│       get_peak_signals.m
│       get_peak_signal_average.m
│       plot_signal_average.m
│       slice_peak_data.m
│       which_fpd_correction.m
│
├───plotting
│       calculate_subfig_grid.m
│       cal_subfig_parameters.m
│       create_datacolumn_text.m
│       create_experiment_info_text.m
│       create_figure_with_size.m
│       delete_certain_lines_from_figure.m
│       fig_full.m
│       fig_half.m
│       limit_y_axes.m
│       ntitle.m
│       plotDatainfig.m
│       plot_chosen_data_files.m
│       PLOT_datacolumns_from_multiple_files.m
│       plot_DataMean.m
│       PLOT_DataOnly.m
│       PLOT_DataOnly_no_own_figure.m
│       PLOT_DataWithPeaks.m
│       PLOT_DataWithPeaks_no_own_fig.m
│       PLOT_DataWithPeaks_no_own_figure.m
│       PLOT_Data_and_mp_ap_fp.m
│       plot_data_to_subplots.m
│       plot_data_to_subplots_with_layout.m
│       plot_data_with_linestyle.m
│       plot_fft.m
│       plot_files_with_irregular_beating.m
│       plot_fp_summary.m
│       plot_hypoxia_line.m
│       PLOT_multiple_data_with_peaks.m
│       plot_peak_distance_matrix.m
│       plot_quick_BPM_summary_plot.m
│       PLOT_signal_upside_down.m
│       plot_signal_with_fpd_parameters.m
│       plot_summary.m
│       plot_summary_of_irregular_data.m
│       plot_tdep.m
│       set_figure_to_half_or_full_screen_size.m
│       set_sqtitle.m
│       slice_and_plot_datapeak_signals.m
│       Summarize_plot_DataPeaks_summary.m
│       tight_subplot.m
│
├───saving
│       choose_saving_folder.m
│       choose_saving_name.m
│       save_data_files.m
│       save_each_data_in_Data_to_single_mat_files.m
│
└───utils
        calculate_threshold_value.m
        choose_timep_unit.m
        convert_indexes_to_sec.m
        convert_seconds_to_different_time_units.m
        create_data_and_ylabel_text_for_peak_analysis_plot.m
        disp_found_peaks.m
        filter_data.m
        find_first_index_where_data_reach_threshold.m
        find_max_or_min.m
        find_max_or_min_with_lowpass.m
        find_peak_info.m
        remove_data_from_DataInfo_variable.m
        remove_data_from_Data_BPM_variable.m
        remove_data_from_Data_variable.m
        remove_other_variables_than_needed.m
``` 

# Future improvements
**Backlog  & Long-term goals**
**Currently under development**
- [ ] Provide link to example data
- [ ] Good data recommender: checks raw (MEA) data and recommends "most suitable" electrodes 
  - Recommended data/electrodes should include measurement information (e.g. beating signal) as typically many electrodes mainly include noise
- [ ] .abf file reading for MEA files
- [ ] GUI: fusing Analysis and plotting tabs to single tab
- [ ] Area under curve calculation for FP signal
- [ ] Calculate and visualize signal propagation (for MEA files)
- [ ] More interactive GUI, e.g. user could
  - [ ] delete or add peaks by clicking mouse
  - [ ] crop data by mouse for partial data analysis, e.g. only consider time between 10 and 15 sec in a minute-long recording
- [ ] Include more data filtering options
- [ ] Architectural change enabling better data analysis
