function saving_name = choose_saving_name(save_name_default)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
narginchk(0,1)
nargoutchk(0,1)
if nargin < 1
    save_name_default = {'temp'};
end

prompt = {['Write saving name']};
dlgtitle = 'Set name';
definputs = [save_name_default];
opts.Interpreter = 'none';
out = inputdlg(prompt,dlgtitle,[1 100],definputs,opts);
saving_name = out{1};
