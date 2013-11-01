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
        function [plotPropProcObj, plObj, isRegSpec] = parceInput(plotFullFieldList,...
                varargin)
            import gras.ellapx.smartdb.PlotPropProcessor;
            import modgen.common.parseparext;
            import modgen.common.throwerror;
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
                plObj = smartdb.disp.RelationDataPlotter();
            else
                plObj=reg{1};
            end
            %
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
        %
        function patchColor = getRegTubeColor(~,varargin)
            patchColor = [1 0 0];
        end
        
        function patchAlpha = getRegTubeAlpha(~,varargin)
            patchAlpha = 1;
        end
        %
        function hVec = plotCreateReachTubeFunc(self, plotPropProcessorObj,...
                hAxes,varargin)
            import gras.ellapx.enums.EApproxType;
            %
            [approxType,QArray,aMat,MArray]=deal(varargin{10:13});
            modgen.common.checkvar(approxType,...
                @(x)isa(x,'gras.ellapx.enums.EApproxType'));
            tubeNamePrefix = self.REACH_TUBE_PREFIX;
            %
            patchColorVec = plotPropProcessorObj.getColor(varargin(:));
            patchAlpha = plotPropProcessorObj.getTransparency(varargin(:));
            %
            hVec = plotCreateGenericTubeFunc(self,patchColorVec,...
                patchAlpha,hAxes, varargin{1:9},approxType,...
                QArray, aMat, tubeNamePrefix);
            %
            axis(hAxes, 'tight');
            axis(hAxes, 'normal');
            %
            if approxType == EApproxType.External
                hTouchVec=self.plotCreateTubeTouchCurveFunc(hAxes,...
                    plotPropProcessorObj,varargin{:});
                hVec=[hVec,hTouchVec];
            end
            %
            hAddVec = plotCreateRegTubeFuncInternal(self,...
                hAxes,varargin{1:9},...
                approxType,MArray,aMat);
            hVec=[hVec, hAddVec];
            %
        end
        function hVec = plotCreateRegTubeFuncInternal(self,...
                hAxes,varargin)
            import gras.ellapx.enums.EApproxType;
            %
            patchColorVec = self.getRegTubeColor(varargin(:));
            patchAlpha = self.getRegTubeAlpha(varargin{:});
            %
            [approxType,MArray,aMat]=deal(varargin{10:12});
            modgen.common.checkvar(approxType,...
                @(x)isa(x,'gras.ellapx.enums.EApproxType'));
            %
            tubeNamePrefix = self.REG_TUBE_PREFIX;
            hVec = self.plotCreateGenericTubeFunc(...
                patchColorVec,patchAlpha,hAxes,varargin{1:9},...
                approxType,MArray, aMat, tubeNamePrefix);
        end
        function hVec = plotCreateRegTubeFunc(self,...
                hAxes,varargin)
            import gras.ellapx.enums.EApproxType;
            %
            [approxType,~,aMat,MArray]=deal(varargin{10:13});
            modgen.common.checkvar(approxType,...
                @(x)isa(x,'gras.ellapx.enums.EApproxType'));
            %
            tubeNamePrefix = self.REG_TUBE_PREFIX;
            hVec = self.plotCreateRegTubeFuncInternal(...
                hAxes,varargin{1:9},...
                approxType,MArray, zeros(size(aMat)), tubeNamePrefix);
            %
        end
        function hVec = plotCreateGenericTubeFunc(self,...
                patchColorVec,patchAlpha, hAxes, varargin)
            
            [~, timeVec, lsGoodDirOrigVec, ~, sTime,...
                ~, ~, ~,~, approxType, QArray, aMat,...
                tubeNamePrefix] = deal(varargin{:});
            
            nSPoints=self.N_SPOINTS;
            goodDirStr=self.goodDirProp2Str(lsGoodDirOrigVec,sTime);
            nTimePoints=length(timeVec);
            %
            if nTimePoints==1
                graphObjTypeName='Set';
            else
                graphObjTypeName='Tube';
            end
            graphObjectName=sprintf('%s %s, %s: %s',tubeNamePrefix,...
                graphObjTypeName,char(approxType),goodDirStr);
            [vMat,fMat]=gras.geom.tri.elltubetri(...
                QArray,aMat,timeVec,nSPoints);
            %
            if nTimePoints==1
                nVerts=size(vMat,1);
                indVertVec=[1:nVerts,1];
                hVec=line('Parent',hAxes,'xData',vMat(indVertVec,1),...
                    'yData',vMat(indVertVec,2),...
                    'zData',vMat(indVertVec,3),'Color',patchColorVec,...
                    'DisplayName',graphObjectName);
                view(hAxes,[90 0 0]);
            else
                hVec=patch('FaceColor', 'interp', 'EdgeColor', 'none',...
                    'DisplayName', graphObjectName,...
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
        function hVec=axesSetPropReachTubeFunc(self,hAxes,axesName,projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            %            set(hAxes,'PlotBoxAspectRatio',[3 1 1]);
            axis(hAxes,'on');
            axis(hAxes,'auto');
            grid(hAxes,'on');
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
                SData.ltGoodDirOrigMat,SData.projArray,...
                SData.lsGoodDirOrigVec,SData.ltGoodDirOrigProjMat,...
                SData.ltGoodDirNormOrigProjVec] = ...
                cellfun(@fInterpTuple,SData.ltGoodDirNormOrigVec,...
                SData.ltGoodDirOrigMat,SData.projArray,self.timeVec,...
                num2cell(SData.indSTime),SData.ltGoodDirOrigProjMat,...
                SData.ltGoodDirNormOrigProjVec,'UniformOutput',false);
            SData.lsGoodDirNormOrig=vertcat(lsGoodDirNormOrigList{:});
            %
            function [projSTimeMat,lsGoodDirNormOrig,ltGoodDirNormOrigVec,...
                    ltGoodDirOrigMat,projArray,lsGoodDirOrigVec,...
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
            import modgen.common.throwerror;
            PLOT_FULL_FIELD_LIST =...
                {'projType','timeVec','lsGoodDirOrigVec',...
                'ltGoodDirMat','sTime','xTouchCurveMat',...
                'xTouchOpCurveMat','ltGoodDirNormVec',...
                'ltGoodDirNormOrigVec','approxType','QArray','aMat','MArray',...
                'ltGoodDirNormOrigProjVec','ltGoodDirOrigProjMat'};
            
            [plotPropProcObj, plObj,isRelPlotterSpec] = gras.ellapx.smartdb...
                .rels.EllTubeProjBasic.parceInput(PLOT_FULL_FIELD_LIST,...
                varargin{:});
            
            isHoldFin = fPostHold(self,isRelPlotterSpec);
            if self.getNTuples()>0
                checkDimensions(self);
                dim = self.dim(1);
                if (dim == 3) && ( size(self.timeVec{1},2) ~= 1)
                    throwerror('wrongInput',...
                        '3d Tube can be displayed only after cutting');
                end
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
                fPostFun = @(varargin)axesPostPlotFunc(self,isHoldFin,varargin{:});
                %
                isEmptyRegVec=cellfun(@(x)all(x(:) == 0), self.MArray);
                %
                if all(isEmptyRegVec)
                    plotInternal(isEmptyRegVec,false,false);
                else
                    plotInternal(isEmptyRegVec,false,true);
                end
                plotInternal(~isEmptyRegVec,true,false);
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
            end
            function plotInternal(isTupleVec,isRegPlot,isAutoHoldOn)
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
                    fPlotList,PLOT_FULL_FIELD_LIST,...
                    'axesPostPlotFunc',fPostFun,...
                    'isAutoHoldOn',isAutoHoldOn);
            end
        end
        function plObj = plotExt(self,varargin)
            % PLOTEXT - plots external approximation of ellTube.
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
            %       relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
            %       colorSpec: char[1,1] - color specification code, can be 'r','g',
            %                    etc (any code supported by built-in Matlab function).
            %
            %   properties:
            %
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
            %       'showDiscrete':logical[1,1]  -
            %           if true, approximation in 3D will be filled in every time slice
            %       'nSpacePartPoins': double[1,1] -
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
            %       relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
            %       colorSpec: char[1,1] - color specification code, can be 'r','g',
            %                    etc (any code supported by built-in Matlab function).
            %
            %   properties:
            %
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
            %       'showDiscrete':logical[1,1]  -
            %           if true, approximation in 3D will be filled in every time slice
            %       'nSpacePartPoins': double[1,1] -
            %           number of points in every time slice.
            % Output:
            %   regular:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
            %       data plotter object.
            %
            import gras.ellapx.enums.EApproxType;
            approxType = gras.ellapx.enums.EApproxType.Internal;
            plObj = self.getTuplesFilteredBy(...
                'approxType', approxType)...
                .plotExtOrInternal(@calcPointsInt,varargin{:});
        end
    end
    methods (Access=protected)
        function checkForNoReg(self)
            import modgen.common.throwwarn;
            isNoReg=all(cellfun(@(x)all(x(:) == 0), self.MArray));
            if ~isNoReg
                throwwarn('wrongInput',...
                    ['plotting of ellipsoidal reachability ',...
                    'domains for regularized tubes is not yet',...
                    ' implemented, you may still use "plot" method ',...
                    'to plot ellipsoidal tubes though']);
            end
        end
    end
    methods (Access = private)
        function plObj = plotExtOrInternal(self,fCalcPoints,varargin)
            import modgen.common.throwerror;
            import gras.geom.tri.elltube2tri;
            import gras.geom.tri.elltubediscrtri;
            import gras.ellapx.smartdb.rels.EllTubeProjBasic;
            import modgen.logging.log4j.Log4jConfigurator;
            import gras.ellapx.enums.EProjType;
            projType = gras.ellapx.enums.EProjType.Static;
            %
            self = self.getTuplesFilteredBy(...
                'projType', projType);
            if self.getNTuples()>0
                [reg,~,isShowDiscrete,nPlotPoints]=...
                    modgen.common.parseparext(varargin,...
                    {'showDiscrete','nSpacePartPoins' ;...
                    false, 600;
                    @(x)isa(x,'logical'),@(x)isa(x,'double')});
                %
                checkDimensions(self);
                dim = self.dim(1);
                if (dim == 3) && ( size(self.timeVec{1},2) ~= 1)
                    throwerror('wrongInput',...
                        '3d Tube can be displayed only after cutting');
                end
                %
                PLOT_FULL_FIELD_LIST =...
                    {'projType','timeVec','lsGoodDirOrigVec',...
                    'ltGoodDirMat','sTime','xTouchCurveMat',...
                    'xTouchOpCurveMat','ltGoodDirNormVec',...
                    'ltGoodDirNormOrigVec','approxType','QArray','aMat',...
                    'MArray','dim'};
                %
                %
                [plotPropProcObj, plObj, isRelPlotterSpec] = gras.ellapx.smartdb...
                    .rels.EllTubeProjBasic.parceInput(PLOT_FULL_FIELD_LIST,...
                    reg{:});
                %                 %
                isHoldFin = fPostHold(self,isRelPlotterSpec);
                
                fGetReachGroupKey=...
                    @(varargin)figureGetNamedGroupKey2Func(self,...
                    'reachTube',varargin{:});
                %
                fSetReachFigProp=@(varargin)figureNamedSetPropFunc(self,...
                    'reachTube',varargin{:});
                %
                fGetTubeAxisKey=@(varargin)axesGetKeyTubeFunc(self,varargin{:});
                %
                fSetTubeAxisProp=@(varargin)...
                    axesSetPropReachTubeFunc(self,varargin{:});
                %
                fPostFun = @(varargin)axesPostPlotFunc(self,isHoldFin,varargin{:});
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
                    @(varargin) plotCenter2dCase(...
                    @(varargin)patch(varargin{:},'marker','*'),...
                    plotPropProcObj, varargin{:});%
                rel=smartdb.relations.DynamicRelation(self);
                rel.groupBy({'projSTimeMat'});
                fGetGroupKeyList = {fGetReachGroupKey};
                fSetFigPropList = {fSetReachFigProp};
                fGetAxisKeyList = {fGetTubeAxisKey};
                fSetAxiPropList = {fSetTubeAxisProp};
                fPlotList = {fPlotReachTube};
                if (fDim(self.dim,self.timeVec) == 2)
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
                    'MArray','dim','calcPrecision'},...
                    'axesPostPlotFunc',fPostFun,...
                    'isAutoHoldOn',false);
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
                plObj = smartdb.disp.RelationDataPlotter();
            end
        end
    end
    
end
function figureGroupKeyName=figureGetNamedGroupKey2Func(self,...
    groupName,projType,projSTimeMat,...
    varargin)
import gras.ellapx.enums.EProjType;
figureGroupKeyName=[groupName,'_',lower(char(projType)),...
    '_sp',self.projMat2str(projSTimeMat)];
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
%
function checkCenterVecAndTimeVec(aMat,timeVec,calcPrecision)
import modgen.common.throwerror;
nTubes = numel(aMat);
aMatList = aMat;
timeVec = timeVec{1};
maxTol=max(calcPrecision);
%
for iTube = 2:nTubes
    [isEqual,~,~,~,~,reportStr]= modgen.common.absrelcompare(aMatList{1},...
        aMatList{iTube},maxTol,maxTol,@abs);
    if ~isEqual
        throwerror('wrongInput:diffCenters',...
            ['centers are different: ',reportStr]);
    end
end
%
for iTube = 2:numel(nTubes)
    if (timeVec{iTube}~=timeVec)
        throwerror('differentTimeVec', ...
            'Time vectors must be equal.');
    end
end
end
%
function dimOut = fDim(dim,timeVec)
dim = dim(1);
if (dim == 3) || (size(timeVec{1},2) >1)
    dimOut = 3;
else
    dimOut = 2;
end
end
%
function hVec =...
    plotCenter2dCase(fPatch,plotPropProcObj,hAxes,projType,...
    timeVec, lsGoodDirOrigVec, ltGoodDirMat,sTime,...
    xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
    ltGoodDirNormOrigVec, approxType, QArray, aMat, MArray,~,...
    ~, varargin)
vMat = [timeVec{1};aMat{1}(:,1)];
fMat = [1 1];
graphObjectName =  ['Reach Tube: by ', char(approxType(1))];
vararginForProc = {projType(1),...
    timeVec{1}, lsGoodDirOrigVec{1}, ltGoodDirMat{1},sTime(1),...
    xTouchCurveMat{1}, xTouchOpCurveMat{1}, ltGoodDirNormVec{1},...
    ltGoodDirNormOrigVec{1}, approxType(1), QArray{1}, aMat{1}, MArray{1}};
patchColorVec = plotPropProcObj.getColor(vararginForProc(:));
patchAlpha = plotPropProcObj.getTransparency(vararginForProc(:));
patchWidth = plotPropProcObj.getLineWidth(vararginForProc(:));
h1 = fPatch('Vertices',vMat','Faces',fMat,'Parent',hAxes);
set(h1, 'EdgeColor', patchColorVec, 'LineWidth', patchWidth,'FaceAlpha',patchAlpha,...
    'FaceColor',patchColorVec,'DisplayName',graphObjectName);
hVec = h1;
view(hAxes,[90 0 0]);
end
%
function hVec =...
    plotCreateReachApproxTubeFunc(fTri,fCalcPoints,fPatch,...
    nPlotPoints,plotPropProcObj,hAxes,projType,...
    timeVec, lsGoodDirOrigVec, ltGoodDirMat,sTime,...
    xTouchCurveMat, xTouchOpCurveMat, ltGoodDirNormVec,...
    ltGoodDirNormOrigVec, approxType, QArray, aMat, MArray,dim,...
    calcPrecision)
import modgen.graphics.camlight;
graphObjectName =  ['Reach Tube: by ', char(approxType(1))];
[vMat,fMat] = calcPoints(fTri,fCalcPoints,...
    nPlotPoints,...
    timeVec,  QArray, aMat,dim,...
    calcPrecision);
vararginForProc = {projType(1),...
    timeVec{1}, lsGoodDirOrigVec{1}, ltGoodDirMat{1},sTime(1),...
    xTouchCurveMat{1}, xTouchOpCurveMat{1}, ltGoodDirNormVec{1},...
    ltGoodDirNormOrigVec{1}, approxType(1), QArray{1}, aMat{1}, MArray{1}};
patchColorVec = plotPropProcObj.getColor(vararginForProc(:));
patchAlpha = plotPropProcObj.getTransparency(vararginForProc(:));
patchWidth = plotPropProcObj.getLineWidth(vararginForProc(:));
patchIsFill = plotPropProcObj.getIsFilled(vararginForProc(:));
if fDim(dim,timeVec) == 2
    if ~patchIsFill
        patchAlpha = 0;
    end
    h1 = fPatch('Vertices',vMat','Faces',fMat,'Parent',hAxes);
    set(h1, 'EdgeColor', patchColorVec, 'LineWidth', patchWidth,'FaceAlpha',patchAlpha,...
        'FaceColor',patchColorVec,'DisplayName',graphObjectName);
    hVec = h1;
    view(hAxes,[90 0 0]);
else
    hVec = fPatch('Vertices',vMat', 'Faces', fMat, ...
        'FaceVertexCData', repmat(patchColorVec,size(vMat,2),1), ...
        'FaceColor','interp', ...
        'FaceAlpha', patchAlpha,'EdgeColor',patchColorVec,'Parent',hAxes,...
        'EdgeLighting','phong','FaceLighting','phong','EdgeColor', 'none',...
        'DisplayName',graphObjectName);
    material('metal');
end

end
function [vMat,fMat] = calcPoints(fTri,fCalcPoints,...
    nPlotPoints,...
    timeVec,...
    QArray, aMat, dim,...
    calcPrecision, varargin)
%
nDims = dim(1);
checkCenterVecAndTimeVec(aMat,timeVec,calcPrecision);
[lGridMat, fMat] = gras.geom.tri.spheretriext(nDims,nPlotPoints);
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
    if dim == 2
        xMat = [repmat(timeVec,[1,size(xMat,2)]); xMat];
    end
    vMat = [xMat xMat(:,1)];
else
    fMat = fTri(nDir,nTimePoints);
    xMat = zeros(3,nDir*nTimePoints);
    for iTime = 1:nTimePoints
        xSliceTimeVec = fCalcPoints(nDir,lGridMat,nDims,...
            squeeze(qArr(:,:,iTime,:)),...
            aMat{1}(:,iTime),absTol);
        xMat(:,(iTime-1)*nDir+1:iTime*nDir) =...
            [timeVec(iTime)*ones(1,nDir); xSliceTimeVec];
    end
    vMat = xMat;
end
end
%
function xMat = calcPointsInt(nDir,lGridMat,nDims,qArr,...
    centerVec,absTol)
import gras.geom.ell.rhomat
xMat = zeros(nDims,nDir);
tubeNum = size(qArr,3);
%
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
%
function xMat = calcPointsExt(nDir,lGridMat,nDims,qArr,...
    centerVec,~)
xMat = zeros(nDims,nDir);
nTubes = size(qArr,3);
distAllMat = zeros(nTubes,nDir);
boundaryPointsAllCMat = cell(nTubes,nDir);
for iDir = 1:nDir
    lVec = lGridMat(:,iDir);
    distVec = gras.gen.SquareMatVector...
        .lrDivideVec(qArr,...
        lVec);
    distAllMat(:,iDir) = distVec;
    for iTube = 1:nTubes
        boundaryPointsAllCMat{iTube,iDir} = lVec/realsqrt(distVec(iTube));
    end
end
[~,xInd] = max(distAllMat,[],1);
for iDir = 1:size(xInd,2)
    xMat(:,iDir) = boundaryPointsAllCMat{xInd(iDir),iDir}...
        +centerVec;
end
end
