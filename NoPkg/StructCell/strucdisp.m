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
FILLER_SYMBOL_CODE=32;
DASH_SYMBOL_CODE=45;
DEFAULT_MAX_ARRAY_LENGTH=10;
DEFAULT_DEPTH=-1;
DEFAULT_PRINT_VALUES=true;
DEFAULT_NUMBER_FORMAT='%g';
DEFAULT_NAME = 'Structure';
%% Main program
%%%%% start program %%%%%
checkgen(SInp,'isstruct(x)');
[reg,~,depth,inpPrintValues,maxArrayLength,numberFormat,structureName]=parseparext(varargin,...
    {'depth','printValues','maxArrayLength','numberFormat','defaultName';...
    DEFAULT_DEPTH,...
    DEFAULT_PRINT_VALUES,...
    DEFAULT_MAX_ARRAY_LENGTH,...
    DEFAULT_NUMBER_FORMAT,...
    DEFAULT_NAME;
    'isscalar(x)&&isnumeric(x)&&fix(x)==x',...
    'islogical(x)&&isscalar(x)',...
    'isscalar(x)&&isnumeric(x)&&fix(x)==x&&x>0',...
    'isstring(x)',...
    'isstring(x)'},[0,1],...
    'regDefList',{''});
fileName=reg{1};
% start recursive function
listStr = recFieldPrint(SInp, 0, inpPrintValues);

% 'listStr' is a cell array containing the output
% Now it's time to actually output the data
% Default is to output to the command window
% However, if the filename argument is defined, output it into a file

if nargout==0
    % write data to screen
    for i = 1 : length(listStr)
        disp(cell2mat(listStr(i, 1)));
    end
else
    resStr='';
    for i = 1 : length(listStr)
        resStr=[resStr,evalc('disp(cell2mat(listStr(i, 1)))')];
    end
end
if ~isempty(fileName)
    % open file and check for errors
    fid = fopen(fileName, 'wt');
    if fid < 0
        error('Unable to open output file');
    end
    % write data to file
    for i = 1 : length(listStr)
        fprintf(fid, '%s\n', cell2mat(listStr(i, 1)));
    end
    % close file
    fclose(fid);
end

%% FUNCTION: recFieldPrint
    function listStr = recFieldPrint(Structure, indent,printValues)
        if nargin<3
            printValues=inpPrintValues;
        end
        % Start to initialiase the cell listStr. This cell is used to store all the
        % output, as this is much faster then directly printing it to screen.
        listStr = {};
        
        % "Structure" can be a scalar or a vector.
        % In case of a vector, this recursive function is recalled for each of
        % the vector elements. But if the values don't have to be printed, only
        % the size of the structure and its fields are printed.
        if numel(Structure) > 1
            if (printValues == 0)
                varStr = createArraySize(Structure, 'Structure');
                listStr = [{' '}; {[structureName, varStr]}];
                body = recFieldPrint(Structure(1), indent);
                listStr = [listStr; body; {'   O'}];
            else
                sizeVec = size(Structure);
                indexVec = ones(1, length(sizeVec));
                for iStruc = 1 : min(numel(Structure), maxArrayLength)
                    if (~isvector(Structure))
                        indexStr = [structureName, '('];
                        for iDimension = 1 : length(sizeVec) - 1
                            indexStr = [indexStr, sprintf('%d, ',...
                                indexVec(iDimension))];
                        end
                        indexStr = [indexStr, sprintf('%d)', indexVec(end))];
                        indexVec = incrementIndexVec(indexVec, sizeVec);
                    else
                        indexStr = sprintf([structureName,'(%d)'], iStruc);
                    end
                    listStr = [listStr; {' '}; {indexStr}];
                    body = recFieldPrint(Structure(iStruc), indent);
                    listStr = [listStr; body; {'   O'}];
                end
                if (numel(Structure) > maxArrayLength)
                    listStr = [listStr; {' '}; sprintf('<<%d elements more>>', ...
                        numel(Structure) - maxArrayLength)];
                end
            end
            return
        end
        
        %% Select structure fields
        % The fields of the structure are distinguished between structure and
        % non-structure fields. The structure fields are printed first, by
        % recalling this function recursively.
        
        % First, select all fields.
        %
        fields = fieldnames(Structure);
        % Next, structfun is used to return an boolean array with information of
        % which fields are of type structure.
        if isempty(fields)
            return;
        end
        isStruct = structfun(@isstruct, Structure);
        % Finally, select all the structure fields
        
        strucFields = fields(isStruct == 1);
        
        %% Recursively print structure fields
        % The next step is to select each structure field and handle it
        % accordingly. Each structure can be empty, a scalar, a vector or a matrix.
        % Matrices and long vectors are only printed with their fields and not with
        % their values. Long vectors are defined as vectors with a length larger
        % then the maxArrayLength value. The fields of an empty structure are not
        % printed at all.
        % It is not necessary to look at the length of the vector if the values
        % don't have to be printed, as the fields of a vector or matrix structure
        % are the same for each element.
        
        % First, some indentation calculations are required.
        
        strIndent = getIndentation(indent + 1);
        listStr = [listStr; {strIndent}];
        strIndent = getIndentation(indent);
        
        % Next, select each field seperately and handle it accordingly
        
        for iField = 1 : length(strucFields)
            fieldName = cell2mat(strucFields(iField));
            Field =  Structure.(fieldName);
            %
            % Empty structure
            if isempty(Field)
                strSize = createArraySize(Field, 'Structure');
                line = sprintf('%s   |--- %s :%s', ...
                    strIndent, fieldName, strSize);
                listStr = [listStr; {line}];
                %
                % Scalar structure
            elseif isscalar(Field)
                line = sprintf('%s   |--- %s', strIndent, fieldName);
                % Recall this function if the tree depth is not reached yet
                if (depth < 0) || (indent + 1 < depth)
                    lines = recFieldPrint(Field, indent + 1);
                    listStr = [listStr; {line}; lines; ...
                        {[strIndent '   |       O']}];
                else
                    listStr = [listStr; {line}];
                end
                %
                % Short vector structure of which the values should be printed
            elseif (isvector(Field)) &&  ...
                    (printValues > 0) && ...
                    (length(Field) < maxArrayLength) && ...
                    ((depth < 0) || (indent + 1 < depth))
                %
                % Use a for-loop to print all structures in the array
                for iFieldElement = 1 : length(Field)
                    line = sprintf('%s   |--- %s(%g)', ...
                        strIndent, fieldName, iFieldElement);
                    lines = recFieldPrint(field(iFieldElement), indent + 1);
                    listStr = [listStr; {line}; lines; ...
                        {[strIndent '   |       O']}];
                    if iFieldElement ~= length(Field)
                        listStr = [listStr; {[strIndent '   |    ']}];
                    end
                end
                %
                % Structure is a matrix or long vector
                % No values have to be printed or depth limit is reached
            else
                varStr = createArraySize(Field, 'Structure');
                line = sprintf('%s   |--- %s :%s', ...
                    strIndent, fieldName, varStr);
                lines = recFieldPrint(Field(1), indent + 1,false);
                listStr = [listStr; {line}; lines; ...
                    {[strIndent '   |       O']}];
            end
            %
            % Some extra blank lines to increase readability
            listStr = [listStr; {[strIndent '   |    ']}];
            
        end % End iField for-loop
        
        
        %% Field Filler
        % To properly align the field names, a filler is required. To know how long
        % the filler must be, the length of the longest fieldname must be found.
        % Because 'fields' is a cell array, the function 'cellfun' can be used to
        % extract the lengths of all fields.
        maxFieldLength = max(cellfun(@length, fields));
        
        %% Print non-structure fields without values
        % Print non-structure fields without the values. This can be done very
        % quick.
        if printValues == 0
            noStrucFields = fields(isStruct == 0);
            for iField  = 1 : length(noStrucFields)
                Field = cell2mat(noStrucFields(iField));
                filler = char(ones(1, ...
                    maxFieldLength - length(Field) + 2) * DASH_SYMBOL_CODE);
                listStr = [listStr; {[strIndent '   |' filler ' ' Field]}];
            end
            return
        end
        
        
        %% Select non-structure fields (to print with values)
        % Select fields that are not a structure and group them by data type. The
        % following groups are distinguished:
        %   - characters and strings
        %   - numeric arrays
        %   - logical
        %   - empty arrays
        %   - matrices
        %   - numeric scalars
        %   - cell arrays
        %   - other data types
        
        % Character or string (array of characters)
        isChar = structfun(@ischar, Structure);
        charFields = fields(isChar == 1);
        %
        % Numeric fields
        isNumeric = structfun(@isnumeric, Structure);
        %
        % Numeric scalars
        isScalar = structfun(@isscalar, Structure);
        isScalar = isScalar .* isNumeric;
        scalarFields = fields(isScalar == 1);
        %
        % Numeric vectors (arrays)
        isVector = structfun(@isvector, Structure);
        isVector = isVector .* isNumeric .* not(isScalar);
        vectorFields = fields(isVector == 1);
        %
        % Logical fields
        isLogical = structfun(@islogical, Structure);
        logicalFields = fields(isLogical == 1);
        %
        % Empty arrays
        isEmpty = structfun(@isempty, Structure);
        isEmpty = isEmpty&~structfun(@iscell, Structure)&~isChar;
        emptyFields = fields(isEmpty == 1);
        %
        % Numeric matrix with dimension size 2 or higher
        isMatrix = structfun(@(x) ndims(x) >= 2, Structure);
        isMatrix = isMatrix .* isNumeric .* not(isVector) ...
            .* not(isScalar) .* not(isEmpty);
        matrixFields = fields(isMatrix == 1);
        %
        % Cell array
        isCell = structfun(@iscell, Structure);
        cellFields = fields(isCell == 1);
        %
        % Datatypes that are not checked for
        isOther = not(isChar + isNumeric + isCell + isStruct + ...
            isLogical + isEmpty);
        otherFields = fields(isOther == 1);
        
        %% Print non-structure fields
        % Print all the selected non structure fields
        % - Strings are printed to a certain amount of characters
        % - Vectors are printed as long as they are shorter than maxArrayLength
        % - Matrices are printed if they have less elements than maxArrayLength
        % - The values of cells are not printed
        
        
        % Start with printing strings and characters. To avoid the display screen
        % becoming a mess, the part of the string that is printed is limited to 31
        % characters. In the future this might become an optional parameter in this
        % function, but for now, it is placed in the code itself.
        % if the string is longer than 31 characters, only the first 31  characters
        % are printed, plus three dots to denote that the string is longer than
        % printed.
        
        maxStrLength = 31;
        for iField = 1 : length(charFields)
            Field = charFields{iField};
            filler = char(ones(1, maxFieldLength - length(Field) + 2)...
                * DASH_SYMBOL_CODE);
            if (size(Structure.(Field), 1) > 1) && (size(Structure.(Field), 2) > 1)
                varStr = createArraySize(Structure.(Field), 'char');
                %             elseif length(Field) > maxStrLength
                %                 varStr = sprintf(' ''%s...''', Structure.(Field(1:maxStrLength)));
            else
                varStr = sprintf(' ''%s''', Structure.(Field));
            end
            listStr = [listStr; {[strIndent '   |' filler ' ' Field ' :' varStr]}];
        end
        
        %% Print empty fields
        for iField = 1 : length(emptyFields)
            Field = cell2mat(emptyFields(iField));
            filler = char(ones(1, maxFieldLength - length(Field) + 2)...
                * DASH_SYMBOL_CODE);
            listStr = [listStr; {[strIndent '   |' filler ' ' Field ' : [ ]' ]}];
        end
        %% Print logicals. If it is a scalar, print true/false, else print vector
        % information
        for iField = 1 : length(logicalFields)
            Field = cell2mat(logicalFields(iField));
            filler = char(ones(1, maxFieldLength - length(Field) + 2)...
                * DASH_SYMBOL_CODE);
            if (isscalar(Structure.(Field)))
                if (Structure.(Field))
                    varStr = ' true';
                else
                    varStr = ' false';
                end
            elseif (isvector(Structure.(Field)) && ...
                    length(Structure.(Field)) <= maxArrayLength)
                varStr = '';
                for iIndex = 1 : numel(Structure.(Field))
                    if (Structure.(Field)(iIndex))
                        varStr = [varStr, 'true '];
                    else
                        varStr = [varStr, 'false '];
                    end
                end
                varStr = ['[' varStr(1:length(varStr) - 1) ']'];
            else
                varStr = createArraySize(Structure.(Field), 'Logic array');
            end
            listStr = [listStr; {[strIndent '   |' filler ' ' Field ' :' varStr]}];
        end
        
        % Print numeric scalar field. The %g format is used, so that integers,
        % floats and exponential numbers are printed in their own format.
        
        for iField = 1 : length(scalarFields)
            Field = cell2mat(scalarFields(iField));
            filler = char(ones(1, maxFieldLength - length(Field) + 2)...
                * DASH_SYMBOL_CODE);
            varStr = sprintf([' ',numberFormat], Structure.(Field));
            listStr = [listStr; {[strIndent '   |' filler ' ' Field ' :' varStr]}];
        end
        
        
        %% Print numeric array. If the length of the array is smaller then
        % maxArrayLength, then the values are printed. Else, print the length of
        % the array.
        
        for iField = 1 : length(vectorFields)
            Field = cell2mat(vectorFields(iField));
            filler = char(ones(1, maxFieldLength - length(Field) + 2)...
                * DASH_SYMBOL_CODE);
            if length(Structure.(Field)) > maxArrayLength
                varStr = createArraySize(Structure.(Field), 'Array');
            else
                varStr = sprintf([numberFormat,' '], Structure.(Field));
                varStr = ['[' varStr(1:length(varStr) - 1) ']'];
            end
            listStr = [listStr; {[strIndent '   |' filler ' ' Field ...
                ' : ' varStr]}];
            
        end
        %% Print numeric matrices. If the matrix is two-dimensional and has more
        % than maxArrayLength elements, only its size is printed.
        % If the matrix is 'small', the elements are printed in a matrix structure.
        % The top and the bottom of the matrix is indicated by a horizontal line of
        % dashes. The elements are also lined out by using a format defined by
        % numberFormat. Because the name of the matrix is only printed on the first
        % line, the space is occupied by this name must be filled up on the other
        % lines. This is done by defining a 'filler2'.
        % This method was developed by S. Wegerich.
        
        for iField = 1 : length(matrixFields)
            Field = cell2mat(matrixFields(iField));
            filler = char(ones(1, maxFieldLength - length(Field) + 2)...
                * DASH_SYMBOL_CODE);
            if numel(Structure.(Field)) > maxArrayLength
                varStr = createArraySize(Structure.(Field), 'Array');
                varCell = {[strIndent '   |' filler ' ' Field ' :' varStr]};
            else
                %                matrixSize = size(Structure.(Field));
                %                 filler2 = char(ones(1, maxFieldLength + 6) * FILLER_SYMBOL_CODE);
                %                 dashes = char(ones(1, 12 * matrixSize(2) + 1) * DASH_SYMBOL_CODE);
                curPrintFormat=numberFormat;
                printedFieldValue=cellfun(@(x)sprintf(curPrintFormat,x),...
                    num2cell(Structure.(Field)),'UniformOutput',false);
                varCell=formCellOfString(strIndent,printedFieldValue,...
                    maxFieldLength,[filler ' '  Field]);
            end
            listStr = [listStr; varCell];
        end
        %% Print cell array information, i.e. the size of the cell array. The
        % content of the cell array is not printed.
        for iField = 1 : length(cellFields)
            Field = cell2mat(cellFields(iField));
            filler = char(ones(1, maxFieldLength - length(Field) + 2)...
                * DASH_SYMBOL_CODE);
            isMatOfStrings=ndims(Structure.(Field))==2&&...
                iscellstr(Structure.(Field))&&...
                all(all((cellfun('size',Structure.(Field),1)==1)&...
                (cellfun('ndims',Structure.(Field))==2)));
            if isempty(Structure.(Field))
                varCell = {[strIndent '   |' filler ' ' Field ' : {}']};
            elseif (numel(Structure.(Field)) > maxArrayLength)||~isMatOfStrings
                varStr = createArraySize(Structure.(Field), 'Cell');
                varCell = {[strIndent '   |' filler ' ' Field ' :' varStr]};
            else
                varCell=formCellOfString(strIndent,Structure.(Field),...
                    maxFieldLength,[filler ' '  Field]);
            end
            listStr = [listStr; varCell];
        end
        %% Print unknown datatypes. These include objects and user-defined classes
        for iField = 1 : length(otherFields)
            Field = cell2mat(otherFields(iField));
            filler = char(ones(1, maxFieldLength - length(Field) + 2)...
                * DASH_SYMBOL_CODE);
            varStr=[' ',evalc('display(Structure.(Field))')];
            varStr=varStr(1:end-1);
            listStr = [listStr; {[strIndent '   |' filler ' ' Field ' :' varStr]}];
        end
    end
    function varCell=formCellOfString(strIndent,fieldValue,...
            maxFieldLength,filler)
        matrixSize=size(fieldValue);
        maxStringLength=max(max(cellfun('length',fieldValue)));
        adjustedFieldValue=cellfun(@(x)[x,...
            repmat(' ',1,maxStringLength-length(x)),'|'],...
            fieldValue,'UniformOutput',false);
        nDashes=(maxStringLength+1)* matrixSize(2)+1;
        filler2 = char(ones(1, maxFieldLength + 6) * FILLER_SYMBOL_CODE);
        dashes = char(ones(1, nDashes)* DASH_SYMBOL_CODE);
        varCell = {[strIndent '   |' filler2 dashes]};
        %
        % first line with field name
        varStr = [adjustedFieldValue{1,:}];
        varCell = [varCell; {[strIndent '   |' filler ' : |' varStr]}];
        %
        % second and higher number rows
        for j = 2 : size(adjustedFieldValue,1)
            varStr = [adjustedFieldValue{j,:}];
            varCell = [varCell; {[strIndent '   |' filler2 '|' varStr]}];
        end
        varCell = [varCell; {[strIndent '   |' filler2 dashes]}];
    end

end

function newIndexVec = incrementIndexVec(indexVec, sizeVec)
newIndexVec = indexVec;
for iDimension = 1 : length(sizeVec)
    newIndexVec(iDimension) = newIndexVec(iDimension) + 1;
    if (newIndexVec(iDimension) <= sizeVec(iDimension))
        break;
    else
        newIndexVec(iDimension) = 1;
    end
end
end

%% FUNCTION: getIndentation
% This function creates the hierarchical indentations

function str = getIndentation(indent)
x = '   |    ';
str = '';

for i = 1 : indent
    str = cat(2, str, x);
end
end

%% FUNCTION: createArraySize
% This function returns a string with the array size of the input variable
% like: "[1x5 Array]" or "[2x3x5 Structure]" where 'Structure' and 'Array'
% are defined by the type parameter

function varStr = createArraySize(varName, type)
varSize = size(varName);
arraySizeStr = sprintf('%gx', varSize);
arraySizeStr(length(arraySizeStr)) = [];
varStr = [' [' arraySizeStr ' ' type ']'];
end