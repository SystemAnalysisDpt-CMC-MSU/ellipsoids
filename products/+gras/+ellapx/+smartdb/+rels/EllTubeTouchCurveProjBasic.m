classdef EllTubeTouchCurveProjBasic<gras.ellapx.smartdb.rels.EllTubeTouchCurveBasic
    properties (Constant,Hidden)
        FCODE_PROJ_S_MAT
        FCODE_PROJ_TYPE
        FCODE_LT_GOOD_DIR_NORM_ORIG_VEC
        FCODE_LS_GOOD_DIR_NORM_ORIG
		FCODE_LT_GOOD_DIR_ORIG_MAT 
        FCODE_LS_GOOD_DIR_ORIG_VEC
        %
    end
    methods (Access=protected)
        function resStr=projSpecVec2Str(~,projSTimeMat)
            resStr=['[',modgen.string.catwithsep(...
                cellfun(@(x)sprintf('x_%d',x),num2cell(...
                find(projSTimeMat)),'UniformOutput',false),','),']'];
        end
        %
        function axesName=axesGetKeyTubeFunc(self,~,projSTimeMat,varargin)
            axesName=['Ellipsoidal tubes, proj. on subspace ',...
                self.projSpecVec2Str(projSTimeMat)];
        end
        %
        function axesName=axesGetKeyGoodCurveFunc(self,~,projSTimeMat,varargin)
            axesName=['Good directions: proj. on subspace ',...
                self.projSpecVec2Str(projSTimeMat)];
        end
        function hVec=axesSetPropGoodCurveFunc(self,hAxes,axesName,...
                projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            self.scaleAxesHeight(hAxes,0.9,false);
            %
            ylim(hAxes,[-1 1]);
            zlim(hAxes,[-1 1]);
            set(hAxes,'PlotBoxAspectRatio',[6 1 1]);            
            hVec=self.axesSetPropBasic(hAxes,axesName,projSTimeMat,varargin{:});
        end
        %
        function scaleAxesHeight(~,hAxes,scaleFactor,isShift)
            isScaled=get(hAxes,'UserData');
            if isempty(isScaled)||~isScaled
                posVec=get(hAxes,'Position');
                newPosVec=posVec+...
                    [0 -(scaleFactor-1)*posVec(4)*isShift 0 ...
                    (scaleFactor-1)*posVec(4)];
                set(hAxes,'Position',newPosVec);
                set(hAxes,'UserData',true);
            end
        end
        function hVec=axesSetPropTubeFunc(self,hAxes,axesName,projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            self.scaleAxesHeight(hAxes,1.1,true);
            axis(hAxes,'auto');            
            hVec=self.axesSetPropBasic(hAxes,axesName,projSTimeMat,varargin{:});
        end
        function hVec=axesSetPropBasic(~,hAxes,axesName,projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            import modgen.graphics.camlight;

            title(hAxes,axesName);
            checkgen(projSTimeMat,@(x)size(x,1)==2);
            indDimVec=find(sum(projSTimeMat));
            yLabel=sprintf('x_%d',indDimVec(1));
            zLabel=sprintf('x_%d',indDimVec(2));
            xLabel='time';
            %
            set(hAxes,'XLabel',...
                text('String',xLabel,'Interpreter','tex','Parent',hAxes));
            set(hAxes,'YLabel',...
                text('String',yLabel,'Interpreter','tex','Parent',hAxes));
            set(hAxes,'ZLabel',...
                text('String',zLabel,'Interpreter','tex','Parent',hAxes));
            viewAngleVec=RelDispConfigurator.getViewAngleVec();
            view(hAxes,viewAngleVec);
            set(hAxes,'xtickmode','auto',...
                'ytickmode','auto',...
                'ztickmode','auto','xgrid','on','ygrid','on','zgrid','on'); 
            hVec=[];
            %
            lightTypeList={{'left'},{40,65},{-20,25}};
            hLightVec=cellfun(@(x)camlight(hAxes,x{:}),lightTypeList);
            hVec=[hVec,hLightVec];            
        end
        %
        function figureGroupKeyName=figureGetGroupKeyFunc(self,projType,...
                projSTimeMat,sTime,varargin)
            import gras.ellapx.enums.EProjType;
            figureGroupKeyName=self.figureGetNamedGroupKeyFunc('',...
                projType,projSTimeMat,sTime,varargin{:});
        end
        %
        function figureGroupKeyName=figureGetNamedGroupKeyFunc(self,...
                groupName,projType,projSTimeMat,sTime,...
                lsGoodDirOrigVec,varargin)
            import gras.ellapx.enums.EProjType;
            import gras.ellapx.smartdb.RelDispConfigurator;
            isGoodCurvesSeparately=...
                RelDispConfigurator.getIsGoodCurvesSeparately();
            figureGroupKeyName=[groupName,'_',lower(char(projType)),...
                '_sp',self.projSpecVec2Str(projSTimeMat),'_st',...
                num2str(sTime)];
            if isGoodCurvesSeparately
                goodCurveStr=self.goodDirProp2Str(lsGoodDirOrigVec,sTime);
                figureGroupKeyName=[figureGroupKeyName,', ',goodCurveStr];
            end
        end        
        %
        function figureSetPropFunc(self,hFigure,figName,indGroup,...
                projType,projSTimeMat,sTime,varargin)
            self.figureNamedSetPropFunc('',hFigure,figName,indGroup,...
                projType,projSTimeMat,sTime,varargin{:});
        end
        function figureNamedSetPropFunc(~,~,hFigure,...
                figureGroupName,indGroup,...
                ~,~,~,varargin)
            import gras.ellapx.enums.EProjType;
            %
            modgen.common.type.simple.checkgen(indGroup,'x==1');
            %
            set(hFigure,'NumberTitle','off','WindowStyle','docked',...
                'RendererMode','manual','Renderer','OpenGL','Name',...
                figureGroupName,'PaperPositionMode','auto');
        end        
        %
        function [cMat,cOpMat]=getGoodDirColor(self,hAxes,~,~,...
                ~,~,~,~,...
                ~,ltGoodDirNormVec,ltGoodDirNormOrigVec,...
                varargin)
            ONE_NORM_COLOR_RGB_VEC=[1 0 0];%RED
            ZERO_NORM_COLOR_RGB_VEC=[1 1 0];%YELLOW
            normRatioVec=ltGoodDirNormVec./ltGoodDirNormOrigVec;
            nPoints=length(normRatioVec);
            cMat=repmat(ZERO_NORM_COLOR_RGB_VEC,nPoints,1)+...
                normRatioVec.'*(ONE_NORM_COLOR_RGB_VEC-...
                ZERO_NORM_COLOR_RGB_VEC);
            cOpMat=cMat;
        end
        function [cMat,cOpMat]=getGoodCurveColor(self,varargin)
            [cMat,cOpMat]=self.getGoodDirColor(varargin{:});
        end        
        function hVec=plotCreateGoodDirFunc(self,hAxes,projType,timeVec,...
                lsGoodDirOrigVec,ltGoodDirMat,sTime,xTouchCurveMat,...
                xTouchOpCurveMat,ltGoodDirNormVec,ltGoodDirNormOrigVec,...
                varargin)
            import gras.ellapx.enums.EProjType;
            [cMat,cOpMat]=self.getGoodDirColor(hAxes,projType,timeVec,...
                lsGoodDirOrigVec,ltGoodDirMat,sTime,xTouchCurveMat,...
                xTouchOpCurveMat,ltGoodDirNormVec,ltGoodDirNormOrigVec,...
                varargin{:});
            %
            hVec(2)=dispDirCurve(ltGoodDirMat,lsGoodDirOrigVec,cMat);
            %
            hVec(1)=dispDirCurve(-ltGoodDirMat,-lsGoodDirOrigVec,cOpMat);
            axis(hAxes,'vis3d');
            function hVec=dispDirCurve(ltGoodDirMat,lsGoodDirOrigVec,cMat)
                import modgen.graphics.plot3adv;
                goodDirStr=self.goodDirProp2Str(lsGoodDirOrigVec,...
                    sTime);                
                plotName=['Good directions curve: ',goodDirStr];
                vMat=ltGoodDirMat./repmat(ltGoodDirNormOrigVec,2,1);
                hVec=plot3adv(timeVec.',vMat(1,:).',vMat(2,:).',cMat,...
                    'lineWidth',2,'Parent',hAxes,'DisplayName',plotName);
            end
        end
        function hVec=plotCreateTubeTouchCurveFunc(self,hAxes,projType,...
                    timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,varargin)
            [cMat,cOpMat]=self.getGoodCurveColor(hAxes,projType,timeVec,...
                lsGoodDirOrigVec,ltGoodDirMat,sTime,xTouchCurveMat,...
                xTouchOpCurveMat,ltGoodDirNormVec,ltGoodDirNormOrigVec,...
                varargin{:});
            hVec(2)=dispTouchCurve(xTouchCurveMat,lsGoodDirOrigVec,cMat);
            hVec(1)=dispTouchCurve(xTouchOpCurveMat,-lsGoodDirOrigVec,cOpMat);
            %
            function hVec=dispTouchCurve(xTouchCurveMat,lsGoodDirOrigVec,cMat)
                import modgen.graphics.plot3adv;
                plotName=['Good curve: ',...
                    self.goodDirProp2Str(lsGoodDirOrigVec,sTime)];
                propList={'lineWidth',2,...
                    'Parent',hAxes,'DisplayName',plotName};
                hVec=plot3adv(timeVec.',xTouchCurveMat(1,:).',...
                    xTouchCurveMat(2,:).',cMat,propList{:});
            end
        end
        %
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            import gras.gen.SquareMatVector;
            %
            if self.getNTuples()>0
                %
                TS_CHECK_TOL=1e-13;
                fCheck=@(x,y,z)max(abs(x-y(z)))<=TS_CHECK_TOL;
                fCheck2d=@(x,y,z)max(abs(x-y(:,z)))<=TS_CHECK_TOL;
                indSTime=num2cell(self.indSTime);
                self.checkSVsTConsistency(num2cell(self.lsGoodDirNormOrig),...
                    self.ltGoodDirNormOrigVec,indSTime,'lsGoodDirNormOrig',...
                    'ltGoodDirNormOrigVec',fCheck);
                self.checkSVsTConsistency(self.lsGoodDirOrigVec,...
                    self.ltGoodDirOrigMat,indSTime,'lsGoodDirNormOrig',...
                    'ltGoodDirNormOrigVec',fCheck2d);
                nInd=length(self.projSTimeMat);
                compareLsGoodDirVec=cell(nInd,1);
                indList=cell(nInd,1);
                for iInd=1:nInd
                    compareLsGoodDirVec{iInd}=self.projSTimeMat{iInd}*self.lsGoodDirOrigVec{iInd};
                    indList{iInd}=1:size(self.projSTimeMat{iInd},1);
                end
                self.checkSVsTConsistency(self.lsGoodDirVec,...
                    compareLsGoodDirVec,indList,...
                    'lsGoodDirVec','lsGoodDirOrigVec',fCheck);
            end
        end
    end
end