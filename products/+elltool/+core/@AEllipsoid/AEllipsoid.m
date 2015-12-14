classdef AEllipsoid < elltool.core.ABasicEllipsoid
    properties(Access=protected)
        centerVec    
        absTol
    end
    methods
        function ellObj=AEllipsoid(varargin)
            ellObj=ellObj@elltool.core.ABasicEllipsoid();
        end
        function resArr=repMat(self,varargin)
            % REPMAT -  is analogous to built-in repmat function with 
            %           one exception - it copies the objects, not 
            %           just the handles
            % Example:
            %   firstEllObj = ellipsoid([1; 2], eye(2));
            %   secEllObj = ellipsoid([1; 1], 2*eye(2));
            %   ellVec = [firstEllObj secEllObj];
            %   repMat(ellVec)
            %
            %   ans =
            %   1x2 array of ellipsoids.
            %
            %
            % $Author: Peter Gagarinov <pgagarinov@gmail.com> $   
            % $Date: 24-04-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and Cybernetics,
            %             Science, System Analysis Department 2012-2013 $
            %
            %
            sizeVec=horzcat(varargin{:});
            resArr=repmat(self,sizeVec);
            resArr=resArr.getCopy();
        end
         
        function centerVecVec=getCenterVec(self)
            % GETCENTERVEC - returns centerVec vector of given ellipsoid
            %
            % Input:
            %   regular:
            %      self: ellipsoid[1,1]
            %
            % Output:
            %   centerVecVec: double[nDims,1] - centerVec of ellipsoid
            %
            % Example:
            %   ellObj = ellipsoid([1; 2], eye(2));
            %   getCenterVec(ellObj)
            %
            %   ans =
            %
            %        1
            %        2
            %
            % $Author: Peter Gagarinov <pgagarinov@gmail.com> $   
            % $Date: 24-04-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and Cybernetics,
            %             Science, System Analysis Department 2012-2013 $
            self.checkIfScalar();
            centerVecVec=self.centerVec;
        end
    end
    methods(Access=protected)
        function checkIfScalar(self,errMsg)
            if nargin<2
                errMsg='input argument must be single ellipsoid.';
            end
            modgen.common.checkvar(self,'isscalar(x)',...
                'errorMessage',errMsg);
        end
    end
    methods (Access=protected,Abstract)
        checkIsMeVirtual(ellArr,varargin)
    end
    methods (Abstract)
        shapeMat=getShapeMat(self)
        [SDataArr,SFieldNiceNames,SFieldDescr]=...
            toStruct(ellArr,isPropIncluded)
    end
    methods (Abstract, Static)
        ellArr=fromRepMat(varargin)
        ellArr=fromStruct(SEllArr)
    end
    methods
        outEllArr=plus(varargin)
        trArr=trace(ellArr)
    end
end