classdef StructDisp < handle
    % This class is responsible for displaying structure outline
    
    methods
        function self=StructDisp(varargin)
            % STRUCTDISP is a constructor for the class of the same name
            %
            % Usage: StructDisp(SInp,varargin)
            %
            % Input:
            %   regular:
            %       SInp: struct[1,1] - is a scalar structure datatype with
            %           unknown field content
            %   properties:
            %       depth: numeric[1,1] - the number of hierarchical levels
            %           of the structure that are displayed; if depth is
            %           smaller than zero, all levels are displayed;
            %           default value is -1 (display all levels)
            %       printValues: logical[1,1] -  flag that states if the
            %           field values should be displayed as well; the
            %           default value is true (print values)
            %       maxArrayLength: numberic[1,1] - a positive integer,
            %           which determines up to which length or size the
            %           values of a vector or matrix are printed; for a 
            %           vector holds that if the length of the vector is
            %           smaller or equal to maxArrayLength, the values are
            %           printed; if the vector is longer than
            %           maxArrayLength, then only the size of the vector is
            %           printed; the values of a 2-dimensional (m,n) array
            %           are printed if the number of elements (m x n) is
            %           smaller or equal to maxArrayLength; for vectors and
            %           arrays, this constraint overrides the printValues
            %           flag
            %       numberFormat: char[1,] - format specification used for
            %           displaying numeric values, passed directly to
            %           sprintf, by default '%g' is used
            %       defaultName: char [1,] - default name of the structure
            %           itself
            %       isFullCheck: logical [1,1] - if false, then it is
            %           supposed that only the values of leaves for SInp
            %           may be changed when UPDATE method is called, so
            %           that the inner structure is stable and no
            %           additional checks should be performed; otherwise
            %           the full check for consistency of inner structure
            %           of old and new values of SInp is performed
            %
            % $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-10-01 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2014 $
            %
            
            import modgen.common.parseparext;
            [reg,propValCVec]=self.parseArgList(varargin);
            [reg,~,self.isFullCheck]=parseparext(reg,...
                {'isFullCheck';true;'islogical(x)&&isscalar(x)'},...
                [1 1],'regDefList',{'isstruct(x)&&isscalar(x)'});
            [self.inpPrintValues,self.structureName,...
                self.maxArrayLength,self.depth,self.numberFormat]=...
                deal(propValCVec{:});
            self.initialize(reg{1});
        end
        
        function resStr=display(self)
            % DISPLAY returns string with displayed outline of structure or
            % simply displays this outline (in the case there are no output
            % arguments)
            %
            % Usage: resStr=display(self) OR
            %        display(self)
            %
            % input:
            %   regular:
            %     self: StructDisp [1,1] - class object
            % output:
            %   optional:
            %     resStr: char [1,] - string with displayed outline of
            %         structure
            %
            % $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-10-08 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2014 $
            %
            
            resultString=modgen.string.catwithsep(self.dispCVec,sprintf('\n'));
            if nargout==0
                % write data to screen
                disp(resultString);
            else
                resStr=[resultString,sprintf('\n')];
            end
        end
        
        function [changedRowIndVec,changedColIndVec]=update(self,SStructInp)
            % UPDATE quickly updates stored displayed outline by comparison
            % of old and new values of structure, besides, some additional
            % information concerning numbers of rows that were changed and
            % for each of these row the corresponding number of column
            % starting from which the change in this row was made
            %
            % Usage: update(self,SStructInp) OR
            %        [changedRowIndVec,changedColIndVec]=...
            %            update(self,SStructInp)
            %
            % input:
            %   regular:
            %     self: StructDisp [1,1] - class object containing previous
            %         ("old") outline of structure
            %     SStructInp: struct [1,1] - scalar structure containing
            %         new structure
            % output:
            %   optional:
            %     changedRowIndVec: double [nRows,1] - numbers of rows in
            %         which changes were made
            %     changedColIndVec: double [nRows,1] - for each row in 
            %         changedRowIndVec the corresponding elemenent in this
            %         array contain the number of column starting from
            %         which the change was made
            %
            % $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-10-08 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2014 $
            %
            
            if ~(isstruct(SStructInp)&&isscalar(SStructInp)),
                modgen.common.throwerror('wrongInput',...
                    'SStructInp must be scalar structure')
            end
            [isLocalChanges,changedLeavesPathCVec,changedLeavesValCVec]=...
                getleaveslist(SStructInp,self.SStruct,self.isFullCheck);
            if isLocalChanges,
                if ~isempty(changedLeavesPathCVec),
                    [isLeavesVec,indLeavesVec]=ismember(changedLeavesPathCVec,...
                        {self.SLeavesInfoVec.path}.');
                    if any(isLeavesVec),
                        if ~all(isLeavesVec),
                            indLeavesVec=indLeavesVec(isLeavesVec);
                            changedLeavesValCVec(~isLeavesVec)=[];
                        end
                        SLeavesInfoVecCur=self.SLeavesInfoVec(indLeavesVec);
                        rowIndCVec={SLeavesInfoVecCur.rowIndVec}.';
                        colIndCVec={SLeavesInfoVecCur.colIndVec}.';
                        nLeaves=numel(indLeavesVec);
                        idVec=(1:nLeaves).';
                        inpCVec=self.getRecFieldPrintAddArgs();
                        [curDispCVec,outIdVec,curRowIndCVec,curColIndCVec]=...
                            self.recFieldPrint(...
                            {idVec,changedLeavesValCVec},inpCVec{:});
                        if ~isequal(idVec,outIdVec),
                            [~,indLeavesVec]=ismember(idVec,outIdVec);
                            curRowIndCVec=curRowIndCVec(indLeavesVec);
                            curColIndCVec=curColIndCVec(indLeavesVec);
                        end
                        isLocalChanges=isequal(...
                            cellfun('length',rowIndCVec),...
                            cellfun('length',curRowIndCVec));
                        if isLocalChanges,
                            for iLeave=1:nLeaves,
                                rowIndVec=rowIndCVec{iLeave};
                                colIndVec=colIndCVec{iLeave};
                                curRowIndVec=curRowIndCVec{iLeave};
                                curColIndVec=curColIndCVec{iLeave};
                                nRows=numel(rowIndVec);
                                for iRow=1:nRows,
                                    self.dispCVec{rowIndVec(iRow)}=...
                                        [self.dispCVec{rowIndVec(iRow)}(...
                                        1:(colIndVec(iRow)-1))...
                                        curDispCVec{curRowIndVec(iRow)}(...
                                        curColIndVec(iRow):end)];
                                end
                            end
                            self.SStruct=SStructInp;
                            if nargout>0,
                                changedRowIndVec=vertcat(rowIndCVec{:});
                                changedColIndVec=vertcat(colIndCVec{:});
                            end
                        end
                    end
                end
            end
            if ~isLocalChanges,
                self.initialize(SStructInp);
                if nargout>0,
                    nRows=numel(self.dispCVec);
                    changedRowIndVec=(1:nRows).';
                    changedColIndVec=ones(nRows,1);
                end
            end
        end
    end
    
    methods (Static)
        function resStr=strucdisp(varargin)
            % STRUCDISP  display structure outline
            %
            % Usage: STRUCDISP(STRUC,fileName,'depth',DEPTH,'printValues',PRINTVALUES,...
            %           'maxArrayLength',MAXARRAYLENGTH) stores
            %        the hierarchical outline of a structure and its substructures into
            %        the specified file
            %
            % input:
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
            % output:
            %   regular:
            %       resStr: char [1,] - resulting string with displayed
            %           structure contents
            %
            % $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-10-08 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2014 $
            %
            %
            
            import modgen.common.parseparext;
            className=mfilename('class');
            [reg,propValCVec]=feval([className '.parseArgList'],...
                varargin);
            reg=parseparext(reg,{},[1 2],...
                'regDefList',{[],''},...
                'regCheckList',{'isstruct(x)','isstring(x)'});
            SInp=reg{1};
            fileName=reg{2};
            propValCVec=horzcat(propValCVec,{...
                eval([className '.DASH_SYMBOL_CODE']),...
                eval([className '.FILLER_SYMBOL_CODE'])});
            %% Main program
            %%%%% start program %%%%%
            % start recursive function
            listStr = modgen.struct.StructDisp.recFieldPrint(SInp, 0,...
                propValCVec{:});
            
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
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Private properties and methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties (GetAccess=private,Constant,Hidden)
        FILLER_SYMBOL_CODE=32;
        DASH_SYMBOL_CODE=45;
        DEFAULT_MAX_ARRAY_LENGTH=10;
        DEFAULT_DEPTH=-1;
        DEFAULT_PRINT_VALUES=true;
        DEFAULT_NUMBER_FORMAT='%g';
        DEFAULT_NAME = 'Structure';
    end
    
    properties (Access=private,Hidden)
        SStruct
        dispCVec = cell(0,1);
        SLeavesInfoVec = repmat(...
            struct('path','','rowIndVec',NaN,'colIndVec',NaN),[0 1]);
        depth
        inpPrintValues
        maxArrayLength
        numberFormat
        structureName
        isFullCheck
    end
    
    methods (Access=private,Hidden)
        function initialize(self,SStructInp)
            self.SStruct=SStructInp;
            inpCVec=self.getRecFieldPrintAddArgs();
            [self.dispCVec,...
                leavesPathCVec,leavesRowIndCVec,leavesColIndCVec]=...
                self.recFieldPrint(self.SStruct, inpCVec{:});
            self.SLeavesInfoVec=struct(...
                'path',leavesPathCVec,...
                'rowIndVec',leavesRowIndCVec,...
                'colIndVec',leavesColIndCVec);
        end
        
        function inpCVec=getRecFieldPrintAddArgs(self)
            inpCVec={0, self.inpPrintValues, self.structureName,...
                self.maxArrayLength, self.depth, self.numberFormat,...
                self.DASH_SYMBOL_CODE, self.FILLER_SYMBOL_CODE};
        end
    end
    
    methods (Access=private,Static,Hidden)
        function [regCVec,propValCVec]=parseArgList(argCVec)
            import modgen.common.parseparext;
            className=mfilename('class');
            [regCVec,~,depthVal,printValuesVal,...
                maxArrayLengthVal,numberFormatVal,...
                structureNameVal]=parseparext(argCVec,...
                {'depth','printValues','maxArrayLength',...
                'numberFormat','defaultName',;...
                getConstant('DEFAULT_DEPTH'),...
                getConstant('DEFAULT_PRINT_VALUES'),...
                getConstant('DEFAULT_MAX_ARRAY_LENGTH'),...
                getConstant('DEFAULT_NUMBER_FORMAT'),...
                getConstant('DEFAULT_NAME');
                'isscalar(x)&&isnumeric(x)&&fix(x)==x',...
                'islogical(x)&&isscalar(x)',...
                'isscalar(x)&&isnumeric(x)&&fix(x)==x&&x>0',...
                'isstring(x)',...
                'isstring(x)'});
            propValCVec={printValuesVal,structureNameVal,maxArrayLengthVal,...
                depthVal,numberFormatVal};

            function res=getConstant(constantName)
                res=eval([className '.' constantName]);
            end
        end
        
        %% FUNCTION: recFieldPrint
        function [listStr,...
                leavesPathCVec,leavesRowIndCVec,leavesColIndCVec] = ...
                recFieldPrint(Structure, indent, printValues,...
                structureName, maxArrayLength, depth, numberFormat,...
                DASH_SYMBOL_CODE, FILLER_SYMBOL_CODE)
            className=mfilename('class');
            inpCVec={printValues,...
                structureName, maxArrayLength, depth, numberFormat,...
                DASH_SYMBOL_CODE, FILLER_SYMBOL_CODE};
            isnListStrOnly=nargout>1;
            % Start to initialiase the cell listStr. This cell is used to store all the
            % output, as this is much faster then directly printing it to screen.
            listStr = {};
            if isnListStrOnly,
                leavesPathCVec = cell(0,1);
                leavesRowIndCVec = cell(0,1);
                leavesColIndCVec = cell(0,1);
            end
            
            % "Structure" can be a scalar or a vector.
            % In case of a vector, this recursive function is recalled for each of
            % the vector elements. But if the values don't have to be printed, only
            % the size of the structure and its fields are printed.
            if isstruct(Structure) && numel(Structure) > 1
                if (printValues == 0)
                    varStr = createArraySize(Structure, 'Structure');
                    body = feval([className '.recFieldPrint'],...
                        Structure(1), indent, inpCVec{:});
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
                        if isnListStrOnly,
                            [body,elemPathCVec,elemRowIndCVec,elemColIndCVec] = ...
                                feval([className '.recFieldPrint'],...
                                Structure(iStruc), indent, inpCVec{:});
                            nAdd=numel(listStr);
                            leavesPathCVec=vertcat(leavesPathCVec,...
                                strcat(indexStr,'.',elemPathCVec)); %#ok<AGROW>
                            leavesRowIndCVec=vertcat(leavesRowIndCVec,...
                                cellfun(@(x)x+nAdd,...
                                elemRowIndCVec,'UniformOutput',false)); %#ok<AGROW>
                            leavesColIndCVec=vertcat(leavesColIndCVec,...
                                elemColIndCVec); %#ok<AGROW>
                        else
                            body = feval([className '.recFieldPrint'],...
                                Structure(iStruc), indent, inpCVec{:});
                        end
                        listStr = [listStr; {' '}; {[structureName,indexStr]}; body; {'   O'}]; %#ok<AGROW>
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
            if isstruct(Structure),
                fields = fieldnames(Structure);
            else
                fields=Structure{1};
                if ~iscell(fields),
                    leavesPathCVec=nan(0,1);
                end
            end
            % Next, structfun is used to return an boolean array with information of
            % which fields are of type structure.
            if isempty(fields)
                return;
            end
            if isstruct(Structure),
                valsCVec = struct2cell(Structure);
            else
                valsCVec=Structure{2};
            end
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
                isLeaves = false;
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
                        if isnListStrOnly,
                            [lines,curPathCVec,curRowIndCVec,curColIndCVec] = ...
                                feval([className '.recFieldPrint'],...
                                fieldVal, indent + 1, inpCVec{:});
                            isLeaves = ~isempty(curPathCVec);
                            curRowIndCVec = cellfun(@(x)x+1,...
                                curRowIndCVec,'UniformOutput',false);
                        else
                            lines = feval([className '.recFieldPrint'],...
                                fieldVal, indent + 1, inpCVec{:});
                        end
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
                    if isnListStrOnly,
                        curPathCVec = cell(0,1);
                        curRowIndCVec = cell(0,1);
                        curColIndCVec = cell(0,1);
                    end
                    for iFieldElement = 1 : nFieldElement;
                        [subIndList{:}]=ind2sub(sizeVec,iFieldElement);
                        indexStr=sprintf('%d ',horzcat(subIndList{:}));
                        indexStr=indexStr(1:end-1);
                        elemName=horzcat('[',indexStr,']');
                        %
                        %line = sprintf('%s   |--- %s(%s)', ...
                        %    strIndent, fieldName, elemName);
                        line = horzcat(strIndent, '   |--- ',...
                            fieldName, '(', elemName, ')');
                        if isnListStrOnly,
                            [lines,elemPathCVec,...
                                elemRowIndCVec,elemColIndCVec] = ...
                                feval([className '.recFieldPrint'],...
                                fieldVal(iFieldElement), indent + 1, inpCVec{:});
                            if ~isempty(elemPathCVec),
                                nAdd=numel(curListStr);
                                curPathCVec=vertcat(curPathCVec,...
                                    strcat('(',strrep(indexStr,' ',','),').',...
                                    elemPathCVec)); %#ok<AGROW>
                                curRowIndCVec=vertcat(curRowIndCVec,...
                                    cellfun(@(x)x+nAdd+1,elemRowIndCVec,...
                                    'UniformOutput',false)); %#ok<AGROW>
                                curColIndCVec=vertcat(curColIndCVec,...
                                    elemColIndCVec); %#ok<AGROW>
                            end
                        else
                            lines = feval([className '.recFieldPrint'],...
                                fieldVal(iFieldElement), indent + 1, inpCVec{:});
                        end
                        curListStr = [curListStr;{line}; lines; ...
                            {[strIndent '   |       O'];[strIndent '   |    ']}]; %#ok<AGROW>
                    end
                    curListStr(end)=[];
                    if isnListStrOnly,
                        isLeaves=~isempty(curPathCVec);
                    end
                end
                %
                if isLeaves,
                    nAdd=numel(listStr);
                    if curPathCVec{1}(1)=='(',
                        leavesPathCVec=vertcat(leavesPathCVec,...
                            strcat(fieldName,curPathCVec)); %#ok<AGROW>
                    else
                        leavesPathCVec=vertcat(leavesPathCVec,...
                            strcat(fieldName,'.',curPathCVec)); %#ok<AGROW>
                    end
                    leavesRowIndCVec=vertcat(leavesRowIndCVec,...
                        cellfun(@(x)x+nAdd,curRowIndCVec,...
                        'UniformOutput',false)); %#ok<AGROW>
                    leavesColIndCVec=vertcat(leavesColIndCVec,...
                        curColIndCVec); %#ok<AGROW>
                end
                % Some extra blank lines to increase readability
                listStr = [listStr; curListStr; {[strIndent '   |    ']}]; %#ok<AGROW>
            end % End iField for-loop
            
            %% Field Filler
            % To properly align the field names, a filler is required. To know how long
            % the filler must be, the length of the longest fieldname must be found.
            % Because 'fields' is a cell array, the function 'cellfun' can be used to
            % extract the lengths of all fields.
            if iscell(fields),
                maxFieldLength = max(cellfun('length', fields));
            else
                maxFieldLength = 0;
            end
            
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
            if isnListStrOnly,
                fieldColIndVec = nan(nFields, 1);
            end
            for iField = 1 : nFields
                fieldName = getFieldName(charFields,iField);
                fieldVal = charVals{iField};
                filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                    * DASH_SYMBOL_CODE);
                if (size(fieldVal, 1) > 1) && (size(fieldVal, 2) > 1)
                    varStr = createArraySize(fieldVal, 'char');
                    %             elseif length(Field) > maxStrLength
                    %                 varStr = sprintf(' ''%s...''', Structure.(Field(1:maxStrLength)));
                else
                    %varStr = sprintf(' ''%s''', fieldVal);
                    varStr = horzcat(' ''', reshape(fieldVal,1,[]), '''');
                end
                fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' :' varStr];
                if isnListStrOnly,
                    fieldColIndVec(iField) = numel(fieldListStr{iField})-numel(varStr)+2;
                end
            end
            if nFields,
                if isnListStrOnly,
                    leavesPathCVec = vertcat(leavesPathCVec,charFields);
                    leavesRowIndCVec = vertcat(leavesRowIndCVec,...
                        num2cell(numel(listStr)+(1:nFields).'));
                    leavesColIndCVec = vertcat(leavesColIndCVec,...
                        num2cell(fieldColIndVec));
                end
                listStr = vertcat(listStr, fieldListStr);
            end            
            
            %% Print empty fields
            nFields = length(emptyFields);
            fieldListStr = cell(nFields, 1);
            if isnListStrOnly,
                fieldColIndVec = nan(nFields, 1);
            end
            for iField = 1 : nFields
                fieldName = getFieldName(emptyFields,iField);
                filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                    * DASH_SYMBOL_CODE);
                fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' : [ ]' ];
                if isnListStrOnly,
                    fieldColIndVec(iField) = numel(fieldListStr{iField})-2;
                end
            end
            if nFields,
                if isnListStrOnly,
                    leavesPathCVec = vertcat(leavesPathCVec,emptyFields);
                    leavesRowIndCVec = vertcat(leavesRowIndCVec,...
                        num2cell(numel(listStr)+(1:nFields).'));
                    leavesColIndCVec = vertcat(leavesColIndCVec,...
                        num2cell(fieldColIndVec));
                end
                listStr = vertcat(listStr, fieldListStr);
            end
            %% Print logicals. If it is a scalar, print true/false, else print vector
            % information
            nFields = length(logicalFields);
            fieldListStr = cell(nFields, 1);
            if isnListStrOnly,
                fieldColIndVec = nan(nFields, 1);
            end
            for iField = 1 : nFields
                fieldName = getFieldName(logicalFields,iField);
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
                if isnListStrOnly,
                    fieldColIndVec(iField) = numel(fieldListStr{iField})-numel(varStr)+2;
                end
            end
            if nFields,
                if isnListStrOnly,
                    leavesPathCVec = vertcat(leavesPathCVec,logicalFields);
                    leavesRowIndCVec = vertcat(leavesRowIndCVec,...
                        num2cell(numel(listStr)+(1:nFields).'));
                    leavesColIndCVec = vertcat(leavesColIndCVec,...
                        num2cell(fieldColIndVec));
                end
                listStr = vertcat(listStr, fieldListStr);
            end
            
            % Print numeric scalar field. The %g format is used, so that integers,
            % floats and exponential numbers are printed in their own format.
            
            nFields = length(scalarFields);
            fieldListStr = cell(nFields, 1);
            if isnListStrOnly,
                fieldColIndVec = nan(nFields, 1);
            end
            for iField = 1 : nFields
                fieldName = getFieldName(scalarFields,iField);
                fieldVal = scalarVals{iField};
                filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                    * DASH_SYMBOL_CODE);
                varStr = sprintf([' ',numberFormat], fieldVal);
                fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' :' varStr];
                if isnListStrOnly,
                    fieldColIndVec(iField) = numel(fieldListStr{iField})-numel(varStr)+2;
                end
            end
            if nFields,
                if isnListStrOnly,
                    leavesPathCVec = vertcat(leavesPathCVec,scalarFields);
                    leavesRowIndCVec = vertcat(leavesRowIndCVec,...
                        num2cell(numel(listStr)+(1:nFields).'));
                    leavesColIndCVec = vertcat(leavesColIndCVec,...
                        num2cell(fieldColIndVec));
                end
                listStr = vertcat(listStr, fieldListStr);
            end
            
            %% Print numeric array. If the length of the array is smaller then
            % maxArrayLength, then the values are printed. Else, print the length of
            % the array.
            
            nFields = length(vectorFields);
            fieldListStr = cell(nFields, 1);
            if isnListStrOnly,
                fieldColIndVec = nan(nFields, 1);
            end
            for iField = 1 : nFields
                fieldName = getFieldName(vectorFields,iField);
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
                if isnListStrOnly,
                    fieldColIndVec(iField) = numel(fieldListStr{iField})-numel(varStr)+2;
                end
            end
            if nFields,
                if isnListStrOnly,
                    leavesPathCVec = vertcat(leavesPathCVec,vectorFields);
                    leavesRowIndCVec = vertcat(leavesRowIndCVec,...
                        num2cell(numel(listStr)+(1:nFields).'));
                    leavesColIndCVec = vertcat(leavesColIndCVec,...
                        num2cell(fieldColIndVec));
                end
                listStr = vertcat(listStr, fieldListStr);
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
            
            nFields = length(matrixFields);
            if isnListStrOnly,
                fieldRowIndCVec = cell(nFields, 1);
                fieldColIndCVec = cell(nFields, 1);
            end
            for iField = 1 : nFields
                fieldName = getFieldName(matrixFields,iField);
                fieldVal = matrixVals{iField};
                filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                    * DASH_SYMBOL_CODE);
                if numel(fieldVal) > maxArrayLength
                    varStr = createArraySize(fieldVal, 'Array');
                    varCell = {[strIndent '   |' filler ' ' fieldName ' :' varStr]};
                    if isnListStrOnly,
                        fieldRowIndCVec{iField} = numel(listStr)+1;
                        fieldColIndCVec{iField} = numel(varCell{:})-numel(varStr)+2;
                    end
                else
                    %                matrixSize = size(Structure.(Field));
                    %                 filler2 = char(ones(1, maxFieldLength + 6) * FILLER_SYMBOL_CODE);
                    %                 dashes = char(ones(1, 12 * matrixSize(2) + 1) * DASH_SYMBOL_CODE);
                    printedFieldValue=cellfun(@(x)sprintf(numberFormat,x),...
                        num2cell(fieldVal),'UniformOutput',false);
                    if isnListStrOnly,
                        [varCell,fieldRowIndCVec{iField},fieldColIndCVec{iField}]=...
                            formCellOfString(strIndent,printedFieldValue,...
                            maxFieldLength,[filler ' '  fieldName],...
                            FILLER_SYMBOL_CODE,DASH_SYMBOL_CODE);
                        fieldRowIndCVec{iField}=fieldRowIndCVec{iField}+numel(listStr);
                    else
                        varCell=formCellOfString(strIndent,printedFieldValue,...
                            maxFieldLength,[filler ' '  fieldName],...
                            FILLER_SYMBOL_CODE,DASH_SYMBOL_CODE);
                    end
                end
                listStr = [listStr; varCell]; %#ok<AGROW>
            end
            if nFields&&isnListStrOnly,
                leavesPathCVec=vertcat(leavesPathCVec,matrixFields);
                leavesRowIndCVec = vertcat(leavesRowIndCVec,fieldRowIndCVec);
                leavesColIndCVec = vertcat(leavesColIndCVec,fieldColIndCVec);
            end
            %% Print cell array information, i.e. the size of the cell array. The
            % content of the cell array is not printed.
            nFields = length(cellFields);
            if isnListStrOnly,
                fieldRowIndCVec = cell(nFields, 1);
                fieldColIndCVec = cell(nFields, 1);
            end
            for iField = 1 : nFields
                fieldName = getFieldName(cellFields,iField);
                fieldVal = cellVals{iField};
                filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                    * DASH_SYMBOL_CODE);
                isMatOfStrings=ismatrix(fieldVal)&&...
                    iscellstr(fieldVal)&&...
                    all(all((cellfun('size',fieldVal,1)==1)&...
                    (cellfun('ndims',fieldVal)==2)));
                if isempty(fieldVal)
                    varCell = {[strIndent '   |' filler ' ' fieldName ' : {}']};
                    if isnListStrOnly,
                        fieldRowIndCVec{iField} = numel(listStr)+1;
                        fieldColIndCVec{iField} = numel(varCell{:})-1;
                    end
                elseif (numel(fieldVal) > maxArrayLength)||~isMatOfStrings
                    varStr = createArraySize(fieldVal, 'Cell');
                    varCell = {[strIndent '   |' filler ' ' fieldName ' :' varStr]};
                    if isnListStrOnly,
                        fieldRowIndCVec{iField} = numel(listStr)+1;
                        fieldColIndCVec{iField} = numel(varCell{:})-numel(varStr)+2;
                    end
                else
                    if isnListStrOnly,
                        [varCell,fieldRowIndCVec{iField},fieldColIndCVec{iField}]=...
                            formCellOfString(strIndent,fieldVal,...
                            maxFieldLength,[filler ' '  fieldName],...
                            FILLER_SYMBOL_CODE,DASH_SYMBOL_CODE);
                        fieldRowIndCVec{iField}=fieldRowIndCVec{iField}+numel(listStr);
                    else
                        varCell=...
                            formCellOfString(strIndent,fieldVal,...
                            maxFieldLength,[filler ' '  fieldName],...
                            FILLER_SYMBOL_CODE,DASH_SYMBOL_CODE);
                    end
                end
                listStr = [listStr; varCell]; %#ok<AGROW>
            end
            if nFields&&isnListStrOnly,
                leavesPathCVec=vertcat(leavesPathCVec,cellFields);
                leavesRowIndCVec = vertcat(leavesRowIndCVec,fieldRowIndCVec);
                leavesColIndCVec = vertcat(leavesColIndCVec,fieldColIndCVec);
            end
            %% Print unknown datatypes. These include objects and user-defined classes
            nFields = length(otherFields);
            fieldListStr = cell(nFields, 1);
            if isnListStrOnly,
                fieldColIndVec = nan(nFields, 1);
            end
            for iField = 1 : nFields
                fieldName = getFieldName(otherFields,iField);
                fieldVal = otherVals{iField}; %#ok<NASGU>
                filler = char(ones(1, maxFieldLength - length(fieldName) + 2)...
                    * DASH_SYMBOL_CODE);
                varStr=[' ',evalc('display(fieldVal)')];
                varStr=varStr(1:end-1);
                fieldListStr{iField} = [strIndent '   |' filler ' ' fieldName ' :' varStr];
                if isnListStrOnly,
                    fieldColIndVec(iField) = numel(fieldListStr{iField})-numel(varStr)+2;
                end
            end
            if nFields,
                if isnListStrOnly,
                    leavesPathCVec = vertcat(leavesPathCVec,otherFields);
                    leavesRowIndCVec = vertcat(leavesRowIndCVec,...
                        num2cell(numel(listStr)+(1:nFields).'));
                    leavesColIndCVec = vertcat(leavesColIndCVec,...
                        num2cell(fieldColIndVec));
                end
                listStr = vertcat(listStr, fieldListStr);
            end
            
            function fieldName=getFieldName(fieldNameList,iElem)
                if iscell(fieldNameList),
                    fieldName=fieldNameList{iElem};
                else
                    fieldName='';
                end
            end

        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inner functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [varCell,rowIndVec,colIndVec]=formCellOfString(strIndent,fieldValue,...
    maxFieldLength,filler,FILLER_SYMBOL_CODE,DASH_SYMBOL_CODE)
isnVarCellOnly=nargout>1;
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
filler2 = char(ones(1, maxFieldLength + 6) * ...
    FILLER_SYMBOL_CODE);
dashes = char(ones(1, nDashes)* ...
    DASH_SYMBOL_CODE);
nRows = size(adjustedFieldValue,1);
varCell = cell(nRows+2,1);
if isnVarCellOnly,
    rowIndVec=(1:nRows+2).';
    colIndVec=nan(nRows+2,1);
end
%
prefixStr=[strIndent '   |' filler2];
if isnVarCellOnly,
    colIndVec(1)=numel(prefixStr)+1;
end
varCell{1} = [prefixStr dashes];
%
% first line with field name
prefixStr=[strIndent '   |' filler ' : |'];
varStr=[adjustedFieldValue{1,:}];
if isnVarCellOnly,
    colIndVec(2)=numel(prefixStr)+1;
end
varCell{2} =[prefixStr varStr];
%
% second and higher number rows
prefixStr=[strIndent '   |' filler2 '|'];
if isnVarCellOnly,
    colIndVec(3:(nRows+1))=numel(prefixStr)+1;
end
for iRow = 2 : nRows
    varStr = [adjustedFieldValue{iRow,:}];
    varCell{iRow+1} = [prefixStr varStr];
end
prefixStr=[strIndent '   |' filler2];
if isnVarCellOnly,
    colIndVec(end)=numel(prefixStr)+1;
end
varCell{nRows+2} = [prefixStr dashes];
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

%%
function [isLocalChanges,pathCVec,valCVec]=getleaveslist(SInp,SOld,isFullCheck)
% GETLEAVESLIST generates a list of structure leaves paths
%
% Input:
%   regular:
%     SInp: struct [] - input structure array
%     SOld: struct [] - previous structure array to compare
%
% Output:
%   regular:
%     isLocalChanges: logical [1,1] - if true, then changes are local, i.e.
%        changed are only values of fields; otherwise false, i.e. in the
%        case when the fields of structure SInp themselves are changed in
%        comparison to previous structure SOld
%     pathCVec: char cell [nLeaves,1] - list with paths to leaves
%     valCVec: cell [nLeaves,1] - list with values of leaves
%   optional:
%     isFullCheck: logical [1,1] - if true, then full check for consistency
%        of inner structure for SInp and SOld is performed, otherwise it is
%        supposed that SInp and SOld differ only in the values of their
%        leaves and no check is performed
%
% $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-10-03 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2014 $
%
%
if nargin<3,
    isFullCheck=true;
end
if isequaln(SInp,SOld),
    isLocalChanges=true;
    pathCVec=cell(0,1);
else
    [isLocalChanges,pathCVec]=getleaveslistint(SInp,SOld);
end
if ~isLocalChanges,
    pathCVec=cell(0,1);
    valCVec=cell(0,1);
    return;
end
if nargout>1
    nLeaves=length(pathCVec);
    valCVec=cell(nLeaves,1);
    for iLeave=1:nLeaves
        pathStr=pathCVec{iLeave};
        if pathStr(1)=='(',
            valCVec{iLeave}=eval(['SInp' pathCVec{iLeave}]);
        else
            valCVec{iLeave}=eval(['SInp.' pathCVec{iLeave}]);
        end
    end
end
    function [isLocalChanges,pathCVec]=getleaveslistint(SInp,SOld,fieldNameList)
        pathCVec=cell(0,1);
        if nargin>=3,
            if isequaln(SInp,SOld),
                isLocalChanges=true;
                return;
            end
        else
            fieldNameList=fieldnames(SInp);
        end
        if isFullCheck,
            sizeVec=size(SInp);
            oldFieldNameList=fieldnames(SOld);
            isLocalChanges=numel(fieldNameList)==numel(oldFieldNameList)&&...
                all(ismember(fieldNameList,oldFieldNameList))&&...
                isequal(sizeVec,size(SOld));
            if ~isLocalChanges||isempty(SInp),
                return;
            end
        else
            if isempty(SInp),
                isLocalChanges=true;
                return;
            end
        end
        nFields=numel(fieldNameList);
        isLocalChanges=true;
        %
        if nFields>0
            nElems=numel(SInp);
            fieldPathCVec=cell(nFields,nElems);
            isVector=nElems>1;
            if isVector,
                if ~isFullCheck,
                    sizeVec=size(SInp);
                end
                subIndList=cell(1,length(sizeVec));
            end
            for iElem=1:nElems,
                if isVector,
                    [subIndList{:}]=ind2sub(sizeVec,iElem);
                    indexStr=sprintf('%d,',horzcat(subIndList{:}));
                    indexStr=['(' indexStr(1:end-1) ')'];
                end
                for iField=1:nFields
                    fieldName=fieldNameList{iField};
                    SCur=SInp(iElem).(fieldName);
                    SOldCur=SOld(iElem).(fieldName);
                    isCurStruct=isstruct(SCur);
                    if isFullCheck,
                        if isCurStruct~=isstruct(SOldCur),
                            isLocalChanges=false;
                            return;
                        end
                    end
                    if isCurStruct,
                        curFieldNameList=fieldnames(SCur);
                        if ~isempty(curFieldNameList),
                            [isLocalChanges,fieldPathCVec{iField,iElem}]=...
                                getleaveslistint(SCur,SOldCur,curFieldNameList);
                            if ~isLocalChanges,
                                return;
                            end
                            curFieldPathCVec=fieldPathCVec{iField,iElem};
                            nPaths=numel(curFieldPathCVec);
                            if nElems==1,
                                if numel(SCur)==1,
                                    prefixStr=horzcat(fieldName,'.');
                                else
                                    prefixStr=fieldName;
                                end
                            else
                                if numel(SCur)==1,
                                    prefixStr=horzcat(indexStr,'.',fieldName,'.');
                                else
                                    prefixStr=horzcat(indexStr,'.',fieldName);
                                end
                            end
                            for iPath=1:nPaths,
                                curFieldPathCVec{iPath}=...
                                    horzcat(prefixStr,curFieldPathCVec{iPath});
                            end
                            fieldPathCVec{iField,iElem}=curFieldPathCVec;
                        end
                    elseif ~isequaln(SCur,SOldCur),
                        if nElems==1,
                            fieldPathCVec{iField,iElem}={fieldName};
                        else
                            fieldPathCVec{iField,iElem}={horzcat(indexStr,'.',...
                                fieldName)};
                        end
                    end
                end
            end
            pathCVec=vertcat(fieldPathCVec{:});
        end
    end
end