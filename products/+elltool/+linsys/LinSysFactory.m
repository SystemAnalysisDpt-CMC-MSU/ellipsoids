classdef LinSysFactory
    methods(Static)
        function linSys = create(varargin)
            if (nargin > 7)  && ischar(varargin{8}) && (varargin{8} == 'd')
                linSys = elltool.linsys.LinSysDiscrete(varargin{:});
            else
                linSys = elltool.linsys.LinSysContinuous(varargin{:});
            end
        end
    end
end