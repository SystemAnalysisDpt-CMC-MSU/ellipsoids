function resStr=strucdisp(SInp,varargin)
% STRUCDISP  display structure outline
%
% Usage: STRUCDISP(STRUC,fileName,'depth',DEPTH,'printValues',PRINTVALUES,...
%           'maxArrayLength',MAXARRAYLENGTH) stores
%        the hierarchical outline of a structure and its substructures into
%        the specified file
%
% Input:
%   regular:
%       SInp: struct[1,1] - is a structure datatype with unknown field
%           content. It can be  either a scalar or a vector, but not a
%           matrix. STRUC is the only mandatory argument in this function.
%           All other arguments are optional.
%
%   optional
%       fileName: char[1,] is the name of the file to which the output
%           should be printed. if this argument is not defined, the output
%           is printed to the command window.
%
%   properties
%       depth: numeric[1,1] - the number of hierarchical levels of
%           the structure that are printed. If DEPTH is smaller than zero,
%           all levels are printed. Default value for DEPTH is -1
%           (print all levels).
%
%       printValues: logical[1,1] -  flag that states if the field values
%           should be printed  as well. The default value is 1 (print values)
%
%       maxArrayLength: numberic[1,1] - a positive integer,
%           which determines up to which length or size the values of
%           a vector or matrix are printed. For a  vector holds that
%           if the length of the vector is smaller or equal to
%           MAXARRAYLENGTH, the values are printed. If the vector is
%           longer than MAXARRAYLENGTH, then only the size of the
%           vector is printed. The values of a 2-dimensional (m,n)
%           array are printed if the number of elements (m x n) is
%           smaller or equal to MAXARRAYLENGTH. For vectors and arrays,
%           this constraint overrides the PRINTVALUES flag.
%       numberFormat: char[1,] - format specification used for displaying
%           numberic values, passed directly to sprintf, by default '%g' is
%           used
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-08 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

import modgen.common.type.simple.checkgen;
import modgen.common.parseparext;
%% Constants
FILLER_SYMBOL_CODE=modgen.struct.StructDisp.FILLER_SYMBOL_CODE;
DASH_SYMBOL_CODE=modgen.struct.StructDisp.DASH_SYMBOL_CODE;
%% Main program
%%%%% start program %%%%%
checkgen(SInp,'isstruct(x)');
[reg,~,depth,inpPrintValues,maxArrayLength,numberFormat,structureName]=parseparext(varargin,...
    {'depth','printValues','maxArrayLength','numberFormat','defaultName';...
    modgen.struct.StructDisp.DEFAULT_DEPTH,...
    modgen.struct.StructDisp.DEFAULT_PRINT_VALUES,...
    modgen.struct.StructDisp.DEFAULT_MAX_ARRAY_LENGTH,...
    modgen.struct.StructDisp.DEFAULT_NUMBER_FORMAT,...
    modgen.struct.StructDisp.DEFAULT_NAME;
    'isscalar(x)&&isnumeric(x)&&fix(x)==x',...
    'islogical(x)&&isscalar(x)',...
    'isscalar(x)&&isnumeric(x)&&fix(x)==x&&x>0',...
    'isstring(x)',...
    'isstring(x)'},[0,1],...
    'regDefList',{''});
fileName=reg{1};
% start recursive function
listStr = modgen.struct.StructDisp.recFieldPrint(SInp, 0, inpPrintValues,...
    structureName, maxArrayLength, depth, numberFormat,...
    DASH_SYMBOL_CODE, FILLER_SYMBOL_CODE);

% 'listStr' is a cell array containing the output
% Now it's time to actually output the data
% Default is to output to the command window
% However, if the filename argument is defined, output it into a file
resultString=modgen.string.catwithsep(listStr,sprintf('\n'));
if nargout==0
    % write data to screen
    disp(resultString);
else
    resStr=[resultString,sprintf('\n')];
end
if ~isempty(fileName)
    % open file and check for errors
    fid = fopen(fileName, 'wt');
    if fid < 0
        error('Unable to open output file');
    end
    % write data to file
    nListRows=length(listStr);
    for iListRow = 1 : nListRows
        fprintf(fid, '%s\n', listStr{iListRow});
    end
    % close file
    fclose(fid);
end