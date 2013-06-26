classdef MatrixInterpolantFactory
    methods (Static)
        function obj=createInstance(type,varargin)
            import modgen.common.type.simple.checkgen;
            import modgen.common.throwerror;
            checkgen(type,'isstring(x)');
            switch lower(type)
                case 'posdef_chol',
                    obj=gras.interp.PosDefMatCholCubicSpline(varargin{:});
                case 'nndef_chol',
                    obj=gras.interp.NNDefMatCholCubicSpline(varargin{:});
                case 'column',
                    obj=gras.interp.MatrixColCubicSpline(varargin{:});
                case 'row',
                    obj=gras.interp.MatrixRowCubicSpline(varargin{:});
                case 'scalar'
                    obj=gras.interp.MatrixScalarCubicSpline(varargin{:});
                case 'column_triu'
                    obj=gras.interp.MatrixColTriuCubicSpline(varargin{:});
                case 'symm_column_triu',
                    obj=gras.interp.MatrixColTriuSymmCubicSpline(varargin{:});
                otherwise,
                    throwerror('wrongInput',...
                        'Interpolation type %s is not supported',type);
            end
        end
    end
end