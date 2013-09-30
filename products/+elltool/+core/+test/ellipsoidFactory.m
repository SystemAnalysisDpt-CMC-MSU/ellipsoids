classdef ellipsoidFactory
    methods(Static)
        function ellObj = create(varargin)
            ellObj = elltoolboxcore.ellipsoid.ellipsoid(varargin{:});
        end
    end
end