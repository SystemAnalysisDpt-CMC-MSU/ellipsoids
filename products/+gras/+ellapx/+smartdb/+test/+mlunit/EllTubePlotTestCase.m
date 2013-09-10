classdef EllTubePlotTestCase < mlunitext.test_case
    
    methods
        function self = EllTubePlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
		
        function test_getPlotStructure(self)
            import gras.ellapx.smartdb.RelDispConfigurator;
            import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            n = 4;
            T = 1;
            q11 = @(t)[ cos(2*pi*t/n) sin(2*pi*t/n) ; -sin(2*pi*t/n)  cos(2*pi*t/n) ];
            ltGDir = [];
            QArrList = cell(n+1,1);
            sTime =1;
            timeVec = 1:T;
            for iHandleVec= 0:n
                ltGDir = [ltGDir ([1 0]*q11(iHandleVec))'];
                QArrListTemp = repmat(q11(iHandleVec)'*diag([1 4])*q11(iHandleVec),[1,1,T]);
                QArrList{iHandleVec+1} = QArrListTemp;
            end
            
            ltGDir = repmat(ltGDir,[1 1 T]);
            aMat = repmat([1 0]',[1,T]);
            approxType = gras.ellapx.enums.EApproxType(1);
            calcPrecision = 10^(-3);
            
            rel =gras.ellapx.smartdb.rels.EllTube.fromQArrays(QArrList',aMat...
                ,timeVec,ltGDir,sTime',approxType,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision);
           
            projSpace2List = {[1 1;1 0].'};
            
            projObj=EllTubeStaticSpaceProjector(projSpace2List);
            relStatProj=projObj.project(rel);
            
            rel2=smartdb.relations.DynamicRelation(relStatProj);
            rel2.groupBy({'projSTimeMat'});
            RelDispConfigurator.setIsGoodCurvesSeparately(true);
            pl = relStatProj.plot('fGetColor',@(x)[1,0,0],...
                'colorFieldList', {'approxType'});
            SFigHandles=pl.getPlotStructure.figHMap.toStruct();
            SAxesHandles=pl.getPlotStructure.figToAxesToHMap.toStruct();
            [~, handleVecList] = modgen.struct.getleavelist(SFigHandles);
            [~, axesVecList] = modgen.struct.getleavelist(SAxesHandles);
            for iHandleVec = 1: size(handleVecList,1)
                mlunitext.assert(handleVecList{iHandleVec},...
                    axesVecList{2*iHandleVec-1});
                mlunitext.assert(handleVecList{iHandleVec},...
                    axesVecList{2*iHandleVec});
            end
        end		
         function testDifferentProjTypes(self)
            rel = self.createTube3(3,4,2);
            projMatList = {[1 0; 0 1].'};
                    %
            projType=gras.ellapx.enums.EProjType.Static;
            relStatProj=rel.project(projType,projMatList,...
               @fGetProjMat);
            projType=gras.ellapx.enums.EProjType.DynamicAlongGoodCurve;
            relDynProj=rel.project(projType,projMatList,@fGetProjMat);
            rel=smartdb.relationoperators.union(relStatProj,relDynProj);
            plObj=rel.plotExt(); %#ok<NASGU>
        end
        function testOneTime(self)
            %touch test
            import gras.ellapx.smartdb.RelDispConfigurator;
            import gras.ellapx.smartdb.rels.EllUnionTube;
            rel = self.createTube3(5,1,1);
            projSpaceList = {[1 0; 0 1].'};
            projType = gras.ellapx.enums.EProjType.Static;
            relStatProj = ...
                rel.project(projType,projSpaceList,@fGetProjMat);
            plObj = relStatProj.plot(); %#ok<NASGU>
        end
        function testDifferentProjMat(self)
            %touchTest
            import gras.ellapx.smartdb.RelDispConfigurator;
            import gras.ellapx.smartdb.rels.EllUnionTube;
            nTube = 3;
            q11 = @(t)[ cos(2*pi*t/nTube) sin(2*pi*t/nTube) ; -sin(2*pi*t/nTube) ...
                cos(2*pi*t/nTube) ];
            rel = self.createTube3(3,4,2);
            projSpaceList = {[1 0; 0 1].'};
            projSpace2List = {q11(0.523)};
            projType = gras.ellapx.enums.EProjType.Static;
            relStatProj = ...
                rel.project(projType,projSpaceList,@fGetProjMat);
            relStatProj2 = ...
                rel.project(projType,projSpace2List,@fGetProjMat);
            relStatProj.unionWith(relStatProj2);
            
            RelDispConfigurator.setIsGoodCurvesSeparately(false);
            pl = relStatProj.plot(); %#ok<NASGU>
        end
        function testPlotIntAndExtProperties(self)
            %
            rel = self.createTubeWithProj(2,1);
            %
            plObj = rel.plotInt('fGetColor',@(approxType)[1 0 0],...
                'colorFieldList', {'approxType'});
            self.checkParams(plObj, 2, true, 0.1, [1 0 0],1);
            %
            plObj = rel.plotExt('fGetColor',@(approxType)[0 1 0],...
                'colorFieldList', {'approxType'});
            self.checkParams(plObj, 2, true, 0.3, [0 1 0],1);
            %
            rel = self.createTubeWithProj(2,2);
            %
            plObj = rel.plotInt('fGetLineWidth', @(x)4,...
                'lineWidthFieldList', {'approxType'},...
                'fGetFill',@(x) true,...
                'fillFieldList',{'approxType'},...
                'fGetAlpha',@(x) 0.8,...
                'alphaFieldList',{'approxType'});
            self.checkParams(plObj, 4, true, 0.8, [0 1 0],2);
            plObj = rel.plotExt('fGetLineWidth', @(x)3,...
                'lineWidthFieldList', {'approxType'},...
                'fGetFill',@(x) false,...
                'fillFieldList',{'approxType'});
            self.checkParams(plObj, 3, false, 0, [0 0 1],2);
            rel = self.createTubeWithProj(3,3);
            %
            plObj = rel.plotInt('fGetColor',@(approxType)[0 1 1],...
                'colorFieldList', {'approxType'},...
                'fGetFill',@(x) true,...
                'fillFieldList',{'approxType'},...
                'fGetAlpha',@(x) 0.3,...
                'alphaFieldList',{'approxType'});
            
            self.checkParams(plObj, [], true, 0.3, [0 1 1],3);
            plObj = rel.plotExt('fGetAlpha',@(x) 0.8,...
                'alphaFieldList',{'approxType'});
            self.checkParams(plObj, [],true, 0.8, [0 0 1],3);
            
        end
        function testPlotInt(self)
            import gras.ellapx.enums.EApproxType;
            approxType = gras.ellapx.enums.EApproxType.Internal;
            fRight = @(a,b,c) a+b>=c;
            fPlot = @(x) x.plotInt;
            fTestPlot(self,approxType,fPlot,fRight);
        end
        function testPlotInfN(self)
            %when n-> infty a union of internal approximations
            %converges to a union of internal estiamtes
            rel = self.createTube2(50,1);
            plObj = rel.plotExt();
            plObj = rel.plotInt(plObj);
            self.check2Points(plObj);
        end
        function testPlotExt(self)
            import gras.ellapx.enums.EApproxType;
            fRight = @(a,b,c) a-b<=c;
            approxType = gras.ellapx.enums.EApproxType.External;
            fPlot = @(x) x.plotExt;
            fTestPlot(self,approxType,fPlot,fRight);
            
        end
        function fTestPlot(self,approxType,fPlot,fRight)
            rel = self.createTubeWithProj(2,1);
            plObj = fPlot(rel);
            
            rel2 = rel.getTuplesFilteredBy(...
                'approxType', approxType);
            self.checkPoints(rel2,plObj,1,fRight);
            
            rel = self.createTubeWithProj(2,2);
            plObj = fPlot(rel);
            rel2 = rel.getTuplesFilteredBy(...
                'approxType', approxType);
            self.checkPoints(rel2,plObj,2,fRight);
            
            rel = self.createTubeWithProj(3,3);
            plObj = fPlot(rel);
            rel2 = rel.getTuplesFilteredBy(...
                'approxType', approxType);
            self.checkPoints(rel2,plObj,3,fRight);
        end
        %
    end
    
    methods (Static)
        function relStatProj  = createTubeWithProj(dim,ind)
            import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            
            if dim == 2
                projSpaceList = {[2 1; 1 3]};
            else
                projSpaceList = {[2 1 0; 1 3 1; 2 0 0]};
            end
            rel = gras.ellapx.smartdb...
                .test.mlunit.EllTubePlotTestCase.createTube(ind);
            projObj=EllTubeStaticSpaceProjector(projSpaceList);
            relStatProj=projObj.project(rel);
        end
        function relStatProj = createTube2(nTube,nTime)
            import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            q11 = @(t)[ cos(2*pi*t/nTube) sin(2*pi*t/nTube) ;...
                -sin(2*pi*t/nTube)  cos(2*pi*t/nTube) ];
            ltGDir = [];
            QArrList = cell(nTube+1,1);
            Q2ArrList = cell(nTube+1,1);
            sTime =1;
            timeVec = 1:nTime;
            for i= 0:nTube
                ltGDir = [ltGDir ([1 0]*q11(i))']; %#ok<AGROW>
                QArrListTemp = repmat(q11(i)'*diag([1 4])*q11(i),[1,1,nTime]);
                QArrList{i+1} = QArrListTemp;
                Q2ArrListTemp = repmat(q11(i)'*diag([1 0.5])*q11(i),[1,1,nTime]);
                Q2ArrList{i+1} = Q2ArrListTemp;
            end
            
            ltGDir = repmat(ltGDir,[1 1 nTime]);
            aMat = repmat([0 0]',[1,nTime]);
            approxExtType = gras.ellapx.enums.EApproxType.External;
            approxIntType = gras.ellapx.enums.EApproxType.Internal;
            calcPrecision = 10^(-3);
            
            rel = gras.ellapx.smartdb.rels.EllTube.fromQArrays(QArrList',aMat...
                ,timeVec,ltGDir,sTime',approxExtType,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision);
            rel.unionWith(...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(Q2ArrList',aMat...
                ,timeVec,ltGDir,sTime',approxIntType,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision));
            projSpaceList = {[1 0; 0 1].'};
            projObj=EllTubeStaticSpaceProjector(projSpaceList);
            relStatProj=projObj.project(rel);
        end
        function rel = createTube3(nTube,nTime,ind)
            q11 = @(t)[ cos(2*pi*t/nTube) sin(2*pi*t/nTube) ; -sin(2*pi*t/nTube) ...
                cos(2*pi*t/nTube) ];
            ltGDir = [];
            QArrList = cell(nTube+1,1);
            sTime =1;
            timeVec = 1:nTime;
            for i= 0:nTube
                ltGDir = [ltGDir ([1 0]*q11(i))'];                 %#ok<AGROW>
                QArrListTemp = repmat(q11(i)'*diag([1 4])*q11(i),[1,1,nTime]);
                QArrList{i+1} = QArrListTemp;
            end
            
            ltGDir = repmat(ltGDir,[1 1 nTime]);
            aMat = repmat([1 0]',[1,nTime]);
            approxType = gras.ellapx.enums.EApproxType.External;
            calcPrecision = 10^(-3);
            if ind == 1
                rel = gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(...
                    gras.ellapx.smartdb.rels.EllTube.fromQArrays(QArrList',aMat...
                    ,timeVec,ltGDir,sTime',approxType,...
                    char.empty(1,0),char.empty(1,0),...
                    calcPrecision));
            elseif ind == 2
                rel = gras.ellapx.smartdb.rels.EllTube.fromQArrays(QArrList',aMat...
                    ,timeVec,ltGDir,sTime',approxType,...
                    char.empty(1,0),char.empty(1,0),...
                    calcPrecision);
            end
        end
        function rel = createTube(ind)
            fTransMat2d = @(t)[cos(5*(t-2)) sin(5*(t-2));...
                -sin(5*(t-2)) cos(5*(t-2))];
            fTrans2Mat2d = @(t)[cos(7*(t-4)) sin(7*(t-4));...
                -sin(7*(t-4)) cos(7*(t-4))];
            fTrans2Mat3d = @(t)[cos(5*(t-2)) sin(5*(t-2)) 0;...
                -sin(5*(t-2)) cos(5*(t-2)) 0; 0 0 1];
            approxInt = gras.ellapx.enums.EApproxType.Internal;
            approxExt = gras.ellapx.enums.EApproxType.External;
            calcPrecision = 10^(-3);
            switch ind
                case 1
                    fQ1Int = @(t) fTransMat2d(t)'*diag([1 0.5])*...
                        fTransMat2d(t);
                    fQ2Int = @(t) fTrans2Mat2d(t)'*diag([1 0.5])...
                        *fTrans2Mat2d(t);
                    fQ1Ext = @(t) fTransMat2d(t)'*diag([1 4])*fTransMat2d(t);
                    fQ2Ext = @(t) fTrans2Mat2d(t)'*diag([1 4])...
                        *fTrans2Mat2d(t);
                    QArrList = {cat(3,fQ1Int(1),fQ1Int(2),fQ1Int(3),...
                        fQ1Int(4),fQ1Int(5));...
                        cat(3,fQ2Int(1),fQ2Int(2),fQ2Int(3),fQ2Int(4),...
                        fQ2Int(5));...
                        cat(3,fQ1Ext(1),fQ1Ext(2),fQ1Ext(3),...
                        fQ1Ext(4),fQ1Ext(5));...
                        cat(3,fQ2Ext(1),fQ2Ext(2),fQ2Ext(3),fQ2Ext(4),...
                        fQ2Ext(5))};
                    aMat = [1 1 1 0 0; 0 0 1 1 1];
                    timeVec = 1:5;
                    ltGDir = {cat(3,fTransMat2d(1)'*[1;0],...
                        fTransMat2d(2)'*[1;0],...
                        fTransMat2d(3)'*[1;0], fTransMat2d(4)'*[1;0], ...
                        fTransMat2d(5)'*[1;0]);...
                        cat(3,fTrans2Mat2d(1)'*[1;0],...
                        fTrans2Mat2d(2)'*[1;0],...
                        fTrans2Mat2d(3)'*[1;0], fTrans2Mat2d(4)'*[1;0] ,...
                        fTrans2Mat2d(5)'*[1;0])};
                    sTime =[2; 4];
                case 2
                    QArrList = {diag([1 0.5 ]);...
                        fTransMat2d(1)'*diag([1 0.5])*fTransMat2d(1);...
                        diag([1 4 ]);...
                        fTransMat2d(1)'*diag([1 4])*fTransMat2d(1)};
                    aMat = [1;0];
                    timeVec = 1;
                    ltGDir = {[1;0];fTransMat2d(1)'*[1;0]};
                    sTime = [1 1];
                case 3
                    QArrList = {diag([1 0.2 0.5 ]);...
                        fTrans2Mat3d(1)'*diag([1 0.2 0.5])...
                        *fTrans2Mat3d(1);...
                        diag([1 2 4 ]);...
                        fTrans2Mat3d(1)'*diag([1 2 4])...
                        *fTrans2Mat3d(1)};
                    aMat = [1;0;0];
                    timeVec = 1;
                    ltGDir = {[1;0;0];fTrans2Mat3d(1)'*[1;0;0]};
                    sTime = [1 1];
            end
            rel = gras.ellapx.smartdb.rels...
                .EllTube.fromQArrays(QArrList(1),aMat...
                ,timeVec,ltGDir{1},sTime(1),approxInt,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision);
            rel.unionWith(...
                gras.ellapx.smartdb.rels...
                .EllTube.fromQArrays(QArrList(2),aMat...
                ,timeVec,ltGDir{2},sTime(2),approxInt,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision));
            rel.unionWith(...
                gras.ellapx.smartdb.rels...
                .EllTube.fromQArrays(QArrList(3),aMat...
                ,timeVec,ltGDir{1},sTime(1),approxExt,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision));
            rel.unionWith(...
                gras.ellapx.smartdb.rels...
                .EllTube.fromQArrays(QArrList(4),aMat...
                ,timeVec,ltGDir{2},sTime(2),approxExt,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision));
        end
        function checkParams(plObj, linewidth, fill, shade, colorVec,...
                curCase)
            SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
            [~, handleVecList] = modgen.struct.getleavelist(SHPlot);
            handleVec = [handleVecList{:}];
            plEllObjVec = get(handleVec, 'Children');
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Type'),'light'));
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Marker'), '*'));
            isEq = true;
            switch curCase
                case 1
                    colorPlMat = get(plEllObjVec, 'FaceVertexCData');
                    if numel(colorPlMat) > 0
                        colorPlVec = colorPlMat(1, :);
                        if numel(colorVec) > 0
                            isEq = isEq & all(colorVec == colorPlVec);
                        end
                    end
                    shadePl = get(plEllObjVec, 'FaceAlpha');
                    if shadePl == 0
                        isFill = false;
                    else
                        isFill = true;
                    end
                case 2
                    linewidthPl = get(plEllObjVec, 'linewidth');
                    colorPlVec = get(plEllObjVec, 'EdgeColor');
                    if numel(linewidth) > 0
                        isEq = isEq & eq(linewidth, linewidthPl);
                    end
                    if numel(colorVec) > 0
                        isEq = isEq & min(eq(colorVec, colorPlVec));
                    end
                    shadePl = get(plEllObjVec, 'FaceAlpha');
                    if numel(shade) > 0
                        isEq = isEq & eq(shade, shadePl);
                    end
                    if get(plEllObjVec, 'FaceAlpha') > 0
                        isFill = true;
                    else
                        isFill = false;
                    end
                case 3
                    shadePl = get(plEllObjVec, 'FaceAlpha');
                    if numel(shade) > 0
                        isEq = isEq & eq(shade, shadePl);
                    end
                    colorPlMat = get(plEllObjVec, 'FaceVertexCData');
                    if numel(colorPlMat) > 0
                        colorPlVec = colorPlMat(1, :);
                        if numel(colorVec) > 0
                            isEq = isEq & all(colorVec == colorPlVec);
                        end
                    end
                    if get(plEllObjVec, 'FaceAlpha') > 0
                        isFill = true;
                    else
                        isFill = false;
                    end
            end
            mlunitext.assert_equals(isEq, true);
            mlunitext.assert_equals(isFill, fill);
        end
        function check2Points(plObj)
            ABS_TOL = 10^(-2);
            SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
            [~, handleVecList] = modgen.struct.getleavelist(SHPlot);
            handleVec = [handleVecList{:}];
            plEllObjVec = get(handleVec, 'Children');
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Type'),'light'));
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Marker'), '*'));
            isEq = true;
            [~,yDataVec,zDataVec] = getData(plEllObjVec);
            yDataVec = [ yDataVec{1}; yDataVec{2}];
            zDataVec = [ zDataVec{1}; zDataVec{2}];
            for iPoint = 1:size(yDataVec,1)
                if abs(yDataVec(iPoint)^2+zDataVec(iPoint)^2-1)>ABS_TOL
                    isEq = false;
                end
            end
            mlunitext.assert_equals(isEq, true);
        end
        function checkPoints(rel,plObj,curCase,fRight)
            ABS_TOL = 10^(-5);
            SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
            [~, handleVecList] = modgen.struct.getleavelist(SHPlot);
            handleVec = [handleVecList{:}];
            xTitl = get(get(handleVec,'xLabel'),'String');
            yTitl =  get(get(handleVec,'yLabel'),'String');
            zTitl =  get(get(handleVec,'zLabel'),'String');
            
            plEllObjVec = get(handleVec, 'Children');
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Type'),'light'));
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Marker'), '*'));
            isEq = true;
            [xDataVec,yDataVec,zDataVec] = getData(plEllObjVec);
            name =  get(plEllObjVec,'DisplayName');
            isEq = isEq & strcmp(name,['Reach Tube: by ',...
                char(rel.approxType(1))]);
            timeVec = rel.timeVec{1};
            qArrList = rel.QArray;
            aMat = rel.aMat;
            curInd = 1;
            projSTimeMat = rel.projSTimeMat{1};
            switch curCase
                case 1
                    isEq = isEq && strcmp(xTitl,'time')&&strcmp(yTitl,...
                        rel.projRow2str(projSTimeMat,1))...
                        &&strcmp(zTitl,...
                        rel.projRow2str(projSTimeMat,2));
                    %
                    [xDataVec,xInd] = sort(xDataVec);
                    prev = 1;
                    yDataVec = yDataVec(xInd);
                    zDataVec = zDataVec(xInd);
                    for iTime = 1:size(timeVec,2)
                        numberPoints = numel(find(xDataVec == ...
                            xDataVec(prev)));
                        for iDir = 1:numberPoints
                            for iTube = 1:numel(qArrList)
                                yP = yDataVec(curInd);
                                zP = zDataVec(curInd);
                                qMat = qArrList{iTube}(:,:,iTime);
                                cVec = aMat{iTube}(:,iTime);
                                yP = yP-cVec(1);
                                zP = zP-cVec(2);
                                if ~fRight([yP zP]/qMat*[yP zP]'-1,...
                                        ABS_TOL,0)
                                    isEq = false;
                                end
                            end
                            curInd = curInd+1;
                        end
                        prev = prev + numberPoints;
                    end
                case 2
                    isEq = isEq && strcmp(xTitl,'time')&&strcmp(yTitl,...
                        rel.projRow2str(projSTimeMat,1))...
                        &&strcmp(zTitl,...
                        rel.projRow2str(projSTimeMat,2));
                    for iDir = 1:size(xDataVec,2)
                        for iTube = 1:numel(qArrList)
                            xP = yDataVec(curInd);
                            yP = zDataVec(curInd);
                            qMat = qArrList{iTube}(:,:,1);
                            cVec = aMat{iTube}(:,1);
                            xP = xP-cVec(1);
                            yP = yP-cVec(2);
                            if ~fRight([xP yP]/qMat*[xP yP]'-1,ABS_TOL,0)
                                isEq = false;
                            end
                        end
                        curInd = curInd+1;
                    end
                    
                case 3
                    isEq = isEq && strcmp(xTitl,...
                        rel.projRow2str(projSTimeMat,1))...
                        &&strcmp(yTitl,...
                        rel.projRow2str(projSTimeMat,2))...
                        &&strcmp(zTitl,...
                        rel.projRow2str(projSTimeMat,3));
                    for iDir = 1:size(xDataVec,2)
                        for iTube = 1:numel(qArrList)
                            xP = xDataVec(curInd);
                            yP = yDataVec(curInd);
                            zP = zDataVec(curInd);
                            qMat = qArrList{iTube}(:,:,1);
                            cVec = aMat{iTube}(:,1);
                            xP = xP-cVec(1);
                            yP = yP-cVec(2);
                            zP = zP-cVec(3);
                            
                            if ~fRight([xP yP zP]/qMat*[xP yP zP]'-1,...
                                    ABS_TOL,0)
                                isEq = false;
                            end
                        end
                        curInd = curInd+1;
                    end
            end
            mlunitext.assert_equals(isEq, true);
        end
    end
end
%
function [projOrthMatArray, projOrthMatTransArray] =...
    fGetProjMat(projMat, timeVec, varargin)
nTimePoints = length(timeVec);
projOrthMatArray = repmat(projMat, [1, 1, nTimePoints]);
projOrthMatTransArray = repmat(projMat.',...
    [1,1,nTimePoints]);
end
%
function [outXDataVec, outYDataVec, outZDataVec] = getData(hObj)
outXDataMat = get(hObj, 'XData');
outYDataMat = get(hObj, 'YData');
outZDataMat = get(hObj, 'ZData');
outXDataVec = outXDataMat(:)';
outYDataVec = outYDataMat(:)';
outZDataVec = outZDataMat(:)';
end