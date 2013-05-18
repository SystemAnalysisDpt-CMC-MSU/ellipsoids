classdef mlunit_test_diskbasedhashmap_nostorage < mlunitext.test_case

    properties 
        map
        rel1
        rel2
    end
    
    methods
        function self = mlunit_test_diskbasedhashmap_nostorage(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
            import modgen.*;
            self.map=containers.DiskBasedHashMap('storageBranchKey',...
                'testBranch','storageFormat','none');
            %
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
            self.map.removeAll();
        end
        function self=test_putGet(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            rel2=self.rel2;
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            self.map.put(keyList,inpObjList);
            isThere=fliplr(self.map.isKey(fliplr(keyList)));
            isEqual=any(isThere==true);
            mlunitext.assert_equals(isEqual,false);
            self.map.removeAll();
        end
        function self=test_getKeyList(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            rel2=self.rel2;
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            self.map.put(keyList,inpObjList);
            isEqual=isequal({},self.map.getKeyList);
            mlunitext.assert_equals(isEqual,true);
            self.map.remove('rel2');
            isEqual=isequal({},self.map.getKeyList);
            mlunitext.assert_equals(isEqual,true);
            self.map.removeAll();
        end        
        function self=test_isKeyAndRemove(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            rel2=self.rel2;
            rel3=self.rel2;            
            inpObjList={rel1,rel2,rel3};
            keyList={'rel1','rel2','rel3'};
            self.map.put(keyList,inpObjList);
            self.map.remove(keyList{3});
            mlunitext.assert_equals(self.map.isKey(keyList{3}),false);
            keyList=keyList(1:2);
            isThere=fliplr(self.map.isKey(fliplr(keyList)));
            isEqual=any(isThere==true);
            mlunitext.assert_equals(isEqual,false);
            self.map.removeAll();
        end
        function self=test_getFileNameByKey(self,varargin)
            import smartdb.*;
            import modgen.*;
            rel1=self.rel1;
            inpObjList={rel1};
            keyList='rel1';
            self.map.put(keyList,inpObjList);
            self.map.getFileNameByKey(keyList);
        end
    end
end