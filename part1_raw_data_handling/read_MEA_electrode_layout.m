function [electrode_layout, layout_name] = read_MEA_electrode_layout(mea_layout_name)
% function [electrode_layout, mea_layout_name] = read_MEA_electrode_layout(mea_layout_name)
% 
% 
% mea layout default is normal Multichannels 64 electrodes
    % Layout of Multichannels' MEA 64 electrodes
    % electrode index starting from 0
    % 	21=23	31=25	41=28	51=31	61=34	71=36
    % 12=20	22=21	32=24	42=29	52=30	62=35	72=38	82=39
    % 13=18	23=19	33=22	43=27	53=32	63=37	73=40	83=41
    % 14=15	24=16	34=17	44=26	54=33	64=42	74=43	84=44
    % ref=14	25=13	35=12	45=3	55=56	65=47	75=46	85=45
    % 16=11	26=10	36=7	46=2	56=57	66=52	76=49	86=48
    % 17=9	27=8	37=5	47=0	57=59	67=54	77=51	87=50
    % 	28=6	38=4	48=1	58=58	68=55	78=53


narginchk(0,1)
nargoutchk(1,2)

mea_folder =  '.\mea_layouts\';
% default layout that is loaded if else is given in input
if nargin < 1
    mea_layout_name = 'MEA_64_electrode_layout.txt'; 
    disp('Set default mea layout:')
    disp(mea_layout_name)
    layout_name = 'MC64';
end
% default values
delimeter_ = ' ';
HeaderLines_ = 1;

if ~strcmp(mea_layout_name,'MEA_64_electrode_layout.txt')
    warning('Other layouts: TODO if needed!')
    warning('Now choosing default layout!')
    %TODO: !!!
    mea_layout_name = 'MEA_64_electrode_layout.txt';
%     prompt = {['Give MEA Layout full path and information',10,...
%         Measurement file]};
%     dlgtitle = 'Give MEA ';
%     definputs = [mea_file_name(1:3), delimeter, num2str(HeaderLines)];
%     opts.Interpreter = 'none';
%     output_names = inputdlg(prompt,dlgtitle,[1 100],definputs,opts);
end

disp('%%%%%%%%%%%%%%%%%%%%%%')
disp('Reading MEA layout')
% fid=fopen(mea_layout_name);
% electrode_layout=textscan(fid,'%f%f','delimiter',delimeter_, 'HeaderLines', HeaderLines_ );
% fclose(fid);
temp=readtable([mea_folder,mea_layout_name]);
electrode_layout = unique(sortrows(temp));
disp('MEA layout read:')
disp(mea_layout_name)

end