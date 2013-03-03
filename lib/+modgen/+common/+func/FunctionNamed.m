classdef FunctionNamed<modgen.common.func.AFunction
    % FUNCTIONNAMED is a class determining function with scalar values that
    % have its name (or is given by its function handle)

    properties (Access=private,Hidden)
        % name of function (or its function handle)
        functionName
    end
    
    methods
        function self=FunctionNamed(funcName)
            % FUNCTIONNAMED is constructor of FunctionNamed class
            %
            % Usage: self=FunctionNamed(functionName)
            %
            % input:
            %   regular:
            %     functionName: char or function_handle - name of function
            %         or its function_handle
            % output:
            %   regular:
            %     self: FunctionNamed [1,1] - class object
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %

            if nargin<1,
                error([upper(mfilename),':wrongInput'],...
                    'functionName must be given as input');
            end
            %% initial actions
            if ischar(funcName),
                if ~(size(funcName,2)==numel(funcName)&&size(funcName,2)>0),
                     error([upper(mfilename),':wrongInput'],...
                         'functionName must be nonempty string or scalar function_handle');
                end
                if ~(exist(funcName,'builtin')||exist(funcName,'file')),
                    error([upper(mfilename),':wrongInput'],...
                        'function %s does not exist',funcName);
                end
                funcNameStr=funcName;
            elseif isa(funcName,'function_handle')&&numel(funcName)==1,
                funcNameStr=func2str(funcName);
            else
                error([upper(mfilename),':wrongInput'],...
                    'functionName must be nonempty string or scalar function_handle');
            end
            if nargout(funcName)==0,
                error([upper(mfilename),':wrongInput'],...
                    'function %s must have at least one output argument',funcNameStr);
            end
            nInpArgs=nargin(funcName);
            if nInpArgs==-1,
                nInpArgs=Inf;
            end
            self=self@modgen.common.func.AFunction(nInpArgs);
            self.functionName=funcName;
        end
        
        function funcName=getFuncName(self)
            % GETFUNCNAME returns the name of implemented function (or its
            % function handle)
            %
            % Usage: funcName=getFuncName(self)
            %
            % input:
            %   regular:
            %     self: AFunction [1,1] - class object
            % output:
            %   regular:
            %     functionName: char [1,] or function_handle[1,1] - name of
            %        function or its function handle
            %
            %
            
            if numel(self)~=1,
                error([upper(mfilename),':wrongInput'],...
                    'self must be scalar object');
            end
            funcName=self.functionName;
        end
        
        function outValVec=getFuncValues(self,inpValMat)
            % GETFUNCVALUES returns values of function for given values of
            % its input arguments
            %
            % Usage: outValVec=getFuncValues(self,inpValMat)
            %
            % input:
            %   regular:
            %     self: AFunction [1,1] - class object
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
                isnWrong=size(inpValMat,2)<=self.getNInpArgs();
            end
            if ~isnWrong,
                error([upper(mfilename),':wrongInout'],[...
                    'inpValMat must be numeric matrix with number of '...
                    'columns consistent with number of input arguments '...
                    'of the function implemented by class object']);
            end
            inpValMat=modgen.common.num2cell(double(inpValMat),1);
            outValVec=feval(self.functionName,inpValMat{:});
        end
        
        function isEq=isEqual(self,otherObj)
            % ISEQUAL compares current AFunction object with other
            % AFunction object and returns true if they are equal,
            % otherwise it returns false
            %
            % Usage: isEq=isEqual(self,otherObj)
            %
            % input:
            %   regular:
            %     self: AFunction [1,1] - current class object
            %     otherObj: AFunction [1,1] - other class object
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
            funcName1=self.getFuncName();
            funcName2=self.getFuncName();
            if isa(funcName1,'function_handle'),
                funcName1=func2str(funcName1);
            end
            if isa(funcName2,'function_handle'),
                funcName2=func2str(funcName2);
            end
            isEq=strcmp(funcName1,funcName2);
        end
    end
end