classdef ObjectApproxControlParams
    properties (Constant=true)
        nAddTopElems=32;
        errorCheckMode=1.e-3;
        approxPrec=1;
        freeMemoryMode=0;
        discardIneqMode=1;
        incDim=0;
        faceDist=.9e-5;
        inApproxDist=1.e-4;
        ApproxDist=1.e-5;
        precTest=1.e-4;
        relPrec=1.e-5;
        inftyDef=1.e6;
        isVerbose=0;
    end
    methods
        
        function propVal=getPropValue(self,propName) %#ok<MANU>
            propVal=elltool.multobj.ObjectApproxControlParams.(propName);
        end
        
        function defaultValVec=getValues(self,PROP_LIST)
            defaultValVec=cell(1,numel(PROP_LIST));
            for iElem=1:numel(PROP_LIST)
                defaultValVec{iElem}= self.getPropValue(PROP_LIST{iElem});
            end
        end
        function SParams=parseParams(self,paramsSetList,PROP_LIST)
            import modgen.common.checkmultvar;
            valList=cell(1,numel(PROP_LIST));
            defaultValVec=self.getValues(PROP_LIST);
            fieldList=PROP_LIST;
            [~,~,valList{:}]=...
                modgen.common.parseparext(paramsSetList,{PROP_LIST{:};...
                defaultValVec{:};});
            SParamsValCMat=[fieldList;valList];
            SParams=struct(SParamsValCMat{:});
            
        end
        
    end
end