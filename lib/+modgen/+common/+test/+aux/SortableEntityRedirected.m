classdef SortableEntityRedirected<...
        modgen.common.test.aux.CompareRedirectAppliance&...
        modgen.common.test.aux.SortableEntity
    methods
        function self=SortableEntityRedirected(varargin)
            self=self@modgen.common.test.aux.SortableEntity(varargin{:});
        end
    end
end