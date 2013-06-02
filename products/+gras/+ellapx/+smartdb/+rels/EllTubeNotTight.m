classdef EllTubeNotTight < gras.ellapx.smartdb.rels.AEllTubeNotTight & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    % EllTubeNotTight - class which keeps not-tight ellipsoidal tubes
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
    %
    %   TODO: correct description of the fields in
    %   gras.ellapx.smartdb.rels.EllTubeNotTight
    %
    methods (Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    %
    methods
        function self=EllTubeNotTight(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
    end
end

