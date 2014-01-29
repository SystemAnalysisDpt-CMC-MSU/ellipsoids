classdef mlunit_test_nostorage < mlunitext.test_case

    properties 
        map
        rel1
        rel2
    end
    
    methods
        function self = mlunit_test_nostorage(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)
            import modgen.*;
            self.map=containers.ondisk.HashMapXMLMetaData(...
                'storageFormat','none');
            self.map.removeAll();
        end
        function self=test_putGetWithMetaData(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=struct('a',1,'b',2);
            rel2=struct('a',1,'b',2,'c',3);
            metaData1=struct('version','1.0','author','test1');
            metaData2=struct('version','2.0','author','test2',...
                'application','testApplication');
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            metaDataList={metaData1,metaData2};
            self.map.put(keyList,inpObjList,metaDataList);
            inpArgList={fliplr(keyList),'UniformOutput',false};
            self.runAndCheckError('[valueObjList,metaDataGetList]=self.map.get(inpArgList{:})',...
                'AHASHMAP:GETFILENAMEBYKEY:noRecord');
            %
            self.map.removeAll();
        end
    end
end