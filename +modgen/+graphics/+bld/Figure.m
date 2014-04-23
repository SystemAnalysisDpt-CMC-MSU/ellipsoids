classdef Figure<modgen.graphics.bld.AElementWithProps
    properties (GetAccess=protected,Constant)
        REGULAR_PROP_NAME_LIST={'groupPlaceCVec'};
    end
    
    properties (GetAccess=public,SetAccess=protected)
        groupPlaceCVec=cell(1,0);
        displayLegend=false;
        linkAxes='x';
        figureName='';
        dateFormat='dd/mm';
        synchroDates=true;
        xGrid=true;
        yGrid=true;
        fontSize=8;
        fontWeight='normal';
    end
    
    methods
        function self=Figure(varargin)
            if nargin>0,
                [reg,prop]=self.parseRegAndPropList(varargin{:});
                self.setRegularProps(reg{:});
                for iProp=1:2:numel(prop)-1,
                    self.(prop{iProp})=prop{iProp+1};
                end
            end
        end
        
        function graphCVec=getGraphObjList(self)
            graphCVec=cellfun(@(x)x.getGraphObjList(),...
                self.groupPlaceCVec,'UniformOutput',false);
            graphCVec=horzcat(graphCVec{:});
        end
    end
    
    methods (Access=protected)
        function setRegularProps(self,varargin)
            reg=modgen.common.parseparext(...
                varargin,{},[1 1],0,...
                'regCheckList',{'numel(x)==length(x)&&iscell(x)&&~isempty(x)'});
            reg=reshape(reg{:},1,[]);
            modgen.common.checkvar(reg,[...
                'all(cellfun(''prodofsize'',x)==1&'...
                'cellfun(@(y)isa(y,''modgen.graphics.bld.GroupPlace''),x))']);
            self.groupPlaceCVec=reg;
        end
    end
end