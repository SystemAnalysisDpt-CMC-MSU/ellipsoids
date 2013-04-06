classdef AReach < elltool.reach.IReach
% $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
    properties (Constant, GetAccess = protected)
        MIN_EIG_Q_REG_UNCERT = 0.1
        EXTERNAL_SCALE_FACTOR = 1.02
        INTERNAL_SCALE_FACTOR = 0.98
        DEFAULT_INTAPX_S_SELECTION_MODE = 'volume'
        COMP_PRECISION = 5e-3
        FIELDS_NOT_TO_COMPARE = {'LT_GOOD_DIR_MAT'; ...
            'LT_GOOD_DIR_NORM_VEC'; 'LS_GOOD_DIR_NORM'; ...
            'LS_GOOD_DIR_VEC';' IND_S_TIME';...
            'S_TIME'; 'TIME_VEC'};
    end
    %
    properties (Access = protected)
        switchSysTimeVec
        x0Ellipsoid
        linSysCVec
        isCut
        isProj
        isBackward
        projectionBasisMat
        ellTubeRel
    end
    %
    properties (Constant, Access = private)
        EXTERNAL = 'e'
        INTERNAL = 'i'
        UNION = 'u'
    end
    %
    methods
        function isProj = isprojection(self)
            isProj = self.isProj;
        end
        %
        function isCut = iscut(self)
            isCut = self.isCut;
        end
        %
        function isEmpty = isempty(self)
            isEmpty = isempty(self.x0Ellipsoid);
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
        %
        function isEqual = isEqual(self, reachObj, varargin)
            import gras.ellapx.smartdb.F;
            import gras.ellapx.enums.EApproxType;
            APPROX_TYPE = F.APPROX_TYPE;
            %
            ellTube = self.ellTubeRel;
            compEllTube = reachObj.ellTubeRel;
            %
            if nargin == 4
                ellTube = ellTube.getTuplesFilteredBy(APPROX_TYPE,...
                    varargin{2});
                ellTube = ellTube.getTuples(varargin{1});
                compEllTube = compEllTube.getTuplesFilteredBy(APPROX_TYPE,...
                    varargin{2});
            end
            %
            if ellTube.getNElems < compEllTube.getNElems
                compEllTube = compEllTube.getTuplesFilteredBy(...
                    'lsGoodDirNorm', 1);
            end
            %
            pointsNum = numel(ellTube.timeVec{1});
            newPointsNum = numel(compEllTube.timeVec{1});
            compTimeGridIndVec = 2 .* (1 : pointsNum) - 1;
            firstTimeVec = ellTube.timeVec{1};
            secondTimeVec = compEllTube.timeVec{1};
            if pointsNum ~= newPointsNum
                secondTimeVec = secondTimeVec(compTimeGridIndVec);
            end
            if max(abs(firstTimeVec - secondTimeVec) > self.COMP_PRECISION)
                compTimeGridIndVec = compTimeGridIndVec +...
                    double(compTimeGridIndVec > pointsNum);
            end
            fieldsNotToCompVec =...
                F.getNameList(self.FIELDS_NOT_TO_COMPARE);
            fieldsToCompVec =...
                setdiff(ellTube.getFieldNameList, fieldsNotToCompVec);
            
            if pointsNum ~= newPointsNum
                compEllTube =...
                    compEllTube.thinOutTuples(compTimeGridIndVec);
            end
            isEqual = compEllTube.getFieldProjection(...
                fieldsToCompVec).isEqual(...
                ellTube.getFieldProjection(fieldsToCompVec),...
                'maxTolerance', self.COMP_PRECISION);
        end
    end
end