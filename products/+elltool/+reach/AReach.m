classdef AReach < elltool.reach.IReach
% Kirill Mayantsev
% <kirill.mayantsev@gmail.com>$  
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics 
%             and Computer Science, 
%             System Analysis Department 2013$
%
    properties (Access = protected)
        switchSysTimeVec
        x0Ellipsoid
        linSysCVec
        isCut
        isProj
        isBackward
        projectionBasisMat
        %
        absTol
        relTol
        nPlot2dPoints
        nPlot3dPoints
        nTimeGridPoints
    end
    %
    properties (Constant, Access = private)
        EXTERNAL = 'e'
        INTERNAL = 'i'
        UNION = 'u'
    end
    %
    methods (Access = private)
        function isArr = fApplyArrMethod(self,propertyName,addFunc)
            if nargin < 3
                isArr = arrayfun(@(x) x.(propertyName), self); 
            else
                fApplyToProperty = str2func(addFunc);
                isArr = arrayfun(@(x) fApplyToProperty(x.(propertyName)), self);
            end    
            %in case of empty input array make output logical
            isArr = logical(isArr);  
        end    
    end
    %
    methods (Access = protected, Static)
        function [propArr, propVal] = getProperty(rsArr,propName,fPropFun)
        % GETPROPERTY - gives array the same size as rsArray with values of 
        %               propName properties for each reach set in rsArr. 
        %               Private method, used in every public property getter.
        %               
        %
        % Input:
        %   regular:
        %       rsArray: elltool.reach.AReach[nDims1, nDims2,...] -  
        %           multidimension array of reach sets 
        %       propName: char[1,N] - name property
        %
        %   optional:
        %       fPropFun: function_handle[1,1] - function that apply to the propArr. 
        %           The default is @min.        
        %
        % Output:
        %   regular:
        %       propArr: double[nDim1, nDim2,...] -  multidimension array of properties 
        %          for reach object in rsArr
        %   optional:
        %       propVal: double[1, 1] - return result of work fPropFun with the propArr
        %
        % $Author: Zakharov Eugene <justenterrr@gmail.com>$
        %   $Date: 17-november-2012$
        % $Author: Grachev Artem  <grachev.art@gmail.com> $
        %   $Date: March-2013$
        % $Copyright: Moscow State University,
        %             Faculty of Computational Mathematics
        %             and Computer Science,
        %             System Analysis Department 2013 $
        %
            import modgen.common.throwerror;
            propNameList = {'absTol', 'relTol', 'nPlot2dPoints',...
                'nPlot3dPoints', 'nTimeGridPoints'};
            if ~any(strcmp(propName, propNameList))
                throwerror('wrongInput', [propName, ':no such property']);
            end
            %
            if nargin == 2
                fPropFun = @min;
            end
            propArr = arrayfun(@(x)x.(propName), rsArr); 
            if nargout == 2
                propVal = fPropFun(propArr(:));
            end
        end
        %
        function [absTolArr, absTolVal] = getAbsTol(rsArr, varargin)
        % GETABSTOL - gives the array of absTol for all elements in rsArr
        %
        % Input:
        %   regular:
        %       rsArr: elltool.reach.ReachDiscrete[nDim1, nDim2, ...] - multidimension 
        %              array of reach sets
        %   optional:
        %       fAbsTolFun: function_handle[1,1] - function that apply to the absTolArr. 
        %               The default is @min.
        %         
        % Output:
        %   regular:
        %       absTolArr: double [absTol1, absTol2, ...] - return absTol for each 
        %                 element in rsArr
        %   optional:
        %       absTol: double[1,1] - return result of work fAbsTolFun with the absTolArr
        %
        % Usage:
        %   use [~,absTol] = rsArr.getAbsTol() if you want get only absTol,
        %   use [absTolArr,absTol] = rsArr.getAbsTol() if you want get absTolArr and absTol,
        %   use absTolArr = rsArr.getAbsTol() if you want get only absTolArr
        % 
        %$Author: Zakharov Eugene  <justenterrr@gmail.com> $
        % $Author: Grachev Artem  <grachev.art@gmail.com> $
        %   $Date: March-2013$
        % $Copyright: Moscow State University,
        %             Faculty of Computational Mathematics
        %             and Computer Science, 
        %             System Analysis Department 2013 $
        % 
            [absTolArr, absTolVal] = elltool.reach.AReach.getProperty(...
                rsArr, 'absTol', varargin{:});
        end
        %
        function [relTolArr, relTolVal] = getRelTol(rsArr, varargin)
        % GETRELTOL - gives the array of relTol for all elements in ellArr
        %
        % Input:
        %   regular:
        %       rsArr: elltool.reach.AReach[nDim1,nDim2, ...] - multidimension  
        %           array of reach sets.
        %   optional
        %       fRelTolFun: function_handle[1,1] - function that apply to the  
        %           relTolArr. The default is @min.
        %
        % Output:
        %   regular:
        %       relTolArr: double [relTol1, relTol2, ...] - return relTol for each 
        %           element in rsArr
        %   optional:
        %       relTol: double[1,1] - return result of work fRelTolFun with the
        %           relTolArr
        %           
        %
        % Usage:
        %   use [~,relTol] = rsArr.getRelTol() if you want get only relTol,
        %   use [relTolArr,relTol] = rsArr.getRelTol() if you want get relTolArr
        %        and relTol,
        %   use relTolArr = rsArr.getRelTol() if you want get only relTolArr
        %
        %$Author: Zakharov Eugene  <justenterrr@gmail.com> $
        % $Author: Grachev Artem  <grachev.art@gmail.com> $
        %   $Date: March-2013$
        % $Copyright: Moscow State University,
        %             Faculty of Computational Mathematics
        %             and Computer Science, 
        %             System Analysis Department 2013 $
        %
            [relTolArr, relTolVal] = elltool.reach.AReach.getProperty(...
                rsArr, 'relTol', varargin{:});
        end
        %
        function nPlot2dPointsArr = getNPlot2dPoints(rsArr)
        % GETNPLOT2DPOINTS - gives array  the same size as rsArr of value of 
        %                    nPlot2dPoints property for each element in rsArr - 
        %                    array of reach sets
        % 
        %
        % Input:
        %   regular:
        %     rsArr:elltool.reach.AReach[nDims1,nDims2,...] - reach set array 
        %           
        %
        % Output:
        %   nPlot2dPointsArr:double[nDims1,nDims2,...] - array of values of 
        %       nTimeGridPoints property for each reach set in rsArr
        %
        % $Author: Zakharov Eugene
        % <justenterrr@gmail.com> $    
        % $Date: 17-november-2012 $ 
        % $Copyright: Moscow State University,
        %             Faculty of Computational Mathematics
        %             and Computer Science,
        %             System Analysis Department 2012 $
        %
            nPlot2dPointsArr =...
                elltool.reach.AReach.getProperty(rsArr, 'nPlot2dPoints');
        end
        %
        function nPlot3dPointsArr = getNPlot3dPoints(rsArr)
        % GETNPLOT3DPOINTS - gives array  the same size as rsArr of value of 
        %                    nPlot3dPoints property for each element in rsArr
        %                    - array of reach sets
        %
        % Input:
        %   regular:
        %       rsArr:elltool.reach.AReach[nDims1,nDims2,...] - reach set array
        %
        % Output:
        %   nPlot3dPointsArr:double[nDims1,nDims2,...]- array of values of 
        %             nPlot3dPoints property for each reach set in rsArr
        %       
        %
        % $Author: Zakharov Eugene
        % <justenterrr@gmail.com> $    
        % $Date: 17-november-2012 $ 
        % $Copyright: Moscow State University,
        %             Faculty of Computational Mathematics
        %             and Computer Science,
        %             System Analysis Department 2012 $
        %
            nPlot3dPointsArr =...
                elltool.reach.AReach.getProperty(rsArr, 'nPlot3dPoints');
        end
        %
        function nTimeGridPointsArr = getNTimeGridPoints(rsArr)
        % GETNTIMEGRIDPOINTS - gives array  the same size as rsArr of value of 
        %                      nTimeGridPoints property for each element in rsArr
        %                     - array of reach sets
        % 
        % Input:
        %   regular:
        %       rsArr: elltool.reach.AReach[nDims1,nDims2,...] - reach set 
        %         array
        %
        % Output:
        %   nTimeGridPointsArr: double[nDims1,nDims2,...]- array of values of 
        %       nTimeGridPoints property for each reach set in rsArr
        %       
        %
        % $Author: Zakharov Eugene
        % <justenterrr@gmail.com> $    
        % $Date: 17-november-2012 $ 
        % $Copyright: Moscow State University,
        %             Faculty of Computational Mathematics
        %             and Computer Science,
        %             System Analysis Department 2012 $
        %
            nTimeGridPointsArr =...
                elltool.reach.AReach.getProperty(rsArr, 'nTimeGridPoints');
        end
    end
    methods
        function resArr=repMat(self,varargin)
            sizeVec=horzcat(varargin{:});
            resArr=repmat(self,sizeVec);
            resArr=resArr.getCopy();    
        end
        %
        function isProjArr = isprojection(self)
            isProjArr = fApplyArrMethod(self,'isProj');  
        end
        %
        function isCutArr = iscut(self)
            isCutArr = fApplyArrMethod(self,'isCut');  
        end
        %
        function isEmptyArr = isempty(self)   
            isEmptyArr = fApplyArrMethod(self,'x0Ellipsoid','isempty');
        end
        %
        function isEmptyIntersect =...
                intersect(self, intersectObj, approxTypeChar)
            if ~(isa(intersectObj, 'ellipsoid')) &&...
                    ~(isa(intersectObj, 'hyperplane')) &&...
                    ~(isa(intersectObj, 'polytope'))
                throwerror(['INTERSECT: first input argument must be ',...
                    'ellipsoid, hyperplane or polytope.']);
            end
            if (nargin < 3) || ~(ischar(approxTypeChar))
                approxTypeChar = self.EXTERNAL;
            elseif approxTypeChar ~= self.INTERNAL
                approxTypeChar = self.EXTERNAL;
            end
            if approxTypeChar == self.INTERNAL
                approxCVec = self.get_ia();
                isEmptyIntersect =...
                    intersect(approxCVec, intersectObj, self.UNION);
            else
                approxCVec = self.get_ea();
                approxNum = size(approxCVec, 2);
                isEmptyIntersect =...
                    intersect(approxCVec(:, 1),...
                    intersectObj, self.INTERNAL);
                for iApprox = 2 : approxNum
                    isEmptyIntersect =...
                        isEmptyIntersect |...
                        intersect(approxCVec(:, iApprox),...
                        intersectObj, self.INTERNAL);
                end
            end
        end
    end
end