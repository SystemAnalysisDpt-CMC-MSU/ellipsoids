classdef TopsReportRelation<mlunitext.rels.TypifiedByFieldCodeRel
    properties (Constant)
        FCODE_RUN_TIME
        FCODE_TEST_NAME
    end
    methods
        function self=TopsReportRelation(varargin)
            self=self@mlunitext.rels.TypifiedByFieldCodeRel(varargin{:});
            self.sortBy('runTime','direction','desc');
        end
    end
end