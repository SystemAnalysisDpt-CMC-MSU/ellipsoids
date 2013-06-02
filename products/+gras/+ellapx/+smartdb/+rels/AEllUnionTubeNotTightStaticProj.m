classdef AEllUnionTubeNotTightStaticProj < ...
        gras.ellapx.smartdb.rels.AEllTubeNotTightProj & ...
        gras.ellapx.smartdb.rels.AEllUnionTubeNotTight & ...
        gras.ellapx.smartdb.rels.IEllUnionTubeNotTightStaticProj
    %
    properties (Constant,Access=protected)
        N_ISO_SURF_ONEDIM_POINTS=70;
        N_ISO_SURF_MIN_TIME_POINTS=200;
        N_ISO_SURF_MAX_TIME_POINTS=700;
    end
    %
    methods
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
            import modgen.logging.log4j.Log4jConfigurator
            %
            if self.getNTuples()>0
                if nargin<2
                    plObj=smartdb.disp.RelationDataPlotter;
                end
                %
                plObj.plotGeneric(self,...
                    @self.figureGetGroupKeyFunc,...
                    {'projType','projSTimeMat','sTime','lsGoodDirOrigVec'},...
                    @self.figureSetPropFunc,...
                    {'projType','projSTimeMat','sTime'},...
                    {@self.axesGetKeyTubeFunc,@self.axesGetKeyGoodCurveFunc},...
                    {'projType','projSTimeMat'},...
                    {@self.axesSetPropTubeFunc,@self.axesSetPropGoodCurveFunc},...
                    {'projSTimeMat'},...
                    {@self.plotCreateReachTubeFunc,@self.plotCreateGoodDirFunc},...
                    self.getPlotArgumentsFieldList());
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
                plObj=smartdb.disp.RelationDataPlotter.empty;
            end
        end
    end
    %
    methods (Access=protected)
        function fieldList=getPlotArgumentsFieldList(self)
            import gras.ellapx.smartdb.F
            %
            FIELDS={'PROJ_TYPE','TIME_VEC','LS_GOOD_DIR_ORIG_VEC',...
                'LT_GOOD_DIR_MAT','S_TIME','LT_GOOD_DIR_NORM_VEC',...
                'LT_GOOD_DIR_NORM_ORIG_VEC','APPROX_TYPE','Q_ARRAY',...
                'A_MAT','M_ARRAY'};
            %
            fieldList=F.getNameList(FIELDS);
        end
        %
        function checkDataConsistency(self)
            import gras.ellapx.enums.EProjType
            import modgen.common.throwerror
            %
            if ~all(self.projType==EProjType.Static)
                throwerror('wrongInput',...
                    'projType can only contain ''Static''');
            end
        end
        %
        function axesName=axesGetKeyTubeFunc(self,~,projSTimeMat,varargin)
            axesName=['Ellipsoidal union tubes, proj. on subspace ',...
                self.projSpecVec2Str(projSTimeMat)];
        end
        %
        function figureSetPropFunc(self,hFigure,varargin)
            figureSetPropFunc@gras.ellapx.smartdb.rels.AEllTubeNotTightProj(...
                self,hFigure,varargin{:});
            figName=get(hFigure,'Name');
            set(hFigure,'Name',['Union, ',figName]);
        end
        %
        function figureGroupKeyName=figureGetGroupKeyFunc(self,varargin)
            import gras.ellapx.enums.EProjType;
            figureGroupKeyName=['union_',...
                figureGetGroupKeyFunc@gras.ellapx.smartdb.rels.AEllTubeProjBasic(...
                self,varargin{:})];
        end
        %
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
        %
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
        %
        function hVec=plotCreateReachTubeFunc(self,hAxes,~,inpTimeVec,...
                lsGoodDirOrigVec,~,sTime,~,~,approxType,QArray,aMat,~,varargin)
            %
            import gras.ellapx.enums.EProjType
            import modgen.common.throwerror
            import gras.ellapx.enums.EApproxType
            import gras.interp.MatrixInterpolantFactory
            %
            nDims=size(aMat,1);
            if nDims~=2
                throwerror('wrongDimensionality',...
                    'plotting of only 2-dimensional projections is supported');
            end
            goodDirStr=self.goodDirProp2Str(lsGoodDirOrigVec,sTime);
            patchName=sprintf('Union tube, %s: %s',char(approxType),...
                goodDirStr);
            %
            [patchColor,patchAlpha]=self.getPatchColorByApxType(approxType);
            %
            % calculate mesh for elltube to choose the points for isogrid
            %
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
            xVec=linspace(xMin,xMax,self.N_ISO_SURF_ONEDIM_POINTS);
            yVec=linspace(yMin,yMax,self.N_ISO_SURF_ONEDIM_POINTS);
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
        %
        function [cMat,cOpMat]=getGoodDirColor(self,ltGoodDirNormVec,...
                ltGoodDirNormOrigVec,varargin)
            %
            [cMat,cOpMat]=getGoodDirColor@...
                gras.ellapx.smartdb.rels.AEllTubeNotTightProj(self,...
                ltGoodDirNormVec,ltGoodDirNormOrigVec);
            %
            if length(varargin) >= 2
                cMat=adjustColor(cMat,varargin{1});
                cOpMat=adjustColor(cOpMat,varargin{2});
            end
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
    end
end