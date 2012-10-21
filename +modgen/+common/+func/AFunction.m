classdef AFunction
    % AFUNCTION is a class determining function with scalar values

    properties (Access=private,Hidden)
        % number of input arguments
        nInpArgs
    end
    
    methods
        function self=AFunction(nInpArgs)
            % AFUNCTION is constructor of AFunction class
            %
            % Usage: self=AFunction()
            %
            % input:
            %   regular:
            %     nInpArgs: double [1,1] - number of input arguments for
            %         given function
            % output:
            %   regular:
            %     self: AFunction [1,1] - class object
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
                    'nInpArgs must be given as input');
            end
            isnWrong=isnumeric(nInpArgs)&&numel(nInpArgs)==1;
            if isnWrong,
                nInpArgs=double(nInpArgs);
                isnWrong=floor(nInpArgs)==nInpArgs&&nInpArgs>=1;
            end
            if ~isnWrong,
                error([upper(mfilename),':wrongInput'],...
                    'nInpArgs must be scalar positive integer');
            end
            self.nInpArgs=nInpArgs;
        end
        
        function nInpArgsVec=getNInpArgs(self)
            % GETNINPARGS returns the number of input arguments for
            % implemented functions
            %
            % Usage: nInpArgsVec=getNInpArgs(self)
            %
            % input:
            %   regular:
            %     self: AFunction [nFuncs,1] - array with class objects
            % output:
            %   regular:
            %     nInpArgsVec: double [nFuncs,1] - array containing number
            %        of input arguments (if -1, then the number of input
            %        arguments is not fixed in the respective function)
            %
            %
            
            nInpArgsVec=reshape(vertcat(self.nInpArgs),size(self));
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
            if numel(self)~=1||numel(otherObj)~=1,
                error([upper(mfilename),':wrongInput'],...
                    'both object to be compared must be scalar');
            end
            %% compare objects
            isEq=isequal(class(self),class(otherObj));
        end
    end
    
    methods (Abstract)
        outValVec=getFuncValues(self,inpValMat)
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
    end
end