classdef EllTubeProjBasic<gras.ellapx.smartdb.rels.EllTubeBasic&...
        gras.ellapx.smartdb.rels.EllTubeTouchCurveProjBasic
    properties (Constant,Hidden, GetAccess=protected)
        N_SPOINTS=90;
        REACH_TUBE_PREFIX='Reach';
        REG_TUBE_PREFIX='Reg';
    end
    methods (Access = protected)
        function fieldList=getDetermenisticSortFieldList(~)        
            fieldList={'projSTimeMat','projType',...
                'sTime','lsGoodDirOrigVec','approxType'};
        end        
        function fieldsList = getSFieldsList(self)
            import  gras.ellapx.smartdb.F;
            ellTubeBasicList = self.getSFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldsList=[ellTubeBasicList;...
                F().getNameList({'LS_GOOD_DIR_NORM_ORIG';...
                'LS_GOOD_DIR_ORIG_VEC'})];
        end
        function fieldsList = getTFieldsList(self)
            import  gras.ellapx.smartdb.F;
            ellTubeBasicList = self.getTFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldsList=[ellTubeBasicList;F().getNameList(...
                {'LT_GOOD_DIR_NORM_ORIG_VEC';'LT_GOOD_DIR_ORIG_MAT'})];
        end
        function fieldsList = getScalarFieldsList(self)
            import  gras.ellapx.smartdb.F;
            ellTubeBasicList = self.getScalarFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldsList=[ellTubeBasicList;...
                F().getNameList({'LS_GOOD_DIR_NORM_ORIG'})];
        end
        function fieldList=getNotComparedFieldsList(self)
            import  gras.ellapx.smartdb.F;
            fieldList = self.getNotComparedFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldList=[fieldList;F().getNameList(...
                {'LT_GOOD_DIR_NORM_ORIG_VEC';'LS_GOOD_DIR_NORM_ORIG'})];  
        end        
    end
    methods
        function fieldsList = getNoCatOrCutFieldsList(self)
            import  gras.ellapx.smartdb.F;
            ellTubeBasicList = self.getNoCatOrCutFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldsList=[ellTubeBasicList;...
                F().getNameList({'LS_GOOD_DIR_NORM_ORIG';...
                'LS_GOOD_DIR_ORIG_VEC';'PROJ_S_MAT';'PROJ_TYPE'})];
        end
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
        function SData = getInterpDataInternal(self, newTimeVec)
            import gras.ellapx.smartdb.F;
            SData = getInterpDataInternal@...
                gras.ellapx.smartdb.rels.EllTubeBasic(self,newTimeVec);
            [SData.projSTimeMat, ...
                lsGoodDirNormOrigList, ...
                SData.ltGoodDirNormOrigVec,...
                SData.ltGoodDirOrigMat,...
                SData.lsGoodDirOrigVec,SData.ltGoodDirOrigProjMat,...
                SData.ltGoodDirNormOrigProjVec] = ...
                cellfun(@fInterpTuple,SData.ltGoodDirNormOrigVec,...
                SData.ltGoodDirOrigMat,SData.projArray,self.timeVec,...
                num2cell(SData.indSTime),SData.ltGoodDirOrigProjMat,...
                SData.ltGoodDirNormOrigProjVec,'UniformOutput',false);
            SData.lsGoodDirNormOrig=vertcat(lsGoodDirNormOrigList{:});
            %
            function [projSTimeMat,lsGoodDirNormOrig,ltGoodDirNormOrigVec,...
                    ltGoodDirOrigMat,lsGoodDirOrigVec,...
                    ltGoodDirOrigProjMat,ltGoodDirNormOrigProjVec] = ...
                    fInterpTuple(ltGoodDirNormOrigVec,ltGoodDirOrigMat,...
                    projArray,timeVec,indSTime,...
                    ltGoodDirOrigProjMat,ltGoodDirNormOrigProjVec)
                ltGoodDirOrigMat=simpleInterp(ltGoodDirOrigMat,true);
                ltGoodDirNormOrigVec=interp1(timeVec,...
                    ltGoodDirNormOrigVec,newTimeVec,'nearest','extrap');
                projArray=simpleInterp(projArray);
                %
                lsGoodDirOrigVec=ltGoodDirOrigMat(:,indSTime);
                lsGoodDirNormOrig=ltGoodDirNormOrigVec(indSTime);
                %
                ltGoodDirOrigProjMat=simpleInterp(ltGoodDirOrigProjMat,true);
                %
                ltGoodDirNormOrigProjVec=interp1(timeVec,...
                    ltGoodDirNormOrigProjVec,newTimeVec,'nearest','extrap');
                projSTimeMat = projArray(:,:,indSTime);
                %
                function interpArray=simpleInterp(inpArray,isVector)
                    import gras.interp.MatrixInterpolantFactory;        
                    if nargin<2
                        isVector=false;
                    end
                    if isVector
                        nDims=size(inpArray,1);                        
                        nPoints=size(inpArray,2);
                        inpArray=reshape(inpArray,[nDims,1,nPoints]);
                    end
                    splineObj=MatrixInterpolantFactory.createInstance(...
                        'nearest',inpArray,timeVec);
                    interpArray=splineObj.evaluate(newTimeVec);
                    if isVector
                        interpArray=permute(interpArray,[1 3 2]);
                    end
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
                'ltGoodDirNormOrigVec','approxType','QArray','aMat','MArray',...
                'ltGoodDirNormOrigProjVec','ltGoodDirOrigProjMat'};
            
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
                    fPlotList,PLOT_FULL_FIELD_LIST);
            end
        end
    end
end
