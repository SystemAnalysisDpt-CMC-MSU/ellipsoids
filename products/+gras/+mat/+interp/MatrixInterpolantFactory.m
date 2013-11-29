classdef MatrixInterpolantFactory
    methods (Static)
        function obj=createInstance(type,varargin)
            import modgen.common.type.simple.checkgen;
            import modgen.common.throwerror;
            checkgen(type,'isstring(x)');
            switch lower(type)
                case 'linear',
                    obj=gras.mat.interp.MatrixLinearInterp(varargin{:});
                case 'nearest',
                    obj=gras.mat.interp.MatrixNearestInterp(varargin{:});                    
                case 'posdef_chol',
                    obj=gras.mat.interp.PosDefMatCholCubicSpline(varargin{:});
                case 'nndef_chol_mult',
                    obj=gras.mat.interp.NNDefMatCholMultCubicSpline(varargin{:});
                case 'nndef_triu',
                    obj=gras.mat.interp.MatrixNNDefTriuCubicSpline(varargin{:});
                case 'column',
                    obj=gras.mat.interp.MatrixColCubicSpline(varargin{:});
                case 'row',
                    obj=gras.mat.interp.MatrixRowCubicSpline(varargin{:});
                case 'scalar'
                    obj=gras.mat.interp.MatrixScalarCubicSpline(varargin{:});
                case 'column_triu'
                    obj=gras.mat.interp.MatrixColTriuCubicSpline(varargin{:});
                case 'symm_column_triu',
                    obj=gras.mat.interp.MatrixColTriuSymmCubicSpline(varargin{:});
                otherwise,
                    throwerror('wrongInput',...
                        'Interpolation type %s is not supported',type);
            end
        end
    end
end