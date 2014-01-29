classdef FunctionLinear<modgen.common.func.AFunction
    % FUNCTIONLINEAR is a class determining linear function with scalar
    % values

    properties (GetAccess=private,Constant,Hidden)
        % list of names for linear functions recognized by their names
        LINEAR_FUNC_NAME_LIST={'deal','partialdeal','minus','plus'};
        % list of the corresponding coefficient vectors
        LINEAR_FUNC_COEFF_VEC_LIST={1,1,[1 -1],[1 1]};
    end
    
    properties (Access=private,Hidden)
        % vector with coefficients of linear function
        coeffVec
    end
    
    methods
        function self=FunctionLinear(varargin)
            % FUNCTIONLINEAR is constructor of FunctionLinear class
            %
            % Usage: self=FunctionLinear(functionName)
            %
            % input:
            %   regular:
            %     coeffVec: double [nCoeffs,1] - vector with coefficients
            %         of given linear function
            %
            % OR
            % 
            %   regular:
            %     functionName: char or function_handle - name of function
            %         or its function_handle
            % output:
            %   regular:
            %     self: FunctionLinear [1,1] - class object
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %

            if nargin~=1,
                error([upper(mfilename),':wrongInput'],...
                    'coeffVec or functionName must be given as input');
            end
            %% get input arguments
            isCoeffVec=isnumeric(varargin{1});
            isFuncName=ischar(varargin{1})||isa(varargin{1},'function_handle');
            if ~(isFuncName||isCoeffVec),
                error([upper(mfilename),':wrongInput'],...
                    'Incorrect input format');
            end
            %% initial actions
            if isCoeffVec,
                coeffList=double(varargin{1});
                % check list of coefficients
                if isempty(coeffList)||~(ndims(coeffList)==2&&...
                        numel(coeffList)==length(coeffList)),
                    error([upper(mfilename),':wrongInput'],...
                        'coeffVec must be vector with finite numeric values');
                end
            else
                % get name of function
                funcName=varargin{1};
                if ~ischar(funcName),
                    if numel(funcName)~=1,
                        error([upper(mfilename),':wrongInput'],...
                            'functionName must be nonempty string or scalar function handle');
                    end
                    funcName=func2str(funcName);
                end
                % get list of coefficients by function name
                [isLinear,indLinear]=feval([mfilename('class') '.isLinear'],funcName);
                if ~isLinear,
                    error([upper(mfilename),':wrongInput'],...
                        'function %s is not recognized as linear',funcName);
                end
                coeffList=...
                    eval([mfilename('class') '.LINEAR_FUNC_COEFF_VEC_LIST']);
                coeffList=coeffList{indLinear};
            end
            %% set class properties
            self=self@modgen.common.func.AFunction(numel(coeffList));
            self.coeffVec=reshape(coeffList,1,[]);
        end
        
        function coeffVec=getCoeffVec(self)
            % GETCOEFFVEC returns vector with coefficients of implemented
            % linear function
            %
            % Usage: coeffVec=getCoeffVec(self)
            %
            % input:
            %   regular:
            %     self: AFunctionLinear [1,1] - class object
            % output:
            %   regular:
            %     coeffVec: double [1,nCoeffs] - vector with coefficients
            %        of implemented linear function
            %
            %
            
            if numel(self)~=1,
                error([upper(mfilename),':wrongInput'],...
                    'self must be scalar object');
            end
            coeffVec=self.coeffVec;
        end
        
        function outValVec=getFuncValues(self,inpValMat)
            % GETFUNCVALUES returns values of function for given values of
            % its input arguments
            %
            % Usage: outValVec=getFuncValues(self,inpValMat)
            %
            % input:
            %   regular:
            %     self: AFunctionLinear [1,1] - class object
            %     inpValMat: double [nRows,nInpArgs] - matrix with values
            %         of input arguments
            % output:
            %   regular:
            %     outValVec: double [nRows,1] - vector with values of
            %         the function implemented by self
            %
            %
            
            if nargin<2,
                error([upper(mfilename),':wrongInput'],...
                    'self and inpValMat must be given as input arguments');
            end
            if numel(self)~=1,
                error([upper(mfilename),':wrongInput'],...
                    'self must be scalar object');
            end
            isnWrong=isnumeric(inpValMat)&&ndims(inpValMat)==2;
            if isnWrong,
                [nRows nCols]=size(inpValMat);
                isnWrong=nCols==self.getNInpArgs();
            end
            if ~isnWrong,
                error([upper(mfilename),':wrongInout'],[...
                    'inpValMat must be numeric matrix with number of '...
                    'columns consistent with number of input arguments '...
                    'of the function implemented by class object']);
            end
            if nCols==1,
                outValVec=double(inpValMat)*self.getCoeffVec();
            else
                outValVec=sum(double(inpValMat).*repmat(self.getCoeffVec(),nRows,1),2);
            end
        end
        
        function isEq=isEqual(self,otherObj)
            % ISEQUAL compares current AFunctionLinear object with other
            % AFunctionLinear object and returns true if they are equal,
            % otherwise it returns false
            %
            % Usage: isEq=isEqual(self,otherObj)
            %
            % input:
            %   regular:
            %     self: AFunctionLinear [1,1] - current class object
            %     otherObj: AFunctionLinear [1,1] - other class object
            % output:
            %   regular:
            %     isEq: logical [1,1] - true if objects are equal, false
            %         otherwise
            %
            %
            
            %% initial actions
            if nargin<2,
                error([upper(mfilename),':wrongInput'],...
                    'both object to be compared must be given');
            end
            isEq=isEqual@modgen.common.func.AFunction(self,otherObj);
            if ~isEq,
                return;
            end
            %% compare functions
            isEq=isequalwithequalnans(self.getCoeffVec(),otherObj.getCoeffVec());
        end
    end
    
    methods (Static)
        function [isLinearVec,indLinearVec]=isLinear(functionNameList)
            % ISLINEAR determines for each function by its name whether it
            % is linear or not (i.e. whether it is possible to create for
            % each function object of the given class or not)
            %
            % Usage: isLinearVec=getIsLinearVec(functionNameList)
            %
            % input:
            %   regular:
            %     functionNameList: char [1,] or char cell [nFuncs,1] -
            %         names of functions
            % output:
            %   regular:
            %     isLinearVec: logical [1(nFuncs),1] - if true, then the
            %         corresponding function is recogized as linear one,
            %         otherwise false
            %   optional:
            %     indLinearVec: double [1(nFuncs),1] - index of linear
            %         function in the list of recognizable linear functions
            %
            %
            
            %% initial actions
            % check functionNameList
            if ischar(functionNameList),
                isnWrong=size(functionNameList,2)==numel(functionNameList)&&...
                        numel(functionNameList)>0;
                functionNameList={functionNameList};
            else
                isnWrong=iscellstr(functionNameList);
                if isnWrong,
                    isnWrong=all(cellfun('size',functionNameList,2)==...
                        cellfun('prodofsize',functionNameList)&...
                        cellfun('prodofsize',functionNameList)>0);
                end
            end
            if ~isnWrong,
                error([upper(mfilename),':wrongInput'],...
                    'functionNameList must be nonempty string or cell array of nonempty strings');
            end
            % return result
            linearFuncNameList=...
                eval([mfilename('class') '.LINEAR_FUNC_NAME_LIST']);
            if nargout>1,
                [isLinearVec,indLinearVec]=ismember(functionNameList,...
                    linearFuncNameList);
            else
                isLinearVec=ismember(functionNameList,...
                    linearFuncNameList);
            end
        end
    end
end