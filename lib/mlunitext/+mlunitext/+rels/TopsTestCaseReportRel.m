classdef TopsTestCaseReportRel<mlunitext.rels.TypifiedByFieldCodeRel
    properties (Constant)
        FCODE_TEST_RUN_TIME        
        FCODE_TEST_CASE_NAME
    end
    methods
        function self=TopsTestCaseReportRel(varargin)
            import mlunitext.rels.F;
            self=self@mlunitext.rels.TypifiedByFieldCodeRel(varargin{:});
            self.sortBy(F.TEST_RUN_TIME,'direction','desc');
        end
    end
end