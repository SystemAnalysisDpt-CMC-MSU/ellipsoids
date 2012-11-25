classdef MatrixOperationsFactory
    properties (Constant,GetAccess=public)
        USE_SPLINE_INTERPOLATION = true;
    end
    methods(Static)
        function obj =create(timeVec)
            import gras.ellapx.uncertcalc.MatrixOperationsFactory;
            if MatrixOperationsFactory.USE_SPLINE_INTERPOLATION
                obj = gras.interp.SplineMatrixOperations(timeVec);
            else
                obj = gras.mat.fcnlib.CompositeMatrixOperations();
            end
        end
    end
end