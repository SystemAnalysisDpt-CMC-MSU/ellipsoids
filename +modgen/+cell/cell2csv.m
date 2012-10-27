function cell2csv(datName,cellArray,seperator,excelVersion)
% Writes cell array content into a *.csv file.
% 
% CELL2CSV(datName,cellArray,seperator,excelVersion)
%
% datName      = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray    = Name of the Cell Array where the data is in
% seperator    = seperating sign, normally:',' (it's default)
% excelVersion = depending on the Excel Version, the cells are put into
%                quotes before added to the file (only numeric values)
%
%         by Sylvain Fiedler, KA, 2004
% updated by Sylvain Fiedler, Metz, 06
% fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler

if seperator ~= ''
    seperator = ',';
end

if excelVersion > 2000
    seperator = ';';
end
%
[fid,messageStr] = fopen(datName,'w');
if fid<0
    modgen.common.throwerror('failedToOpenFile',...
        ['cannot create file %s for writing, reason:',messageStr],datName);
end
%
try
    for z=1:size(cellArray,1)
        for s=1:size(cellArray,2)
            var=cellArray{z,s};
            
            if ~isempty(var)
                if isnumeric(var)
                    var = num2str(var);
                elseif islogical(var)
                    if var
                        var = 'TRUE';
                    else
                        var = 'FALSE';
                    end
                end
                if excelVersion > 2000
                    var = ['"' var '"'];
                end
                fprintf(fid,var);
            end
            if s ~= size(cellArray,2)
                fprintf(fid,seperator);
            end
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
catch meObj
    fclose(fid);
    rethrow(meObj);
end