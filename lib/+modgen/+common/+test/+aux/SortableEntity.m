classdef SortableEntity<modgen.common.test.aux.CompEntity
    %
    methods
        function [resVec,indVec]=sort(inpVec)
            [resVec,indVec]=modgen.algo.sort.mergesort(inpVec);
        end
        function self=SortableEntity(varargin)
            self=self@modgen.common.test.aux.CompEntity(varargin{:});
        end
    end
end
