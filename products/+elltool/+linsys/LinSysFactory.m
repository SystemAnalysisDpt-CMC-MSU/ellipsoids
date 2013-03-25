classdef LinSysFactory
    methods(Static)
        function linSys = create(varargin)
            if nargin >= 8
               if varargin{8} == 'd'
                   linSys = elltool.linsys.LinSysDiscrete(varargin{:});
               else
                  linSys = elltool.linsys.LinSysContinuous(varargin{:});
               end
            else
                linSys = elltool.linsys.LinSysContinuous(varargin{:});
            end
        end
    end
end