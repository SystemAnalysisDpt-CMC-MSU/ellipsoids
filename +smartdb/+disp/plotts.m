function plotts(rel,varargin)
% PLOTTS plots a content of ARelation object as a set of time series
% grouping them by certain attributes of an input relation

% 
% smartdb.disp.plotts(vaMetricTSObj,'xfieldname', 'time_stamp_ts', 'yfieldname','metric_value_ts',...
%  'figuregroupby','inst_id', 'figurenameby','inst_name',...
% 'axesgroupby','vametric_configured_id','axesnameby','vametric_configured_name', 'graphnameby','vametric_configured_name');
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

[~,prop]=modgen.common.parseparams(varargin,[],0);
nProp=length(prop);
figureGroupBy=[];
figureNameBy=[];
axesGroupBy=[];
axesNameBy=[];
graphNameByList=[];
plotSpecByList=[];
colorByList=[];
lineWidthByList=[];
markerSizeByList=[];
isDryRun=false;
linkAxesSpec='none';
nTuples=rel.getNTuples();
if nTuples==0
    error([upper(mfilename),':wrongInput'],...
        'no data, nothing to plot');
end
isLegendDisplayed=false;
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'xfieldname',
            xFieldNameList=prop{k+1};
        case 'yfieldname',
            yFieldNameList=prop{k+1};
        case 'figuregroupby',
            figureGroupBy=prop{k+1};
        case 'figurenameby',
            figureNameBy=prop{k+1};
        case 'axesgroupby',
            axesGroupBy=prop{k+1};
        case 'axesnameby',
            axesNameBy=prop{k+1};
        case 'graphnameby',
            graphNameByList=prop{k+1};
        case 'plotspecby'
            plotSpecByList=prop{k+1};
        case 'colorby',
            colorByList=prop{k+1};
        case 'linewidthby',
            lineWidthByList=prop{k+1};
        case 'markersizeby',
            markerSizeByList=prop{k+1};
        case 'dryrun',
            isDryRun=prop{k+1};
        case 'linkaxes',
            linkAxesSpec=prop{k+1};
        case 'displaylegend',
            isLegendDisplayed=prop{k+1};
%         case 'colorby',
%             color
        otherwise,
            error([upper(mfilename),':unknownProperty'],...
                'property %s is not supported',prop{k});
    end
end
%
if isempty(figureGroupBy)
    figureGroupByVec=ones(nTuples,1);
else
    figureGroupByVec=rel.(figureGroupBy);
end
%
if isempty(figureNameBy)&&~isempty(figureGroupBy)
    figureNameBy=figureGroupBy;
end
%
if isempty(figureNameBy)
    figureNameList=repmat({'figureName'},nTuples,1);
else
    figureNameList=rel.(figureNameBy);
    if isnumeric(figureNameList)
        figureNameList=num2cell(figureNameList);
        figureNameList=cellfun(@num2str,figureNameList,'UniformOutput',false);        
    elseif ~iscellstr(figureNameList)
        error([mfilename,':wrongInput'],'numeric or cell of strings is expected in field %s',figureNameBy);
    end
end
if isempty(axesGroupBy)
    indAxesVec=ones(nTuples,1);
else
    indAxesVec=rel.(axesGroupBy);
end
%
if isempty(axesNameBy)&&~isempty(axesGroupBy)
    axesNameBy=axesGroupBy;
end
%
if isempty(axesNameBy)
    axesNameList=repmat({'axesName'},nTuples,1);
else
    axesNameList=rel.(axesNameBy);
    if isnumeric(axesNameList)
        axesNameList=num2cell(axesNameList);
        axesNameList=cellfun(@num2str,axesNameList,'UniformOutput',false);
    elseif ~iscellstr(axesNameList)
        error([mfilename,':wrongInput'],'numeric or cell of strings is expected in field %s',axesNameBy);
    end
        
end
%
if ischar(xFieldNameList)
    xFieldNameList={xFieldNameList};
end
%
if ischar(yFieldNameList)
    yFieldNameList={yFieldNameList};
end
if ischar(plotSpecByList)
    plotSpecByList={plotSpecByList};
end
%
if ischar(colorByList)
    colorByList={colorByList};
end
%
if ischar(lineWidthByList)
    lineWidthByList={lineWidthByList};
end
%
if ischar(markerSizeByList)
    markerSizeByList={markerSizeByList};
end
%
if ischar(graphNameByList)
    graphNameByList={graphNameByList};
end
%
nFieldsY=length(yFieldNameList);
nFieldsX=length(xFieldNameList);
%
if (nFieldsX==1)&&(nFieldsY>1)
    xFieldNameList=repmat(xFieldNameList,1,nFieldsY);
end
%
nTuples=rel.getNTuples();
nTs=length(xFieldNameList);
%
if isempty(plotSpecByList)
    plotSpecByList=repmat({''},1,nTs);
    plotSpecCodeMat=repmat({'-'},nTuples,nTs);
else
    plotSpecCodeMat=rel.toCell(plotSpecByList{:});
end
%
if isempty(colorByList)
    colorByList=repmat({''},1,nTs);
    colorCodeMat=repmat({[0 0 1]},nTuples,nTs);
else
    colorCodeMat=rel.toCell(colorByList{:});
end
%
if isempty(lineWidthByList)
    lineWidthByList=repmat({''},1,nTs);
    lineWidthMat=ones(nTuples,nTs);
else
    lineWidthMat=rel.toMat('fieldNameList',lineWidthByList,...
        'UniformOutput',true);
end
%
if isempty(markerSizeByList)
    markerSizeByList=repmat({''},1,nTs);
    markerSizeMat=ones(nTuples,nTs);
else
    markerSizeMat=rel.toMat('fieldNameList',markerSizeByList,...
        'UniformOutput',true);
end
%
if isempty(graphNameByList)
    graphNameMat=repmat({'graphName'},nTuples,nTs);
else
    graphNameMat=rel.toCell(graphNameByList{:});
    %
    if iscellnum(graphNameMat)
        graphNameMat=cellfun(@num2str,graphNameMat,'UniformOutput',false);
    end
    %
    if ~iscellstr(graphNameMat)
        error([mfilename,':wrongInput'],...
            'numeric or cell of strings is expected in field %s',...
            graphNameByList);
    end    
    %
end
%
if ~auxchecksize(colorByList,yFieldNameList,...
        plotSpecByList,graphNameByList,lineWidthByList,markerSizeByList,...
        size(xFieldNameList))
    error([upper(mfilename),':wrongInput'],['xFieldName, yFieldName,',...
        'colorBy, plotSpecBy, lineWidthByList, markerSizeByList ',...
        'and graphNameBy properties ',...
        'are expected to be of the same size']);
end
%
xVecCMat=rel.toCell(xFieldNameList{:});
yVecCMat=rel.toCell(yFieldNameList{:});
%
%    
[figureGroupVec,indForward,indBackward]=unique(figureGroupByVec);
indVecCVec=accumarray(indBackward,transpose(1:nTuples),[],@(x){x});
xGroupedCVec=cellfun(@(x)(reshape(xVecCMat(x,:),1,[])),indVecCVec,'UniformOutput',false);
yGroupedCVec=cellfun(@(x)(reshape(yVecCMat(x,:),1,[])),indVecCVec,'UniformOutput',false);
%
[tmp,indAxesCVec,indGroupCVec]=cellfun(@(x)(unique(indAxesVec(x))),indVecCVec,'UniformOutput',false);
%
axesNameListCVec=cellfun(@(x,y)axesNameList(x(y)),indVecCVec,indAxesCVec,'UniformOutput',false);
%
graphNameListCVec=cellfun(@(x)reshape(graphNameMat(x,:),1,[]),indVecCVec,'UniformOutput',false);
plotSpecCodeListCVec=cellfun(@(x)reshape(plotSpecCodeMat(x,:),1,[]),indVecCVec,'UniformOutput',false);
colorCodeListCVec=cellfun(@(x)reshape(colorCodeMat(x,:),1,[]),indVecCVec,'UniformOutput',false);
markerSizeListCVec=cellfun(@(x)reshape(markerSizeMat(x,:),1,[]),indVecCVec,'UniformOutput',false);
lineWidthListCVec=cellfun(@(x)reshape(lineWidthMat(x,:),1,[]),indVecCVec,'UniformOutput',false);
%
indGroupCVec=cellfun(@(x)repmat(x,1,nTs),indGroupCVec,'UniformOutput',false);
%
figureNameList=figureNameList(indForward);
%
if ~isDryRun;
    hFigureCVec=cellfun(@(x)(prepivfigure(...
        'Name',x,'Visible','off','WindowStyle','docked')),...
        figureNameList,'UniformOutput',false);    
    %
    hAxesCVec=cellfun(@(hFig,figureName,xCell,yCell,groupMembership,...
        groupTitles,graphLegends,graphPlotSpecs,graphColorSpecs,...
        graphLineWidth,graphMarkerSize)...
        plotts('fHandle',hFig,'figureName',figureName,'xCell',xCell,'yCell',yCell,...
        'groupMembership',groupMembership,'groupTitles',...
        groupTitles,'graphLegends',graphLegends,...
        'isSortByXAxis',true,'dateFormat','dd/mm/yy',...
        'graphPlotSpecs',graphPlotSpecs,'linkAxes',linkAxesSpec,...
        'displayLegend',isLegendDisplayed,'graphRGBColors',graphColorSpecs,...
        'lineWidth',graphLineWidth,'markerSize',graphMarkerSize),...
        hFigureCVec,figureNameList,xGroupedCVec,yGroupedCVec,indGroupCVec,...
        axesNameListCVec,...
        graphNameListCVec,plotSpecCodeListCVec,colorCodeListCVec,...
        lineWidthListCVec,markerSizeListCVec,...
        'UniformOutput',false);
    %%
    drawnow;
    %hBrowserCVec=cellfun(@(x)plotbrowser(x),hFigureCVec,'UniformOutput',false);
    cellfun(@(x)set(x,'Selected','off','Visible','on'),hFigureCVec);
end

end


function hFigure=prepivfigure(varargin)
% p=inputParser();
% p.addParamValue('Name','MSFT');
% p.parse(varargin{:});
hFigure=figure();
set(hFigure,'NumberTitle','off',varargin{:});

%set(hFigure,'menubar','none');
end
function isA=iscellnum(inpCell)
isA=iscell(inpCell)&&all(reshape(cellfun(@isnumeric,inpCell),1,[]));
end
