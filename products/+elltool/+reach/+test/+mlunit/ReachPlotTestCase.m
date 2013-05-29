classdef ReachPlotTestCase < mlunitext.test_case

    properties (Access=private)
        reachObj
    end
    methods(Access = private)
        function getPlotAndCheck(self, passedArgList, fColor,...
                fLineWidth, fTrans, colorFieldList, lineWidthFieldList,...
                transFieldList, namePlot)
            import gras.ellapx.enums.EApproxType;
            
            if strcmp(namePlot, 'plot_ia')
                approxType = EApproxType.Internal;
            else
                approxType = EApproxType.External;
            end
            
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
            checkPlot(self, 'plot_ia');
        end
        function testPlotEA(self)
            checkPlot(self, 'plot_ea');
        end
        
        function checkPlot(self, namePlot)
            import gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest

            colorFieldList = {'approxType'};
            lineWidthFieldList = {'approxType'};
            transFieldList = {'approxType'};

            checkPlotAdvance();
            checkPlotDefault();
            checkPlotSemiDefault()
            
            function checkPlotAdvance()
                passedArgList = {'color', [1, 0, 0], 'width', 3,...
                    'shade', 0.9};
                fColor = @(approxType)([1, 0, 0]);
                fLineWidth = @(approxType)(3);
                fTrans = @(approxType)(0.9);

                getPlotAndCheck(self, passedArgList, fColor,...
                    fLineWidth, fTrans, colorFieldList,...
                    lineWidthFieldList, transFieldList, namePlot)
            end
            
            function checkPlotDefault()
                passedArgList = {};
                fColor = @(approxType)getColorDefault(self, approxType);
                fLineWidth = @(approxType)(2);
                fTrans = @(approxType)getAlphaDefault(self, approxType);

                getPlotAndCheck(self, passedArgList, fColor,...
                    fLineWidth, fTrans, colorFieldList,...
                    lineWidthFieldList, transFieldList, namePlot)
            end
            
            function checkPlotSemiDefault()
                passedArgList = {'color', [1, 0, 0]};
                fColor = @(approxType)([1, 0, 0]);
                fLineWidth = @(approxType)(2);
                fTrans = @(approxType)getAlphaDefault(self, approxType);
                
                getPlotAndCheck(self, passedArgList, fColor,...
                    fLineWidth, fTrans, colorFieldList,...
                    lineWidthFieldList, transFieldList, namePlot)
            end

        end
    end   
end
       