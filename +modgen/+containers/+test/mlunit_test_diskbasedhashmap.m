classdef mlunit_test_diskbasedhashmap < mlunitext.test_case
    %
    properties 
        map
        mapFactory
        rel1
        rel2
        testParamList
        resTmpDir
    end
    %
    methods
        function self = mlunit_test_diskbasedhashmap(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = tear_down(self)
            rmdir(self.resTmpDir,'s');
        end
        function self = set_up_param(self,mapFactory,varargin)
            import modgen.*;
            self.mapFactory=mapFactory;
            self.resTmpDir=modgen.test.TmpDataManager.getDirByCallerKey();
            storageRootDir=self.resTmpDir;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'testBranch','storageLocationRoot',storageRootDir,...
                varargin{:});
            %
            self.rel1=struct(...
                    'gamma',{{[1 2 3],[1 2 3]}},...
                    'delta',{{[1 2 3], [4 5 6]}},...
                    'epsilon',{{'nu','mu'}},...
                    'zeta',int16([144 1]),...
                    'eta',logical([1 1]),...
                    'theta',{{'nu','nu'}},...
                    'iota',{{'nu','mu'}});
            %                
            self.rel2=struct(...
                    'gamma',{{[1 2 3],[1 2 44545453]}},...
                    'delta',{{[1 2.676676734 3], [4.23232423423424 5 6]}},...
                    'epsilon',{{'nu','mu'}},...
                    'zeta',int8([431 2121]),...
                    'eta',logical([1 0]),...
                    'theta',{{'nu','nu'}},...
                    'iota',{{'nu','mu'}});
            %
            self.testParamList=[varargin,...
                {'storageLocationRoot',storageRootDir}];
            self.map.removeAll();
        end
        %
        function self = test_constructor(self,varargin)
            obj1=self.mapFactory.getInstance();
            metaClass=metaclass(obj1);
            inpParamList=modgen.common.parseparams(...
                self.testParamList,{'storageLocationRoot'});
            obj2=self.mapFactory.getInstance('storageLocationRoot',...
                fileparts(which(metaClass.Name)),inpParamList{:});
            mlunitext.assert_equals(strcmp(obj1.getStorageLocation(),...
                obj2.getStorageLocation),true);
        end
        %
        function self=test_putGet(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            rel2=self.rel2;
            %
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            %
            self.map.put(keyList,inpObjList);
            valueObjList=fliplr(self.map.get(fliplr(keyList),'UniformOutput',false));
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            mlunitext.assert_equals(isEqual,true);
            %
            map=self.map;
            map.removeAll();
            %
        end
        %
        function self=test_longKeyPutGet(self)
            rel=self.rel1;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            map=self.map;
            map.removeAll();
            keyStr=repmat('a',namelengthmax);
            self.runAndCheckError('map.put({keyStr},{rel})',':wrongInput');
            self.runAndCheckError('map.get({keyStr})',':wrongInput');
            %
            keyStr=repmat('a',1,namelengthmax);
            map.put({keyStr},{rel});
            resObj=map.get({keyStr});
            isEqual=isequal(rel,resObj);
            mlunitext.assert_equals(true,isEqual);
        end
        %
        function self=test_getKeyList(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            rel2=self.rel2;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            self.map.removeAll();            
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            self.map.put(keyList,inpObjList);
            isEqual=isequal(sort(keyList),sort(self.map.getKeyList));
            mlunitext.assert_equals(isEqual,true);
            self.map.remove('rel2');
            isEqual=isequal({'rel1'},self.map.getKeyList);
            mlunitext.assert_equals(isEqual,true);
            self.map.removeAll();
        end
        %
        function self=test_putGetWithoutCells(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1};
            keyList='rel1';
            self.map.put(keyList,inpObjList);
            valueObjList=self.map.get(keyList,'UniformOutput',false);
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            mlunitext.assert_equals(isEqual,true);
            inpObjList=rel1;
            keyList={'rel1'};
            self.map.put(keyList,inpObjList);
            valueObjList=self.map.get(keyList,'UniformOutput',false);
            inpObjList={inpObjList};
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            mlunitext.assert_equals(isEqual,true);
        end
        %
        function self=test_isKeyAndRemove(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            rel2=self.rel2;
            rel3=self.rel2;            
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1,rel2,rel3};
            keyList={'rel1','rel2','rel3'};
            self.map.put(keyList,inpObjList);
            self.map.remove(keyList{3});
            mlunitext.assert_equals(self.map.isKey(keyList{3}),false);
            inpObjList=inpObjList(1:2);
            keyList=keyList(1:2);
            valueObjList=fliplr(self.map.get(fliplr(keyList),'UniformOutput',false));
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            mlunitext.assert_equals(isEqual,true);
            self.map.removeAll();
        end
        %
        function self=test_removeAll(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            rel2=self.rel2;
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            self.map.put(keyList,inpObjList);
            self.map.remove('rel2');
            %
            map1=self.mapFactory.getInstance('storageBranchKey',...
                'testBranch2',self.testParamList{:});
            map1.removeAll();
            map1.put('rel1',rel1);
            %
            isThere1=self.map.isKey(keyList);
            isThere2=map1.isKey(keyList);
            mlunitext.assert_equals(all(isThere1==isThere2),true);
            map1.removeAll();
            isThere=map1.isKey({'rel1'});
            mlunitext.assert_equals(isThere,false);
            self.map.removeAll();
        end
        %
        function self=test_getFileNameByKey(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1};
            keyList='rel1';
            self.map.put(keyList,inpObjList);
            self.map.getFileNameByKey(keyList);
        end
    end
end