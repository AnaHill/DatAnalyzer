function delete_certain_lines_from_figure(linenumbers_to_delete, hfig)
% function delete_certain_lines_from_figure(linenumbers_to_delete, hfig)
% E.g. delete datalines 1 & 3 from current figure
% delete_certain_lines_from_figure([1,3])
narginchk(1,2)
% linenumber_to_delete = 2;
if nargin < 2 || isempty(hfig)
    if ~isempty(findobj('Type', 'figure'))
        fig_parameters = get(gcf);
    else
        warning('no opened figures!')
        return
    end
end
% number_of_subfigs=0;
for pp = 1:length(fig_parameters.Children)
    if strcmp(fig_parameters.Children(pp).Type,'axes')
         gca = fig_parameters.Children(pp);
         delete(gca.Children(end-linenumbers_to_delete+1)), 
         if strcmp(gca.YLimMode,'auto')
            ylim('auto')
         else % TODO: e.g. normalized figure
             
         end
    end
end



end
