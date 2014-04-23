classdef Graph<modgen.graphics.bld.AElementWithProps
    properties (GetAccess=protected,Constant)
        REGULAR_PROP_NAME_LIST={'xVec','yVec'};
    end
    
    properties (GetAccess=public,SetAccess=protected)
        xVec=zeros(0,1);
        yVec=zeros(0,1);
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
    end
    
    methods
        function self=Graph(varargin)
            if nargin>0,
                [reg,prop]=self.parseRegAndPropList(varargin{:});
                self.setRegularProps(reg{:});
                for iProp=1:2:numel(prop)-1,
                    self.(prop{iProp})=prop{iProp+1};
                end
            end
        end
        
        function resetData(self,varargin)
            self.setRegularProps(varargin{:});
        end
    end
    
    methods (Access=protected)
        function setRegularProps(self,varargin)
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
    end
end