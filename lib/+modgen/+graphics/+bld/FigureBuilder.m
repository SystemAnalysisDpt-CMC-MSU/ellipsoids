classdef FigureBuilder
    properties (GetAccess=private,Constant)
        FIGURE_PLOTTS_PROP_MAPPING={...
            'dateFormat','dateFormat',[];...
            'displayLegend','displayLegend',[];...
            'figureName','figureName',[];...
            'fontSize','fontSize',[];...
            'fontWeight','fontWeight',[];...
            'linkAxes','linkAxes',[];...
            'synchroDates','synchroDates',[];...
            'xGrid','xGrid',[];...
            'yGrid','yGrid',[]};
        GRAPH_GROUP_PLOTTS_PROP_MAPPING={...
            'legendLocation','graphLegendsLocation',[];...
            'groupTitle','groupTitles',[];...
            'groupXLabel','groupXLabels',[];...
            'groupYLabel','groupYLabels',[];...
            'xAxisLocation','groupXAxisLocations',[];...
            'yAxisLocation','groupYAxisLocations',[];...
            'xColor','groupXColors',[];...
            'yColor','groupYColors',[];...
            'zoomDir','graphZoomDirList',[];...
            'xType','xTypes',[];...
            'roundXLabel','roundXLabels',@(varargin)horzcat(varargin{:});...
            'xLabelRotation','groupXLabelRotation',@(varargin)horzcat(varargin{:});...
            'yLabelRotation','groupYLabelRotation',@(varargin)horzcat(varargin{:});...
            'propSetFunc','groupPropSetFuncList',[];...
            'scale','scale',[];...
            'scaleParam','scaleParam',[];...
            'xLim','xLim',[];...
            'yLim','yLim',[]};
        GRAPH_PLOTTS_PROP_MAPPING={...
            'type','graphTypes',[];...
            'plotSpecs','graphPlotSpecs',[];...
            'lineWidth','lineWidth',@(varargin)horzcat(varargin{:});...
            'barWidthVec','widthCell',[];...
            'markerSize','markerSize',@(varargin)horzcat(varargin{:});...
            'legend','graphLegends',[];...
            'color','graphRgbColors',[];...
            'SSpecProps','graphSpecPropList',[];...
            'propSetFunc','graphPropSetFuncList',[];...
            'markerName','markerName',[]};
        FIGURE_ELEM_NAME='FIGURE';
        GRAPH_GROUP_ELEM_NAME='GRAPH_GROUP';
        GRAPH_ELEM_NAME='GRAPH';
    end
    
    methods (Static)
        function handleMap=createFigure(figureObj,varargin)
            if nargin==0,
                modgen.common.throwerror('wrongInput',...
                    'figureObj must be given as input');
            end
            if ~(numel(figureObj)==1&&isa(figureObj,'modgen.graphics.bld.Figure')),
                modgen.common.throwerror('wrongInput',...
                    'figureObj is wrong');
            end
            [~,~,propsForVisibleMap,hFigure,fontSize,fontWeight,...
                rendererMode,rendererName,isPropsForVisibleMap,...
                isHFigure,isFontSize,isFontWeight,...
                isRendererMode,isRendererName]=...
                modgen.common.parseparext(varargin,{...
                'PropsForVisibleMap','hFigure','fontSize','fontWeight',...
                'RendererMode','Renderer';...
                [],[],[],[],[],[];...
                'isscalar(x)&&isa(x,''modgen.graphics.bld.PropsForVisibleMap'')',...
                'isscalar(x)&&isreal(x)&&isnumeric(x)&&ishandle(x)',...
                'isscalar(x)&&isreal(x)&&isnumeric(x)',...
                'isstring(x)&&~isempty(x)',...
                'isstring(x)&&~isempty(x)',...
                'isstring(x)&&~isempty(x)'},...
                [0 0],'propRetMode','separate');
            plottsAddArgList={};
            if isHFigure,
                plottsAddArgList=horzcat(plottsAddArgList,...
                    {'fHandle',hFigure});
            end
            if isFontSize,
                plottsAddArgList=horzcat(plottsAddArgList,...
                    {'fontSize',fontSize});
            end
            if isFontWeight,
                plottsAddArgList=horzcat(plottsAddArgList,...
                    {'fontWeight',fontWeight});
            end
            figPropArgList={};
            if isRendererMode,
                figPropArgList=horzcat(figPropArgList,...
                    {'RendererMode',rendererMode});
            end
            if isRendererName,
                figPropArgList=horzcat(figPropArgList,...
                    {'Renderer',rendererName});
            end
            %
            className=mfilename('class');
            elementMapping=containers.Map('UniformValues',false);
            if isPropsForVisibleMap,
                [~,figurePropList]=...
                    propsForVisibleMap.getMapPairsRestrictedOnKeys({figureObj});
                if isempty(figurePropList),
                    modgen.common.throwerror('wrongInput',...
                        'PropsForVisibleMap must contain figure object');
                end
                figurePropList=figurePropList{:};
            else
                figurePropList={};
            end
            figureElemName=eval([className '.FIGURE_ELEM_NAME']);
            elementMapping(figureElemName)={figureObj;figurePropList};
            [groupPlaceCVec,groupPlacePropListCVec]=...
                getChildObj(figureObj,'groupPlaceCVec');
            [groupCVec,groupPropListCVec]=...
                cellfun(@(x)getChildObj(x,'groupCVec'),...
                groupPlaceCVec,'UniformOutput',false);
            groupCVec=horzcat(groupCVec{:});
            groupPropListCVec=horzcat(groupPropListCVec{:});
            graphGroupElemName=eval([className '.GRAPH_GROUP_ELEM_NAME']);
            elementMapping(graphGroupElemName)=...
                [groupCVec;groupPropListCVec];
            [graphCVec,graphPropListCVec]=...
                cellfun(@(x)getChildObj(x,'graphCVec'),...
                groupCVec,'UniformOutput',false);
            graphCVec=horzcat(graphCVec{:});
            graphPropListCVec=horzcat(graphPropListCVec{:});
            graphElemName=eval([className '.GRAPH_ELEM_NAME']);
            elementMapping(graphElemName)=[graphCVec;graphPropListCVec];
            %
            areaDistrVec=cellfun(@(x,y)getProp(x,y,'areaDistr'),...
                groupPlaceCVec,groupPlacePropListCVec);
            isnWrong=isnumeric(areaDistrVec)&&isreal(areaDistrVec);
            if isnWrong,
                areaDistrVec=double(areaDistrVec);
                isnWrong=all(areaDistrVec>=0&areaDistrVec<=1);
            end
            if ~isnWrong,
                modgen.common.throwerror('wrongInput',[...
                    'areaDistr is wrong for objects of groupPlaceCVec '...
                    'within figureObj']);
            end
            if all(areaDistrVec==0),
                areaDistrVec=1/numel(areaDistrVec);
            else
                areaDistrVec=areaDistrVec/sum(areaDistrVec);
            end
            %
            elementNameList=elementMapping.keys();
            nElements=elementMapping.length();
            plottsInputCVec=cell(nElements,1);
            for iElement=1:nElements,
                prefixStr=[mfilename('class') '.'...
                    upper(elementNameList{iElement})];
                propMapping=eval([prefixStr '_PLOTTS_PROP_MAPPING']);
                if isempty(propMapping),
                    continue;
                end
                objPropCMat=elementMapping(elementNameList{iElement});
                nObjs=size(objPropCMat,2);
                propCVec=cellfun(@(x,y)getPropList(x,y),...
                    objPropCMat(1,:),objPropCMat(2,:),...
                    'UniformOutput',false);
                propNameCVec=cellfun(@(x)x(1:2:end-1),propCVec,...
                    'UniformOutput',false);
                propValCVec=cellfun(@(x)x(2:2:end),propCVec,...
                    'UniformOutput',false);
                nPropsVec=cellfun('prodofsize',propNameCVec);
                [propNameCVec,~,indPropVec]=unique(...
                    horzcat(propNameCVec{:}));
                indPropCVec=mat2cell(reshape(indPropVec,1,[]),1,nPropsVec);
                isPropMat=false(nObjs,numel(propNameCVec));
                for iObj=1:nObjs,
                    isPropMat(iObj,indPropCVec{iObj})=true;
                end
                isPropVec=all(isPropMat,1);
                nProps=sum(isPropVec);
                if ~all(isPropVec),
                    indPropVec=cumsum(isPropVec);
                    indPropVec(~isPropVec)=0;
                else
                    indPropVec=1:nProps;
                end
                if nProps,
                    propValCMat=cell(nObjs,nProps);
                    for iObj=1:nObjs,
                        curIndVec=indPropVec(indPropCVec{iObj});
                        isPropVec=curIndVec~=0;
                        propValCMat(iObj,curIndVec(isPropVec))=...
                            propValCVec{iObj}(isPropVec);
                    end
                    if strcmpi(elementNameList{iElement},figureElemName),
                        aggrFuncCVec=repmat({@deal},1,nProps);
                    else
                        aggrFuncCVec=repmat({@(varargin)varargin},1,nProps);
                    end
                    [~,indPropVec]=ismember(...
                        propNameCVec,propMapping(:,1));
                    propNameCVec=reshape(propMapping(indPropVec,2),1,[]);
                    isFuncVec=~cellfun('isempty',...
                        propMapping(indPropVec,3));
                    if any(isFuncVec),
                        indPropVec=indPropVec(isFuncVec);
                        aggrFuncCVec(isFuncVec)=...
                            propMapping(indPropVec,3);
                    end
                    propValCVec=cellfun(...
                        @(aggrFunc,valCVec)feval(aggrFunc,valCVec{:}),...
                        aggrFuncCVec,num2cell(propValCMat,1),...
                        'UniformOutput',false);
                    plottsInputCVec{iElement}=reshape([...
                        propNameCVec;...
                        propValCVec],1,[]);
                end
            end
            plottsInputCVec=horzcat(plottsInputCVec{:});
            placeMembershipVec=arrayfun(@(x,y)repmat(x,1,y),...
                1:numel(groupPlaceCVec),cellfun(...
                @(x)numel(getChildObj(x,'groupCVec')),groupPlaceCVec),...
                'UniformOutput',false);
            placeMembershipVec=horzcat(placeMembershipVec{:});
            plottsInputCVec=horzcat(plottsInputCVec,...
                {'placeMembership',placeMembershipVec});
            groupMembershipVec=arrayfun(@(x,y)repmat(x,1,y),...
                1:numel(groupCVec),cellfun(...
                @(x)numel(getChildObj(x,'graphCVec')),groupCVec),...
                'UniformOutput',false);
            groupMembershipVec=horzcat(groupMembershipVec{:});
            plottsInputCVec=horzcat(plottsInputCVec,...
                {'groupMembership',groupMembershipVec});
            plottsInputCVec=horzcat(plottsInputCVec,...
                plottsAddArgList);
            %% plotting
            if ~isempty(figPropArgList),
                plottsInputCVec=horzcat(plottsInputCVec,...
                    {'figurePropSetFunc',@figurePropSetFunc});
            end
            [hAxesVec,hPlotVec]=plotts(...
                'xCell',cellfun(@(x)x.xVec,graphCVec,...
                'UniformOutput',false),...
                'yCell',cellfun(@(x)x.yVec,graphCVec,...
                'UniformOutput',false),...
                'groupAreaDistr',areaDistrVec,...
                plottsInputCVec{:});
            if ~isHFigure,
                hFigureVec=get(hAxesVec,'Parent');
                if iscell(hFigureVec),
                    hFigureVec=horzcat(hFigureVec{:});
                end
                hFigureVec=unique(hFigureVec);
                if numel(hFigureVec)>1,
                    modgen.common.throwerror('wrongObjState',...
                        'Some axes relate to different figures');
                end
                hFigure=hFigureVec;
            end
            handleMap=modgen.graphics.bld.HandleMap(...
                vertcat(graphCVec(:),groupCVec(:),{figureObj}),...
                vertcat(hPlotVec(:),hAxesVec(:),hFigure));
            %% additional actions
            nGroupPlaces=numel(groupPlaceCVec);
            for iGroupPlace=1:nGroupPlaces,
                [groupCVec,groupPropListCVec]=...
                    getChildObj(groupPlaceCVec{iGroupPlace},'groupCVec');
                hGroupAxesVec=hAxesVec(placeMembershipVec==iGroupPlace);
                isRightYAxisLocVec=cellfun(...
                    @(x,y)strcmp(getProp(x,y,'yAxisLocation'),'right'),...
                    groupCVec,groupPropListCVec);
                isLeftYAxisLocVec=~isRightYAxisLocVec;
                isEmptyAxesVec=arrayfun(@(hAxes)isEmptyAxes(hAxes),...
                    hGroupAxesVec);
                if any(isEmptyAxesVec)
                    isLeftYAxisLocVec(isEmptyAxesVec)=false;
                    isRightYAxisLocVec(isEmptyAxesVec)=false;
                end
                if sum(isLeftYAxisLocVec)>1||...
                        sum(isRightYAxisLocVec)>2,
                     modgen.common.throwerror('wrongStateObj',[...
                         'There are more than one left or '...
                         'more than two right axes for '...
                         '%d place, this feature is not yet '...
                         'implemented '],iGroupPlace);
                end
                if ~any(isRightYAxisLocVec),
                    continue;
                end
                indRightAxesVec=find(isRightYAxisLocVec);
                if any(isLeftYAxisLocVec),
                   hLeftAxes=hGroupAxesVec(find(...
                       isLeftYAxisLocVec,1,'first'));
                   tickLenVec=get(hLeftAxes,'TickLength');
                   tickLenVec(1)=tickLenVec(1)/4;
                   hRightAxes=hGroupAxesVec(indRightAxesVec(1));
                   set(hRightAxes,'TickLength',tickLenVec);
                   arrayfun(...
                       @(hAxes)set(hAxes,'XGrid','off','YGrid','off'),...
                       hGroupAxesVec(isRightYAxisLocVec));
                else
                   arrayfun(...
                       @(hAxes)set(hAxes,'XGrid','off','YGrid','off'),...
                       hGroupAxesVec(indRightAxesVec(2:end)));
                end
                if numel(indRightAxesVec)>1,
                    groupObj=groupCVec{indRightAxesVec(end)};
                    groupPropList=groupPropListCVec{indRightAxesVec(end)};
                    hAxes=hGroupAxesVec(indRightAxesVec(end));
                    set(hAxes,'Visible','off',...
                        'Units','normalized',...
                        'XGrid','off','YGrid','off',...
                        'YTickMode','manual');
                    tickLenVec=get(hAxes,'TickLength');
                    fontSize=get(hAxes,'FontSize');
                    fontWeight=get(hAxes,'FontWeight');
                    posVec=get(hAxes,'Position');
                    posVec(1)=posVec(1)+posVec(3)+(1-sum(posVec([1 3])))/2;
                    posVec(3)=tickLenVec(1);
                    hAnnotAxes=axes('Position',posVec,...
                        'Color','none','FontSize',fontSize,...
                        'FontWeight',fontWeight,...
                        'YAxisLocation','right',...
                        'HandleVisibility','off',...
                        'XTickLabelMode','manual',...
                        'XTick',[],'XTickLabel',[],...
                        'YTickLabelMode','manual','YTickMode','manual',...
                        'YLim',get(hAxes,'YLim'),...
                        'YTick',get(hAxes,'YTick'),...
                        'YTickLabel',get(hAxes,'YTickLabel'),...
                        'YGrid','on'); %#ok<LAXES>
                    ylabel(hAnnotAxes,getProp(groupObj,groupPropList,'groupYLabel'),...
                        'Interpreter','none',...
                        'FontSize',fontSize,'FontWeight',fontWeight,...
                        'Rotation',getProp(groupObj,groupPropList,'yLabelRotation'));
                    %set(hAxes,'UserData',hAnnotAxes);
                end
            end
            
            function res=isEmptyAxes(hAxes)
                res=strcmp(get(hAxes,'Visible'),'off');
                if ~res,
                    yLabelStr=get(get(hAxes,'YLabel'),'String');
                    if iscell(yLabelStr),
                        yLabelStr=yLabelStr{:};
                    end
                    res=isempty(yLabelStr)&&isempty(get(hAxes,'YTickLabel'));
                end
            end
            
            function [childObjCVec,propListCVec]=getChildObj(parentObj,childFieldName)
                childObjCVec=parentObj.(childFieldName);
                if nargout>1,
                    propListCVec=cell(size(childObjCVec));
                end
                if isPropsForVisibleMap&&~isempty(childObjCVec),
                    [childObjCVec,propListCVec]=...
                        propsForVisibleMap.getMapPairsRestrictedOnKeys(childObjCVec);
                end
                childObjCVec=reshape(childObjCVec,1,[]);
                if nargout>1,
                    propListCVec=reshape(propListCVec,1,[]);
                end
            end
            
            function value=getProp(obj,propList,propName)
                if isempty(propList),
                    value=obj.(propName);
                else
                    indProp=2*find(strcmpi(propList(1:2:end-1),propName),1,'last');
                    if isempty(indProp),
                        value=obj.(propName);
                    else
                        value=propList{indProp};
                    end
                end
            end
            
            function propList=getPropList(obj,propList)
                if isempty(propList),
                    propList=obj.getPropList();
                else
                    objPropList=obj.getPropList();
                    [isObjPropVec,indObjPropVec]=ismember(...
                        propList(1:2:end-1),objPropList(1:2:end-1));
                    if any(isObjPropVec),
                        indObjPropVec=indObjPropVec(isObjPropVec);
                        objPropList(2*indObjPropVec)=propList(reshape(...
                            [false(size(isObjPropVec));isObjPropVec],1,[]));
                    end
                    propList=objPropList;
                end
                isnPropVec=~ismember(propList(1:2:end-1),...
                    propMapping(:,1));
                if any(isnPropVec),
                    isnPropVec=reshape(repmat(isnPropVec,2,1),1,[]);
                    propList(isnPropVec)=[];
                end
            end
            
            function figurePropSetFunc(fHandle)
                set(fHandle,figPropArgList{:});
            end
        end
    end
end