classdef MatrixOperationsFactory<modgen.common.obj.StaticPropStorage
    properties (Constant,GetAccess=public)
        DEFAULT_IS_SPLINE_USED = true;
        IS_SPLINE_OP_PROP_NAME='isSplineUsed';
    end
    methods(Static)
        function obj =create(timeVec)
            import gras.mat.MatrixOperationsFactory;
            import modgen.common.throwerror;
            [isSplineUsed,isThere]=MatrixOperationsFactory.getProp(...
                MatrixOperationsFactory.IS_SPLINE_OP_PROP_NAME,true);
            if ~isThere
                isSplineUsed=MatrixOperationsFactory.DEFAULT_IS_SPLINE_USED;
            end
            if isSplineUsed
                obj = gras.interp.SplineMatrixOperations(timeVec);
            else
                obj = gras.mat.CompositeMatrixOperations();
            end
        end
        function setIsSplineUsed(isSplineUsed)
            import gras.mat.MatrixOperationsFactory;
            MatrixOperationsFactory.setProp(...
                MatrixOperationsFactory.IS_SPLINE_OP_PROP_NAME,isSplineUsed);
        end
    end
    methods (Static, Access=private)
        function [propVal,isThere]=getProp(propName,varargin)
            branchName=mfilename('class');
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,varargin{:});
        end
        function setProp(propName,propVal)
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        function flush()
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.flushInternal(branchName);
        end
    end
end