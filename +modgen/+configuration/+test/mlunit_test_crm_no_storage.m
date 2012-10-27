classdef mlunit_test_crm_no_storage < modgen.configuration.test.mlunit_test_crm
    methods
        function self = mlunit_test_crm_no_storage(varargin)
            self = self@modgen.configuration.test.mlunit_test_crm(varargin{:});
        end
        function self = test_setGetConf(self)
            import modgen.configuration.test.*;
            SConf=genteststruct(3);
            metaData=struct('a','111','b','222');
            self.cm.putConf('testConfA',SConf,3,metaData);
            [SRes,confVersion,metaDataRes]=self.cm.getConf('testConfA');
            mlunit.assert_equals(isequalwithequalnans(SConf,SRes),true);
            metaData.version='3';
            mlunit.assert_equals(isequalwithequalnans(metaData,metaDataRes),true);
            mlunit.assert_equals(isequalwithequalnans(3,confVersion),true);
        end
        function self = test_copyConfAndgetConfList(self)
            import modgen.configuration.test.*;
            SConf=genteststruct(3);
            self.cm.putConf('testConfA',SConf);
            self.cm.copyConf('testConfA','testConfAA');
            SRes=self.cm.getConf('testConfAA');
            mlunit.assert_equals(isequalwithequalnans(SConf,SRes),true);
            self.cm.removeConf('testConfB');
            confNameList=self.cm.getConfNameList();
            isEqual=isequal(sort({'testConfA','testConfAA'}),...
                sort(confNameList));
            mlunit.assert_equals(isEqual,true);
        end        
        function self = test_isParam(self)
            import modgen.configuration.test.*;
            SConf=genteststruct(3);
            self.cm.putConf('testConfA',SConf);
            self.cm.selectConf('testConfA');
            isPos=self.cm.isParam('dConf.gen.cdefs.gen.instTypeCode');
            mlunit.assert_equals(isPos,true);
            isPos=self.cm.isParam('dConf.gen.cdefs.gen.instTypeCode__');
            mlunit.assert_equals(isPos,false);
            isPos=self.cm.isParam('.dConf.gen.cdefs.gen.instTypeCode');
            mlunit.assert_equals(isPos,true);
            
        end        
        function self = test_setGetParamWithDot(self)
            import modgen.configuration.test.*;
            %
            paramNameList={'.dConf.backtest.calc.pairForecast.meanDec.nLags',...
                'dConf.backtest.calc.pairForecast.meanDec.nLags'};
            for iParam=1:length(paramNameList)
                self=self.initData();                
                paramName=paramNameList{iParam};
                self.cm.selectConf('testConfA');
                paramVal=self.cm.getParam(paramName);
                paramVal=paramVal+3;
                self.cm.setParam(paramName,paramVal);
                paramVal2=self.cm.getParam(paramName);
                mlunit.assert_equals(isequalwithequalnans(paramVal,paramVal2),true);
                self.cm.selectConf('testConfB');
                self.cm.setParam(paramName,Inf);
                paramVal3=self.cm.getParam(paramName);            
                mlunit.assert_equals(isequalwithequalnans(Inf,paramVal3),true);            
            end
        end
        function self = test_setGetParamNegative(self)
            import modgen.configuration.test.*;
            %
            self=self.initData();
            paramName='.dConf.backtest.calc.pairForecast.meanDec.nLags123';
            self.cm.selectConf('testConfA');
            try
                self.cm.getParam(paramName);
                mlunit.assert_equals(true,false);
            catch meObj
                isOk=~isempty(strfind(meObj.identifier,...
                    'CONFREPOMANAGERANYSTORAGE:invalidParam'));
                mlunit.assert_equals(isOk,true);
            end
        end
        function self = test_setParamInCache(self)
            import modgen.configuration.test.*;
            %
            paramNameList={'.dConf.backtest.calc.pairForecast.meanDec.nLags',...
                'dConf.backtest.calc.pairForecast.meanDec.nLags'};
            for iParam=1:length(paramNameList)
                self=self.initData();                
                paramName=paramNameList{iParam};
                self.cm.selectConf('testConfA');
                paramValue=rand(1);
                self.cm.setParam(paramName,paramValue,'writeDepth','cache');
                mlunit.assert_equals(true,self.cm.isParam(paramName));
                mlunit.assert_equals(paramValue,self.cm.getParam(paramName));
                paramValue=rand(1);
                self.cm.setParam(paramName,paramValue,'writeDepth','cache');
                mlunit.assert_equals(true,self.cm.isParam(paramName));
                mlunit.assert_equals(paramValue,self.cm.getParam(paramName));
            end
        end        
    end
end