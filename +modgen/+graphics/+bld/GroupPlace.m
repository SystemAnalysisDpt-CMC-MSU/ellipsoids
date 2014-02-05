classdef GroupPlace<modgen.graphics.bld.AElementWithProps
    properties
        areaDistr=0;
    end
    properties (GetAccess=public,SetAccess=protected)
        groupCVec=cell(1,0);
    end
    
    methods
        function self=GroupPlace(varargin)
            [reg,~,prop]=modgen.common.parseparext(...
                varargin,self.getPropNameList(),...
                'propRetMode','list');
            self.resetGroups(reg{:});
            self.setPropList(prop{:});
        end

        function resetGroups(self,varargin)
            reg=modgen.common.parseparext(...
                varargin,{},[1 1],0,...
                'regCheckList',{'numel(x)==length(x)&&iscell(x)&&~isempty(x)'});
            reg=reshape(reg{:},1,[]);
            modgen.common.checkvar(reg,[...
                'all(cellfun(''prodofsize'',x)==1&'...
                'cellfun(@(y)isa(y,''modgen.graphics.bld.GraphGroup''),x))']);
            self.groupCVec=reg;
        end
        
        function graphCVec=getGraphObjList(self)
            graphCVec=cellfun(@(x)x.getGraphObjList(),...
                self.groupCVec,'UniformOutput',false);
            graphCVec=horzcat(graphCVec{:});
        end
        
        function groupCVec=getGraphGroupObjList(self)
            groupCVec=self.groupCVec;
        end
    end
end