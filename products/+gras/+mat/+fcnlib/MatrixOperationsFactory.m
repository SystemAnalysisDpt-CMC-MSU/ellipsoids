classdef MatrixOperationsFactory
    properties (Constant,GetAccess=public)
        USE_SPLINE_INTERPOLATION = true;
    end
    methods(Static)
        function obj =create(timeVec)
            if gras.mat.fcnlib.MatrixOperationsFactory.USE_SPLINE_INTERPOLATION
                obj = gras.mat.fcnlib.SplineMatrixOperations(timeVec);
            else
                obj = gras.mat.fcnlib.CompositeMatrixOperations();
            end
        end
    end
end