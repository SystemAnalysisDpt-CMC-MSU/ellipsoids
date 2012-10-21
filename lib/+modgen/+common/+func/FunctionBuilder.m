classdef FunctionBuilder
    % FUNCTIONBUILDER is a class that builds objects of AFunction class

    methods (Static)
        function objCVec=build(varargin)
            % BUILD creates objects of AFunction class
            %
            % Usage: self=build(functionNameList,varargin)
            %
            % input:
            %   optional:
            %     functionNameList: char or function_handle [nFuncs,1] or
            %         cell [nFuncs,1], each cell contains char [1,] or
            %         function_handle [1,1] - names of functions or their
            %         function_handle values
            %   properties:
            %     linearFuncCoeffList: double [nCoeffs,1] or
            %         cell [nFuncs,1], i-th cell contains
            %         double [nCoeffs_i,1] - if nonempty, the corresponding
            %         function is linear and this vector determines its
            %         coefficients, otherwise the corresponding function is
            %         nonlinear and is determined by the respective value
            %         from functionNameList
            % output:
            %   regular:
            %     objCVec: cell [nFuncs,1], each cell contains 
            %         AFunction [1,1] - list of created class objects
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-06 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %

            %% parse parameters
            [reg,prop]=modgen.common.parseparams(varargin,[],[0 1]);
            isFuncNameList=~isempty(reg);
            nProp=length(prop);
            isInpLinearCoeff=false;
            for iProp=1:2:nProp-1,
                switch lower(prop{iProp})
                    case 'linearfunccoefflist',
                        isInpLinearCoeff=true;
                        linearFuncCoeffList=prop{iProp+1};
                    otherwise
                        error([upper(mfilename),':wrongInput'],...
                            'Unknown property: %s',prop{iProp});
                end
            end
            %% check input arguments
            if ~(isFuncNameList||isInpLinearCoeff),
                error([upper(mfilename),':wrongInput'],...
                    'Either functionNameList or linearFuncCoeffList must be given');
            end
            % check linearFuncCoeffList
            if isInpLinearCoeff,
                isnWrong=isnumeric(linearFuncCoeffList);
                if isnWrong,
                    linearFuncCoeffList={linearFuncCoeffList};
                else
                    isnWrong=iscell(linearFuncCoeffList);
                    if isnWrong,
                        isnWrong=all(cellfun(@isnumeric,linearFuncCoeffList));
                    end
                end
                if ~isnWrong,
                    error([upper(mfilename),':wrongInput'],...
                        'Wrong format of linearFuncCoeffList');
                end
            end                
            isnLinearVecProcessed=isInpLinearCoeff;
            % check functionNameList
            if isFuncNameList,
                functionNameList=reg{1};
                if iscell(functionNameList),
                    % process the general case
                    % get isLinearVec
                    if isInpLinearCoeff,
                        if numel(linearFuncCoeffList)~=numel(functionNameList),
                            error([upper(mfilename),':wrongInput'],...
                                'functionNameList and linearFuncCoeffList are not consistent in size');
                        end
                        linearFuncCoeffList=reshape(linearFuncCoeffList,size(functionNameList));
                        isLinearVec=~cellfun('isempty',linearFuncCoeffList);
                        isnLinearVecProcessed=false;
                    else
                        isLinearVec=false(size(functionNameList));
                    end
                    isCharVec=cellfun('isclass',functionNameList,'char');
                    isFuncVec=cellfun('isclass',functionNameList,'function_handle');
                    functionNameStrList=functionNameList;
                    isnWrong=all(isCharVec|isFuncVec);
                    % check cells in functionNameList that are strings
                    if isnWrong&&any(isCharVec),
                        isnWrong=all(...
                            cellfun('size',functionNameList(isCharVec),1)==1&...
                            cellfun('size',functionNameList(isCharVec),2)>=...
                            double(~isLinearVec(isCharVec))&...
                            cellfun('ndims',functionNameList(isCharVec))==2);
                    end
                    % check cells in functionNameList that are function handles
                    if isnWrong&&any(isFuncVec),
                        isnWrong=all(...
                            cellfun('prodofsize',functionNameList(isFuncVec))==1);
                        if isnWrong,
                            functionNameStrList(isFuncVec)=cellfun(@func2str,...
                                functionNameList(isFuncVec),'UniformOutput',false);
                        end
                    end
                    if ~isnWrong,
                        error([upper(mfilename),':wrongInput'],...
                            'all cells in functionNameList must contain string or scalar function_handle');
                    end
                elseif isa(functionNameList,'function_handle'),
                    % process the case when all functions are given by their
                    % function handles
                    functionNameList={functionNameList};
                    functionNameStrList=cellfun(@func2str,functionNameList,...
                        'UniformOutput',false);
                elseif ischar(functionNameList),
                    % process the case when single function is given by string
                    if ~(ndims(functionNameList)==2&&...
                            size(functionNameList,1)==1&&size(functionNameList,2)>0),
                        error([upper(mfilename),':wrongInput'],...
                            'functionNameList must be nonempty string');
                    end
                    functionNameList={functionNameList};
                    functionNameStrList=functionNameList;
                else
                    error([upper(mfilename),':wrongInput'],...
                        'functionNameList is of wrong type');
                end
            end
            % get isLinearVec
            if isnLinearVecProcessed,
                if isFuncNameList,
                    % check whether linearFuncCoeffList is consistent with
                    % functionNameList
                    if numel(linearFuncCoeffList)~=numel(functionNameList),
                        error([upper(mfilename),':wrongInput'],...
                            'functionNameList and linearFuncCoeffList are not consistent in size');
                    end
                    linearFuncCoeffList=reshape(linearFuncCoeffList,size(functionNameList));
                end
                isLinearVec=~cellfun('isempty',linearFuncCoeffList);
            elseif ~isInpLinearCoeff,
                % determine what functions are linear by their names
                isLinearVec=modgen.common.func.FunctionLinear.isLinear(functionNameStrList);
            end
            %% construct objects
            objCVec=cell(size(isLinearVec));
            if any(isLinearVec),
                if isInpLinearCoeff,
                    objCVec(isLinearVec)=cellfun(@(x)modgen.common.func.FunctionLinear(x),...
                        linearFuncCoeffList(isLinearVec),'UniformOutput',false);
                else
                    objCVec(isLinearVec)=cellfun(@(x)modgen.common.func.FunctionLinear(x),...
                        functionNameList(isLinearVec),'UniformOutput',false);
                end
            end
            if ~all(isLinearVec),
                if ~isFuncNameList,
                    error([upper(mfilename),':wrongInput'],...
                        'for some functions linearFuncCoeffList is empty, functionNameList must be given');
                end
                objCVec(~isLinearVec)=cellfun(@(x)modgen.common.func.FunctionNamed(x),...
                    functionNameList(~isLinearVec),'UniformOutput',false);
            end
        end
    end
end