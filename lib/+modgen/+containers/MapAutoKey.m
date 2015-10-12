classdef MapAutoKey<handle
    %MAPAUTOKEY Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant,GetAccess=private)
        MAX_VALUE=intmax('uint64');
    end
    properties (Access=private)
        curCounter=uint64(0);
        curPrefix='';
        directPrefix
        autoPrefix
        plainMap
    end
    properties (Dependent,SetAccess=private,GetAccess=public)
        Count
    end
    methods
        function nKeys=get.Count(self)
            nKeys=self.plainMap.Count;
        end
        function fullKey=getDirectKey(self,keyStr)
            fullKey=[self.directPrefix,keyStr];
        end
        function isPos=isKey(self,keyStr)
            isPos=self.plainMap.isKey(keyStr);
        end
        function remove(self,keyList)
            self.plainMap.remove(keyList);
        end
        function value=get(self,keyStr)
            value=self.plainMap(keyStr);
        end
        function valueList=values(self)
            valueList=self.plainMap.values;
        end
        function keyList=keys(self)
            keyList=self.plainMap.keys;
        end
        function self=MapAutoKey(varargin)
            [restArgList,~,self.directPrefix,self.autoPrefix]=...
                modgen.common.parseparext(varargin,...
                {'directPrefix','autoPrefix';
                '','';
                'ischarstring(x)','ischarstring(x)'});
            %
            self.plainMap=containers.Map(restArgList{:});
        end
        function putDirect(self,keyStr,value)
            self.plainMap(self.getDirectKey(keyStr))=value;
        end
        function put(self,keyStr,value)
            self.plainMap(keyStr)=value;
        end
        function keyStr=putAuto(self,value)
            if self.curCounter==self.MAX_VALUE
                self.curPrefix=[self.curPrefix,'0'];
                self.curCounter=0;
            end
            self.curCounter=self.curCounter+1;
            keyStr=sprintf('%s%s%u',self.autoPrefix,self.curPrefix,self.curCounter);
            self.plainMap(keyStr)=value;
        end
        
    end
end