classdef EllTubeProjBasic<gras.ellapx.smartdb.rels.EllTubeBasic&...
        gras.ellapx.smartdb.rels.EllTubeTouchCurveProjBasic
    properties (Constant,Hidden, GetAccess=protected)
        N_SPOINTS=90;
        REACH_TUBE_PREFIX='Reach';
        REG_TUBE_PREFIX='Reg';
    end
    methods
        function namePrefix=getReachTubeNamePrefix(self)
            % GETREACHTUBEANEPREFIX - return prefix of the reach tube
            %
            % Input:
            %   regular:
            %      self.
            namePrefix=self.REACH_TUBE_PREFIX;
        end
        function namePrefix=getRegTubeNamePrefix(self)
            % GETREGTUBEANEPREFIX - return prefix of the reg tube
            %
            % Input:
            %   regular:
            %      self.
            namePrefix=self.REG_TUBE_PREFIX;
        end
    end
    methods (Static = true, Access = protected)
        function [plotPropProcObj, plObj] = parceInput(plotFullFieldList,...
                varargin)
            import gras.ellapx.smartdb.PlotPropProcessor;
            import modgen.common.parseparext;
            
            plotSpecFieldListDefault = {'approxType'};
            colorFieldListDefault = {'approxType'};
            alphaFieldListDefault = {'approxType'};
            widthFieldListDefault = {'approxType'};
            fillFieldListDefault = {'approxType'};
            
            fGetPatchColorDefault =...
                @(approxType)getPatchColorByApxType(approxType);
            fGetAlphaDefault =...
                @(approxType)getPatchAlphaByApxType(approxType);
            fGetLineWidthDefault = ...
                @(approxType)(2);
            fGetFillDefault = ...
                @(approxType)(true);
            
            [reg, isRegSpec, fGetColor, fGetAlpha, fGetLineWidth,...
                fGetFill, colorFieldList, alphaFieldList, widthFieldList,...
                fillFieldList,...
                plotSpecFieldList, ~, ~, ~, ~, isColorList, isAlphaList,...
                isFillList, isWidthList, isPlotSpecFieldList] = ...
                parseparext(varargin, {'fGetColor', 'fGetAlpha',...
                'fGetLineWidth', 'fGetFill', 'colorFieldList',...
                'alphaFieldList',...
                'lineWidthFieldList', 'fillFieldList', 'plotSpecFieldList';...
                fGetPatchColorDefault, fGetAlphaDefault,...
                fGetLineWidthDefault,fGetFillDefault,colorFieldListDefault,...
                alphaFieldListDefault, widthFieldListDefault,...
                fillFieldListDefault, plotSpecFieldListDefault;...
                'isfunction(x)', 'isfunction(x)',...
                'isfunction(x)', 'isfunction(x)',...
                'iscell(x)', 'iscell(x)', 'iscell(x)',...
                'iscell(x)', 'iscell(x)'},...
                [0 1],...
                'regCheckList',...
                {@(x)isa(x,'smartdb.disp.RelationDataPlotter')},...
                'regDefList', cell(1,1));
            
            checkListOfField();
            
            plotPropProcObj = PlotPropProcessor(plotFullFieldList,...
                fGetColor, colorFieldList, fGetLineWidth, widthFieldList,...
                fGetFill, fillFieldList, fGetAlpha, alphaFieldList);
            
            if ~isRegSpec
                plObj=smartdb.disp.RelationDataPlotter;
            else
                plObj=reg{1};
            end
            
            function checkListOfField()
                if isPlotSpecFieldList
                    if ~isColorList
                        colorFieldList = plotSpecFieldList;
                    end
                    if ~isAlphaList
                        alphaFieldList = plotSpecFieldList;
                    end
                    if ~isWidthList
                        widthFieldList = plotSpecFieldList;
                    end
                    if ~isFillList
                        fillFieldList = plotSpecFieldList;
                    end
                end
            end
            
            function patchColor = getPatchColorByApxType(approxType)
                import gras.ellapx.enums.EApproxType;
                switch approxType
                    case EApproxType.Internal
                        patchColor = [0 1 0];
                    case EApproxType.External
                        patchColor = [0 0 1];
                    otherwise,
                        throwerror('wrongInput',...
                            'ApproxType=%s is not supported',char(approxType));
                end
            end
            
            function patchAlpha = getPatchAlphaByApxType(approxType)
                import gras.ellapx.enums.EApproxType;
                switch approxType
                    case EApproxType.Internal
                        patchAlpha=0.1;
                    case EApproxType.External
                        patchAlpha=0.3;
                    otherwise,
                        throwerror('wrongInput',...
                            'ApproxType=%s is not supported',char(approxType));
                end
            end
        end
    end
    
    methods (Access=protected)
        function dependencyFieldList=getTouchCurveDependencyFieldList(~)
            dependencyFieldList={'sTime','lsGoodDirOrigVec',...
                'projType','projSTimeMat','MArray'};
        end
        
        function patchColor = getRegTubeColor(~, ~)
            patchColor = [1 0 0];
        end
        
        function patchAlpha = getRegTubeAlpha(~, ~)
            patchAlpha = 1;
        end
        %
        function hVec = plotCreateReachTubeFunc(self, plotPropProcessorObj,...
                hAxes,projType,...
                timeVec, lsGoodDirOrigVec, ltGoodDirMat,sTime,...
                xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
                ltGoodDirNormOrigVec, approxType, QArray, aMat, MArray,...
                varargin)
            
            import gras.ellapx.enums.EApproxType;
            %
            tubeNamePrefix = self.REACH_TUBE_PREFIX;
            hVec = plotCreateGenericTubeFunc(self,...
                plotPropProcessorObj, hAxes, projType,...
                timeVec, lsGoodDirOrigVec, ltGoodDirMat, sTime,...
                xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
                ltGoodDirNormOrigVec,...
                approxType, QArray, aMat, tubeNamePrefix);
            
            axis(hAxes, 'tight');
            axis(hAxes, 'normal');
            if approxType == EApproxType.External
                hTouchVec=self.plotCreateTubeTouchCurveFunc(hAxes,...
                    plotPropProcessorObj, projType,...
                    timeVec, lsGoodDirOrigVec, ltGoodDirMat, sTime,...
                    xTouchCurveMat,xTouchOpCurveMat, ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec, approxType, QArray, aMat, MArray,...
                    varargin{:});
                hVec=[hVec,hTouchVec];
            end
            if approxType == EApproxType.Internal
                hAddVec = plotCreateRegTubeFunc(self, plotPropProcessorObj,...
                    hAxes, projType,...
                    timeVec, lsGoodDirOrigVec, ltGoodDirMat,sTime,...
                    xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec, approxType, QArray, aMat, MArray);
                hVec=[hVec, hAddVec];
            end
        end
        function hVec = plotCreateRegTubeFunc(self, plotPropProcessorObj,...
                hAxes, projType,...
                timeVec, lsGoodDirOrigVec, ltGoodDirMat, sTime,...
                xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
                ltGoodDirNormOrigVec,...
                approxType,~,aMat,MArray,...
                varargin)
            import gras.ellapx.enums.EApproxType;
            %
            if approxType == EApproxType.Internal
                tubeNamePrefix = self.REG_TUBE_PREFIX;
                hVec = self.plotCreateGenericTubeFunc(plotPropProcessorObj,...
                    hAxes,  projType,...
                    timeVec, lsGoodDirOrigVec, ltGoodDirMat, sTime,...
                    xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,...
                    approxType, MArray, zeros(size(aMat)), tubeNamePrefix);
            else
                hVec=[];
            end
        end
        function hVec = plotCreateGenericTubeFunc(self,...
                plotPropProcessorObj, hAxes, varargin)
            
            [~, timeVec, lsGoodDirOrigVec, ~, sTime,...
                ~, ~, ~,~, approxType, QArray, aMat,...
                tubeNamePrefix] = deal(varargin{:});
            
            nSPoints=self.N_SPOINTS;
            goodDirStr=self.goodDirProp2Str(lsGoodDirOrigVec,sTime);
            patchName=sprintf('%s Tube, %s: %s',tubeNamePrefix,...
                char(approxType),goodDirStr);
            [vMat,fMat]=gras.geom.tri.elltubetri(...
                QArray,aMat,timeVec,nSPoints);
            nTimePoints=length(timeVec);
            
            patchColorVec = plotPropProcessorObj.getColor(varargin(:));
            patchAlpha = plotPropProcessorObj.getTransparency(varargin(:));
            
            if nTimePoints==1
                nVerts=size(vMat,1);
                indVertVec=[1:nVerts,1];
                hVec=line('Parent',hAxes,'xData',vMat(indVertVec,1),...
                    'yData',vMat(indVertVec,2),...
                    'zData',vMat(indVertVec,3),'Color',patchColorVec);
                view(hAxes,[90 0 0]);
            else
                hVec=patch('FaceColor', 'interp', 'EdgeColor', 'none',...
                    'DisplayName', patchName,...
                    'FaceAlpha', patchAlpha,...
                    'FaceVertexCData', repmat(patchColorVec,size(vMat,1),1),...
                    'Faces',fMat,'Vertices',vMat,'Parent',hAxes,...
                    'EdgeLighting','phong','FaceLighting','phong');
                material('metal');
            end
            hold(hAxes,'on');
        end
        function hVec=axesSetPropRegTubeFunc(self,hAxes,axesName,projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            set(hAxes,'PlotBoxAspectRatio',[3 1 1]);
            hVec=self.axesSetPropBasic(hAxes,axesName,projSTimeMat,varargin{:});
        end
    end
    methods (Access=protected)
        function checkTouchCurves(self,fullRel)
            import gras.ellapx.enums.EProjType;
            TIGHT_PROJ_TOL=1e-15;
            self.checkTouchCurveVsQNormArray(fullRel,fullRel,...
                @(x)max(x-1),...
                ['any touch line''s projection should be within ',...
                'its tube projection'],@(x,y)x==y);
            isTightDynamicVec=...
                (fullRel.lsGoodDirNorm>=1-TIGHT_PROJ_TOL)&...
                (fullRel.projType==EProjType.DynamicAlongGoodCurve);
            rel=fullRel.getTuples(isTightDynamicVec);
            self.checkTouchCurveVsQNormArray(rel,rel,...
                @(x)abs(x-1),...
                ['for dynamic tight projections touch line should be ',...
                'on the boundary of tube''s projection'],...
                @(x,y)x==y);
        end
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            import gras.gen.SquareMatVector;
            %
            checkDataConsistency@gras.ellapx.smartdb.rels.EllTubeBasic(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.EllTubeTouchCurveProjBasic(self);
            if self.getNTuples()>0
                checkFieldList={'dim',...
                    'projSTimeMat','projType','ltGoodDirNormOrigVec',...
                    'lsGoodDirNormOrig','lsGoodDirOrigVec','timeVec'};
                %
                [isOkList,errTagList,reasonList]=...
                    self.applyTupleGetFunc(@checkTuple,checkFieldList,...
                    'UniformOutput',false);
                %
                isOkVec=vertcat(isOkList{:});
                if ~all(isOkVec)
                    indFirst=find(~isOkVec,1,'first');
                    errTag=errTagList{indFirst};
                    reasonStr=reasonList{indFirst};
                    throwerror(['wrongInput:',errTag],...
                        ['Tuples with indices %s have inconsistent ',...
                        'values, reason: ',reasonStr],...
                        mat2str(find(~isOkVec)));
                end
            end
            function [isOk,errTagStr,reasonStr] = checkTuple(dim,...
                    projSTimeMat, projType, ltGoodDirNormOrigVec,...
                    lsGoodDirNormOrig, lsGoodDirOrigVec, timeVec)
                errTagStr='';
                import modgen.common.type.simple.lib.*;
                reasonStr='';
                nDims=dim;
                nFDims=length(lsGoodDirOrigVec);
                nPoints=length(timeVec);
                isOk=ismatrix(projSTimeMat)&&size(projSTimeMat,2)==nFDims&&...
                    numel(projType)==1&&...
                    isrow(ltGoodDirNormOrigVec)&&...
                    numel(ltGoodDirNormOrigVec)==nPoints&&...
                    iscol(lsGoodDirOrigVec)&&...
                    numel(lsGoodDirNormOrig)==1&&...
                    size(projSTimeMat,1)==nDims;
                if ~isOk
                    reasonStr='Fields have inconsistent sizes';
                    errTagStr='badSize';
                end
            end
        end
    end
    methods
        function plObj=plot(self, varargin)
            % PLOT - displays ellipsoidal tubes using the specified
            %   RelationDataPlotter
            %
            % Input:
            %   regular:
            %       self:
            %   optional:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
            %           object used for displaying ellipsoidal tubes
            %   properties:
            %       fGetColor: function_handle[1, 1] -
            %           function that specified colorVec for
            %           ellipsoidal tubes
            %       fGetAlpha: function_handle[1, 1] -
            %           function that specified transparency
            %           value for ellipsoidal tubes
            %       fGetLineWidth: function_handle[1, 1] -
            %           function that specified lineWidth for good curves
            %       fGetFill: function_handle[1, 1] - this
            %           property not used in this version
            %       colorFieldList: cell[nColorFields, ] of char[1, ] -
            %           list of parameters for color function
            %       alphaFieldList: cell[nAlphaFields, ] of char[1, ] -
            %           list of parameters for transparency function
            %       lineWidthFieldList: cell[nLineWidthFields, ]
            %           of char[1, ] - list of parameters for lineWidth
            %           function
            %       fillFieldList: cell[nIsFillFields, ] of char[1, ] -
            %           list of parameters for fill function
            %       plotSpecFieldList: cell[nPlotFields, ] of char[1, ] -
            %           defaul list of parameters. If for any function in
            %           properties not specified list of parameters,
            %           this one will be used
            %
            % Output:
            %   plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
            %           object used for displaying ellipsoidal tubes
            %
            % $Author:
            % Peter Gagarinov  <pgagarinov@gmail.com>
            % Artem Grachev <grachev.art@gmail.com>
            % $Date: May-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013$
            %
            import gras.ellapx.smartdb.rels.EllTubeProjBasic;
            import modgen.logging.log4j.Log4jConfigurator;
            
            PLOT_FULL_FIELD_LIST =...
                {'projType','timeVec','lsGoodDirOrigVec',...
                'ltGoodDirMat','sTime','xTouchCurveMat',...
                'xTouchOpCurveMat','ltGoodDirNormVec',...
                'ltGoodDirNormOrigVec','approxType','QArray','aMat','MArray'};
            
            [plotPropProcObj, plObj] = gras.ellapx.smartdb...
                .rels.EllTubeProjBasic.parceInput(PLOT_FULL_FIELD_LIST,...
                varargin{:});
            
            if self.getNTuples()>0
                %
                fGetReachGroupKey=...
                    @(varargin)figureGetNamedGroupKeyFunc(self,...
                    'reachTube',varargin{:});
                fGetRegGroupKey=...
                    @(varargin)figureGetNamedGroupKeyFunc(self,...
                    'regTube',varargin{:});
                %
                fSetReachFigProp=@(varargin)figureNamedSetPropFunc(self,...
                    'reachTube',varargin{:});
                fSetRegFigProp=@(varargin)figureNamedSetPropFunc(self,...
                    'regTube',varargin{:});
                %
                fGetTubeAxisKey=@(varargin)axesGetKeyTubeFunc(self,varargin{:});
                fGetCurveAxisKey=@(varargin)axesGetKeyGoodCurveFunc(self,varargin{:});
                %
                fSetTubeAxisProp=@(varargin)axesSetPropTubeFunc(self,varargin{:});
                fSetCurveAxisProp=@(varargin)axesSetPropGoodCurveFunc(self,...
                    varargin{:});
                fSetRegTubeAxisProp=@(varargin)axesSetPropRegTubeFunc(self,varargin{:});
                %
                fPlotReachTube=@(varargin)plotCreateReachTubeFunc(self,...
                    plotPropProcObj, varargin{:});
                fPlotRegTube=@(varargin)plotCreateRegTubeFunc(self,varargin{:});
                fPlotCurve=@(varargin)plotCreateGoodDirFunc(self,...
                    plotPropProcObj, varargin{:});
                %
                isEmptyRegVec=cellfun(@(x)all(x(:) == 0), self.MArray);
                
                plotInternal(isEmptyRegVec,false);
                plotInternal(~isEmptyRegVec,true);
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
            end
            function plotInternal(isTupleVec,isRegPlot)
                if all(isTupleVec)
                    rel=self;
                else
                    rel=self.getTuples(isTupleVec);
                end
                fGetGroupKeyList = {fGetReachGroupKey, fGetReachGroupKey};
                fSetFigPropList = {fSetReachFigProp, fSetReachFigProp};
                fGetAxisKeyList = {fGetTubeAxisKey, fGetCurveAxisKey};
                fSetAxiPropList = {fSetTubeAxisProp, fSetCurveAxisProp};
                fPlotList = {fPlotReachTube, fPlotCurve};
                if isRegPlot
                    fGetGroupKeyList = [fGetGroupKeyList,{fGetRegGroupKey}];
                    fSetFigPropList = [fSetFigPropList,{fSetRegFigProp}];
                    fGetAxisKeyList = [fGetAxisKeyList,{fGetTubeAxisKey}];
                    fSetAxiPropList = [fSetAxiPropList,{fSetRegTubeAxisProp}];
                    fPlotList = [fPlotList, {fPlotRegTube}];
                end
                
                plObj.plotGeneric(rel,...
                    fGetGroupKeyList,...
                    {'projType','projSTimeMat','sTime','lsGoodDirOrigVec'},...
                    fSetFigPropList,...
                    {'projType','projSTimeMat','sTime'},...
                    fGetAxisKeyList,...
                    {'projType','projSTimeMat'},...
                    fSetAxiPropList,...
                    {'projSTimeMat'},...
                    fPlotList,...
                    {'projType','timeVec','lsGoodDirOrigVec',...
                    'ltGoodDirMat','sTime','xTouchCurveMat',...
                    'xTouchOpCurveMat','ltGoodDirNormVec',...
                    'ltGoodDirNormOrigVec','approxType','QArray','aMat','MArray'});
            end
        end
        function plObj = plotExt(self,varargin)
            % PLOTExt - plots external approximation of ellTube.
            %
            %
            % Usage:
            %       obj.plotExt() - plots external approximation of ellTube.
            %       obj.plotExt('Property',PropValue,...) - plots external approximation
            %                                               of ellTube with setting
            %                                               properties.
            %
            % Input:
            %   regular:
            %       obj:  EllTubeProj: EllTubeProj object
            %   optional:
            %       colorSpec: char[1,1] - color specification code, can be 'r','g',
            %                    etc (any code supported by built-in Matlab function).
            %
            %   properties:
            %
            %       'fill': logical[1,1]  -
            %               if true, approximation in 2D will be filled with color.
            %        Default value is false.
            %       'lineWidth': double[1,1]  -
            %                    line width for  2D plots. Default value is 1.
            %       'color': double[1,3] -
            %                sets default color in the form [x y z].
            %                   Default value is [0.5 0.5 0.5].
            %       'shade': double[1,1] -
            %       level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
            %                Default value is 0.4.
            %
            %       'relDataPlotter' - relation data plotter object.
            %       'showDiscrete':logical[1,1]  -
            %           if true, approximation in 3D will be filled in every time slice
            %       'numPointsInOneTime': double[1,1] -
            %           number of points in every time slice.
            % Output:
            %   regular:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
            %       data plotter object.
            %
            
            
            % $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <30 January  2013> $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Cybernetics,
            %            System Analysis Department 2013 $
            import gras.ellapx.enums.EApproxType;
            approxType = gras.ellapx.enums.EApproxType.External;
            plObj = self.getTuplesFilteredBy(...
                'approxType', approxType)...
                .plotExtOrInternal(@calcPointsExt,varargin{:});
        end
        function plObj = plotInt(self,varargin)
            % PLOTINT - plots internal approximation of ellTube.
            %
            %
            % Usage:
            %       obj.plotInt() - plots internal approximation of ellTube.
            %       obj.plotInt('Property',PropValue,...) - plots internal approximation
            %                                               of ellTube with setting
            %                                               properties.
            %
            % Input:
            %   regular:
            %       obj:  EllTubeProj: EllTubeProj object
            %   optional:
            %       colorSpec: char[1,1] - color specification code, can be 'r','g',
            %                    etc (any code supported by built-in Matlab function).
            %
            %   properties:
            %
            %       'fill': logical[1,1]  -
            %               if true, approximation in 2D will be filled with color.
            %        Default value is false.
            %       'lineWidth': double[1,1]  -
            %                    line width for  2D plots. Default value is 1.
            %       'color': double[1,3] -
            %                sets default color in the form [x y z].
            %                   Default value is [0.5 0.5 0.5].
            %       'shade': double[1,1] -
            %       level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
            %                Default value is 0.4.
            %
            %       'relDataPlotter' - relation data plotter object.
            %       'showDiscrete':logical[1,1]  -
            %           if true, approximation in 3D will be filled in every time slice
            %       'numPointsInOneTime': double[1,1] -
            %           number of points in every time slice.
            % Output:
            %   regular:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
            %       data plotter object.
            %
            
            
            % $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <30 January  2013> $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Cybernetics,
            %            System Analysis Department 2013 $
            import gras.ellapx.enums.EApproxType;
            approxType = gras.ellapx.enums.EApproxType.Internal;
            plObj = self.getTuplesFilteredBy(...
                'approxType', approxType)...
                .plotExtOrInternal(@calcPointsInt,varargin{:});
        end
    end
    methods (Access = private)
        function plObj = plotExtOrInternal(self,fCalcPoints,varargin)
            import modgen.common.throwerror;
            import gras.geom.tri.elltube2tri;
            import gras.geom.tri.elltubediscrtri;
            import gras.ellapx.smartdb.rels.EllTubeProjBasic;
            import modgen.logging.log4j.Log4jConfigurator;
            [reg,~,isShowDiscrete,nPlotPoints]=...
                modgen.common.parseparext(varargin,...
                {'showDiscrete','numPointsInOneTime' ;...
                false, 600;
                @(x)isa(x,'logical'),@(x)isa(x,'double')});
            
            
            checkDimensions(self);
            %             checkCenterVecAndTimeVec(self);
            dim = self.dim(1);
            if (dim == 3) && ( size(self.timeVec{1},2) ~= 1)
                throwerror('wrongDim',...
                    '3d Tube can be displayed only after cutting');
            end
            
            
            
            
            PLOT_FULL_FIELD_LIST =...
                {'projType','timeVec','lsGoodDirOrigVec',...
                'ltGoodDirMat','sTime','xTouchCurveMat',...
                'xTouchOpCurveMat','ltGoodDirNormVec',...
                'ltGoodDirNormOrigVec','approxType','QArray','aMat',...
                'MArray','dim'};
            %
            [plotPropProcObj, plObj] = gras.ellapx.smartdb...
                .rels.EllTubeProjBasic.parceInput(PLOT_FULL_FIELD_LIST,...
                reg{:});
            
            %
            %
            if self.getNTuples()>0
                %                 %
                fGetReachGroupKey=...
                    @(varargin)figureGetNamedGroupKey2Func(self,...
                    'reachTube',varargin{:});
                %
                fSetReachFigProp=@(varargin)figureNamedSetPropFunc(self,...
                    'reachTube',varargin{:});
                %
                fGetTubeAxisKey=@(varargin)axesGetKeyTubeFunc(self,varargin{:});
                %
                fSetTubeAxisProp=@(varargin)axesSetPropTubeFunc(self,varargin{:});
                %
                if isShowDiscrete
                    fPlotReachTube=...
                        @(varargin)plotCreateReachApproxTubeFunc(...
                        @elltubediscrtri,fCalcPoints,@patch,...
                        nPlotPoints, plotPropProcObj, varargin{:});
                else
                    fPlotReachTube=...
                        @(varargin)plotCreateReachApproxTubeFunc(...
                        @elltube2tri,fCalcPoints,@patch,...
                        nPlotPoints, plotPropProcObj, varargin{:});
                end
                fPlotCenter = ...
                    @(varargin) plotCenter2dCase(self,...
                    @(varargin)patch(varargin{:},'marker','*'),...
                    plotPropProcObj, varargin{:});%
                
                
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
            end
            rel=smartdb.relations.DynamicRelation(self);
            rel.groupBy({'projSTimeMat'});
            fGetGroupKeyList = {fGetReachGroupKey};
            fSetFigPropList = {fSetReachFigProp};
            fGetAxisKeyList = {fGetTubeAxisKey};
            fSetAxiPropList = {fSetTubeAxisProp};
            fPlotList = {fPlotReachTube};
            if (fDim(self) == 2)
                fGetGroupKeyList = [fGetGroupKeyList,{fGetReachGroupKey}];
                fSetFigPropList = [fSetFigPropList,{fSetReachFigProp}];
                fGetAxisKeyList = [fGetAxisKeyList,{fGetTubeAxisKey}];
                fSetAxiPropList = [fSetAxiPropList,{fSetTubeAxisProp}];
                fPlotList = [fPlotList,{fPlotCenter}];
            end
            plObj.plotGeneric(rel,...
                fGetGroupKeyList,...
                {'projType','projSTimeMat','sTime','lsGoodDirOrigVec'},...
                fSetFigPropList,...
                {'projType','projSTimeMat','sTime'},...
                fGetAxisKeyList,...
                {'projType','projSTimeMat'},...
                fSetAxiPropList,...
                {'projSTimeMat'},...
                fPlotList,...
                {'projType','timeVec','lsGoodDirOrigVec',...
                'ltGoodDirMat','sTime','xTouchCurveMat',...
                'xTouchOpCurveMat','ltGoodDirNormVec',...
                'ltGoodDirNormOrigVec','approxType','QArray','aMat',...
                'MArray','dim','calcPrecision'});
            
            
            
            
            
            %             [plObj,~,isHold]= plotgeombodyarr(...
            %                 @(x)isa(x,'gras.ellapx.smartdb.rels.EllTubeProj'),...
            %                 @fDim,...
            %                 @(x)fCalcBodyArr(x,@elltube2tri,appType,nPlotPoints),...
            %                 @patch,self,reg{:},'color',colorVec,'isTitle',true,...
            %                 'isLabel',true);
            %             if (isCenter)
            %                 reg = modgen.common.parseparext(reg,...
            %                     {'relDataPlotter','priorHold','postHold';...
            %                     [],[],[];
            %                     });
            %                 plObj= plotgeombodyarr(...
            %                     @(x)isa(x,'gras.ellapx.smartdb.rels.EllTubeProj'),...
            %                     @fDim,...
            %                     @fCalcCenterTriArr,...
            %                     @(varargin)patch(varargin{:},'marker','*'),...
            %                     self,reg{:},'color',colorVec,'relDataPlotter',plObj,...
            %                     'priorHold',...
            %                     true,'postHold',isHold,'isTitle',true,...
            %                     'isLabel',true);
            %             end
            %             if (isShowDiscrete)
            %                 plObj= plotgeombodyarr(...
            %                     @(x)isa(x,'gras.ellapx.smartdb.rels.EllTubeProj'),...
            %                     @fDim,@(x)fCalcBodyArr(x,@elltubediscrtri,appType,...
            %                     nPlotPoints),...
            %                     @patch,...
            %                     self,'r','relDataPlotter',plObj, 'priorHold',...
            %                     true,'postHold',isHold,'isTitle',true,...
            %                     'isLabel',true);
            %             end
        end
    end
    
end
function figureGroupKeyName=figureGetNamedGroupKey2Func(~,...
    groupName,projType,projSTimeMat,...
    varargin)
import gras.ellapx.enums.EProjType;
figureGroupKeyName=[groupName,'_',lower(char(projType)),...
    '_sp[',num2str(projSTimeMat(:,1)','%g '),';',...
    num2str(projSTimeMat(:,2)','%g '),']'];

end
function checkDimensions(self)
import modgen.common.throwerror;
tubeArrDims = self.dim;
mDim    = min(tubeArrDims);
nDim    = max(tubeArrDims);
if mDim ~= nDim
    throwerror('dimMismatch', ...
        'Objects must have the same dimensions.');
end
if (mDim < 2) || (nDim > 3)
    throwerror('wrongDim','object dimension can be  2 or 3');
end
end
function checkCenterVecAndTimeVec(aMat,timeVec)
import modgen.common.throwerror;
nTubes = numel(aMat);
aMatCell = aMat;
timeVec = timeVec{1};
for iTime = 1:size(timeVec,2)
    centerVec = aMat{1}(:,iTime);
    for iTube = 2:nTubes
        if (aMatCell{iTube}(:,iTime)~=centerVec)
            throwerror('differentCenterVec', ...
                'Center vectors must be equal.');
        end
    end
end
for iTube = 2:numel(nTubes)
    if (timeVec{iTube}~=timeVec)
        throwerror('differentTimeVec', ...
            'Time vectors must be equal.');
    end
end
end
function dimOut = fDim(obj)
dim = obj.dim(1);
if (dim == 3) || (size(obj.timeVec{1},2) >1)
    dimOut = 3;
else
    dimOut = 2;
end
end

function hVec =...
    plotCenter2dCase(fPatch,plotPropProcObj,hAxes,projType,...
    timeVec, lsGoodDirOrigVec, ltGoodDirMat,sTime,...
    xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
    ltGoodDirNormOrigVec, approxType, QArray, aMat, MArray,dim,...
    calcPrecision, varargin)
hVec = [];
prefixTitl =  'Reach tube cut at time';
xCMat = {aMat{1}(:,1)};
fCMat = {[1 1]};
% xlab = ['[' obj.goodDirProp2Str(1,1) ']'];
% ylab = ['[' obj.goodDirProp2Str(2,1) ']'];
% zlab = '';
titlStr = [prefixTitl  num2str(obj.timeVec{1})];
end

function hVec =...
    plotCreateReachApproxTubeFunc(fTri,fCalcPoints,fPatch,...
    nPlotPoints,plotPropProcObj,hAxes,projType,...
    timeVec, lsGoodDirOrigVec, ltGoodDirMat,sTime,...
    xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
    ltGoodDirNormOrigVec, approxType, QArray, aMat, MArray,dim,...
    calcPrecision, varargin)
hVec = [];
prefixTitl =  'Reach tube cut at time';
[xMat,vMat] = calcPoints(fTri,fCalcPoints,...
    nPlotPoints,...
    timeVec,  QArray, aMat,dim,...
    calcPrecision);
if nTimePoints == 1
    titlStr = [prefixTitl  num2str(timeVec)];
    %     xlab = ['[' obj.goodDirProp2Str(1,1) ']'];
    %     ylab = ['[' obj.goodDirProp2Str(2,1) ']'];
    %     if size(lGridMat, 1) == 3
    %         zlab =  ['[' obj.goodDirProp2Str(3,1) ']'];
    %     else
    %         zlab = '';
    %     end
else
    titlStr = 'reach tube';
    %     ylab = ['[' obj.goodDirProp2Str(1,1) ']'];
    %     zlab = ['[' obj.goodDirProp2Str(2,1) ']'];
    %     xlab = 't';
    
end
end
function [vMat,fMat] = calcPoints(fTri,fCalcPoints,...
    nPlotPoints,...
    timeVec,...
    QArray, aMat, dim,...
    calcPrecision, varargin)


nDims = dim(1);
checkCenterVecAndTimeVec(aMat,timeVec);
[lGridMat, fMat] = gras.geom.tri.spheretriext(nDims,...
    nPlotPoints);
lGridMat = lGridMat';
timeVec = timeVec{1};
nDir = size(lGridMat, 2);
nTimePoints = size(timeVec, 2);
qArr = cat(4, QArray{:});
absTol = max(calcPrecision);
%
if nTimePoints == 1
    xMat = fCalcPoints(nDir,lGridMat,nDims,squeeze(qArr(:,:,1,:)),...
        aMat{1}(:,1),absTol);
    vMat = [xMat xMat(:,1)];
    
else
    fMat = fTri(nDir,nTimePoints);
    xMat = zeros(3,nDir*nTimePoints);
    for iTime = 1:nTimePoints
        xSliceTimeVec = fCalcPoints(nDir,lGridMat,nDims,...
            squeeze(qArr(:,:,iTime,:)),...
            obj.aMat{1}(:,iTime),absTol);
        xMat(:,(iTime-1)*nDir+1:iTime*nDir) =...
            [timeVec(iTime)*ones(1,nDir); xSliceTimeVec];
    end
    vMat = xMat;
end
end


function xMat = calcPointsInt(nDir,lGridMat,nDims,qArr,...
    centerVec,absTol)
import gras.geom.ell.rhomat
xMat = zeros(nDims,nDir);
tubeNum = size(qArr,3);

supAllVec = zeros(tubeNum,nDir);
supVecAllCMat = cell(tubeNum,nDir);
for iTube = 1:tubeNum
    curEllMat = qArr(:,:,iTube);
    [supMat, bpMat] = rhomat(curEllMat,...
        lGridMat,absTol);
    supAllVec(iTube,:) = supMat;
    for indBP=1:size(supVecAllCMat,2)
        supVecAllCMat{iTube,indBP} = bpMat(:,indBP);
    end
end
[~,xInd] = max(supAllVec,[],1);
for iDir = 1:size(xInd,2)
    xMat(:,iDir) = supVecAllCMat{xInd(iDir),iDir}...
        +centerVec;
end
end
function xMat = calcPointsExt(nDir,lGridMat,nDims,qArr,...
    centerVec,~)
xMat = zeros(nDims,nDir);
tubeNum = size(qArr,3);

distAllMat = zeros(tubeNum,nDir);
BoundaryPointsAllCMat = cell(tubeNum,nDir);
for iDir = 1:nDir
    lVec = lGridMat(:,iDir);
    distVec = gras.gen.SquareMatVector...
        .lrDivideVec(qArr,...
        lVec);
    distAllMat(:,iDir) = distVec;
    for iTube = 1:tubeNum
        BoundaryPointsAllCMat{iTube,iDir} = lVec/realsqrt(distVec(iTube));
    end
end
[~,xInd] = max(distAllMat,[],1);
for iDir = 1:size(xInd,2)
    xMat(:,iDir) = BoundaryPointsAllCMat{xInd(iDir),iDir}...
        +centerVec;
end

end
