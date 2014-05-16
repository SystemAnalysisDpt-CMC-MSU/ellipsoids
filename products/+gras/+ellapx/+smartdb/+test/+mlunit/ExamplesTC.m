classdef ExamplesTC < mlunitext.test_case
    %
    methods
        function self = ExamplesTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
        %
        function test_examples(~)
            gras.ellapx.smartdb.test.examples.example_cat(); 
            gras.ellapx.smartdb.test.examples.example_CopySaveProj(); 
            gras.ellapx.smartdb.test.examples.example_CopySaveTubes(); 
            gras.ellapx.smartdb.test.examples.example_CopySaveUnion(); 
            gras.ellapx.smartdb.test.examples.example_cut1(); 
            gras.ellapx.smartdb.test.examples.example_cut2(); 
            gras.ellapx.smartdb.test.examples.example_fromEllArray(); 
            gras.ellapx.smartdb.test.examples.example_fromEllMArray(); 
            gras.ellapx.smartdb.test.examples.example_fromEllTubes(); 
            gras.ellapx.smartdb.test.examples.example_fromQArrays1(); 
            gras.ellapx.smartdb.test.examples.example_fromQArrays2(); 
            gras.ellapx.smartdb.test.examples.example_fromQMArrays1(); 
            gras.ellapx.smartdb.test.examples.example_fromQMArrays2(); 
            gras.ellapx.smartdb.test.examples.example_fromQMScaledArrays(); 
            gras.ellapx.smartdb.test.examples.example_getDataProj(); 
            gras.ellapx.smartdb.test.examples.example_getDataTube(); 
            gras.ellapx.smartdb.test.examples.example_getDataUnion(); 
            gras.ellapx.smartdb.test.examples.example_getEllArrayProj(); 
            gras.ellapx.smartdb.test.examples.example_getEllArrayTube(); 
            gras.ellapx.smartdb.test.examples.example_getEllArrayUnion(); 
            gras.ellapx.smartdb.test.examples.example_getInfoProj(); 
            gras.ellapx.smartdb.test.examples.example_getInfoTube(); 
            gras.ellapx.smartdb.test.examples.example_getInfoUnion(); 
            gras.ellapx.smartdb.test.examples.example_interp(); 
            gras.ellapx.smartdb.test.examples.example_isEqual1(); 
            gras.ellapx.smartdb.test.examples.example_isEqual2(); 
            gras.ellapx.smartdb.test.examples.example_isEqualProj(); 
            gras.ellapx.smartdb.test.examples.example_isEqualUnion(); 
            gras.ellapx.smartdb.test.examples.example_plot(); 
            gras.ellapx.smartdb.test.examples.example_plotExt(); 
            gras.ellapx.smartdb.test.examples.example_plotInt();
            gras.ellapx.smartdb.test.examples.example_project(); 
            gras.ellapx.smartdb.test.examples.example_projectStatic(); 
            gras.ellapx.smartdb.test.examples.example_projectStaticTube(); 
            gras.ellapx.smartdb.test.examples.example_projectToOrths1(); 
            gras.ellapx.smartdb.test.examples.example_projectToOrths2(); 
            gras.ellapx.smartdb.test.examples.example_projectTube(); 
            gras.ellapx.smartdb.test.examples.example_scale(); 
            gras.ellapx.smartdb.test.examples.example_thinOutTuples(); 
        end
    end
end

