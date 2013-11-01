classdef GenEllipsoidFactory
    methods(Static)
        function GenEllObj = create(varargin)
            GenEllObj = elltool.core.GenEllipsoid.GenEllipsoid(varargin{:});
        end
    end
end