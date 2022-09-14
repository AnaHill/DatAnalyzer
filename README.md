# DatAnalyzer
Tools to load, visualize, and analyse data using MATLAB.  
_Please notice, that this readme is currently under developement!_

The main philosophy of this program is to provide flexible, customizable semi-autonomous data analysis tools. Idea is, that all functionalities can be used either through GUI (DatAnalyzer App) or through MATLAB's command line (or scripts). The meaning of semi-autonomous here is that DatAnalyzer provides _i_) quite good automatic settings, for example to detect most of the peaks from large data-sets, and _ii_) flexible tools to manually modify these found peaks, for example deleting some incorrect ones or add individual missing peaks.

**Please notice that currenly, DatAnalyzer works best with MEA .h5 files**  
Before MEA data  can be viewed or analyzed, measurement files must be converted to HDF5 files. Multichannel Systems data, this can be done using their MultiChannel Systems Data Manager software (available [here](https://www.multichannelsystems.com/software/multi-channel-datamanager#docs))

GUI is following
![DatAnalyzer](doc_pics/2022-09-13-08-34-27.png)



## Installation
Prerequisites for DatAnalyzer
- MATLAB R2018B or newer


Installing files either cloning
```
git clone https://github.com/AnaHill/DatAnalyzer.git
```
Or choose Code --> Download ZIP --> unzip files to some folder in your computer. Snapshot below highlights these steps.
![How to download codes](doc_pics/2022-09-12-13-51-12.png)

Add this folder to MATLAB's path (see snapshot below): Home tab --> Set Path --> Add with Subfolders
![Set path](doc_pics/2022-09-14-08-39-58.png)

## References and Citation
DatAnalyzer was partly developed during the research related to following paper. If you find DatAnalyzer useful, please consider citing 
> Häkli, M., Kreutzer, J., Mäki, A.-J., Välimäki, H., Lappi, H., Huhtala, H., Kallio, P., Aalto-Setälä, K., & Pekkanen-Mattila, M. (2021). Human induced pluripotent stem cell-based platform for modeling cardiac ischemia. Scientific Reports, 11(1), 4153. https://doi.org/10.1038/s41598-021-83740-w

## Code structure
- TBA


## Example Data and tutorial for DatAnalyzer

Example data, that is used in the following tutorial is available [here](https://google.com).TODO #3:link

## Future improvements
TO DO list: currently under development
- [ ] Provide link to example data and write tutorial
- [ ] Good data recommender: checks raw (MEA) data and recommends "most suitable" electrodes 
  - Recommended data/electrodes should include measurement information (e.g. beating signal) as typically many electrodes mainly include noise
- [ ] cropping data: user could crop data by mouse, e.g. covering only time between 10 and 15 sec in 1 minute long recording
- [ ] abf file reading for MEA files

Backlog / Long-term goals
- [ ] Calculate and visualize signal propagation (for MEA files)
- [ ] Architechture change so that big data analysis
- [ ] More interactive GUI, e.g. user could delete or add peaks by clicking mouse
- [ ] GUI: fusing Analysis and plotting tabs to single tab
- [ ] Data filtering 
