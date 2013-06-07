classdef ReachPlotTestCase < mlunitext.test_case
   
    properties (Access=private)
        reachObj
    end
    methods(Access = private)
        function getPlotAndCheck(self, passedArgList, fColor,...
                fLineWidth, fTrans, colorFieldList, lineWidthFieldList,...
                transFieldList, namePlot, approxType)
            
            plObj = feval(namePlot, self.reachObj, passedArgList{:});
            relByAppType = getTupleByApproxType(self, approxType);
            
            gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest...
                .checkPlotProp(relByAppType, plObj, fColor, fLineWidth,...
                fTrans, colorFieldList, lineWidthFieldList, transFieldList)
            function relByAppType = getTupleByApproxType(self, approxType)
                import gras.ellapx.smartdb.F;
                APPROX_TYPE = F.APPROX_TYPE;
                ellTubeRel = self.reachObj.getEllTubeRel();
                relByAppType = ellTubeRel.getTuplesFilteredBy(...
                       APPROX_TYPE, approxType);
            end
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
        
        function testPlotIA(self)
            import gras.ellapx.enums.EApproxType;
            checkPlot(self, 'plot_ia', EApproxType.Internal);
        end
        function testPlotEA(self)
            import gras.ellapx.enums.EApproxType;
            checkPlot(self, 'plot_ea', EApproxType.External);
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
       