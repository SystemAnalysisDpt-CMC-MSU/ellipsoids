function [groupHandles,hPlotHandlesVec]=plotts(varargin)
% PLOTTS universal function for time series graph plotting
%
% TODO: use line instead of plot to draw graphics;(Ilya Medvedev)
% TODO: make sure that interpreter option works for legends after the
%    recent fix (Peter Gagarinov)
%
% Usage: plotts(propList)
%
% Input:
%   properties(regular):
%         xCell: cell [1,nGraphs]
%         yCell: cell [1,nGraphs]
%   properties(optional):
%         displayLegend: logical [1,1] - true enables displaying of a
%            legend
%         linkAxes: char[1,1]
%               x - link x-axes
%               y -...
%               xy -..
%               none - default
%
%         groupMembership: double [1,nGraphs], default: [1...1]
%         placeMembership: double [1,nGroups], default: [1:nGroups] - if
%               given, then groups corresponding to equal values of this
%               property are put together on the same place (that is
%               different axes corresponding to these groups are
%               superimposed one on another); in the case this parameter is
%               not given, it is assumed to each group has its own place
%               (default); it should be noted, that in the case the
%               property is passed, groupAreaDistr is treated not for
%               groups but for places
%         groupAreaDistr: double [1,nGroups/nPlaces]/[nRows,nCols] -
%               distribution of area with respect to the height, in the
%               case groupAreaDistr is a matrix, it is assumed that
%               nPlaces<=nRows*nCols, that the total number of elements
%               of groupAreaDist not equal to NaN equals exactly to nPlaces
%               and that all non-NaN elements are positive and their sum
%               along each column is equal to 1
%         graphLegends: cell [1,nGraphs]
%         graphLegendsLocation: cell[1,nGroups] of strings, specified
%                    location of Legend (by default - 'NorthEast')
%                    By details -- see 'legend' function doc
%         groupYLabels: cell [1,nGroups]
%         groupTitles: cell [1,nGroups]
%         groupXLabels: cell [1,nGroups]
%         groupXAxisLocations: cell [1,nGroups]
%         groupYAxisLocations: cell [1,nGroups]
%         groupXColors: cell [1,nGroups]
%         groupYColors: cell [1,nGroups]
%         figureName: char, default: ''
%         graphPlotSpecs: cell [1,nGraphs]
%         graphRgbColors: cell [1,nGraphs], {[R G B]},R,G,B \in [0,1]
%         graphZoomDirList: cell[1,nGroups] of char[1,1], can have the
%            following values:
%               'b' - 'both' - zoom in both directions
%               'v' - 'vertical' - zoom in vertical direction
%               'h' - 'horizontal' - zoom in horizontal direction
%
%         graphTypes: cell [1,nGraphs] : ['bar',{'plot'},'stairs',
%                                   'scatter','widthbar', 'edgebar'],
%               'scatter' method uses lineWidth to determine size of
%               markers
%               'widthbar' method draws bar with different width of
%               different bars. widthCell contains the widths and
%               xCell contains the centers of bars.
%               For right usage intervals of bars should not intersect each other.
%               if widthCell{iGraph} is empty, then use 'bar' method.
%                Use 'widthbar' only with 'normal' scale.
%
%               'edgebar' method draws bar. xCell contains edges of bars
%                and yCell contains heights of bars.
%                For right usage of this method
%                length(xCell) should be equal length(yCell)+1.
%         graphPropSetFuncList: cell [1,nGraphs] - list of functions
%                for each graph that are called after each graph is
%                created, if the respective cell is empty (by default
%                all cells are empty), nothing is done, otherwise it is
%                assumed that the cell contains function_handle [1,1] of a
%                function with single input argument, namely, handle of a
%                graph and no output arguments, this function sets
%                additional properties of the respective graph
%
%         xLim: cell [1, nGroups] --- limits for x-axis.
%         yLim: cell [1, nGroups] --- limits for y-axis.
%              use [] to allow matlab to choose limits automatically.
%
%         scale: cell [1,nGroups]: [{'normal'},'sqrtscale','logarithm'] ---
%                   using specific scale. 'normal' is default option.
%                   'sqrtscale': x=sign(x-a)*sqrt(|x-a|), where a is scaleParam.
%                   'logarithm': x=sign(x-a)*log(|x-a|+1), where a is scaleParam.
%         scaleParam: double[1,nGroups] --- parametr for scaling
%                    (used for 'sqrtscale' and 'logarithm' as
%                     the point which maps to zero.)
%         lineWidth: cell[1,nGraphs]: line widths for each graph, or
%                    double[1,1] if the width is same for all graphs
%                    for edgebar linewidth is a width of edge line.
%         xTypes: cell [1,nGroups] :[{'dates'},'numbers','set','setdates']
%         roundXLabels: integer[1,nGroups]: the number of decimal digits --
%                    only for 'numbers' and 'set' xTypes.
%         dateFormat: char: [{'dd/mm'},....]
%         synchroDates double [{1},0];
%         xGrid: double [{1},0]
%         yGrid: double [{1},0]
%         fHandle: double [1,1]
%                     figure handle, if not specified plotts would create a
%                     new figure for you
%         fontSize: double [1,1]
%         fontWeight: double [1,1]
%         groupXLabelRotation, double [1,nGroups]
%         groupYLabelRotation, double [1,nGroups]
%
%         widthCell: cell [1,nGraphs] - width for widthbar method
%
%
%         dragndrop functionality:
%         isDragEnabled: logical[1,1]
%                   if true, the drag'n'drop functionality would be
%                   enabled, ___note___, that currently dragndrop works
%                   only for one group (nGroups==1)
%                   note, that if grag enabled, all units in figures and axes
%                   would be {normalized}
%         userData: cell[1,nGraphs] of cell[1,nPointsInGraphI] of cell
%                   holding user data foreach point of each graph
%         dragCallback: function handle
%                   handle for dragndrop event,
%                   a function handle wich recieves userdata, and a new point position associated
%                   with this point, when user drag a point of some curve
%                   for example:
%                       [changedCurves,xNewData,yNewData,newUserData]=function
%                       mymove(userData,newPosition)
%
%                   where changedCurves - vector containing numbers of
%                   changed curves, xNewData - double
%                   [nChangedCurves,nPoints], changed x data, yNewData -
%                   double[nChangedCurves,nPoints], changed y data
%                   userData is userData associated with the moving point,
%                   newPosition - double[1,2] - [x,y] of new position
%                   newUserData - new user data for this point
%         dragXLimMultiply: double,
%                   the xLim is going to be  xLim(Data)*dragXLimMultiply
%                   default 1
%         dragYLimMultiply: double, the xLim is going to be
%                   yLim(Data)*dragYLimMultiply      default 1.1
%
%
%         clickCallback: function handle
%                   handler for click event, with the same
%                   specification as dragCallback
%         isSortByXAxis: specified whether the data is sorted by x-axes
%                   value before displaying
%   notes:
%       graphRgbColors has a color specify priority over graphPlotSpecs
%          if you give color parameters in graphPlotSpecs {'r.-'},
%          and also specify graphRgbColors {[1 1 0]}. then after all
%          graph color would be [1 1 0]
%
% Examples:
%    plotts('xCell',{x,x,x},'yCell',{sin(x),cos(x),tan(x)},'groupMembership',[1,2,1],...
%        'groupAreaDistr',[0.3 0.7],'graphLegends',{'sin(x)','cos(x)','tan(x)'},...
%        'groupYLabels',{'aaaa','bbbb'},'figureName','myfigure','graphPlotSpecs',{'c','b','g'},...
%        'graphTypes',{'plot','bar','plot'},'fontSize',8);
%
%      plotts('xCell',{x,x},'yCell',{y,zeros(1,numel(x))},'widthCell',{width,[]},...
%         'groupMembership',[1 1],'graphLegends',{'data','qwert'},...
%         'groupYLabels',{'aaaa','2222'},'figureName','myfigure',...
%         'graphPlotSpecs',{'g','r*'},'graphTypes',{'widthbar','plot'},'fontSize',12);
%
%     plotts('xCell',{x,z},'yCell',{y,zeros(1,numel(z))},...
%     'groupMembership',[1 1],'graphLegends',{'data','xData'},...
%     'groupYLabels',{'aaaa','2222'},'figureName','myfigure',...
%     'graphPlotSpecs',{'g','r*'},'graphTypes',{'edgebar','plot'},'fontSize',12);
%
%     plotts('xCell',{x,z},'yCell',{y,zeros(1,numel(z))},...
%     'groupMembership',[1 1],'graphLegends',{'data','xData'},...
%      'groupYLabels',{'aaaa','2222'},'figureName','myFigure','scale', {'sqrtscale'}, 'scaleparam', 3, ...
%       'graphPlotSpecs',{'g','r*'},'graphTypes',{'edgebar','plot'},'fontSize'
%       ,12,'xlim',{[1,10]},'ylim',{[0,6]});
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 5-Sep-2013 $
%
linkAxesSpec='none';
synchroDates=1;
groupMembership=[];
placeMembership=[];
groupAreaDistr=[];
groupYLabels=[];
groupXLabels=[];
groupXLocations=[];
groupYLocations=[];
groupXColors=[];
groupYColors=[];
groupTitles=[];
graphLegends=[];
graphLegendsLocation='WestOutside';
figureName=[];
graphPlotSpecs=[];
graphRgbColors=[];
graphZoomDirList=[];
graphTypes=[];
graphPropSetFuncList={};
fontSize=8;
fontWeight='normal';
lineWidth=1;
markerSize=1;
markerNameList='none';
xLim=[];
yLim=[];
scale=[];
scaleParam=[];
isSortByXAxis=false;
isLegendDisplayed=false;
%
widthCell=[];
%

xGrid=1;
yGrid=1;
[reg,prop]=parseparams(varargin);
nProp=length(prop);
fHandle=[];
xTypes=[];
roundXLabels=[];
%shifts and margins
xMargin=0.1;
yMargin=0.1;
groupMargin=0.2;
%
dateFormat='dd/mm';
groupXLabelRotation=[];
groupYLabelRotation=[];
%
dragData.isDragEnabled=false;
dragData.dragCallback=[];
dragData.clickCallback=[];
dragData.userData=[];
dragData.plotHandles=[];
dragData.xLimMult=1;
dragData.yLimMult=1.1;
%
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'displaylegend',
            isLegendDisplayed=prop{k+1};
        case 'xcell',
            xCell=prop{k+1};
        case 'ycell',
            yCell=prop{k+1};
        case 'groupmembership',
            groupMembership=prop{k+1};
        case 'placemembership',
            placeMembership=prop{k+1};
        case 'groupareadistr',
            groupAreaDistr=prop{k+1};
        case 'graphlegends',
            graphLegends=prop{k+1};
        case 'graphlegendslocation',
            graphLegendsLocation=prop{k+1};
        case 'groupylabels',
            groupYLabels=prop{k+1};
        case 'groupxlabels',
            groupXLabels=prop{k+1};
        case 'groupxlocations',
            groupXLocations=prop{k+1};
        case 'groupylocations',
            groupYLocations=prop{k+1};
        case 'groupxcolors',
            groupXColors=prop{k+1};
        case 'groupycolors',
            groupYColors=prop{k+1};
        case 'figurename',
            figureName=prop{k+1};
        case 'graphplotspecs',
            graphPlotSpecs=prop{k+1};
        case 'graphrgbcolors',
            graphRgbColors=prop{k+1};
        case 'graphtypes',
            graphTypes=prop{k+1};
        case 'graphpropsetfunclist',
            graphPropSetFuncList=prop{k+1};
        case 'grouptitles',
            groupTitles=prop{k+1};
        case 'fhandle',
            fHandle=prop{k+1};
        case 'xtypes',
            xTypes=prop{k+1};
        case 'roundxlabels'
            roundXLabels=prop{k+1};
        case 'dateformat',
            dateFormat=prop{k+1};
        case 'synchrodates',
            synchroDates=prop{k+1};
        case 'xgrid',
            xGrid=prop{k+1};
        case 'ygrid',
            yGrid=prop{k+1};
        case 'fontsize',
            fontSize=prop{k+1};
        case 'groupmargin',
            groupMargin=prop{k+1};
        case 'xmargin',
            xMargin=prop{k+1};
        case 'ymargin',
            yMargin=prop{k+1};
        case 'fontweight',
            fontWeight=prop{k+1};
        case 'linewidth',
            lineWidth=prop{k+1};
        case 'markersize',
            markerSize=prop{k+1};
        case 'markername',
            markerNameList=prop{k+1};
        case 'groupxlabelrotation',
            groupXLabelRotation=prop{k+1};
        case 'groupylabelrotation',
            groupYLabelRotation=prop{k+1};
        case 'graphzoomdirlist',
            graphZoomDirList=prop{k+1};
        case 'xlim'
            xLim=prop{k+1};
        case 'ylim'
            yLim=prop{k+1};
            % widthcell
        case 'widthcell'
            widthCell=prop{k+1};
        case 'scale'
            scale=prop{k+1};
        case 'scaleparam'
            scaleParam=prop{k+1};
            %drag n drop props after this line
            
        case 'isdragenabled'
            dragData.isDragEnabled=prop{k+1};
        case 'dragcallback'
            dragData.dragCallback=prop{k+1};
        case 'clickcallback'
            dragData.clickCallback=prop{k+1};
        case 'userdata'
            dragData.userData=prop{k+1};
        case 'dragylimmultiply',
            dragData.yLimMult=prop{k+1};
        case 'dragxlimmultiply',
            dragData.xLimMult=prop{k+1};
        case 'issortbyxaxis',
            isSortByXAxis=prop{k+1};
        case 'linkaxes',
            linkAxesSpec=prop{k+1};
        otherwise
            error('GENERAL:wrongproperty','unidentified property name: %s',prop{k});
    end
end
nGraphs=length(xCell);
if isempty(graphPlotSpecs)
    graphPlotSpecs=cell(1,nGraphs);
    graphPlotSpecs(:)={'b'};
end
if isempty(groupMembership)
    groupMembership=ones(1,nGraphs);
end;
%
nGroups=length(unique(groupMembership));
if isempty(placeMembership)
    placeMembership=1:nGroups;
end
[~,~,indPlaceVec]=unique(placeMembership);
nPlaces=max(indPlaceVec);
%
if isempty(groupAreaDistr)
    groupAreaDistr=ones(nPlaces,1)/nPlaces;
    nRows=nPlaces;
    nCols=1;
else
    [nRows nCols]=size(groupAreaDistr);
    if nRows==1,
        groupAreaDistr=groupAreaDistr.';
        nRows=nCols;
        nCols=1;
    end
end
if isempty(graphZoomDirList)
    graphZoomDirList=cell(1,nGroups);
    graphZoomDirList(:)={'b'};
else
    graphZoomDirList=strrep(graphZoomDirList,'h','Horizontal');
    graphZoomDirList=strrep(graphZoomDirList,'v','Vertical');
    graphZoomDirList=strrep(graphZoomDirList,'b','Both');
end
if isempty(groupYLabelRotation)
    groupYLabelRotation=ones(1,nGroups)*90;
end
if isempty(groupXLabelRotation)
    groupXLabelRotation=ones(1,nGroups)*0;
end
if isempty(xTypes)
    xTypes=cell(1,nGroups);
    xTypes(:)={'dates'};
end
if isempty(roundXLabels)
    roundXLabels=nan(1,nGroups);
end
if isempty(graphTypes)
    graphTypes=cell(1,nGraphs);
    graphTypes(:)={'plot'};
end
if isempty(graphPropSetFuncList),
    graphPropSetFuncList=cell(1,nGraphs);
else
    modgen.common.checkvar(graphPropSetFuncList,...
        ['iscell(x)&&isrow(x)&&numel(x)==' num2str(nGraphs)],...
        'graphPropSetFuncList');
    isnEmptyVec=~cellfun('isempty',graphPropSetFuncList);
    if any(isnEmptyVec),
        modgen.common.checkvar(...
            graphPropSetFuncList(isnEmptyVec),...
            'all(cellfun(''isclass'',x,''function_handle'')&cellfun(''prodofsize'',x)==1)',...
            'graphPropSetFuncList');
    end
end
if isempty(groupYLabels)
    groupYLabels=cell(1,nGroups);
end
if isempty(groupXLabels)
    groupXLabels=cell(1,nGroups);
end
if isempty(groupXLocations)
    groupXLocations=repmat({'bottom'},1,nGroups);
end
if isempty(groupYLocations)
    groupYLocations=repmat({'left'},1,nGroups);
end
if isempty(groupXColors)
    groupXColors=repmat({[0 0 0]},1,nGroups);
end
if isempty(groupYColors)
    groupYColors=repmat({[0 0 0]},1,nGroups);
end
if isempty(groupTitles)
    groupTitles=cell(1,nGroups);
end
if isempty(graphLegends)
    graphLegends=cell(1,nGraphs);
end
if ~isa(graphLegendsLocation,'cell')
    graphLegendsLocation={graphLegendsLocation};
    graphLegendsLocation=graphLegendsLocation(ones(1,nGroups));
end
if length(lineWidth)==1
    lineWidth=repmat(lineWidth,1,nGraphs);
end
if length(markerSize)==1
    markerSize=repmat(markerSize,1,nGraphs);
end
if ischar(markerNameList),
    markerNameList={markerNameList};
end
if length(markerNameList)==1,
    markerNameList=repmat(markerNameList,1,nGraphs);
end
%widthBar property
if isempty(widthCell)
    widthCell=cell(1,nGraphs);
    
end
if isempty(scale)
    scale=cell(1,nGroups);
    scale(:)={'normal'};
end
if isempty(scaleParam)
    scaleParam=nan(1,nGroups);
end
if isempty(xLim)
    xLim=cell(1,nGroups);
end
if isempty(yLim)
    yLim=cell(1,nGroups);
end
%
xUnited=[];
for iGraph=1:nGraphs
    xUnited=union(xUnited,xCell{iGraph});
end
isRem=false(size(xUnited));
if synchroDates
    for iGraph=1:nGraphs
        if ~strcmp(xTypes{groupMembership(iGraph)},'dates')
            continue;
        end
        y=yCell{iGraph};
        x=xCell{iGraph};
        x(isnan(y))=nan;
        isRem=isRem|ismember(xUnited,x);
    end
    if any(isRem)
        indFirst=find(isRem,1,'first');
        indLast=find(isRem,1,'last');
        firstDate=xUnited(indFirst);
        lastDate=xUnited(indLast);
        for iGraph=1:nGraphs
            if ~strcmp(xTypes{groupMembership(iGraph)},'dates')
                continue;
            end
            x=xCell{iGraph};
            isPlot=(x<=lastDate)&(x>=firstDate);
            xCell{iGraph}=x(isPlot);
            % for edgebar x and y have different number of elements
            if isequal(graphTypes{iGraph},'edgebar')
                yCell{iGraph}=yCell{iGraph}(isPlot(1:end-1));
            else
                yCell{iGraph}=yCell{iGraph}(isPlot);
            end
            if ~isempty(widthCell{iGraph})
                widthCell{iGraph}=widthCell{iGraph}(isPlot);
            end
            
        end
    end
end
%
if ~isempty(fHandle)
    if ~((numel(fHandle)==1)&&ishandle(fHandle(1)))
        error('Incorrect figure handle');
    end
else
    fHandle=figure;
end
%
visibleState=get(fHandle,'visible');
set(fHandle,'visible','off');
if ~isempty(figureName)
    set(fHandle,'Name',figureName,'NumberTitle','Off');
end
%
if nRows>1,
    groupYDistance=(1-2*yMargin)*(groupMargin)/(nRows-1);
else
    groupYDistance=0;
end
if nCols>1
    groupXDistance=(1-2*xMargin)*(groupMargin)/(nCols-1);
else
    groupXDistance=0;
end
groupWidthTotal=(1-2*xMargin)*(1-groupXDistance*(nCols-1));
groupHeightTotal=(1-2*yMargin)*(1-groupYDistance*(nRows-1));
groupWidth=groupWidthTotal/nCols;
groupHandles=zeros(1,nGroups);
%
hPlotHandlesVec=nan(1,nGraphs);
%
isNanMat=isnan(groupAreaDistr);
groupAreaDistr(isNanMat)=0;
yPos=cumsum(groupAreaDistr,1);
yPos=yMargin+groupHeightTotal*[zeros(1,nCols);yPos(1:end-1,:)]+...
    repmat(max((cumsum(double(~isNanMat),1)-1),0)*groupYDistance,1,nCols);
xPos=repmat(xMargin+...
    (groupWidth+groupXDistance)*(0:nCols-1),nRows,1);
groupAreaDistr(isNanMat)=[];
xPos(isNanMat)=[];
yPos(isNanMat)=[];
%
for iGroup=1:1:nGroups
    iPlace=indPlaceVec(iGroup);
    groupHeight=groupHeightTotal*groupAreaDistr(iPlace);
    groupPosition=[xPos(iPlace) yPos(iPlace) groupWidth groupHeight];
    h=axes('position',groupPosition,'Parent',fHandle);
    set(h,'FontSize',fontSize);
    groupHandles(iGroup)=h;
    if dragData.isDragEnabled
        set(h,'Units','normalized');
    end
    ind=find(groupMembership==iGroup);
    nPlots=length(ind);
    %shakhov bad hack, only works for one group
    %shakhov hack, only works for one group (uLimit and if)
    % xUnited --- all sorted points at x-axis
    % xUnitedScale --- all scaled sorted points at x-axis
    xUnited=[];
    xUnitedScale=[];
    for iPlot=1:1:nPlots
        iCell=ind(iPlot);
        %cut off nan tails
        x=xCell{iCell};
        y=yCell{iCell};
        xUnited=union(xUnited,x);
        % reparametrization by scale
        switch scale{iGroup}
            case 'sqrtscale'
                if ~isnan(scaleParam(iGroup))
                    x=(2*(x>=scaleParam(iGroup))-1).*power(abs(x-scaleParam(iGroup)),0.5);
                    xUnitedScale=union(xUnitedScale,x);
                    
                end
            case 'logarithm'
                if isnan(scaleParam(iGroup))
                    scaleParam(iGroup)=0;
                end
                
                x=(2*(x>=scaleParam(iGroup))-1).*log(abs(x-scaleParam(iGroup))+1);
                xUnitedScale=union(xUnitedScale,x);
            otherwise
                xUnitedScale=xUnited;
        end
        
        if dragData.isDragEnabled
            dragData.xData{iCell}=x;
            dragData.yData{iCell}=y;
            %
        end
        %
        if isSortByXAxis
            [x,indSorted]=sort(x);
            y=y(indSorted);
        end
        switch graphTypes{iCell}
            case {'bar','plot','stairs','scatter','area'}
                isArea=strcmp(graphTypes{iCell},'area');
                if isArea,
                    startIndVec=find(diff([false;~isnan(y(:));false])~=0);
                    if isempty(startIndVec),
                        vertexMat=[x(1) y(1)];
                        faceMat=1;
                        faceVertexCDataMat=1;
                    else
                        endIndVec=startIndVec(2:2:end)-1;
                        startIndVec=startIndVec(1:2:end-1);
                        nPeriods=numel(startIndVec);
                        vertexMat=cell(nPeriods,1);
                        faceMat=cell(nPeriods,1);
                        faceVertexCDataMat=cell(nPeriods,1);
                        iVertex=0;
                        for iPeriod=1:nPeriods,
                            curIndVec=startIndVec(iPeriod):endIndVec(iPeriod);
                            xVec=reshape(x(curIndVec),[],1);
                            yVec=reshape(y(curIndVec),[],1);
                            vertexMat{iPeriod}=[...
                                [xVec(1);xVec;flipud(xVec)]...
                                [0;yVec;zeros(numel(yVec),1)]];
                            nVertices=size(vertexMat{iPeriod},1);
                            faceMat{iPeriod}=iVertex+(1:nVertices);
                            faceVertexCDataMat{iPeriod}=[ones(nVertices-1,1);2];
                            iVertex=iVertex+nVertices;
                        end
                        vertexMat=vertcat(vertexMat{:});
                        faceVertexCDataMat=vertcat(faceVertexCDataMat{:});
                        nVerticesVec=cellfun('length',faceMat);
                        nVerticesVec=max(nVerticesVec)-nVerticesVec;
                        isFaceVec=nVerticesVec>0;
                        if any(isFaceVec),
                            faceMat(isFaceVec)=cellfun(...
                                @(x,y)[x nan(1,y)],...
                                faceMat(isFaceVec),...
                                num2cell(nVerticesVec(isFaceVec)),...
                                'UniformOutput',false);
                        end
                        faceMat=vertcat(faceMat{:});
                    end
                    plotHandle=patch('Faces',faceMat,'Vertices',vertexMat,...
                        'FaceVertexCData',faceVertexCDataMat,...
                        'FaceColor','flat','EdgeColor','k');
                else
                    plotHandle=eval([graphTypes{iCell}...
                        '(groupHandles(iGroup),x,y,graphPlotSpecs{iCell});']);
                end
                legendStr=graphLegends{iCell};
                %
                if ~isempty(legendStr)
                    set(plotHandle,'DisplayName',graphLegends{iCell});
                end
                %
                hPlotHandlesVec(iCell)=plotHandle;
                %
                if strcmpi(graphTypes{iCell},'scatter'),
                    set(plotHandle,'SizeData',lineWidth(iCell));
                elseif ~strcmpi(graphTypes{iCell},'bar'),
                    set(plotHandle,'lineWidth',lineWidth(iCell));
                end
                if ~strcmpi(graphTypes{iCell},'bar')
                    set(plotHandle,'markerSize',markerSize(iCell),...
                        'marker',markerNameList{iCell});
                end
                if ~isempty(graphRgbColors)
                    if ~(strcmpi(graphTypes{iCell},'bar')||isArea),
                        set(plotHandle,'color',graphRgbColors{iCell});
                    else
                        set(plotHandle,'FaceColor',graphRgbColors{iCell});
                    end
                end
                if dragData.isDragEnabled
                    dragData.plotHandles(iPlot)=plotHandle;
                end
            case 'widthbar'
                width=widthCell{iCell};
                if isempty(width)
                    hPlotHandlesVec(iCell)=bar(x,y,graphPlotSpecs{iCell});
                else
                    x=reshape(x,[1,numel(x)]);
                    y=reshape(y,[1,numel(y)]);
                    width=reshape(width,[1,numel(width)]);
                    xWidth=[x-width/2;x-width/2;x+width/2;x+width/2];
                    xWidth=reshape(xWidth,[1,numel(xWidth)]);
                    yWidth=[zeros(1,numel(y));y;y;zeros(1,numel(y))];
                    yWidth=reshape(yWidth,[1,numel(yWidth)]);
                    areaHandle=area(xWidth,yWidth);
                    set(areaHandle,'FaceColor',graphPlotSpecs{iCell},...
                        'lineWidth',lineWidth(iCell),...
                        'markerSize',markerSize(iCell));
                    hPlotHandlesVec(iCell)=areaHandle;
                end
            case 'edgebar'
                x=reshape(x,[1,numel(x)]);
                y=reshape(y,[1,numel(y)]);
                % generate massives for area
                xEdge=[x(2:end-1);x(2:end-1);x(2:end-1)];
                xEdge=reshape(xEdge,[1,numel(xEdge)]);
                xEdge=[x(1),x(1),xEdge,x(end),x(end)];
                yEdge=[y(1:end-1);zeros(1,numel(y)-1);y(2:end)];
                yEdge=reshape(yEdge,[1,numel(yEdge)]);
                yEdge=[0,y(1),yEdge,y(end),0];
                areaHandle=area(xEdge,yEdge);
                set(areaHandle,'FaceColor',graphPlotSpecs{iCell});
                if ~isempty(lineWidth)
                    set(areaHandle,'lineWidth',lineWidth(iCell));
                end
                if ~isempty(markerSize)
                    set(areaHandle,'markerSize',markerSize(iCell));
                end
                set(areaHandle,'edgeColor','w');
                hPlotHandlesVec(iCell)=areaHandle;
        end
        if ~isempty(graphPropSetFuncList{iCell}),
            feval(graphPropSetFuncList{iCell},hPlotHandlesVec(iCell));
        end
        hold(groupHandles(iGroup),'on');
    end;
    % set limits for axes
    if ~isempty(yLim{iGroup})
        ylim(yLim{iGroup});
    end
    
    if ~isempty(xLim{iGroup})
        % reparametrization limits by scale
        switch scale{iGroup}
            case 'sqrtscale'
                if ~isnan(scaleParam(iGroup))
                    xLim{iGroup}(1)=(2*(xLim{iGroup}(1)>=scaleParam(iGroup))-1).*...
                        power(abs(xLim{iGroup}(1)-scaleParam(iGroup)),0.5);
                    xLim{iGroup}(2)=(2*(xLim{iGroup}(2)>=scaleParam(iGroup))-1).*...
                        power(abs(xLim{iGroup}(2)-scaleParam(iGroup)),0.5);
                end
            case 'logarithm'
                xLim{iGroup}(1)=(2*(xLim{iGroup}(1)>=scaleParam(iGroup))-1)...
                    .*log(abs(xLim{iGroup}(1)-scaleParam(iGroup))+1);
                xLim{iGroup}(2)=(2*(xLim{iGroup}(2)>=scaleParam(iGroup))-1)...
                    .*log(abs(xLim{iGroup}(2)-scaleParam(iGroup))+1);
        end
        xlim(xLim{iGroup});
    end
    
    legList=graphLegends(ind);
    isNotEmpty=true(size(legList));
    for iLeg=1:numel(legList)
        if isempty(legList{iLeg})
            isNotEmpty(iLeg)=0;
        end
    end
    ylabel(h,groupYLabels(iGroup),'interpreter','none','FontSize',fontSize,'FontWeight',fontWeight,...
        'Rotation',groupYLabelRotation(iGroup));
    %
    xlabel(h,groupXLabels(iGroup),'interpreter','none','FontSize',fontSize,'FontWeight',fontWeight,...
        'Rotation',groupXLabelRotation(iGroup));
    %
    title(h,groupTitles{iGroup},'interpreter','none','FontSize',fontSize,'FontWeight',fontWeight);
    
    if any(isNotEmpty)&&isLegendDisplayed
        %   legList(~isNotEmpty)={''};
        %legend(hPlotHandlesVec(ind),legList{:},'Location',graphLegendsLocation{iGroup});
        %legend(groupHandles(iGroup),legList,'Location',graphLegendsLocation{iGroup});
        hLegend=legend(groupHandles(iGroup),'show');
        set(hLegend,'Interpreter','none','Location',graphLegendsLocation{iGroup});
        %set(hLegend,'Visible','on');
        %legend(groupHandles(iGroup),'show');
    end
    
    
    % xticklabels depends on xTypes and scale.
    hZoom = zoom(fHandle);
    hPan=pan(fHandle);
    setAxesZoomMotion(hZoom,groupHandles(iGroup),graphZoomDirList{iGroup});
    switch xTypes{iGroup}
        case 'numbers',
            %
            SEvent.Axes=h;
            zoomNumberCallback([],SEvent,...
                scale{iGroup},scaleParam(iGroup),roundXLabels(iGroup));
            %
            fZoomCallback=@(obj,event)zoomNumberCallback(obj,event,...
                scale{iGroup},scaleParam(iGroup),roundXLabels(iGroup));
            set(hZoom,'ActionPostCallback',fZoomCallback);
            set(hPan,'ActionPostCallback',fZoomCallback);
            %
        case 'dates',
            datetick(groupHandles(iGroup),'x');
            set(hZoom,'ActionPostCallback',@zoomDatesCallback);
            set(hPan,'ActionPostCallback',@zoomDatesCallback);
            %
            % we use xtick for scaled data and xticklabel for original data.
        case 'set',
            set(h,'xtick',xUnitedScale);
            set(h,'xticklabel',xUnited);
            if length(roundXLabels)>=iGroup;
                set(h,'xticklabel',round(xUnited*10^roundXLabels(iGroup))/10^roundXLabels(iGroup));
            end
        case 'setdates',
            set(h,'xtick',xUnitedScale);
            set(h,'xticklabel',datestr(xUnited,dateFormat));
    end
    set(h,'FontSize',fontSize,'FontWeight',fontWeight);
    if xGrid
        set(h,'XGrid','on');
    end
    if yGrid
        set(h,'YGrid','on');
    end
    set(h,...
        'XAxisLocation',groupXLocations{iGroup},...
        'YAxisLocation',groupYLocations{iGroup},...
        'XColor',groupXColors{iGroup},...
        'YColor',groupYColors{iGroup});
    if any(indPlaceVec(1:iGroup-1)==iPlace),
        set(h,'Color','none');
    end
    
end
if ~strcmp(linkAxesSpec,'none')
    linkaxes(groupHandles,linkAxesSpec);
    if strcmp(linkAxesSpec,'x')
        hAxesVec=groupHandles(strcmp(xTypes,'dates')|...
            strcmp(xTypes,'numbers'));
        hlink=linkprop(hAxesVec,{'XTickLabel','XTick'});
        KEY = 'graphics_linkxticklabel';
        for i=1:length(hAxesVec)
            setappdata(hAxesVec(i),KEY,hlink);
        end
    end
end
set(fHandle,'Visible',visibleState);
%
if dragData.isDragEnabled
    dragData.axesHandles=groupHandles(1);
    %tie callbacks and initialize dragndrop
    set(fHandle,'Units','normalized');
    plotdragndrops(fHandle,dragData);
    
end


end


function [ plotHandles ] = plotdragndrops( fHandle,dragData )
%service function you are not supposed to use it

figureHandle=fHandle;
FigureData=guidata(fHandle);
FigureData.dragData=dragData;
guidata(fHandle,FigureData);
FigureData=guidata(figureHandle);

axesHandle=dragData.axesHandles;

xLim=xlim(axesHandle);
yLim=ylim(axesHandle);
%
FigureData.dragData.axesXLims=xLim;
FigureData.dragData.axesYLims=yLim;
%
%
%xLim=xLim*(1+1/12);
%
xLimLen=xLim*[-1;1]/2;
xLimMid=xLim*[1;1]/2;
%
xLimMult=FigureData.dragData.xLimMult;
xLimScr=xLimMid+xLimLen*xLimMult*[-1;1];
%
yLimLen=yLim*[-1;1]/2;
yLimMid=yLim*[1;1]/2;
%
yLimMult=FigureData.dragData.yLimMult;
yLimScr=yLimMid+yLimLen*yLimMult*[-1;1];
%
xlim(axesHandle,xLimScr);
ylim(axesHandle,yLimScr);
%
set(axesHandle,'XLimMode','manual');
set(axesHandle,'YLimMode','manual');
position=get(axesHandle,'Position');

set(figureHandle,'WindowButtonUpFcn',{@figuremouseup,position});
set(figureHandle,'WindowButtonMotionFcn',{@figuremousemove});
%
%
nGraphs=length(dragData.plotHandles);

plotHandles=dragData.plotHandles;
for iGraph=1:nGraphs
    set(plotHandles(iGraph),'ButtonDownFcn',{@pointbuttondown,iGraph});
end
%
FigureData.dragData.dragmode='normal';
FigureData.dragData.axesPosition=position(1:2);
FigureData.dragData.axesSizes=position(3:4);

%
guidata(figureHandle,FigureData);
%
plotrefresh(axesHandle,1:nGraphs);
%
%
end
function pointbuttondown(plotHandle,~,indCurve)
% on point click event
%here we need to find the most close point

axesHandle=get(plotHandle,'Parent');
figureHandle=get(axesHandle,'Parent');
FigureData=guidata(figureHandle);
axesPosition=FigureData.dragData.axesPosition;
mousePosition=get(figureHandle,'CurrentPoint');
pointPosition=mousePosition-axesPosition;
aspectRatio=FigureData.dragData.dragScale;
dataPosition=aspectRatio(1:2).*pointPosition+aspectRatio(3:4);
%
xVec=get(plotHandle,'XData');
[dist,indPoint]=min(abs(xVec-dataPosition(1)));
%
isNear=dist>0;
%
if isNear
    %
    pointUserData=FigureData.dragData.userData{indCurve}{indPoint};
    %
    FigureData.dragData.currentPointUserData=pointUserData;
    FigureData.dragData.currentPlotHandle=plotHandle;
    FigureData.dragData.currentIndPoint=indPoint;
    FigureData.dragData.dragmode='drag';
    FigureData.dragData.currentIndCurve=indCurve;
    FigureData.dragData.axesHandle=axesHandle;
    clickCallback=FigureData.dragData.clickCallback;
    if ~isempty(clickCallback)
        [changedCurves,xNewData,yNewData,changedUserData]=feval(clickCallback,pointUserData,dataPosition);
        FigureData.dragData.xData(changedCurves)=xNewData(:);
        FigureData.dragData.yData(changedCurves)=yNewData(:);
        FigureData.dragData.userData{FigureData.dragData.currentIndCurve}{indPoint}=changedUserData;
        guidata(figureHandle,FigureData);
        plotrefresh(axesHandle,changedCurves);
    end
end
end
%
function figuremousemove(figureHandle,~)
% on mouse move
FigureData=guidata(figureHandle);
%

switch FigureData.dragData.dragmode
    case 'drag'
        
        axesPosition=FigureData.dragData.axesPosition;
        axesHandle=FigureData.dragData.axesHandle;
        mousePosition=get(figureHandle,'CurrentPoint');
        %if all(mousePosition<axesPosition+axesSizes) && all(mousePosition>axesPosition)
        pointPosition=mousePosition-axesPosition;
        aspectRatio=FigureData.dragData.dragScale;
        dataPosition=aspectRatio(1:2).*pointPosition+aspectRatio(3:4);
        dragCallback=FigureData.dragData.dragCallback;
        %get the userData
        pointUserData=FigureData.dragData.currentPointUserData;
        %
        [changedCurves,xNewData,yNewData,changedUserData]=feval(dragCallback,pointUserData,dataPosition);
        FigureData.dragData.xData(changedCurves)=xNewData(:);
        FigureData.dragData.yData(changedCurves)=yNewData(:);
        indPoint=FigureData.dragData.currentIndPoint;
        FigureData.dragData.userData{FigureData.dragData.currentIndCurve}{indPoint}=changedUserData;
        guidata(figureHandle,FigureData);
        plotrefresh(axesHandle,changedCurves);
        %end
        
end
end
%

%
function figuremouseup(figureHandle,~,~)
% on mouse up
FigureData=guidata(figureHandle);
FigureData.dragData.dragmode='normal';
axesHandle=FigureData.dragData.axesHandles;
guidata(figureHandle,FigureData);
plotrefresh(axesHandle,[]);
%
end

function plotrefresh(axesHandle,changedCurves)
%
figureHandle=get(axesHandle,'Parent');
FigureData=guidata(figureHandle);
%
dragData=FigureData.dragData;
%
xLimOld=FigureData.dragData.axesXLims;
yLimOld=FigureData.dragData.axesYLims;
%
for iGraph=1:length(changedCurves)
    indGraph=changedCurves(iGraph);
    plotHandle=dragData.plotHandles(indGraph);
    xData=dragData.xData{indGraph};
    yData=dragData.yData{indGraph};
    set(plotHandle,'XData',xData);
    set(plotHandle,'YData',yData);
end
%
%see whether the limits are changed
xMat=cell2mat(dragData.xData);
yMat=cell2mat(dragData.yData);
xMax=max(max(xMat));
yMax=max(max(yMat));
xMin=min(min(xMat));
yMin=min(min(yMat));

xLim=[xMin xMax];
yLim=[yMin yMax];
%
if (any(xLimOld~=xLim))
    FigureData.dragData.axesXLims=xLim;
    %
    xLimLen=xLim*[-1;1]/2;
    xLimMid=xLim*[1;1]/2;
    %
    xLimMult=FigureData.dragData.xLimMult;
    xLimScr=xLimMid+xLimLen*xLimMult*[-1;1];
    %
    xlim(axesHandle,xLimScr);
end
%
if (any(yLimOld~=yLim))
    FigureData.dragData.axesYLims=yLim;
    %
    yLimLen=yLim*[-1;1]/2;
    yLimMid=yLim*[1;1]/2;
    %
    yLimMult=FigureData.dragData.yLimMult;
    yLimScr=yLimMid+yLimLen*yLimMult*[-1;1];
    %
    ylim(axesHandle,yLimScr);
end
%
position=FigureData.dragData.axesSizes;
wAxes=position(1);
hAxes=position(2);
xLimScr=xlim(axesHandle);
yLimScr=ylim(axesHandle);
wData=xLimScr(2)-xLimScr(1);
hData=yLimScr(2)-yLimScr(1);
%
%
FigureData.dragData.dragScale=[wData/wAxes hData/hAxes xLimScr(1) yLimScr(1)];
guidata(figureHandle,FigureData);
%
end
%
function zoomDatesCallback(~,eventdata)
datetick(eventdata.Axes,'keeplimits');
end
%
function zoomNumberCallback(~,eventdata,scale,scaleParam,roundXLabel)
h=eventdata.Axes;
set(h,'XTickMode','auto');
x=get(h,'xtick');
if isequal(scale,'sqrtscale') && ~isnan(scaleParam)
    x=(2*(x>=0)-1).*x.^2+scaleParam;
end
if isequal(scale,'logarithm')
    x=(2*(x>=0)-1).*(exp(abs(x))-1)+scaleParam;
end
set(h,'xticklabel',x);
%
if ~isnan(roundXLabel)
    x=get(h,'xtick');
    if isequal(scale,'sqrtscale') && ~isnan(scaleParam)
        x=(2*(x>=0)-1).*x.^2+scaleParam(iGroup);
    end
    if isequal(scale,'logarithm')
        x=(2*(x>=0)-1).*(exp(abs(x))-1)+scaleParam;
    end
    set(h,'xticklabel',round(x*10^roundXLabel)/10^roundXLabel);
end
end


