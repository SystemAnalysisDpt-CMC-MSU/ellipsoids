classdef ReachPlotTestCase < mlunitext.test_case

    properties (Access=private)
        reachObj
    end
    
    methods
        function self = ReachPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
%             self.reachObj = getReach();
        end
        
        function set_up(self)
            self.reachObj = getReach();
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
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest
            
            if strcmp(namePlot, 'plot_ia')
                approxType = EApproxType.Internal;
            else
                approxType = EApproxType.External;
            end
            
            colorFieldList = {'approxType'};
            lineWidthFieldList = {'approxType'};
            transFieldList = {'approxType'};

            checkPlotAdvance();
            checkPlotDefault();
            checkPlotSemiDefault()
            
            function checkPlotAdvance()
                plObj = feval(namePlot, self.reachObj, 'color',...
                    [1, 0, 0], 'width', 3, 'shade', 0.9);
                tuple = getTupleByApproxType(self, approxType);
                fColor = @(approxType)deal([1, 0, 0]);
                fLineWidth = @(approxType)deal(3);
                fTrans = @(approxType)deal(0.9);

                gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest...
                    .checkPlotProp(tuple, plObj, fColor, fLineWidth, fTrans,...
                    colorFieldList, lineWidthFieldList, transFieldList)
            end
            
            function checkPlotDefault()
                
                plObj = feval(namePlot, self.reachObj);
                tuple = getTupleByApproxType(self, approxType);
                fColor = @(approxType)getColorDefault(self, approxType);
                fLineWidth = @(approxType)deal(2);
                fTrans = @(approxType)getAlphaDefault(self, approxType);

                gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest...
                    .checkPlotProp(tuple, plObj, fColor, fLineWidth, fTrans,...
                    colorFieldList, lineWidthFieldList, transFieldList)
            end
            
            function checkPlotSemiDefault()
                plObj = feval(namePlot, self.reachObj, 'color',...
                    [1, 0, 0]);
                tuple = getTupleByApproxType(self, approxType);
                fColor = @(approxType)deal([1, 0, 0]);
                fLineWidth = @(approxType)deal(2);
                fTrans = @(approxType)getAlphaDefault(self, approxType);

                gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest...
                    .checkPlotProp(tuple, plObj, fColor, fLineWidth, fTrans,...
                    colorFieldList, lineWidthFieldList, transFieldList)
            end
            
            function tuple = getTupleByApproxType(self, approxType)
                import gras.ellapx.smartdb.F;
                APPROX_TYPE = F.APPROX_TYPE;
                ellTubeRel = self.reachObj.getEllTubeRel();
                tuple = ellTubeRel.getTuplesFilteredBy(...
                       APPROX_TYPE, approxType);
                
            end
        end
    end   
end

function reachObj = getReach()
    import elltool.reach.ReachFactory;
    crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
    crmSys = gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
    reachFactObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
    reachObj = reachFactObj.createInstance();
end
     
       