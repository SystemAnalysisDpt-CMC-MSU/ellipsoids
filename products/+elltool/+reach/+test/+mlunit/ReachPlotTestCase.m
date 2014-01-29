classdef ReachPlotTestCase < mlunitext.test_case
   
    properties (Access=private)
        reachObj
    end
    methods(Access = private)
        function getPlotAndCheck(self, passedArgList, fColor,...
                fLineWidth, fTrans, colorFieldList, lineWidthFieldList,...
                transFieldList, namePlot, approxType)
            
            plObj = feval(namePlot, self.reachObj, passedArgList{:});
            relByAppType = self.getTupleByApproxType( approxType);
            
            gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest...
                .checkPlotProp(relByAppType, plObj, fColor, fLineWidth,...
                fTrans, colorFieldList, lineWidthFieldList, transFieldList)
            
        end
        function relByAppType = getTupleByApproxType(self, approxType)
                import gras.ellapx.smartdb.F;
                APPROX_TYPE = F.APPROX_TYPE;
                ellTubeRel = self.reachObj.getEllTubeRel();
                relByAppType = ellTubeRel.getTuplesFilteredBy(...
                       APPROX_TYPE, approxType);
            end
    end
    
    methods
        function self = ReachPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function set_up_param(self, reachFactObj)
            self.reachObj = reachFactObj.createInstance();
            if ~self.reachObj.isprojection()
                if self.reachObj.dimension() > 2
                    projBasisMat = eye(self.reachObj.dimension(), 2);
                else
                    projBasisMat = eye(self.reachObj.dimension());
                end
                self.reachObj = self.reachObj.projection(projBasisMat);
            end
        end
        
        function self = tear_down(self,varargin)
            close all;
        end
        
        function patchColor = getColorDefault(~, approxType)
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
        function patchAlpha = getAlphaDefault(~, approxType)
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
        
        function testPlotIa(self)
            import gras.ellapx.enums.EApproxType;
            checkPlot(self, 'plotIa', EApproxType.Internal);
        end
        function testPlotByIa(self)
            import gras.ellapx.enums.EApproxType;
            fRight = @(a,b,c) a+b>=c;
            check2Plot(self, 'plotByIa',EApproxType.Internal,fRight);
        end
        function testPlotEa(self)
            import gras.ellapx.enums.EApproxType;
            checkPlot(self, 'plotEa', EApproxType.External);
        end
        function testPlotByEa(self)
            import gras.ellapx.enums.EApproxType;
            fRight = @(a,b,c) a-b<=c;
            check2Plot(self, 'plotByEa',EApproxType.External,fRight);
        end
        function check2Plot(self,namePlot,approxType,fRight)
            import gras.ellapx.smartdb.test.mlunit.EllTubePlotTestCase
            import gras.ellapx.enums.EApproxType;
            rel = self.getTupleByApproxType(approxType);
            expLineWidth = 2;
            expFill = true;
            if approxType == EApproxType.External
                expShade  = 0.3;
                expColor = [0 0 1];
            elseif approxType == EApproxType.Internal
                expShade  = 0.1;
                expColor = [0 1 0];
            end
            if numel(rel.QArray) > 0
                timeVec = rel.timeVec{1};
                nDim = size(rel.QArray{1}, 1);
                mDim = size(timeVec, 2);
                if mDim == 1
                    if nDim == 2
                        curCase = 2;
                    else
                        curCase = 3;
                    end
                else
                    curCase = 1;
                end
                switch curCase
                    case 1
                        plObj = feval(namePlot, self.reachObj,...
                             'r');
                        gras.ellapx.smartdb.test.mlunit...
                            .EllTubePlotTestCase...
                            .checkParams(plObj, expLineWidth, expFill,...
                            expShade, [1 0 0],1);
                        gras.ellapx.smartdb.test.mlunit...
                            .EllTubePlotTestCase...
                            .checkPoints...
                            (rel,plObj,1,fRight);
                    case 2
                        plObj = feval(namePlot, self.reachObj,...
                            'linewidth', 4, ...
                            'fill', true, 'shade', 0.8);                     
                        gras.ellapx.smartdb.test.mlunit...
                            .EllTubePlotTestCase...
                            .checkParamsheckParams(plObj, 4, true,...
                            0.8, expColor,2);
                        gras.ellapx.smartdb.test.mlunit...
                            .EllTubePlotTestCase...
                            .checkPoints...
                            (rel,plObj,2,fRight);
                    case 3
                        plObj = feval(namePlot, self.reachObj,...
                            'fill', true, 'shade', 0.1, ...
                            'color', [0, 1, 1]);      
                        gras.ellapx.smartdb.test.mlunit...
                            .EllTubePlotTestCase...
                            .checkParams(plObj, [], true, 0.1, [0 1 1]);
                        gras.ellapx.smartdb.test.mlunit...
                            .EllTubePlotTestCase...
                            .checkPoints...
                            (rel,plObj,3,fRight);
                end               
            end
        end
        function checkPlot(self, namePlot, approxType)
            import gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest
            import gras.ellapx.enums.EApproxType;
            
            colorFieldList = {'approxType'};
            lineWidthFieldList = {'approxType'};
            transFieldList = {'approxType'};

            checkPlotAdvance();
            checkPlotDefault();
            checkPlotSemiDefault()
            checkPlotSymColor();
            checkPlotSym();
            
            function checkPlotAdvance()
                passedArgList = {'color', [1, 0, 0], 'width', 3,...
                    'shade', 0.9};
                fColor = @(approxType)([1, 0, 0]);
                fLineWidth = @(approxType)(3);
                fTrans = @(approxType)(0.9);

                getPlotAndCheck(self, passedArgList, fColor,...
                    fLineWidth, fTrans, colorFieldList,...
                    lineWidthFieldList, transFieldList, namePlot,...
                    approxType)
            end
            
            function checkPlotDefault()
                passedArgList = {};
                fColor = @(approxType)getColorDefault(self, approxType);
                fLineWidth = @(approxType)(2);
                fTrans = @(approxType)getAlphaDefault(self, approxType);

                getPlotAndCheck(self, passedArgList, fColor,...
                    fLineWidth, fTrans, colorFieldList,...
                    lineWidthFieldList, transFieldList, namePlot,...
                    approxType)
            end
            
            function checkPlotSemiDefault()
                passedArgList = {'color', [1, 0, 0]};
                fColor = @(approxType)([1, 0, 0]);
                fLineWidth = @(approxType)(2);
                fTrans = @(approxType)getAlphaDefault(self, approxType);
                
                getPlotAndCheck(self, passedArgList, fColor,...
                    fLineWidth, fTrans, colorFieldList,...
                    lineWidthFieldList, transFieldList, namePlot,...
                    approxType)
            end
            
            function checkPlotSymColor()
                passedArgList = {'color', 'g'};
                fColor = @(approxType)([0, 1, 0]);
                fLineWidth = @(approxType)(2);
                fTrans = @(approxType)getAlphaDefault(self, approxType);
                
                getPlotAndCheck(self, passedArgList, fColor,...
                    fLineWidth, fTrans, colorFieldList,...
                    lineWidthFieldList, transFieldList, namePlot,...
                    approxType)
            end
            
            function checkPlotSym()
                passedArgList = {'r'};
                fColor = @(approxType)([1, 0, 0]);
                fLineWidth = @(approxType)(2);
                fTrans = @(approxType)getAlphaDefault(self, approxType);
                
                getPlotAndCheck(self, passedArgList, fColor,...
                    fLineWidth, fTrans, colorFieldList,...
                    lineWidthFieldList, transFieldList, namePlot,...
                    approxType)
            end
        end
    end   
end
       