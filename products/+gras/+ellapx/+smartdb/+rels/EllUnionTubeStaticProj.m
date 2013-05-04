classdef EllUnionTubeStaticProj<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel&...
        gras.ellapx.smartdb.rels.EllTubeProjBasic&...
        gras.ellapx.smartdb.rels.EllUnionTubeBasic
    % EllUnionTubeStaticProj - class which keeps projection on static plane 
    %                          union of ellipsoid tubes
    % 
    % Fields:
    %   QArray:cell[1, nElem] - Array of ellipsoid matrices                              
    %   aMat:cell[1, nElem] - Array of ellipsoid centers                               
    %   scaleFactor:double[1, 1] - Tube scale factor                                        
    %   MArray:cell[1, nElem] - Array of regularization ellipsoid matrices                
    %   dim :double[1, 1] - Dimensionality                                          
    %   sTime:double[1, 1] - Time s                                                   
    %   approxSchemaName:cell[1,] - Name                                                      
    %   approxSchemaDescr:cell[1,] - Description                                               
    %   approxType:gras.ellapx.enums.EApproxType - Type of approximation 
    %                 (external, internal, not defined 
    %   timeVec:cell[1, m] - Time vector                                             
    %   calcPrecision:double[1, 1] - Calculation precision                                    
    %   indSTime:double[1, 1]  - index of sTime within timeVec                             
    %   ltGoodDirMat:cell[1, nElem] - Good direction curve                                     
    %   lsGoodDirVec:cell[1, nElem] - Good direction at time s                                  
    %   ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve                              
    %   lsGoodDirNorm:double[1, 1] - Norm of good direction at time s                         
    %   xTouchCurveMat:cell[1, nElem] - Touch point curve for good 
    %                                   direction                     
    %   xTouchOpCurveMat:cell[1, nElem] - Touch point curve for direction 
    %                                     opposite to good direction
    %   xsTouchVec:cell[1, nElem]  - Touch point at time s                                    
    %   xsTouchOpVec :cell[1, nElem] - Touch point at time s
    %   projSTimeMat: cell[1, 1] - Projection matrix at time s                                  
    %   projType:gras.ellapx.enums.EProjType - Projection type                                             
    %   ltGoodDirNormOrigVec:cell[1, 1] - Norm of the original (not 
    %                                     projected) good direction curve   
    %   lsGoodDirNormOrig:double[1, 1] - Norm of the original (not 
    %                                    projected)good direction at time s
    %   lsGoodDirOrigVec:cell[1, 1] - Original (not projected) good 
    %                                 direction at time s
    %   ellUnionTimeDirection:gras.ellapx.enums.EEllUnionTimeDirection - 
    %                      Direction in time along which union is performed          
    %   isLsTouch:logical[1, 1] - Indicates whether a touch takes place 
    %                             along LS           
    %   isLsTouchOp:logical[1, 1] - Indicates whether a touch takes place 
    %                               along LS opposite  
    %   isLtTouchVec:cell[1, nElem] - Indicates whether a touch takes place 
    %                                 along LT         
    %   isLtTouchOpVec:cell[1, nElem] - Indicates whether a touch takes 
    %                                   place along LT opposite  
    %   timeTouchEndVec:cell[1, nElem] - Touch point curve for good 
    %                                    direction                     
    %   timeTouchOpEndVec:cell[1, nElem] - Touch point curve for good 
    %                                      direction
    methods(Access=protected)
        function checkDataConsistency(self)
            import gras.ellapx.enums.EProjType;
            import modgen.common.throwerror;
            checkDataConsistency@...
                gras.ellapx.smartdb.rels.EllTubeProjBasic(self);
            if ~all(self.projType==EProjType.Static)
                throwerror('wrongInput',...
                    'projType can only contain ''Static''');
            end
        end
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    properties (Constant,GetAccess=protected,Hidden)
        N_ISO_SURF_ONEDIM_POINTS=70;
        N_ISO_SURF_MIN_TIME_POINTS=200;
        N_ISO_SURF_MAX_TIME_POINTS=700;
    end
    methods
        function self=EllUnionTubeStaticProj(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
        function plObj=plot(self,plObj)
            % PLOT - displays ellipsoidal tubes using the specified RelationDataPlotter
            %
            % Input:
            %   regular:
            %       self:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
            %           object used for displaying ellipsoidal tubes
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            import gras.ellapx.smartdb.rels.EllUnionTubeStaticProj;
            import modgen.logging.log4j.Log4jConfigurator;
            if self.getNTuples()>0
                if nargin<2
                    plObj=smartdb.disp.RelationDataPlotter;
                end
                %
                plObj.plotGeneric(self,...
                    @(varargin)figureGetGroupKeyFunc(self,varargin{:}),...
                    {'projType','projSTimeMat','sTime','lsGoodDirOrigVec'},...
                    @(varargin)figureSetPropFunc(self,varargin{:}),...
                    {'projType','projSTimeMat','sTime'},...
                    {@(varargin)axesGetKeyTubeFunc(self,varargin{:}),...
                    @(varargin)axesGetKeyGoodCurveFunc(self,varargin{:})},...
                    {'projType','projSTimeMat'},...
                    {@(varargin)axesSetPropTubeFunc(self,varargin{:}),...
                    @(varargin)axesSetPropGoodCurveFunc(self,varargin{:})},...
                    {'projSTimeMat'},...
                    {@(varargin)plotCreateReachTubeFunc(self,varargin{:}),...
                    @(varargin)plotCreateGoodDirFunc(self,varargin{:})},...
                    {'projType','timeVec',...
                    'lsGoodDirOrigVec',...
                    'ltGoodDirMat','sTime','xTouchCurveMat',...
                    'xTouchOpCurveMat','ltGoodDirNormVec',...
                    'ltGoodDirNormOrigVec',...
                    'timeTouchEndVec','timeTouchOpEndVec',...
                    'isLtTouchVec','isLtTouchOpVec',...
                    'approxType','QArray','aMat'});
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
            end
        end
    end
    methods (Access=protected)
        function axesName=axesGetKeyTubeFunc(self,~,projSTimeMat,varargin)
            axesName=['Ellipsoidal union tubes, proj. on subspace ',...
                self.projSpecVec2Str(projSTimeMat)];
        end        
        function figureSetPropFunc(self,hFigure,varargin)
            figureSetPropFunc@gras.ellapx.smartdb.rels.EllTubeProjBasic(...
                self,hFigure,varargin{:});
            figName=get(hFigure,'Name');
            set(hFigure,'Name',['Union, ',figName]);
        end
        function figureGroupKeyName=figureGetGroupKeyFunc(self,varargin)
            import gras.ellapx.enums.EProjType;
            figureGroupKeyName=['union_',...
                figureGetGroupKeyFunc@gras.ellapx.smartdb.rels.EllTubeProjBasic(self,...
                varargin{:})];
        end
        
        function [cMat,cOpMat]=getGoodDirColor(self,hAxes,projType,timeVec,...
                lsGoodDirOrigVec,ltGoodDirMat,sTime,xTouchCurveMat,...
                xTouchOpCurveMat,ltGoodDirNormVec,ltGoodDirNormOrigVec,...
                timeTouchEndVec,timeTouchOpEndVec,...
                    isLtTouchVec,isLtTouchOpVec,varargin)
                [cMat,cOpMat]=...
                    getGoodDirColor@gras.ellapx.smartdb.rels.EllTubeProjBasic(...
                    self,hAxes,projType,timeVec,...
                    lsGoodDirOrigVec,ltGoodDirMat,sTime,xTouchCurveMat,...
                    xTouchOpCurveMat,ltGoodDirNormVec,ltGoodDirNormOrigVec);
                cMat=adjustColor(cMat,isLtTouchVec);
                cOpMat=adjustColor(cOpMat,isLtTouchOpVec);
                %
            function cOutMat=adjustColor(cMat,isTouchVec)
                nPoints=size(ltGoodDirNormVec,2);
                cOutMat=zeros(nPoints,3);
                isnTouchVec=~isTouchVec;
                cOutMat(isTouchVec,:)=cMat(isTouchVec,:);
                cOutMat(isnTouchVec,:)=...
                    self.getNoTouchGoodDirColor(...
                    ltGoodDirNormVec(isnTouchVec),...
                    ltGoodDirNormOrigVec(isnTouchVec));
            end
        end
        function cMat=getNoTouchGoodDirColor(~,ltGoodDirNormVec,...
                ltGoodDirNormOrigVec)
            ONE_NORM_COLOR_RGB_VEC=[1 1 1]*0.5;%GREY
            ZERO_NORM_COLOR_RGB_VEC=[1 1 1];%WHITE
            normRatioVec=ltGoodDirNormVec./ltGoodDirNormOrigVec;
            nPoints=length(normRatioVec);
            cMat=repmat(ZERO_NORM_COLOR_RGB_VEC,nPoints,1)+...
                normRatioVec.'*(ONE_NORM_COLOR_RGB_VEC-...
                ZERO_NORM_COLOR_RGB_VEC);
        end
        function [patchColor,patchAlpha]=getPatchColorByApxType(~,approxType)
            import gras.ellapx.enums.EApproxType;
            switch approxType
                case EApproxType.Internal
                    patchColor=[0.2 1 0];
                    patchAlpha=0.5;
                case EApproxType.External
                    patchColor=[0.2 0 1];
                    patchAlpha=0.3;
                otherwise,
                    throwerror('wrongInput',...
                        'ApproxType=%s is not supported',char(approxType));
            end
        end
        function hVec=plotCreateReachTubeFunc(self,hAxes,projType,...
                    inpTimeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,timeTouchEndVec,timeTouchOpEndVec,...
                isLtTouchVec,isLtTouchOpVec,approxType,QArray,aMat)
            import gras.ellapx.enums.EProjType;
            import modgen.common.throwerror;
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.rels.EllUnionTubeStaticProj;
            import gras.interp.MatrixInterpolantFactory;
            nDims=size(aMat,1);
            if nDims~=2
                throwerror('wrongDimensionality',...
                    'plotting of only 2-dimensional projections is supported');
            end
            goodDirStr=self.goodDirProp2Str(...
                lsGoodDirOrigVec,sTime);
            patchName=sprintf('Union tube, %s: %s',char(approxType),...
                goodDirStr);
            %
            [patchColor,patchAlpha]=...
                self.getPatchColorByApxType(approxType);
            %calculate mesh for elltube to choose the points for isogrid
            %
            %choose iso-grid
            timeVec=inpTimeVec;
            nTimePoints=length(timeVec);
            nMinTimePoints=self.N_ISO_SURF_MIN_TIME_POINTS;
            maxRefineFactor=fix(self.N_ISO_SURF_MAX_TIME_POINTS/nTimePoints);
            minRefineFactor=ceil(nMinTimePoints/nTimePoints);
            %
            onesVec=ones(size(timeVec));
            QMatList=shiftdim(mat2cell(QArray,nDims,nDims,onesVec),1);
            aVecList=mat2cell(aMat,nDims,onesVec);
            timeList=num2cell(timeVec);
            %
            refineFactorList=cellfun(@getRefineFactorByNeighborQMat,...
                aVecList(1:end-1),QMatList(1:end-1),timeList(1:end-1),...
                aVecList(2:end),QMatList(2:end),timeList(2:end),...
                'UniformOutput',false);
            %
            resTimeVecList=cellfun(@(x,y,z)linspace(x,y,z+1),...
                timeList(1:end-1),timeList(2:end),refineFactorList,...
                'UniformOutput',false);
            resTimeVecList=cellfun(@(x)x(1:end-1),resTimeVecList,...
                'UniformOutput',false);
            resTimeVec=[resTimeVecList{:}];
            %
            QMatSpline=MatrixInterpolantFactory.createInstance(...
                'symm_column_triu',QArray,timeVec);
            aVecSpline=MatrixInterpolantFactory.createInstance(...
                'column',aMat,timeVec);
            %
            timeVec=resTimeVec;
            QArray=QMatSpline.evaluate(timeVec);
            aMat=aVecSpline.evaluate(timeVec);
            %
            xMax=max(shiftdim(realsqrt(QArray(1,1,:)),1)+aMat(1,:));
            xMin=min(-shiftdim(realsqrt(QArray(1,1,:)),1)+aMat(1,:));
            %
            yMax=max(shiftdim(realsqrt(QArray(2,2,:)),1)+aMat(2,:));
            yMin=min(-shiftdim(realsqrt(QArray(2,2,:)),1)+aMat(2,:));
            %
            xVec=linspace(xMin,xMax,...
                EllUnionTubeStaticProj.N_ISO_SURF_ONEDIM_POINTS);
            yVec=linspace(yMin,yMax,...
                EllUnionTubeStaticProj.N_ISO_SURF_ONEDIM_POINTS);
            %
            [xxMat,yyMat]=ndgrid(xVec,yVec);
            xyMat=transpose([xxMat(:) yyMat(:)]);
            nXYGridPoints=size(xyMat,2);
            %form value function array
            nTimes=length(timeVec);
            nXPoints=length(xVec);
            nYPoints=length(yVec);
            vArray=nan(nTimes,nXPoints,nYPoints);
            %calculation value function for the plain tube
            
            for iTime=1:nTimes
                vArray(iTime,:)=gras.gen.SquareMatVector.lrDivideVec(...
                    QArray(:,:,iTime),...
                    xyMat-...
                    aMat(:,repmat(iTime,1,nXYGridPoints)));
            end
            %calculation value function for the union tube
            %
            for iTime=2:nTimes
                vArray(iTime,:)=min(vArray(iTime,:),vArray(iTime-1,:));
            end
            %build isosurface
            [tttArray,xxxArray,yyyArray]=ndgrid(timeVec,xVec,yVec);
            [fMat,vMat] = isosurface(tttArray,xxxArray,yyyArray,vArray,1);
            %shrink faces
            maxRangeVec=max(vMat,[],1);
            surfDiam=realsqrt(sum(maxRangeVec.*maxRangeVec));
            MAX_EDGE_LENGTH_FACTOR=0.1;
            minTimeDelta=MAX_EDGE_LENGTH_FACTOR*surfDiam;
            [vMat,fMat]=gras.geom.tri.shrinkfacetri(vMat,fMat,minTimeDelta);
            %
            hVec=patch('FaceColor','interp','EdgeColor','none',...
                'DisplayName',patchName,...
                'FaceAlpha',patchAlpha,...
                'FaceVertexCData',repmat(patchColor,size(vMat,1),1),...
                'Faces',fMat,'Vertices',vMat,'Parent',hAxes,...
                'EdgeLighting','phong','FaceLighting','phong');
            material('metal');
            axis(hAxes,'tight');
            axis(hAxes,'normal');
            hold(hAxes,'on');
            %
            if approxType==EApproxType.External
                hTouchVec=self.plotCreateTubeTouchCurveFunc(...
                    hAxes,projType,...
                    inpTimeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,...
                    timeTouchEndVec,timeTouchOpEndVec,...
                    isLtTouchVec,isLtTouchOpVec);
                hVec=[hTouchVec,hVec];
            end
            function refineFactor=getRefineFactorByNeighborQMat(...
                    aLeftVec,qLeftMat,tLeft,aRightVec,qRightMat,tRight)
                    tDeltaInv=1./(tRight-tLeft);
                    aDiffVec = aRightVec-aLeftVec;
                    aDiff=abs(realsqrt(sum(aDiffVec.*aDiffVec))*tDeltaInv);
                    qDiff=realsqrt(max(abs(eig(qRightMat-qLeftMat))))*tDeltaInv;
                    eigLeftVec=eig(qLeftMat);
                    eigRightVec=eig(qRightMat);
                    condVal=0.5*(max(eigLeftVec)/min(eigLeftVec)+...
                        max(eigRightVec)/min(eigRightVec));
                    refineFactor=min(ceil(max(minRefineFactor,...
                        log(realsqrt((aDiff+qDiff)*condVal)))),maxRefineFactor);
            end
        end
        function hVec=plotCreateTubeTouchCurveFunc(self,hAxes,projType,...
                    timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,timeTouchEndVec,timeTouchOpEndVec,...
                isLtTouchVec,isLtTouchOpVec)
            xTouchCurveMat(:,~isLtTouchVec)=nan;
            xTouchOpCurveMat(:,~isLtTouchOpVec)=nan;
            %
            hVec=plotCreateTubeTouchCurveFunc@...
                gras.ellapx.smartdb.rels.EllTubeProjBasic(...
                self,hAxes,projType,...
                    timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,timeTouchEndVec,timeTouchOpEndVec,...
                isLtTouchVec,isLtTouchOpVec);
            %
            [cMat,cOpMat]=self.getGoodDirColor(hAxes,projType,timeVec,...
                lsGoodDirOrigVec,ltGoodDirMat,sTime,xTouchCurveMat,...
                xTouchOpCurveMat,ltGoodDirNormVec,ltGoodDirNormOrigVec,...
                timeTouchEndVec,timeTouchOpEndVec,...
                isLtTouchVec,isLtTouchOpVec);
            %
            hCVec{2}=dispTouchArea(xTouchCurveMat,timeTouchEndVec,cMat);
            hCVec{1}=dispTouchArea(xTouchOpCurveMat,timeTouchOpEndVec,cOpMat);
            hVec=[hVec,hCVec{:}];
            function hSurfVec=dispTouchArea(xTouchCurveMat,timeEndVec,cMat)
                import modgen.graphics.plot3adv;
                nameSuffix=self.goodDirProp2Str(...
                    lsGoodDirOrigVec,sTime);
                plotName=['Touch surface: ',nameSuffix];
                hSurfVec=self.plotTouchArea(...
                    [timeVec;xTouchCurveMat].',timeEndVec.',cMat,...
                    'Parent',hAxes,'DisplayName',plotName,...
                    'EdgeLighting','phong','FaceLighting','phong',...
                    'FaceColor','interp','EdgeColor','none',...
                    'FaceAlpha',1);
            end
        end
        function h=plotTouchArea(~,vMat,xBarTopVec,colorMat,varargin)
            isVertVec=(vMat(:,1)~=xBarTopVec)&~isnan(xBarTopVec);
            if any(isVertVec)
                vMat(~isVertVec,:)=nan;
                xBarTopVec(~isVertVec)=nan;
                nBasicVerts=size(vMat,1);
                %
                vAddMat=[xBarTopVec vMat(:,2:3)];
                nAddVerts=nBasicVerts;
                indAddVec=transpose(nBasicVerts+1:nBasicVerts+nAddVerts);
                indBasicVec=transpose(1:nBasicVerts);
                %
                vMat=[vMat;vAddMat];
                fMat=[indBasicVec(1:end-1) indBasicVec(2:end) indAddVec(1:end-1);...
                    indBasicVec(2:end) indAddVec(2:end) indAddVec(1:end-1)];
                colorMat=[colorMat;colorMat(indBasicVec,:)];
                %
                %
                h=patch('FaceVertexCData',colorMat,...
                    'Faces',fMat,'Vertices',vMat,varargin{:});
                material('metal');
            else
                h=[];
            end
        end
    end
end