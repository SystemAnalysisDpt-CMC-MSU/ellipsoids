classdef mlunit_test_crm < mlunitext.test_case
    
    properties (Access=protected)
        cm
        SDefaultEthalon=struct('firstProp','alpha','secondProp','beta');
        factory
    end
    methods (Access=protected)
        function self=initData(self)
            import modgen.configuration.test.*;   
            factory=modgen.configuration.test.ConfRepoManagerFactory('plain');
            cm=factory.getInstance();
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            SConfA=genteststruct(1);
            SConfB=genteststruct(2);
            metaA=struct('a','1','b','2');
            metaB=struct('a','11','b','22');
            %
            self.cm.putConf('testConfA',SConfA,100,metaA);
            self.cm.putConf('testConfB',SConfB,200,metaB);
        end
    end
    methods
        function self = mlunit_test_crm(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = set_up_param(self,factory)
            self.factory=factory;
            self=self.initData();
        end
        function self = test_setGetConf(self)
            import modgen.configuration.test.*;
            SConf=genteststruct(3);
            metaData=struct('a','111','b','222');
            self.cm.putConf('testConfA',SConf,3,metaData);
            [SRes,confVersion,metaDataRes]=self.cm.getConf('testConfA');
            mlunitext.assert_equals(isequalwithequalnans(SConf,SRes),true);
            metaData.version='3';
            mlunitext.assert_equals(isequalwithequalnans(metaData,metaDataRes),true);
            mlunitext.assert_equals(isequalwithequalnans(3,confVersion),true);
        end
        function self = test_copyConfAndgetConfList(self)
            import modgen.configuration.test.*;
            SConf=genteststruct(3);
            self.cm.putConf('testConfA',SConf);
            self.cm.copyConf('testConfA','testConfAA');
            SRes=self.cm.getConf('testConfAA');
            mlunitext.assert_equals(isequalwithequalnans(SConf,SRes),true);
            self.cm.removeConf('testConfB');
            confNameList=self.cm.getConfNameList();
            isEqual=isequal(sort({'testConfA','testConfAA'}),...
                sort(confNameList));
            mlunitext.assert_equals(isEqual,true);
        end        
        function self = test_isParam(self)
            import modgen.configuration.test.*;
            SConf=genteststruct(3);
            self.cm.putConf('testConfA',SConf);
            self.cm.selectConf('testConfA');
            isPos=self.cm.isParam('dConf.gen.cdefs.gen.instTypeCode');
            mlunitext.assert_equals(isPos,true);
            isPos=self.cm.isParam('dConf.gen.cdefs.gen.instTypeCode__');
            mlunitext.assert_equals(isPos,false);
            isPos=self.cm.isParam('.dConf.gen.cdefs.gen.instTypeCode');
            mlunitext.assert_equals(isPos,true);
            
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
                mlunitext.assert_equals(isequalwithequalnans(paramVal,paramVal2),true);
                self.cm.selectConf('testConfB');
                self.cm.setParam(paramName,Inf);
                paramVal3=self.cm.getParam(paramName);            
                mlunitext.assert_equals(isequalwithequalnans(Inf,paramVal3),true);            
                self.cm.selectConf('testConfA');
                paramVal5=self.cm.getParam(paramName);
                mlunitext.assert_equals(isequalwithequalnans(paramVal,paramVal5),true);
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
                mlunitext.assert_equals(true,false);
            catch meObj
                isOk=~isempty(strfind(meObj.identifier,...
                    'CONFREPOMANAGERANYSTORAGE:invalidParam'));
                mlunitext.assert_equals(isOk,true);
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
                origParamValue=self.cm.getParam(paramName);
                paramValue=rand(1);
                self.cm.setParam(paramName,paramValue,'writeDepth','cache');
                mlunitext.assert_equals(true,self.cm.isParam(paramName));
                mlunitext.assert_equals(paramValue,self.cm.getParam(paramName));
                self.cm.flushCache();
                self.cm.selectConf('testConfA');
                mlunitext.assert_equals(true,self.cm.isParam(paramName));
                mlunitext.assert_equals(origParamValue,self.cm.getParam(paramName));
                paramName=[paramName,'_2'];
                paramValue=rand(1);
                self.cm.setParam(paramName,paramValue,'writeDepth','cache');
                mlunitext.assert_equals(true,self.cm.isParam(paramName));
                mlunitext.assert_equals(paramValue,self.cm.getParam(paramName));
                self.cm.flushCache();
                self.cm.selectConf('testConfA');
                mlunitext.assert_equals(false,self.cm.isParam(paramName));
            end
        end        
    end
end