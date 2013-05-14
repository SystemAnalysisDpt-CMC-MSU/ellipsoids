classdef mlunit_test_hashmapxmlmetadata < modgen.containers.test.mlunit_test_diskbasedhashmap

    properties 
    end
    methods
        function self = mlunit_test_hashmapxmlmetadata(varargin)
            self = self@modgen.containers.test.mlunit_test_diskbasedhashmap(varargin{:});
        end

        function self=test_putGetWithMetaData(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            rel2=self.rel2;
            metaData1=struct('version','1.0','author','test1');
            metaData2=struct('version','2.0','author','test2',...
                'application','testApplication');
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            metaDataList={metaData1,metaData2};
            self.map.put(keyList,inpObjList,metaDataList);
            [valueObjList,metaDataGetList]=self.map.get(fliplr(keyList),'UniformOutput',false);
            valueObjList=fliplr(valueObjList);
            metaDataGetList=fliplr(metaDataGetList);
            %compare values
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            mlunitext.assert_equals(isEqual,true);
            %compare meta data
            isEqual=all(cellfun(@isequal,metaDataList,metaDataGetList));
            mlunitext.assert_equals(isEqual,true);
            %
            self.map.removeAll();
        end
    end
end