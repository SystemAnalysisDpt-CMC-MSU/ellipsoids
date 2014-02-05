classdef GraphGroup<modgen.graphics.bld.AElementWithProps
    properties
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
        hAxes=NaN;
    end
    properties (GetAccess=public,SetAccess=protected)
        graphCVec=cell(1,0);
    end
    
    methods
        function self=GraphGroup(varargin)
            [reg,~,prop]=modgen.common.parseparext(...
                varargin,self.getPropNameList(),...
                'propRetMode','list');
            self.resetGraphs(reg{:});
            self.setPropList(prop{:});
        end
 
        function resetGraphs(self,varargin)
            reg=modgen.common.parseparext(...
                varargin,{},[1 1],0,...
                'regCheckList',{'numel(x)==length(x)&&iscell(x)'});
            reg=reshape(reg{:},1,[]);
            modgen.common.checkvar(reg,[...
                'all(cellfun(''prodofsize'',x)==1&'...
                'cellfun(@(y)isa(y,''modgen.graphics.bld.Graph''),x))']);
            self.graphCVec=reg;
        end
        
        function set.hAxes(self,hAxesVal)
            if ~isnan(self.hAxes),
                modgen.common.throwerror('wrongObjState',...
                    'It is allowed to set handle just once');
            end
            isnWrong=numel(hAxesVal)==1&&ishandle(hAxesVal);
            if isnWrong,
                isnWrong=strcmp(get(hAxesVal,'Type'),'axes');
            end
            if ~isnWrong,
                modgen.common.throwerror('wrongInput',...
                    'value of handle is wrong');
            end
            self.hAxes=hAxesVal;
        end
        
        function graphCVec=getGraphObjList(self)
            graphCVec=self.graphCVec();
        end
    end
end