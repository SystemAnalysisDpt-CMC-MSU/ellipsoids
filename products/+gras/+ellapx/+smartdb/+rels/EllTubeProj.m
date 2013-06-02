classdef EllTubeProj < ...
        gras.ellapx.smartdb.rels.AEllTube & ...
        gras.ellapx.smartdb.rels.AEllTubeProj & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    % EllTubeProj - class which keeps ellipsoidal tube's projection
    %
    % Fields:
    %   QArray:cell[1, nElem] - Array of ellipsoid matrices
    %   aMat:cell[1, nElem] - Array of ellipsoid centers
    %   scaleFactor:double[1, 1] - Tube scale factor
    %   MArray:cell[1, nElem] - Array of regularization ellipsoid matrices
    %   dim :double[1, 1] - Dimensionality
    %   sTime:double[1, 1] - Time s
    %   approxSchemaName:cell[1,] - Name
    %   approxSchemaDescr:cell[1,] - Description
    %   approxType:gras.ellapx.enums.EApproxType - Type of approximation
    %                 (external, internal, not defined)
    %   timeVec:cell[1, m] - Time vector
    %   calcPrecision:double[1, 1] - Calculation precision
    %   indSTime:double[1, 1]  - index of sTime within timeVec
    %   ltGoodDirMat:cell[1, nElem] - Good direction curve
    %   lsGoodDirVec:cell[1, nElem] - Good direction at time s
    %   ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve
    %   lsGoodDirNorm:double[1, 1] - Norm of good direction at time s
    %   xTouchCurveMat:cell[1, nElem] - Touch point curve for good
    %                                   direction
    %   xTouchOpCurveMat:cell[1, nElem] - Touch point curve for direction
    %                                     opposite to good direction
    %   xsTouchVec:cell[1, nElem]  - Touch point at time s
    %   xsTouchOpVec:cell[1, nElem] - Touch point at time s
    %   projSTimeMat: cell[1, 1] - Projection matrix at time s
    %   projType:gras.ellapx.enums.EProjType - Projection type
    %   ltGoodDirNormOrigVec:cell[1, 1] - Norm of the original (not
    %                                     projected) good direction curve
    %   lsGoodDirNormOrig:double[1, 1] - Norm of the original (not
    %                                    projected)good direction at time s
    %   lsGoodDirOrigVec:cell[1, 1] - Original (not projected) good
    %                                 direction at time s
    %
    % TODO: correct description of the fields in
    %     gras.ellapx.smartdb.rels.EllTubeProj
    %
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
        %
        function checkDataConsistency(self)
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTube(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeProj(self);
        end
        %
        function dependencyFieldList=getTouchCurveDependencyFieldList(varargin)
            dependencyFieldList=getTouchCurveDependencyFieldList@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function figureGroupKeyName=figureGetGroupKeyFunc(varargin)
            figureGroupKeyName=figureGetGroupKeyFunc@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function figureSetPropFunc(varargin)
            figureSetPropFunc@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function hVec=axesSetPropBasicFunc(varargin)
            hVec=axesSetPropBasicFunc@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function checkTouchCurves(varargin)
            checkTouchCurves@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
    end
    %
    methods
        function plObj=plot(varargin)
            plObj=plot@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function self=EllTubeProj(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(varargin{:});
        end
    end
end