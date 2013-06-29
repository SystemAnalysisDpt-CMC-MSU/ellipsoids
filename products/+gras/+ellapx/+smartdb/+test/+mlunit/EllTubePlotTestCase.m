classdef EllTubePlotTestCase < mlunitext.test_case
    
    methods
        function self = EllTubePlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
        function testPlotIntAndExtProperties(self)
            
            rel = self.createTubeWithProj(2,1);
            
            
            
            plObj = rel.plotInt('color',[0 1 0]);
            checkParams(plObj, 1, 1, 0.4, [0 1 0]);
            
            
            plObj = rel.plotExt('color',[1 0 1]);
            checkParams(plObj, 1, 1, 0.4, [1 0 1]);
            
           
            rel = self.createTubeWithProj(2,2);
            
            plObj = rel.plotInt('linewidth', 4, ...
                'fill', true, 'shade', 0.8);
            checkParams(plObj, 4, 1, 0.8, [1 0 0]);
            plObj = rel.plotExt('linewidth', 3, ...
                'fill', 0);
            checkParams(plObj, 3, 0, 0, [1 0 0]);
            rel = self.createTubeWithProj(3,3);
            
            plObj = rel.plotInt('fill', true, 'shade', 0.1, ...
                'color', [0, 1, 1]);
            checkParams(plObj, [], 1, 0.1, [0 1 1]);
            plObj = rel.plotExt('shade', 0.3, ...
                'color', [1, 1, 0]);
            checkParams(plObj, [],1, 0.3, [1 1 0]);
            

            
            
        end
        function testPlotInt(~)
            
            
            
        end
        function testPlotExt(~)
            
            
        end
    end
    methods (Static)
        function relStatProj  = createTubeWithProj(dim,ind)
            projSpaceList = {eye(dim)};
            projType = gras.ellapx.enums.EProjType.Static;
            rel = gras.ellapx.smartdb...
                .test.mlunit.EllTubePlotTestCase.createTube(ind);
            relStatProj = ...
                rel.project(projType,projSpaceList,@fGetProjMat);
        end
        function rel = createTube(ind)
            transMat2d = @(t)[cos(5*(t-2)) sin(5*(t-2));...
                -sin(5*(t-2)) cos(5*(t-2))];
            trans2Mat2d = @(t)[cos(7*(t-4)) sin(7*(t-4));...
                -sin(7*(t-4)) cos(7*(t-4))];
            trans2Mat3d = @(t)[cos(5*(t-2)) sin(5*(t-2)) 0;...
                -sin(5*(t-2)) cos(5*(t-2)) 0; 0 0 1];
            approxInt = gras.ellapx.enums.EApproxType.Internal;
            approxExt = gras.ellapx.enums.EApproxType.External;
            calcPrecision = 10^(-3);
            switch ind
                case 1
                    q1Int = @(t) transMat2d(t)'*diag([1 0.5])*...
                        transMat2d(t);
                    q2Int = @(t) trans2Mat2d(t)'*diag([1 0.5])...
                        *trans2Mat2d(t);
                    q1Ext = @(t) transMat2d(t)'*diag([1 4])*transMat2d(t);
                    q2Ext = @(t) trans2Mat2d(t)'*diag([1 4])...
                        *trans2Mat2d(t);
                    QArrList = {cat(3,q1Int(1),q1Int(2),q1Int(3),...
                        q1Int(4),q1Int(5));...
                        cat(3,q2Int(1),q2Int(2),q2Int(3),q2Int(4),...
                        q2Int(5));...
                        cat(3,q1Ext(1),q1Ext(2),q1Ext(3),...
                        q1Ext(4),q1Ext(5));...
                        cat(3,q2Ext(1),q2Ext(2),q2Ext(3),q2Ext(4),...
                        q2Ext(5))};
                    aMat = repmat([1 0]',[1,5]);
                    timeVec = 1:5;
                    ltGDir = {cat(3,transMat2d(1)'*[1;0],...
                        transMat2d(2)'*[1;0],...
                        transMat2d(3)'*[1;0], transMat2d(4)'*[1;0], ...
                        transMat2d(5)'*[1;0]);...
                        cat(3,trans2Mat2d(1)'*[1;0],...
                        trans2Mat2d(2)'*[1;0],...
                        trans2Mat2d(3)'*[1;0], trans2Mat2d(4)'*[1;0] ,...
                        trans2Mat2d(5)'*[1;0])};
                    sTime =[2; 4];
                case 2
                    QArrList = {diag([1 0.5 ]);...
                        transMat2d(1)'*diag([1 0.5])*transMat2d(1);...
                        diag([1 4 ]);...
                        transMat2d(1)'*diag([1 4])*transMat2d(1)};
                    aMat = [1;0];
                    timeVec = 1;
                    ltGDir = {[1;0];transMat2d(1)'*[1;0]};
                    sTime = [1 1];
                case 3
                    QArrList = {diag([1 0.2 0.5 ]);...
                        trans2Mat3d(1)'*diag([1 0.2 0.5])...
                        *trans2Mat3d(1);...
                        diag([1 2 4 ]);...
                        trans2Mat3d(1)'*diag([1 2 4])...
                        *trans2Mat3d(1)};
                    aMat = [1;0;0];
                    timeVec = 1;
                    ltGDir = {[1;0;0];trans2Mat3d(1)'*[1;0;0]};
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
    end
    
end

function [projOrthMatArray, projOrthMatTransArray] =...
    fGetProjMat(projMat, timeVec, varargin)
nTimePoints = length(timeVec);
projOrthMatArray = repmat(projMat, [1, 1, nTimePoints]);
projOrthMatTransArray = repmat(projMat.',...
    [1,1,nTimePoints]);
end
function checkParams(plObj, linewidth, fill, shade, colorVec)
SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,'Type'),'light'));
plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec, 'Marker'), '*'));
isEq = true;
if strcmp(get(plEllObjVec, 'type'), 'line')
    linewidthPl = get(plEllObjVec, 'linewidth');
    colorPlVec = get(plEllObjVec, 'Color');
    if numel(linewidth) > 0
        isEq = isEq & eq(linewidth, linewidthPl);
    end
    if numel(colorVec) > 0
        isEq = isEq & eq(colorVec, colorPlVec);
    end
elseif strcmp(get(plEllObjVec, 'type'), 'patch')
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
        isFill = [];
    end
else
    isFill = [];
end
mlunitext.assert_equals(isEq, 1);
mlunitext.assert_equals(numel(isFill) > 0, fill);
end