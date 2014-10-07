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
                body = recFieldPrint(Structure(1), indent);
                listStr = [{' '}; {[structureName, varStr]}; body; {'   O'}];
            else
                sizeVec = size(Structure);
                nStruc = min(numel(Structure), maxArrayLength);
                subIndList=cell(1,length(sizeVec));
                for iStruc = 1 : nStruc
                    if (~isscalar(Structure))
                        [subIndList{:}]=ind2sub(sizeVec,iStruc);
                        indexStr = sprintf('%d, ', [subIndList{:}]);
                        indexStr = horzcat('(', ...
                            indexStr(1:end-2), ')');
                    else
                        indexStr = sprintf('(%d)', iStruc);
                    end
                    body = recFieldPrint(Structure(iStruc), indent);
                    listStr = [listStr; {' '}; {indexStr}; body; {'   O'}];
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
        valsCVec = struct2cell(Structure);
        isStructVec = cellfun('isclass', valsCVec, 'struct');
        % Finally, select all the structure fields
        
        strucFields = fields(isStructVec);
        strucVals = valsCVec(isStructVec);
        
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
        
        [strIndent, strIndent2] = getIndentation(indent + 1);
        listStr = [listStr; {strIndent2}];
        
        % Next, select each field seperately and handle it accordingly
        
        nFields = length(strucFields);
        for iField = 1 : nFields
            fieldName = strucFields{iField};
            fieldVal =  strucVals{iField};
            %
            % Empty structure
            if isempty(fieldVal)
                strSize = createArraySize(fieldVal, 'Structure');
                %line = sprintf('%s   |--- %s :%s', ...
                %    strIndent, fieldName, strSize);
                line = horzcat(strIndent, '   |--- ', fieldName,...
                    ' :', strSize);
                curListStr = {line};
                %
                % Scalar structure
            elseif isscalar(fieldVal)
                %line = sprintf('%s   |--- %s', strIndent, fieldName);
                line = horzcat(strIndent, '   |--- ', fieldName);
                % Recall this function if the tree depth is not reached yet
                if (depth < 0) || (indent + 1 < depth)
                    lines = recFieldPrint(fieldVal, indent + 1);
                    curListStr = [{line}; lines; ...
                        {[strIndent '   |       O']}];
                else
                    curListStr = {line};
                end
                %
                % Short vector structure of which the values should be printed
            elseif (printValues > 0) && ...
                    (length(fieldVal) < maxArrayLength) && ...
                    ((depth < 0) || (indent + 1 < depth))
                %
                subIndList=cell(1,ndims(fieldVal));
                sizeVec=size(fieldVal);
               
                % Use a for-loop to print all structures in the array
                nFieldElement = numel(fieldVal);
                curListStr = {};
                for iFieldElement = 1 : nFieldElement;
                    [subIndList{:}]=ind2sub(sizeVec,iFieldElement);
                    elemName=sprintf('%d ',horzcat(subIndList{:}));
                    elemName=horzcat('[',elemName(1:end-1),']');
                    %
                    %line = sprintf('%s   |--- %s(%s)', ...
                    %    strIndent, fieldName, elemName);
                    line = horzcat(strIndent, '   |--- ',...
                        fieldName, '(', elemName, ')');
                    lines = recFieldPrint(fieldVal(iFieldElement), indent + 1);
                    curListStr = [curListStr;{line}; lines; ...
                        {[strIndent '   |       O'];[strIndent '   |    ']}];
                end
                curListStr(end)=[];
            end
            %
            % Some extra blank lines to increase readability
            listStr = [listStr; curListStr; {[strIndent '   |    ']}];
            
        end % End iField for-loop
        
        %% Field Filler
        % To properly align the field names, a filler is required. To know how long
        % the filler must be, the length of the longest fieldname must be found.
        % Because 'fields' is a cell array, the function 'cellfun' can be used to
        % extract the lengths of all fields.
        maxFieldLength = max(cellfun('length', fields));
        
        %% Print non-structure fields without values
        % Print non-structure fields without the values. This can be done very
        % quick.
        if printValues == 0
            noStrucFields = fields(~isStructVec);
            nFields = length(noStrucFields);
            fieldListStr = cell(nFields, 1);
            for iField  = 1 : nFields
                fieldName = noStrucFields{iField};
                filler = char(ones(1, ...
                    maxFieldLength - length(fieldName) + 2) * DASH_SYMBOL_CODE);
                fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName];
            end
            listStr = vertcat(listStr, fieldListStr);
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
        isnProcessedVec=~isStructVec;
        if any(isnProcessedVec),
            isCharVec = isnProcessedVec;
            isCharVec(isnProcessedVec) = ...
                cellfun('isclass', valsCVec(isnProcessedVec), 'char');
            charFields = fields(isCharVec);
            charVals = valsCVec(isCharVec);
            isnProcessedVec(isnProcessedVec)=~isCharVec(isnProcessedVec);
        else
            charFields = {};
        end
        %
        % Logical fields
        if any(isnProcessedVec),
            isLogicalVec = isnProcessedVec;
            isLogicalVec(isnProcessedVec) = ...
                cellfun('isclass', valsCVec(isnProcessedVec), 'logical');
            logicalFields = fields(isLogicalVec);
            logicalVals = valsCVec(isLogicalVec);
            isnProcessedVec(isnProcessedVec)=~isLogicalVec(isnProcessedVec);
        else
            logicalFields = {};
        end
        %
        % Cell array
        if any(isnProcessedVec),
            isCellVec = isnProcessedVec;
            isCellVec(isnProcessedVec) = ...
                cellfun('isclass', valsCVec(isnProcessedVec), 'cell');
            cellFields = fields(isCellVec);
            cellVals = valsCVec(isCellVec);
            isnProcessedVec(isnProcessedVec)=~isCellVec(isnProcessedVec);
        else
            cellFields = {};
        end
        %
        % Empty arrays
        if any(isnProcessedVec),
            isEmptyVec = isnProcessedVec;
            isEmptyVec(isnProcessedVec) = ...
                cellfun('isempty', valsCVec(isnProcessedVec));
            emptyFields = fields(isEmptyVec);
            isnProcessedVec(isnProcessedVec)=~isEmptyVec(isnProcessedVec);
        else
            emptyFields = {};
        end
        %
        % Numeric fields
        if any(isnProcessedVec),
            isNumericVec = isnProcessedVec;
            isNumericVec(isnProcessedVec) = ...
                cellfun(@isnumeric, valsCVec(isnProcessedVec));
            isnProcessedVec(isnProcessedVec)=...
                ~isNumericVec(isnProcessedVec);
            %
            % Numeric scalars
            if any(isNumericVec),
                isScalarVec = isNumericVec;
                isScalarVec(isNumericVec) = ...
                    cellfun('prodofsize', valsCVec(isNumericVec)) == 1;
                scalarFields = fields(isScalarVec);
                scalarVals = valsCVec(isScalarVec);
                isNumericVec(isScalarVec)=false;
            else
                scalarFields = {};
            end
            %
            % Numeric vectors (arrays)
            if any(isNumericVec),
                isVectorVec = isNumericVec;
                isVectorVec(isNumericVec) = ...
                    cellfun(@isvector, valsCVec(isNumericVec));
                vectorFields = fields(isVectorVec);
                vectorVals = valsCVec(isVectorVec);
                isNumericVec(isVectorVec)=false;
            else
                vectorFields = {};
            end
            %
            % Numeric matrix with dimension size 2 or higher
            if any(isNumericVec),
                %isMatrix = structfun(@(x) ndims(x) >= 2, Structure);
                %isMatrix = isMatrix .* isNumeric .* not(isVector) ...
                %    .* not(isScalar) .* not(isEmpty);
                matrixFields = fields(isNumericVec);
                matrixVals = valsCVec(isNumericVec);
            else
                matrixFields = {};
            end
        else
            scalarFields = {};
            vectorFields = {};
            matrixFields = {};
        end
        %
        % Datatypes that are not checked for
        if any(isnProcessedVec),
            otherFields = fields(isnProcessedVec);
            otherVals = valsCVec(isnProcessedVec);
        else
            otherFields = {};
        end
        
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
        
        %maxStrLength = 31;
        nFields = length(charFields);
        fieldListStr = cell(nFields, 1);
        for iField = 1 : nFields
            fieldName = charFields{iField};
            fieldVal = charVals{iField};
            filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                * DASH_SYMBOL_CODE);
            if (size(fieldVal, 1) > 1) && (size(fieldVal, 2) > 1)
                varStr = createArraySize(fieldVal, 'char');
                %             elseif length(Field) > maxStrLength
                %                 varStr = sprintf(' ''%s...''', Structure.(Field(1:maxStrLength)));
            else
                %varStr = sprintf(' ''%s''', fieldVal);
                varStr = horzcat(' ''', fieldVal, '''');
            end
            fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' :' varStr];
        end
        listStr = vertcat(listStr, fieldListStr);
        
        %% Print empty fields
        nFields = length(emptyFields);
        fieldListStr = cell(nFields, 1);
        for iField = 1 : nFields
            fieldName = emptyFields{iField};
            filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                * DASH_SYMBOL_CODE);
            fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' : [ ]' ];
        end
        listStr = vertcat(listStr, fieldListStr);
        %% Print logicals. If it is a scalar, print true/false, else print vector
        % information
        nFields = length(logicalFields);
        fieldListStr = cell(nFields, 1);
        for iField = 1 : nFields
            fieldName = logicalFields{iField};
            fieldVal = logicalVals{iField};
            filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                * DASH_SYMBOL_CODE);
            if (isscalar(fieldVal))
                if (fieldVal)
                    varStr = ' true';
                else
                    varStr = ' false';
                end
            elseif (isvector(fieldVal) && ...
                    length(fieldVal) <= maxArrayLength)
                varStr = repmat({'false '},1,numel(fieldVal));
                if any(fieldVal),
                    varStr(fieldVal) = {'true '};
                end
                varStr = horzcat(varStr{:});
                varStr = [' [' varStr(1:length(varStr) - 1) ']'];
            else
                varStr = createArraySize(fieldVal, 'Logic array');
            end
            fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' :' varStr];
        end
        listStr = vertcat(listStr, fieldListStr);
        
        % Print numeric scalar field. The %g format is used, so that integers,
        % floats and exponential numbers are printed in their own format.
        
        nFields = length(scalarFields);
        fieldListStr = cell(nFields, 1);
        for iField = 1 : nFields
            fieldName = scalarFields{iField};
            fieldVal = scalarVals{iField};
            filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                * DASH_SYMBOL_CODE);
            varStr = sprintf([' ',numberFormat], fieldVal);
            fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' :' varStr];
        end
        listStr = vertcat(listStr, fieldListStr);
        
        %% Print numeric array. If the length of the array is smaller then
        % maxArrayLength, then the values are printed. Else, print the length of
        % the array.
        
        nFields = length(vectorFields);
        fieldListStr = cell(nFields, 1);
        for iField = 1 : nFields
            fieldName = vectorFields{iField};
            fieldVal = vectorVals{iField};
            filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                * DASH_SYMBOL_CODE);
            if length(fieldVal) > maxArrayLength
                varStr = createArraySize(fieldVal, 'Array');
            else
                varStr = sprintf([numberFormat,' '], fieldVal);
                varStr = [' [' varStr(1:length(varStr) - 1) ']'];
            end
            fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ...
                ' :' varStr];
        end
        listStr = vertcat(listStr, fieldListStr);
        %% Print numeric matrices. If the matrix is two-dimensional and has more
        % than maxArrayLength elements, only its size is printed.
        % If the matrix is 'small', the elements are printed in a matrix structure.
        % The top and the bottom of the matrix is indicated by a horizontal line of
        % dashes. The elements are also lined out by using a format defined by
        % numberFormat. Because the name of the matrix is only printed on the first
        % line, the space is occupied by this name must be filled up on the other
        % lines. This is done by defining a 'filler2'.
        % This method was developed by S. Wegerich.
        
        nFields = length(matrixFields);
        for iField = 1 : nFields
            fieldName = matrixFields{iField};
            fieldVal = matrixVals{iField};
            filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                * DASH_SYMBOL_CODE);
            if numel(fieldVal) > maxArrayLength
                varStr = createArraySize(fieldVal, 'Array');
                varCell = {[strIndent '   |' filler ' ' fieldName ' :' varStr]};
            else
                %                matrixSize = size(Structure.(Field));
                %                 filler2 = char(ones(1, maxFieldLength + 6) * FILLER_SYMBOL_CODE);
                %                 dashes = char(ones(1, 12 * matrixSize(2) + 1) * DASH_SYMBOL_CODE);
                curPrintFormat=numberFormat;
                printedFieldValue=cellfun(@(x)sprintf(curPrintFormat,x),...
                    num2cell(fieldVal),'UniformOutput',false);
                varCell=formCellOfString(strIndent,printedFieldValue,...
                    maxFieldLength,[filler ' '  fieldName]);
            end
            listStr = [listStr; varCell];
        end
        %% Print cell array information, i.e. the size of the cell array. The
        % content of the cell array is not printed.
        nFields = length(cellFields);
        for iField = 1 : nFields
            fieldName = cellFields{iField};
            fieldVal = cellVals{iField};
            filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                * DASH_SYMBOL_CODE);
            isMatOfStrings=ismatrix(fieldVal)&&...
                iscellstr(fieldVal)&&...
                all(all((cellfun('size',fieldVal,1)==1)&...
                (cellfun('ndims',fieldVal)==2)));
            if isempty(fieldVal)
                varCell = {[strIndent '   |' filler ' ' fieldName ' : {}']};
            elseif (numel(fieldVal) > maxArrayLength)||~isMatOfStrings
                varStr = createArraySize(fieldVal, 'Cell');
                varCell = {[strIndent '   |' filler ' ' fieldName ' :' varStr]};
            else
                varCell=formCellOfString(strIndent,fieldVal,...
                    maxFieldLength,[filler ' '  fieldName]);
            end
            listStr = [listStr; varCell];
        end
        %% Print unknown datatypes. These include objects and user-defined classes
        nFields = length(otherFields);
        fieldListStr = cell(nFields, 1);
        for iField = 1 : nFields
            fieldName = otherFields{iField};
            fieldVal = otherVals{iField}; %#ok<NASGU>
            filler = char(ones(1, maxFieldLength - length(fieldNa,e) + 2)...
                * DASH_SYMBOL_CODE);
            varStr=[' ',evalc('display(fieldVal)')];
            varStr=varStr(1:end-1);
            fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' :' varStr];
        end
        listStr = vertcat(listStr, fieldListStr);
    end
    function varCell=formCellOfString(strIndent,fieldValue,...
            maxFieldLength,filler)
        matrixSize=size(fieldValue);
        maxStringLength=max(max(cellfun('length',fieldValue)));
        nVals = numel(fieldValue);
        %adjustedFieldValue=cellfun(@(x)[x,...
        %    repmat(' ',1,maxStringLength-length(x)),'|'],...
        %    fieldValue,'UniformOutput',false);
        addLenVec=maxStringLength-cellfun('length',fieldValue(:));
        space = ' ';
        adjustedFieldValue=cell(matrixSize);
        for iVal=1:nVals,
            adjustedFieldValue{iVal}=horzcat(fieldValue{iVal},...
                space(ones(1,addLenVec(iVal))),'|');
        end
        nDashes=(maxStringLength+1)* matrixSize(2)+1;
        filler2 = char(ones(1, maxFieldLength + 6) * FILLER_SYMBOL_CODE);
        dashes = char(ones(1, nDashes)* DASH_SYMBOL_CODE);
        nRows = size(adjustedFieldValue,1);
        varCell = cell(nRows+2,1);
        varCell{1} = [strIndent '   |' filler2 dashes];
        %
        % first line with field name
        varStr = [adjustedFieldValue{1,:}];
        varCell{2} = [strIndent '   |' filler ' : |' varStr];
        %
        % second and higher number rows
        for iRow = 2 : nRows
            varStr = [adjustedFieldValue{iRow,:}];
            varCell{iRow+1} = [strIndent '   |' filler2 '|' varStr];
        end
        varCell{nRows+2} = [strIndent '   |' filler2 dashes];
    end

end

%% FUNCTION: getIndentation
% This function creates the hierarchical indentations

function [str, str2] = getIndentation(indent)
% x = '   |    ';
% str = '';
% 
% for iElem = 1 : indent
%     str = cat(2, str, x);
% end
persistent outCVec;
if indent==1,
    str = '';
    str2 = '   |    ';
else
    nOuts=numel(outCVec);
    if nOuts<indent,
        x = '   |    ';
        if nOuts>0,
            str = outCVec{end};
        else
            str = '';
        end
        outCVec=horzcat(outCVec,cell(1,indent-nOuts));
        for iElem = nOuts+1 : indent
            str = cat(2, str, x);
            outCVec{iElem} = str;
        end
        str2 = str;
        str = outCVec{indent-1};
    else
        str = outCVec{indent-1};
        str2 = outCVec{indent};
    end
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