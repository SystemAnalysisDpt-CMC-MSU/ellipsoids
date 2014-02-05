classdef Graph<modgen.graphics.bld.AElementWithProps
    properties
        type='plot';
        plotSpecs='';
        lineWidth=1;
        barWidthVec=zeros(0,1);
        markerSize=1;
        markerName='none';
        legend='';
        color=[];
        SSpecProps=struct();
        propSetFunc=@(hPlot)[];
        hPlot=NaN;
    end
    
    properties (GetAccess=public,SetAccess=protected)
        xVec=zeros(0,1);
        yVec=zeros(0,1);
    end
    
    methods
        function self=Graph(varargin)
            [reg,~,prop]=modgen.common.parseparext(...
                varargin,self.getPropNameList(),...
                'propRetMode','list');
            self.resetData(reg{:});
            self.setPropList(prop{:});
        end

        function resetData(self,varargin)
            reg=modgen.common.parseparext(...
                varargin,{},[2 2],0,...
                'regCheckList',repmat({'numel(x)==length(x)'},1,2));
            modgen.common.checkvar(reg,[...
                'all(diff(cellfun(''prodofsize'',x))==0)&&'...
                'all(diff(cellfun(''ndims'',x))==0)&&'...
                'all(diff(cellfun(''size'',x,ndims(x{1})))==0)']);
            reg=cellfun(@(x)double(x(:)),reg,'UniformOutput',false);
            self.xVec=reg{1};
            self.yVec=reg{2};
        end
        
        function set.hPlot(self,hPlotVal)
            if ~isnan(self.hPlot),
                modgen.common.throwerror('wrongObjState',...
                    'It is allowed to set handle just once');
            end
            isnWrong=numel(hPlotVal)==1&&ishandle(hPlotVal);
            if isnWrong,
                plotPropNameList=fieldnames(get(hPlotVal));
                isnWrong=all(ismember({'XData','YData'},plotPropNameList));
            end
            if ~isnWrong,
                modgen.common.throwerror('wrongInput',...
                    'value of handle is wrong');
            end
            self.hPlot=hPlotVal;
        end
    end
end