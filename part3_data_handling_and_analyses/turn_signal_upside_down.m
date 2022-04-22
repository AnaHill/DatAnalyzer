function [Data] = turn_signal_upside_down(Data,index,datacolumns)
% function [Data] = turn_signal_upside_down(Data,index,datacolumns);
% turns data found in Data{index,1}.data(:,datacolumns) => data = -data
narginchk(3,3)
nargoutchk(0,1)

try
    for pp = 1:length(index)
        ind = index(pp);
        for kk = 1:length(datacolumns)
           col = datacolumns(kk);
           Data{ind,1}.data(:,col) = -Data{ind,1}.data(:,col);
        end
    end
catch
    error('no prober data found')    
end
end
