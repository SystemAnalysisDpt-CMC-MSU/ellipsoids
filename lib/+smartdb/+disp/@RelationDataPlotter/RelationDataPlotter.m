classdef RelationDataPlotter<handle
    properties (Access=private)
        figHMap
        figToAxesToHMap
        figToAxesToPlotHMap
        nMaxAxesRows
        nMaxAxesCols
        figureGroupKeySuffFunc
    end
    properties (Constant,GetAccess=private)
        DEF_N_MAX_AXES_ROWS=2;
        DEF_N_MAX_AXES_COLS=2;
        DEF_FIGURE_GROUP_SUFF_FUNC=@(x)sprintf('_g%d',x);
    end
    methods
        function SProps=getPlotStructure(self)
            SProps.figHMap=self.figHMap.getCopy();
            SProps.figToAxesToHMap=self.figToAxesToHMap.getCopy();
            SProps.figToAxesToPlotHMap=self.figToAxesToPlotHMap.getCopy();
        end
        function self=RelationDataPlotter(varargin)
            % RELATIONDATAPLOTTER responsible for plotting data from a
            % relation represented by ARelation object
            %
            % Input:
            %   properties:
            %       nMaxAxesRows: numeric[1,1] - maximum number of axes
            %           rows per single figure
            %       nMaxAxesCols: numeric[1,1] - maximum number of axes
            %           columns per single figure
            %       figureGroupKeySuffFunc: function_handle[1,1] - function
            %           responsible for converting a number of figure within a
            %           single group into a character suffix. This function is
            %           useful when a number of axes for some figure is greater
            %           than nMaxAxesRows*nMaxAxesCols in which case the
            %           remainder of the axis is moved to a additional figures
            %           with names composed from figure group name and suffix
            %           produced by figureGroupKeySuffFunc
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-12 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            %
            self.figHMap=modgen.containers.MapExtended();
            self.figToAxesToHMap=modgen.containers.MapExtended();
            self.figToAxesToPlotHMap=modgen.containers.MapExtended();
            %
            [~,~,self.nMaxAxesRows,self.nMaxAxesCols,...
                self.figureGroupKeySuffFunc]=...
                modgen.common.parseparext(varargin,...
                {'nMaxAxesRows','nMaxAxesCols','figureGroupKeySuffFunc';...
                self.DEF_N_MAX_AXES_ROWS,self.DEF_N_MAX_AXES_COLS,...
                self.DEF_FIGURE_GROUP_SUFF_FUNC;...
                'isnumeric(x)&&numel(x)==1','isnumeric(x)&&numel(x)==1',...
                'isfunction(x)&&numel(x)==1'},0);
        end
        %%
        function closeAllFigures(self)
            % CLOSEALLFIGURES closes all figures
            import modgen.logging.log4j.Log4jConfigurator;
            logger=Log4jConfigurator.getLogger();
            %
            mp=self.figHMap;
            cellfun(@closeFigure,mp.values);
            self.clearGraphicHandleMaps();
            function closeFigure(h)
                if ishandle(h)
                    close(h);
                else
                    logger.warn([num2str(h),' is invalid figure handle']);
                end
            end
        end
        %%
        function saveAllFigures(self,resFolderName,formatNameList)
            % SAVEALLFIGURES saves all figures to a specified folder in
            % 'fig' format
            %
            % Input:
            %   regular:
            %       self:
            %       resFolderName: char[1,] - destination folder name
            %
            %   optional:
            %       formatNameList: char[1,]/cell[1,] of char[1,]
            %           - list of format names accepted by the built-in
            %           "saveas" function, default value is 'fig';
            %
            %
            import modgen.logging.log4j.Log4jConfigurator;
            import modgen.common.type.simple.checkcellofstr;
            import modgen.common.genfilename;
            if nargin<3
                formatNameList={'fig'};
            end
            %refresh figures
            drawnow expose;
            %
            logger=Log4jConfigurator.getLogger();
            mp=self.figHMap;
            handleVec=cell2mat(mp.values);
            figureKeyList=mp.keys;
            nFigures=length(figureKeyList);
            formatNameList=checkcellofstr(formatNameList);
            nFormats=length(formatNameList);
            for iFigure=1:nFigures
                hFigure=handleVec(iFigure);
                if ~ishandle(hFigure)
                    logger.warn(sprintf(...
                        ['Handle %d doesn''t exists, probably figure ',...
                        'has been closed manually'],hFigure));
                else
                    shortFigFileName=genfilename(figureKeyList{iFigure});
                    for iFormat=1:nFormats
                        formatName=formatNameList{iFormat};                    
                        figFileName=[resFolderName,filesep,...
                            shortFigFileName,'.',formatName];
                        msgStr=['saving file ',figFileName,' to disk'];
                        logger.debug([msgStr,'...']);                    
                        saveas(hFigure,figFileName,formatName);
                        if ~modgen.system.ExistanceChecker.isFile(figFileName)
                            error([upper(mfilename),':wrongInput'],...
                                'file %s was not created',figFileName);
                        end
                        logger.debug([msgStr,': done']);
                    end
                end
            end
        end
        %%
        function plotGeneric(self,rel,...
                figureGetGroupKeyFunc,figureGetGroupKeyFieldNameList,...
                figureSetPropFunc,figureSetPropFieldNameList,...
                axesGetKeyFunc,axesGetKeyFieldNameList,...
                axesSetPropFunc,axesSetPropFieldNameList,...
                plotCreateFunc,plotCreateFieldNameList,varargin)
            % PLOTGENERIC plots a content of specified ARelation object
            %
            % Input:
            %   regular:
            %       self:
            %       rel: smartdb.relation.ARelation[1,1] - relation
            %           containing the data to plot
            %
            %       figureGetGroupKeyFunc: function_handle[1,1]
            %                       /cell[1,nFuncs] of function_handle[1,1]
            %           - function responsible for producing figure group
            %             name.
            %       figureGetGroupKeyFieldNameList: cell[1,] of char[1,] -
            %           list of fields of specified relation (rel) passed
            %           into figureGetGroupKeyFunc as input arguments
            %
            %       figureSetPropFunc: function_handle[1,1]/
            %                   cell[1,nFuncs] of function_handle[1,1]
            %           - function(s) responsible for setting properties of
            %           figure objects, the first argument to the
            %           function is a handle of the corresponding figure,
            %           the second one is figureKey, the third one is
            %           figure group number while the rest are defined by
            %           the following property
            %       figureSetPropFieldNameList: cell[1,] of char[1,] - list of
            %           fields of specified relations passed into
            %           figureSetPropFunc as additional input arguments
            %
            %       axesGetKeyFunc: function_handle[1,1]/
            %                   cell[1,nFuncs] of function_handle[1,1]
            %           - handle of function(s) responsible for
            %           generating an axes name
            %       axesGetKeyFieldNameList: cell[1,] of char[1,] - list of fields
            %           of the specified relation passed into
            %           axesGetKeyFunc as input arguments
            %
            %       axesSetPropFunc: function_handle[1,1]/
            %                   cell[1,nFuncs] of function_handle[1,1]
            %           - handle of function(s) responsible for
            %           setting axes properties  the first
            %           argument is axes handle, the second one is
            %           axes key while the rest of the arguments defined by
            %           axesSetPropFieldNameList property
            %           
            %       axesSetPropFieldNameList: cell[1,] of char[1,] - list of fields
            %           of the specified relation passed into
            %           axesSetPropFunc as input arguments,             %
            %
            %       plotCreateFunc: function_handle[1,1]/
            %               cell[1,nFuncs] of function_handle[1,1]
            %           - function(s) responsible for plotting data
            %           from the specified relation on
            %           the axes specified by handle passed as
            %           the first input argument to the function
            %       plotCreateFieldNameList: cell[1,] of char[1,] - list of fields
            %           of the specified relation passed into
            %           plotCreateFunc as additional input arguments
            %
            %   properties:
            %       axesPostPlotFunc: function_handle[1,1]/
            %                   cell[1,nFuncs] of function_handle[1,1]
            %           - handle of function(s) responsible for
            %           setting axes properties after the drawing process is finished
            %           the first argument is axes handle, the 
            %           second one is axes key while the rest of them are
            %           defined by axesSetPropFieldNameList
            %
            %
            import modgen.logging.log4j.Log4jConfigurator;
            import modgen.common.type.simple.*;
            import smartdb.disp.RelationDataPlotter;
            import modgen.common.throwerror;
            import modgen.struct.updateleaves;
            import modgen.common.type.simple.checkcelloffunc;
            %
            [~,~,axesPostPlotFunc,isAxesPostPlotFuncSpec]=...
                modgen.common.parseparext(...
                varargin,{'axesPostPlotFunc'},0);
            logger=Log4jConfigurator.getLogger();
            %
            checkcellofstr(figureGetGroupKeyFieldNameList,true);
            checkcellofstr(axesGetKeyFieldNameList,true);
            %
            checkcellofstr(figureSetPropFieldNameList,true);
            checkcellofstr(axesSetPropFieldNameList,true);
            checkcellofstr(plotCreateFieldNameList,true);
            %
            [figureGetGroupKeyFunc,figureSetPropFunc,...
                axesGetKeyFunc,axesSetPropFunc,plotCreateFunc]=...
                RelationDataPlotter.checkFunc(...
                figureGetGroupKeyFunc,figureSetPropFunc,...
                axesGetKeyFunc,axesSetPropFunc,plotCreateFunc);
            %
            if isAxesPostPlotFuncSpec
                [~,axesPostPlotFunc]=...
                RelationDataPlotter.checkFunc(...
                axesSetPropFunc,axesPostPlotFunc);                
            end
            %
            nFuncs=length(figureGetGroupKeyFunc);
            nEntries=rel.getNTuples();
            %
            figureGroupKeyCMat=RelationDataPlotter.cellFunArray(...
                rel,figureGetGroupKeyFunc,...
                figureGetGroupKeyFieldNameList);
            axesKeyCMat=RelationDataPlotter.cellFunArray(rel,...
                axesGetKeyFunc,axesGetKeyFieldNameList);
            %
            figureGroupKeyList=figureGroupKeyCMat(:);
            SData.figureGroupKey=figureGroupKeyList;
            SData.axesKey=axesKeyCMat(:);
            figAxesMapRel=smartdb.relations.DynamicRelation(SData);
            figAxesMapRel.removeDuplicateTuples();
            figAxesMapRel.groupBy('figureGroupKey');
            figAxesMapRel=figAxesMapRel.getTuplesIndexedBy(...
                'figureGroupKey',figureGroupKeyList);
            %
            figurePropCMat=rel.toMat('fieldNameList',figureSetPropFieldNameList);
            axesPropCMat=rel.toMat('fieldNameList',axesSetPropFieldNameList);
            plotPropCMat=rel.toMat('fieldNameList',plotCreateFieldNameList);
            %
            axesUnqCMat=reshape(figAxesMapRel.axesKey,nEntries,nFuncs);
            %
            if nEntries>0
                %
                figureKeyCMat=cell(nEntries,nFuncs);
                hAxesMat=zeros(nEntries,nFuncs);
                hPlotCMat=cell(nEntries,nFuncs);
                for iEntry=1:nEntries
                    for iFunc=1:nFuncs
                        figureGroupKey=figureGroupKeyCMat{iEntry,iFunc};
                        axesKey=axesKeyCMat{iEntry,iFunc};
                        %
                        [hAxesMat(iEntry,iFunc),...
                            figureKeyCMat{iEntry,iFunc}]=...
                            self.getAxesHandle(figureGroupKey,...
                            figureSetPropFunc{iFunc},figurePropCMat(iEntry,:),...
                            axesUnqCMat{iEntry,iFunc},axesKey);
                        %
                    end
                end
                %
                for iEntry=1:nEntries
                    for iFunc=1:nFuncs
                        hPlotCMat{iEntry,iFunc}=setAxesProp(self,...
                            figureKeyCMat{iEntry,iFunc},...
                            axesKeyCMat{iEntry,iFunc},....
                            axesSetPropFunc{iFunc},axesPropCMat(iEntry,:));
                    end
                end
                %
                for iEntry=1:nEntries
                    for iFunc=1:nFuncs
                        hPlotCMat{iEntry,iFunc}=[hPlotCMat{iEntry,iFunc},...
                            plotCreateFunc{iFunc}(...
                            hAxesMat(iEntry,iFunc),...
                            plotPropCMat{iEntry,:})];
                    end
                end
                if isAxesPostPlotFuncSpec
                    for iEntry=1:nEntries
                        for iFunc=1:nFuncs
                            hPlotCMat{iEntry,iFunc}=...
                                [hPlotCMat{iEntry,iFunc},setAxesProp(self,...
                                figureKeyCMat{iEntry,iFunc},...
                                axesKeyCMat{iEntry,iFunc},....
                                axesPostPlotFunc{iFunc},...
                                axesPropCMat(iEntry,:))];
                        end
                    end
                end                
                %% figToAxesToPlotHMap
                %
                [figureKeyUList,~,indUVec]=unique(figureKeyCMat(:));
                nUniqueFigureKeys=length(figureKeyUList);
                for iFigureKey=1:nUniqueFigureKeys
                    figureKey=figureKeyUList{iFigureKey};
%                     self.figToAxesToPlotHMap(figureKey)=...
%                         modgen.containers.MapExtended();
                    isCurAxisVec=indUVec==iFigureKey;
                    axisKeyList=axesKeyCMat(isCurAxisVec);
                    plotHVecList=hPlotCMat(isCurAxisVec);
                    [axisUKeyList,~,indUAVec]=unique(axisKeyList);
                    nUAxis=length(axisUKeyList);
                    plotHandleUKeyList=cell(1,nUAxis);
                    if self.figToAxesToPlotHMap.isKey(figureKey);
                        axisToPlotMap=self.figToAxesToPlotHMap(figureKey);
                    else
                        axisToPlotMap=modgen.containers.MapExtended();
                        self.figToAxesToPlotHMap(figureKey)=axisToPlotMap;
                    end
                    for iAxes=1:nUAxis
                        plotHandleUKeyList{iAxes}=[plotHVecList{indUAVec==iAxes}];
                        axisKey=axisUKeyList{iAxes};
                        if axisToPlotMap.isKey(axisKey)
                            axisToPlotMap(axisKey)=...
                            [axisToPlotMap(axisKey),plotHandleUKeyList{iAxes}];
                        else
                            axisToPlotMap(axisKey)=plotHandleUKeyList{iAxes};
                        end
                    end
                end
                %% Check that all plotting handlers were returned by 
                % plotCreate function
                SFigToAxes=updateleaves(...
                   self.figToAxesToHMap.toStruct(),...
                   @(x,y)sort(findobj('Parent',x).'));
                SExpFigToAxes=updateleaves(...
                   self.figToAxesToPlotHMap.toStruct(),@(x,y)sort(x));
                [isOk,reportStr]=modgen.struct.structcompare(...
                   SExpFigToAxes,SFigToAxes);
                if ~isOk
                   throwerror('wrongInput',...
                       ['Not all figure handlers were registered, ',...
                       'reason %s'],reportStr);
                end
                %
                logger.debug('Storing graphs: done');
            else
                logger.debug('There is nothing to plot');
            end
        end
    end
    %
    methods (Static,Access=private)
        function resCMat=cellFunArray(rel,fHandleList,fieldNameList)
            nTuples=rel.getNTuples();
            nFuncs=length(fHandleList);
            nFields=length(fieldNameList);
            resCMat=cell(nTuples,nFuncs);
            %
            if nFields>0
                figArgList=rel.toArray('fieldNameList',fieldNameList,...
                    'groupByColumns',true);
                for iFunc=1:nFuncs
                    resCMat(:,iFunc)=cellfun(fHandleList{iFunc},figArgList{:},...
                        'UniformOutput',false);
                end
            else
                for iFunc=1:nFuncs
                    resCMat(:,iFunc)=repmat({fHandleList{iFunc}()},nTuples,1);
                end
            end
        end
        function varargout=checkFunc(varargin)
            import modgen.common.type.simple.checkcelloffunc;
            import modgen.common.throwerror;
            nElemVec=zeros(1,nargin);
            for iArg=1:nargin
                varargout{iArg}=checkcelloffunc(varargin{iArg});
                nElemVec(iArg)=numel(varargout{iArg});
            end
            nFuncs=max(nElemVec);
            isScalarVec=nElemVec==1;
            if ~all(isScalarVec|nElemVec==nFuncs);
                throwerror('wrongInput',...
                    'size of function arrrays should be the same');
            end
            varargout(isScalarVec)=cellfun(@(x)repmat(x,1,nFuncs),...
                varargout(isScalarVec),'UniformOutput',false);
        end
    end
    methods (Access=private)
        function hFigure=getFigureHandle(self,figureKey,...
                figureSetPropFunc,figurePropValList,indFigureGroup)
            persistent logger;
            import modgen.logging.log4j.Log4jConfigurator;
            if isempty(logger)
                logger=Log4jConfigurator.getLogger();
            end
            mp=self.figHMap;
            %
            if mp.isKey(figureKey)
                hFigure=mp(figureKey);
            else
                hFigure=figure();
                figureSetPropFunc(hFigure,figureKey,indFigureGroup,...
                    figurePropValList{:});
                logger.debug(['Figure ',figureKey,...
                    ' is created, hFigure=',num2str(hFigure)]);
                mp(figureKey)=hFigure; %#ok<NASGU>
            end
        end
        %%
        function [hAxes,figureKey]=getAxesHandle(self,figureGroupKey,...
                figureSetPropFunc,figurePropValList,...
                axesKeyList,axesKey)
            import modgen.logging.log4j.Log4jConfigurator;
            persistent logger;
            if isempty(logger)
                logger=Log4jConfigurator.getLogger();
            end
            %
            nMaxAxes=self.nMaxAxesCols*self.nMaxAxesRows;
            %
            nTotalAxis=length(axesKeyList);
            indTotalMetric=find(strcmp(axesKey,axesKeyList));
            indFigureGroup=ceil(indTotalMetric/nMaxAxes);
            figureKey=[figureGroupKey,...
                self.figureGroupKeySuffFunc(indFigureGroup)];
            %
            nFullFigures=fix(nTotalAxis/nMaxAxes);
            if indTotalMetric>nFullFigures*nMaxAxes
                nCurMetrics=rem(nTotalAxis-1,nMaxAxes)+1;
            else
                nCurMetrics=nMaxAxes;
            end
            %
            indMetric=rem(indTotalMetric-1,nMaxAxes)+1;
            %
            mp=self.getAxesHandleMap(figureKey);
            %
            if mp.isKey(axesKey)
                hAxes=mp(axesKey);
            else
                hFigure=self.getFigureHandle(figureKey,...
                    figureSetPropFunc,figurePropValList,indFigureGroup);
                %
                nSurfaceRows=min(self.nMaxAxesRows,nCurMetrics);
                nSurfaceColumns=ceil(nCurMetrics/nSurfaceRows);
                %
                logger.debug(['creating axes for figure: ',figureKey,...
                    ',size: ',mat2str([nSurfaceRows,nSurfaceColumns]),...
                    ',position: ',num2str(indMetric)]);
                %
                hAxes=subplot(nSurfaceRows,nSurfaceColumns,indMetric,...
                    'Parent',hFigure);
                %
                mp(axesKey)=hAxes; %#ok<NASGU>
            end
        end
        %%
        function hPlotVec=setAxesProp(self,figureKey,axesKey,axesSetPropFunc,...
                axesPropValList)
            mp=self.getAxesHandleMap(figureKey);
            hAxes=mp(axesKey);
            hPlotVec=feval(axesSetPropFunc,hAxes,axesKey,...
                axesPropValList{:});
            hold(hAxes,'on');
        end
        %%
        function res=getAxesHandleMap(self,figureKey)
            fm=self.figToAxesToHMap;
            if ~fm.isKey(figureKey)
                am=modgen.containers.MapExtended();
                fm(figureKey)=am; %#ok<NASGU>
            else
                am=fm(figureKey);
            end
            res=am;
        end
        %%
        function clearGraphicHandleMaps(self)
            mp=self.figHMap;
            mp.remove(mp.keys);
            %
            fm=self.figToAxesToHMap;
            fm.remove(fm.keys);
            %
            pm=self.figToAxesToPlotHMap;
            pm.remove(pm.keys);
            %
        end
    end
end
%%