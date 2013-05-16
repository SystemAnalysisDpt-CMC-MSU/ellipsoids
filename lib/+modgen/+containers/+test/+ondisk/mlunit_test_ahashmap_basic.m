classdef mlunit_test_ahashmap_basic < mlunitext.test_case

    properties 
        map
        mapFactory
        rel1
        rel2
        testParamList
    end
    
    methods
        function self = mlunit_test_ahashmap_basic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,mapFactory)
            import modgen.*;
            self.mapFactory=mapFactory;
        end

        function self = test_defaultProps(self,varargin)
            map=self.mapFactory.getInstance();
            isHashedKeys=map.getIsHashedKeys();
            isHashedPath=map.getIsHashedPath();
            mlunitext.assert_equals(true,isHashedPath);
            mlunitext.assert_equals(false,isHashedKeys);
        end
    end
end
