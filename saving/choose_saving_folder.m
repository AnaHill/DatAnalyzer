function [saving_folder] = choose_saving_folder(starting_folder)
% ask folder where to save files
narginchk(0,1)
nargoutchk(0,1)

if nargin < 1
    starting_folder =  pwd;
end
try
    saving_folder = [uigetdir(starting_folder,'Choose saving folder'),'\'];
catch
    saving_folder = pwd;
    warning('Saving folder not chosen, choosing current working directory')
end
disp(['Saving folder is: ',saving_folder])
end
