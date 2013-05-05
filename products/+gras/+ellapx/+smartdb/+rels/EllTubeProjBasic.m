classdef EllTubeProjBasic<gras.ellapx.smartdb.rels.EllTubeBasic&...
        gras.ellapx.smartdb.rels.EllTubeTouchCurveProjBasic
    properties (Constant,Hidden, GetAccess=protected)
        N_SPOINTS=90;
        REACH_TUBE_PREFIX='Reach';
        REG_TUBE_PREFIX='Reg';
    end
    methods 
        function namePrefix=getReachTubeNamePrefix(self)
            namePrefix=self.REACH_TUBE_PREFIX;
        end
        function namePrefix=getRegTubeNamePrefix(self)
            namePrefix=self.REG_TUBE_PREFIX;
        end        
    end
    methods (Access=protected)
        function dependencyFieldList=getTouchCurveDependencyFieldList(~)
            dependencyFieldList={'sTime','lsGoodDirOrigVec',...
                'projType','projSTimeMat','MArray'};
        end
    end
    methods (Access=protected)
        function [patchColor,patchAlpha]=getPatchColorByApxType(~,approxType)
            import gras.ellapx.enums.EApproxType;
            switch approxType
                case EApproxType.Internal
                    patchColor=[0 1 0];
                    patchAlpha=0.5;
                case EApproxType.External
                    patchColor=[0 0 1];
                    patchAlpha=0.3;
                otherwise,
                    throwerror('wrongInput',...
                        'ApproxType=%s is not supported',char(approxType));
            end
        end
        function [patchColor,patchAlpha]=getRegTubeColor(~,~)
            patchColor=[1 0 0];
            patchAlpha=1;
        end
        %
        function hVec=plotCreateReachTubeFunc(self,fGetPatchColor,...
                lineWidth, hAxes,projType,...
                timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                ltGoodDirNormOrigVec,approxType,QArray,aMat,MArray,...
                varargin)
            import gras.ellapx.enums.EApproxType;
            %
            hVec=self.plotCreateGenericTubeFunc(hAxes,...
                timeVec,lsGoodDirOrigVec,sTime,...
                approxType,QArray,aMat,fGetPatchColor,self.REACH_TUBE_PREFIX);
            axis(hAxes,'tight');
            axis(hAxes,'normal');
            if approxType==EApproxType.External
                hTouchVec=self.plotCreateTubeTouchCurveFunc(...
                    lineWidth, hAxes,projType,...
                    timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,varargin{:});
                hVec=[hVec,hTouchVec];
            end
            if approxType==EApproxType.Internal
                hAddVec=plotCreateRegTubeFunc(self,hAxes,projType,...
                    timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,approxType,QArray,aMat,MArray);
                hVec=[hVec,hAddVec];
            end
        end
        function hVec=plotCreateRegTubeFunc(self,hAxes,~,...
                timeVec,lsGoodDirOrigVec,~,sTime,...
                ~,~,~,...
                ~,approxType,~,aMat,MArray,...
                varargin)
            import gras.ellapx.enums.EApproxType;
            %
            if approxType==EApproxType.Internal
                fGetPatchColor=@(approxType)getRegTubeColor(self,approxType);
                hVec=self.plotCreateGenericTubeFunc(hAxes,...
                    timeVec,lsGoodDirOrigVec,sTime,...
                    approxType,MArray,zeros(size(aMat)),...
                    fGetPatchColor,self.REG_TUBE_PREFIX);
            else
                hVec=[];
            end
        end
        function hVec=plotCreateGenericTubeFunc(self,hAxes,...
                timeVec,lsGoodDirOrigVec,sTime,...
                approxType,QArray,aMat,fGetPatchColor,tubeNamePrefix)
            nSPoints=self.N_SPOINTS;
            goodDirStr=self.goodDirProp2Str(lsGoodDirOrigVec,sTime);
            patchName=sprintf('%s Tube, %s: %s',tubeNamePrefix,...
                char(approxType),goodDirStr);
            [vMat,fMat]=gras.geom.tri.elltubetri(...
                QArray,aMat,timeVec,nSPoints);
            nTimePoints=length(timeVec);
            [patchColor,patchAlpha]=fGetPatchColor(approxType);
            if nTimePoints==1
                nVerts=size(vMat,1);
                indVertVec=[1:nVerts,1];
                hVec=line('Parent',hAxes,'xData',vMat(indVertVec,1),...
                    'yData',vMat(indVertVec,2),...
                    'zData',vMat(indVertVec,3),'Color',patchColor);
            else
                hVec=patch('FaceColor','interp','EdgeColor','none',...
                    'DisplayName',patchName,...
                    'FaceAlpha',patchAlpha,...
                    'FaceVertexCData',repmat(patchColor,size(vMat,1),1),...
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
            function [isOk,errTagStr,reasonStr]=checkTuple(dim,...
                    projSTimeMat,projType,ltGoodDirNormOrigVec,...
                    lsGoodDirNormOrig,lsGoodDirOrigVec,timeVec)
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
                    sum(sum(projSTimeMat))==nDims;
                if ~isOk
                    reasonStr='Fields have inconsistent sizes';
                    errTagStr='badSize';
                end
            end
        end
    end
    methods
        function plObj=plot(self,varargin)
            % PLOT displays ellipsoidal tubes using the specified
            % RelationDataPlotter
            %
            % Input:
            %   regular:
            %       self:
            %   optional:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
            %           object used for displaying ellipsoidal tubes
            %   properties:
            %       fGetTubeColor: function_handle[1,1] - function with the
            %           following signature:
            %           Input:
            %               regular:
            %                   apxType: gras.ellapx.enums.EApproxType[1,1]
            %                       - approximation type
            %           Output:
            %               patchColor: double[1,3] - RGB color vector
            %               patchAlpha: double[1,1] - transparency level
            %                   within [0,1] range
            %           if not specified, an internal function 
            %               getPatchColorByApxType is used. 
            % Output:
            %   plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
            %           object used for displaying ellipsoidal tubes
            % 
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-01-06 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            import gras.ellapx.smartdb.rels.EllTubeProjBasic;
            import modgen.logging.log4j.Log4jConfigurator;
            import modgen.common.parseparext;
            %deal
            DEFAULT_LINE_WIDTH = 2;
            DEFAULT_FILL = false;
            fGetPatchColorDefault=...
                @(approxType)getPatchColorByApxType(self,approxType);
            [reg, isRegSpec, fGetPatchColor, lineWidth, isFill] = ...
                parseparext(varargin, {'fGetTubeColor', 'width', 'fill';...
                fGetPatchColorDefault, DEFAULT_LINE_WIDTH, DEFAULT_FILL;...
                'isfunction(x)',...
                @(x)(isa(x, 'double') && (x > 0)), 'islogical(x)'},...
                [0 1],...
                'regCheckList',...
                {@(x)isa(x,'smartdb.disp.RelationDataPlotter')},...
                'regDefList',cell(1,1));

            if self.getNTuples()>0
                if ~isRegSpec
                    plObj=smartdb.disp.RelationDataPlotter;
                else
                    plObj=reg{1};
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
                    fGetPatchColor, lineWidth, varargin{:});
                fPlotRegTube=@(varargin)plotCreateRegTubeFunc(self,varargin{:});
                fPlotCurve=@(varargin)plotCreateGoodDirFunc(self,...
                    lineWidth, varargin{:});
                %
                isEmptyRegVec=cellfun(@(x)all(x(:)==0),self.MArray);
                
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
                fGetGroupKeyList={fGetReachGroupKey,fGetReachGroupKey};
                fSetFigPropList={fSetReachFigProp,fSetReachFigProp};
                fGetAxisKeyList={fGetTubeAxisKey,fGetCurveAxisKey};
                fSetAxiPropList={fSetTubeAxisProp,fSetCurveAxisProp};
                fPlotList={fPlotReachTube,fPlotCurve};
                if isRegPlot
                    fGetGroupKeyList=[fGetGroupKeyList,{fGetRegGroupKey}];
                    fSetFigPropList=[fSetFigPropList,{fSetRegFigProp}];
                    fGetAxisKeyList=[fGetAxisKeyList,{fGetTubeAxisKey}];
                    fSetAxiPropList=[fSetAxiPropList,{fSetRegTubeAxisProp}];
                    fPlotList=[fPlotList,{fPlotRegTube}];
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
    end
end
