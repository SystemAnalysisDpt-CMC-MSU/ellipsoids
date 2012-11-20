classdef MatrixOperationsFactory
    properties (Constant,GetAccess=public)
        USE_SPLINE_INTERPOLATION = true;
    end
    methods(Static)
        function obj =create(timeVec)
            if gras.mat.MatrixOperationsFactory.USE_SPLINE_INTERPOLATION
                obj = gras.mat.SplineMatrixOperations(timeVec);
            else
                obj = gras.mat.CompositeMatrixOperations();
            end
        end
    end
end