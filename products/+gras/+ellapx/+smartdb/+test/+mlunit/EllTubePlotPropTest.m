classdef EllTubePlotPropTest < mlunitext.test_case
    properties (Access = private)
       rel
    end
    
     methods(Static)
        function checkPlotProp(rel, plObj, fColor, fLineWidth, fTrans,...
                colorFieldList, lineWidthFieldList, transFieldList)
            
            SHandle = plObj.getPlotStructure().figToAxesToPlotHMap.toStruct();
            [~, handleVecList] = modgen.struct.getleavelist(SHandle);
            handleVec = [handleVecList{:}];
            
            isOkVec = arrayfun(@(x)checkPropsTuple(x),...
                1 : numel(rel.lsGoodDirVec));
            
            mlunitext.assert(all(isOkVec));
            
            function isOk = checkPropsTuple(numberTuple)
                
                lsGoodDirString = vecToStr(rel.lsGoodDirVec{numberTuple});
                lsGoodDirMinusString = ...
                    vecToStr(-rel.lsGoodDirVec{numberTuple});
                
                isColAndAlphaVec = getIsColorAndAlpha(handleVec,...
                    lsGoodDirString);
                isLineWidthVec = getIsLineWidth(handleVec,...
                    lsGoodDirString, lsGoodDirMinusString);
                
                isOkColor = checkOneProperty('FaceVertexCData', fColor,...
                    colorFieldList, isColAndAlphaVec, numberTuple);
                isOkTrans = checkOneProperty('FaceAlpha', fTrans,...
                    transFieldList, isColAndAlphaVec, numberTuple);
                isOkLineWidth = checkOneProperty('lineWidth', fLineWidth,...
                    lineWidthFieldList, isLineWidthVec, numberTuple);
                
                isOk = all([isOkColor, isOkTrans, isOkLineWidth]);
                
            end
            
            function isOk = checkOneProperty(propNameString, fProp,...
                    propFieldList, indProp, numberTuple)
                argList = arrayfun(@(x)(rel.(propFieldList{x})),...
                    1 : numel(propFieldList), 'UniformOutput', false);
                for iArg = 1 : numel(argList)
                    if ~iscell(argList{iArg})
                        argList{iArg} = num2cell(argList{iArg});
                    end
                end
                argList = arrayfun(@(x)(argList{x}{numberTuple}),...
                    1 : numel(argList), 'UniformOutput', false);
                
                propValue = fProp(argList{:});
                plotPropValue = get(handleVec(indProp),...
                    propNameString);
            
                isOk = compareProps(propNameString, propValue, plotPropValue);
            end
            
            function isOkProp = compareProps(propNameString, propValue, plotPropValue)
                if strcmp('lineWidth', propNameString)
                    isOkLineWidthVec = arrayfun(@(x)(plotPropValue{x} == propValue),...
                        1 : numel(plotPropValue));
                    isOkProp = all(isOkLineWidthVec);
                else
                    nRows = size(plotPropValue, 1);
                    isOkProp = isequal(plotPropValue, repmat(propValue, nRows, 1));
                end
            end
            
            function isLineWidthVec = getIsLineWidth(handleVec,...
                    lsGoodDirString, lsGoodDirMinusString)
                isLineWidthVec = cellfun(@(x)(((~isempty(strfind(x,...
                    lsGoodDirString))) || (~isempty(strfind(x,...
                    lsGoodDirMinusString)))) && (~isempty(strfind(x, 'curve')))),...
                    get(handleVec, 'DisplayName'));
            end
            
            function isColorAndAlphaVec = getIsColorAndAlpha(handleVec,...
                lsGoodDirStr)
                isColorAndAlphaVec = cellfun(@(x)((~isempty(strfind(x,...
                    lsGoodDirStr))) && (~isempty(strfind(x, 'Reach')))),...
                    get(handleVec, 'DisplayName'));
            end
            
            function lsGoodDirStr = vecToStr(lsGoodDirVec)
                lsGoodDirStr = num2str(lsGoodDirVec', '%g;');
                lsGoodDirStr =...
                    ['lsGoodDirVec=[' lsGoodDirStr(1 : end - 1) ']'];
                lsGoodDirStr = lsGoodDirStr(~isspace(lsGoodDirStr));
            end
        end
     end
    
    methods
        function self = EllTubePlotPropTest(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function set_up(self)
            nPoints = 10;
            [~, relStatProj, ~] = auxGenTubeAndProjForPlot(nPoints);
            self.rel = relStatProj;
            
            function [rel,relStatProj,relDynProj] =...
                    auxGenTubeAndProjForPlot(nPoints,nTubes)
                calcPrecision = 0.001;
                approxSchemaDescr = char.empty(1,0);
                approxSchemaName = char.empty(1,0);
                nDims = 2;
                if nargin < 2
                    nTubes=1;
                end
                lsGoodDirVec = [1; 0];
                qMat = eye(nDims);
                QArrayList = repmat({repmat(qMat, [1, 1, nPoints])}, 1,...
                    nTubes);
                aMat = zeros(nDims, nPoints);
                timeVec = 1 : nPoints;
                sTime = nPoints;
                approxType = gras.ellapx.enums.EApproxType.Internal;
                %
                rel = create();
                lsGoodDirVec = [0; 1];
                qMat = diag([1, 2]);
                QArrayList = repmat({repmat(qMat,[1, 1, nPoints])}, 1,...
                    nTubes);
                approxType = gras.ellapx.enums.EApproxType.External;
                rel.unionWith(create());
                %
                projSpaceList = {[1 0; 0 1].'};
                %
                projType = gras.ellapx.enums.EProjType.Static;
                relStatProj = rel.project(projType,projSpaceList,@fGetProjMat);
                %
                projType = gras.ellapx.enums.EProjType.DynamicAlongGoodCurve;
                relDynProj = rel.project(projType,projSpaceList,@fGetProjMat);
                function [projOrthMatArray, projOrthMatTransArray] =...
                        fGetProjMat(projMat, timeVec, varargin)
                    nTimePoints = length(timeVec);
                    projOrthMatArray = repmat(projMat, [1, 1, nTimePoints]);
                    projOrthMatTransArray = repmat(projMat.', [1,1,nTimePoints]);
                end
                function rel = create()
                    ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
                    rel=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                        QArrayList, aMat, timeVec,...
                        ltGoodDirArray, sTime, approxType, approxSchemaName,...
                        approxSchemaDescr, calcPrecision);
                end
            end
            
        end
        function patchColor = getColorByApxType(~, approxType)
            import gras.ellapx.enums.EApproxType;
            switch approxType
                case EApproxType.Internal
                    patchColor = [0, 1, 0];
                case EApproxType.External
                    patchColor = [0, 0, 1];
                otherwise,
                    throwerror('wrongInput',...
                        'ApproxType=%s is not supported',...
                        char(approxType));
            end
        end
        function patchAlpha = getAlphaByApxType(~, approxType)
            import gras.ellapx.enums.EApproxType;
            switch approxType
                case EApproxType.Internal
                    patchAlpha = 0.1;
                case EApproxType.External
                    patchAlpha = 0.3;
                otherwise,
                throwerror('wrongInput',...
                    'ApproxType=%s is not supported',...
                    char(approxType));
            end
        end
        function auxCheckPlotProp(self, rel, fColor, fLineWidth,...
                fTrans, colorFieldList, lineWidthFieldList,...
                transFieldList,...
                passedArgList)
            import gras.ellapx.enums.EApproxType;
            import modgen.common.parseparext;

            plObj = smartdb.disp.RelationDataPlotter();
            rel.plot(plObj, passedArgList{:});
            
            self.checkPlotProp(rel, plObj, fColor, fLineWidth, fTrans,...
                colorFieldList, lineWidthFieldList, transFieldList)   
            
        end
        
        function testPlotAdvanced(self)
            fExpTrans = @fTransByParam;
            fExpColor = @fColorByParam;
            fExpLineWidth = @fLineWidthByParam;
            expColorFieldList = {'ltGoodDirMat','QArray'}; 
            expTransFieldList = {'sTime','ltGoodDirMat','QArray'};
            expLineWidthFieldList = {'timeVec','aMat','sTime'};
            
            passedArgList = {'fGetColor', fExpColor,... 
                'fGetAlpha', fExpTrans, 'fGetLineWidth',...
                fExpLineWidth, 'colorFieldList', expColorFieldList,...
                'alphaFieldList', expTransFieldList,...
                'lineWidthFieldList', expLineWidthFieldList};
                
            auxCheckPlotProp(self, self.rel, fExpColor, fExpLineWidth,...
                fExpTrans, expColorFieldList, expLineWidthFieldList,...
                expTransFieldList,...
                passedArgList);
            
            function Trans = fTransByParam(ltGoodDirMat, sTime, QArray)
                sumNorm = norm(ltGoodDirMat) + norm(sTime) + norm(QArray(:, :, 1));
                Trans = (mod(round(sumNorm), 9) + 1)/...
                    (mod(round(sumNorm), 9) + 2);
            end
            function colorVec = fColorByParam(ltGoodDirMat, QArray)
                sumNorm = norm(ltGoodDirMat) + norm(QArray(:, :, 1));
                modSumNorm = mod(round(sumNorm), 3) + 1;
                switch modSumNorm
                    case 1
                        colorVec = [1, 0, 0];
                    case 2
                        colorVec = [0, 1, 0];
                    case 3
                        colorVec = [0, 0, 1];
                end
            end
            function lineWidth = fLineWidthByParam(timeVec, aMat, sTime)
                sumNorm = norm(timeVec) + norm(aMat) + norm(sTime);
                lineWidth = mod(round(sumNorm), 9) + 1;
            end
        end
        
        function testPlotPropFieldListDefault(self)
            import gras.ellapx.enums.EApproxType;
            
            fExpTrans = @(approxType)getAlphaByApxType(self, approxType);
            fExpColor = @(approxType)getColorByApxType(self, approxType);
            fExpLineWidth = @(approxType)(2);
            
            expColorFieldList = {'approxType'};
            expLineWidthFieldList = {'approxType'};
            expTransFieldList = {'approxType'};
            
            passedArgList = {'fGetColor', fExpColor, 'fGetLineWidth',...
                fExpLineWidth, 'fGetAlpha', fExpTrans};
            
            auxCheckPlotProp(self, self.rel, fExpColor,...
                fExpLineWidth, fExpTrans, expColorFieldList,...
                expLineWidthFieldList, expTransFieldList,...
                passedArgList);
        end
        
        function  testPlotPropFuncDefault(self)
            import gras.ellapx.enums.EApproxType;
            
            expColorFieldList={'approxType'};
            expTransFieldList={'approxType'};
            expLineWidthFieldList={'approxType'};
            
            fExpTrans = @(approxType)getAlphaByApxType(self, approxType);
            fExpColor = @(approxType)getColorByApxType(self, approxType);
            fExpLineWidth = @(approxType)(2);
            
            passedArgList = {'colorFieldList', expColorFieldList,...
                'alphaFieldList', expTransFieldList,...
                'lineWidthFieldList', expLineWidthFieldList};

            auxCheckPlotProp(self, self.rel, fExpColor,...
                fExpLineWidth, fExpTrans, expColorFieldList,...
                expLineWidthFieldList, expTransFieldList,...
                passedArgList);
        end
        
        function  testPlotPropSemiDefault(self)
            import gras.ellapx.enums.EApproxType;
            
            expColorFieldList = {'aMat', 'QArray', 'timeVec'};
            expLineWidthFieldList = {'approxType'};
            expTransFieldList = {'approxType'};
            
            fExpColor = @fColorByParam;
            fExpLineWidth = @(approxType)(2);
            fExpTrans = @(approxType)getAlphaByApxType(self, approxType);            
            
            passedArgList = {'fGetColor', fExpColor, 'colorFieldList',...
                expColorFieldList};
                        
            auxCheckPlotProp(self, self.rel, fExpColor,...
                fExpLineWidth, fExpTrans, expColorFieldList,...
                expLineWidthFieldList, expTransFieldList,...
                passedArgList);
            
            function colorVec = fColorByParam(aMat, QArray, timeVec)
                sumNorm = norm(aMat) + norm(QArray(:, :, 1)) + norm(timeVec);
                modSumNorm = mod(round(sumNorm), 4) + 1;
                switch modSumNorm
                    case 1
                        colorVec = [1, 0, 0];
                    case 2
                        colorVec = [0, 1, 0];
                    case 3
                        colorVec = [0, 0, 1];
                    case 4
                        colorVec = [1, 1, 0];
                end
            end
        end
        
        function  testPlotAllDefault(self)
            
            fExpTrans = @(approxType)getAlphaByApxType(self, approxType);
            fExpColor = @(approxType)getColorByApxType(self, approxType);
            fExpLineWidth = @(approxType)(2);
            
            expColorFieldList = {'approxType'};
            expLineWidthFieldList = {'approxType'};
            expTransFieldList = {'approxType'};
            
            passedArgList = {};
            
            auxCheckPlotProp(self, self.rel, fExpColor, fExpLineWidth,...
                fExpTrans, expColorFieldList, expLineWidthFieldList,...
                expTransFieldList,...
                passedArgList);
        end
    end
end

