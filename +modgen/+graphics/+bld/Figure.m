classdef Figure<modgen.graphics.bld.AElementWithProps
    properties
        displayLegend=false;
        linkAxes='x';
        figureName='';
        dateFormat='dd/mm';
        synchroDates=true;
        xGrid=true;
        yGrid=true;
        hFigure=NaN;
        fontSize=8;
        fontWeight='normal';
    end
    
    properties (GetAccess=public,SetAccess=protected)
        groupPlaceCVec=cell(1,0);
    end
    
    methods
        function self=Figure(varargin)
            [reg,~,prop]=modgen.common.parseparext(...
                varargin,self.getPropNameList(),...
                'propRetMode','list');
            self.resetGroupPlaces(reg{:});
            self.setPropList(prop{:});
        end
        
        function resetGroupPlaces(self,varargin)
            reg=modgen.common.parseparext(...
                varargin,{},[1 1],0,...
                'regCheckList',{'numel(x)==length(x)&&iscell(x)&&~isempty(x)'});
            reg=reshape(reg{:},1,[]);
            modgen.common.checkvar(reg,[...
                'all(cellfun(''prodofsize'',x)==1&'...
                'cellfun(@(y)isa(y,''modgen.graphics.bld.GroupPlace''),x))']);
            self.groupPlaceCVec=reg;
        end

        function set.hFigure(self,hFigureVal)
            if ~isnan(self.hFigure),
                modgen.common.throwerror('wrongObjState',...
                    'It is allowed to set handle just once');
            end
            isnWrong=numel(hFigureVal)==1&&ishandle(hFigureVal);
            if isnWrong,
                isnWrong=strcmp(get(hFigureVal,'Type'),'figure');
            end
            if ~isnWrong,
                modgen.common.throwerror('wrongInput',...
                    'value of handle is wrong');
            end
            self.hFigure=hFigureVal;
        end
        
        function graphCVec=getGraphObjList(self)
            graphCVec=cellfun(@(x)x.getGraphObjList(),...
                self.groupPlaceCVec,'UniformOutput',false);
            graphCVec=horzcat(graphCVec{:});
        end
        
        function groupCVec=getGraphGroupObjList(self)
            groupCVec=cellfun(@(x)x.getGraphGroupObjList(),...
                self.groupPlaceCVec,'UniformOutput',false);
            groupCVec=horzcat(groupCVec{:});
        end
    end
end