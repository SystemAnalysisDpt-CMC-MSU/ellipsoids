classdef GraphGroup<modgen.graphics.bld.AElementWithProps
    properties (GetAccess=protected,Constant)
        REGULAR_PROP_NAME_LIST={'graphCVec'};
    end
    
    properties (GetAccess=public,SetAccess=protected)
        graphCVec=cell(1,0);
        legendLocation='NorthEast';
        groupXLabel='';
        groupYLabel='';
        groupTitle='';
        xAxisLocation='bottom';
        yAxisLocation='left';
        xColor=[];
        yColor=[];
        zoomDir='b';
        xLim=[];
        yLim=[];
        scale='normal';
        scaleParam=NaN;
        xType='dates';
        roundXLabel=NaN;
        yLabelRotation=90;
        xLabelRotation=0;
        propSetFunc=@(hAxes)[];
    end
    
    methods
        function self=GraphGroup(varargin)
            if nargin>0,
                [reg,prop]=self.parseRegAndPropList(varargin{:});
                self.setRegularProps(reg{:});
                for iProp=1:2:numel(prop)-1,
                    self.(prop{iProp})=prop{iProp+1};
                end
            end
        end
        
        function graphCVec=getGraphObjList(self)
            graphCVec=self.graphCVec();
        end
    end
    
    methods (Access=protected)
         function setRegularProps(self,varargin)
            reg=modgen.common.parseparext(...
                varargin,{},[1 1],0,...
                'regCheckList',{'numel(x)==length(x)&&iscell(x)'});
            reg=reshape(reg{:},1,[]);
            modgen.common.checkvar(reg,[...
                'all(cellfun(''prodofsize'',x)==1&'...
                'cellfun(@(y)isa(y,''modgen.graphics.bld.Graph''),x))']);
            self.graphCVec=reg;
        end
    end
end