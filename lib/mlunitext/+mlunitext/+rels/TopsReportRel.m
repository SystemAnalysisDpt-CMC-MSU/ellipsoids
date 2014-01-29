classdef TopsReportRel<mlunitext.rels.TypifiedByFieldCodeRel
    properties (Constant)
        FCODE_TEST_RUN_TIME        
        FCODE_TEST_NAME
        FCODE_TEST_CASE_NAME
        FCODE_TEST_MARKER
    end
    methods
        function self=TopsReportRel(varargin)
            import mlunitext.rels.F;
            self=self@mlunitext.rels.TypifiedByFieldCodeRel(varargin{:});
            self.sortBy(F.TEST_RUN_TIME,'direction','desc');
        end
    end
end