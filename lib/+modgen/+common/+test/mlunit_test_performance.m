classdef mlunit_test_performance < mlunitext.test_case
    properties
    end
    
    methods
        function self = mlunit_test_performance(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
            
        end
         function self=test_parseparext_simple(self)
            %
            inpReg={1};
            inpFirstProp={'aa',1};
            inpSecProp={'bb',2,'cc',3};
            inpProp=[inpFirstProp,inpSecProp];
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext([inpReg,inpProp],[],...
                'propRetMode','list');
            mlunitext.assert_equals(3,length(isPropSpec));
            mlunitext.assert_equals(true,all(isPropSpec));
            mlunitext.assert_equals(true,isRegSpec);            
            mlunitext.assert_equals(true,isequal(reg,inpReg));%
            mlunitext.assert_equals(true,isequal(prop,inpProp));%
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext([inpReg,inpProp],{'bb','cc'},...
                'propRetMode','list');
            mlunitext.assert_equals([true,true,true],isRegSpec);            
            mlunitext.assert_equals(true,isequal(reg,[inpReg,inpFirstProp]));%
            mlunitext.assert_equals(true,isequal(prop,inpSecProp));%  
            mlunitext.assert_equals(true,all(isPropSpec));
            mlunitext.assert_equals(2,length(isPropSpec));
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext({},{'bb','cc'},...
                'propRetMode','list');
            mlunitext.assert_equals(true,isempty(reg));
            mlunitext.assert_equals(true,isempty(prop));
            mlunitext.assert_equals(true,isempty(isRegSpec));
            mlunitext.assert_equals(false,any(isPropSpec));
            mlunitext.assert_equals(2,length(isPropSpec));
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext({},[],...
                'propRetMode','list');
            mlunitext.assert_equals(true,isempty(reg));
            mlunitext.assert_equals(true,isempty(prop));
            mlunitext.assert_equals(true,isempty(isRegSpec));            
            mlunitext.assert_equals(true,isempty(isPropSpec));
            %
            nRegs=1;
            regDefList={1,3};
            nRegExpMax=[0,2];
            initInpArgList={1,'joinByInst',true,'keepJoinId',true};
            propCheckMat={'joinByInst','keepJoinId';...
                false,false;...
                'isscalar(x)&&islogical(x)','isscalar(x)&&islogical(x)'};
            %
            checkMaster();
            nRegExpMax=[1,2];
            checkMaster();
            %
            nRegExpMax=[0,1];
            function checkMaster()
                checkP();
                checkP('regCheckList',{'true'});
                checkP('regCheckList',{@true});
                checkP('regCheckList',{'true','true'});
                checkP('regCheckList',{@true,@true});                
            end
            function checkP(varargin)
                [reg1,isRegSpec1Vec]=checkPInt(varargin{:});
                [reg2,isRegSpec2Vec]=checkPInt(varargin{:},'regDefList',regDefList);
                mlunitext.assert_equals(true,isequal(reg1{1},reg2{1}));
                mlunitext.assert_equals(true,...
                    isequal(isRegSpec1Vec(1),isRegSpec2Vec(1)));
                mlunitext.assert_equals(false,isRegSpec2Vec(2));
                mlunitext.assert_equals(true,isequal(1,length(isRegSpec1Vec)));
                mlunitext.assert_equals(true,isequal(2,length(isRegSpec2Vec)));
                mlunitext.assert_equals(true,isequal(1,length(reg1)));
                mlunitext.assert_equals(true,isequal(2,length(reg2)));
                mlunitext.assert_equals(true,isequal(3,reg2{2}));
                % 
                function [reg,isRegSpecVec]=checkPInt(varargin)
                    [reg,isRegSpecVec,isJoinByInst,isJoinIdKept]=...
                        modgen.common.parseparext(initInpArgList,...
                        propCheckMat,nRegExpMax,...
                        varargin{:});
                    mlunitext.assert_equals(true,isRegSpecVec(1));
                    mlunitext.assert_equals(true,isequal(reg(1:nRegs),{1}));
                    mlunitext.assert_equals(true,isJoinByInst);
                    mlunitext.assert_equals(true,isJoinIdKept);
                end
            end
            
        end
        function self=test_parseparams(self)
            [reg,prop]=getparse({'alpha'});
            mlunitext.assert_equals(true,isequal(reg,{'alpha'}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha','beta',1});
            mlunitext.assert_equals(true,isequal(reg,{'alpha'}));
            mlunitext.assert_equals(true,isequal(prop,{'beta',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1});
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3}));
            mlunitext.assert_equals(true,isequal(prop,{'beta',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1},{'alpha'});
            mlunitext.assert_equals(true,isequal(reg,{3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{'alpha',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1},{});
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1,'gamma',1},'gamma');
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'gamma',1,'beta',1},'gamma');
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1,'gamma',1},'Gamma');
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1},'beta');
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha',1},'beta',[0 2]);
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({1,'alpha'},'alpha');
            mlunitext.assert_equals(true,isequal(reg,{1,'alpha'}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse(...
                {1,'alpha',3,'beta',3,'gamma'},{'alpha','gamma'});
            mlunitext.assert_equals(true,isequal(reg,{1,'beta',3,'gamma'}));
            mlunitext.assert_equals(true,isequal(prop,{'alpha',3}));
            function [reg,prop]=getparse(argList,varargin)
                if (nargin>1)
                    propInpNameList=varargin{1};
                    if isnumeric(propInpNameList)&&isempty(propInpNameList)
                        isPropNameSpec=false;
                    else
                        if ischar(propInpNameList)
                            propInpNameList={lower(propInpNameList)};
                        else
                            propInpNameList=lower(propInpNameList);
                        end
                        isPropNameSpec=true;
                    end
                else
                    isPropNameSpec=false;
                end
                %
                [reg,prop]=modgen.common.parseparams(argList,varargin{:});
                %
                if isPropNameSpec
                    nPairs=length(propInpNameList);
                    outCell=cell(1,2*nPairs);
                    [reg1,outCell{:}]=...
                        modgen.common.parseparext(argList,varargin{:});
                    %
                    [propValList,isSpecVec]=getval(outCell);
                    %
                    propNameList=propInpNameList;
                    %
                    mlunitext.assert_equals(true,isequal(reg,reg1));
                    isEqual=isequal(propNameList,...
                        propInpNameList)||isempty(propNameList)&&...
                        isempty(propInpNameList);
                    mlunitext.assert_equals(true,isEqual);
                    pNameList=propNameList(isSpecVec);
                    pValList=propValList(isSpecVec);
                    inpArgList=[pNameList;pValList];
                    s1=struct(inpArgList{:});
                    s2=struct(prop{:});
                    isEqual=isequal(s1,s2);
                    mlunitext.assert_equals(true,isEqual);
                    %
                    if ~all(isSpecVec)
                        defValList=num2cell(rand(size(propNameList)));
                        [reg2,outCell{:}]=...
                            modgen.common.parseparext(argList,...
                            [propNameList;defValList],varargin{2:end});
                        mlunitext.assert_equals(true,isequal(reg,reg2));
                        [propValList,isSpecVec]=getval(outCell);
                        isEqual=isequal(propValList(~isSpecVec),...
                            defValList(~isSpecVec));
                        mlunitext.assert_equals(true,isEqual);
                        %
                        checkStrList=repmat({'false'},size(defValList));
                        checkStrList(isSpecVec)={'true'};
                        [reg3,outCell{:}]=...
                            modgen.common.parseparext(argList,...
                            [propNameList;defValList;...
                            checkStrList],varargin{2:end});
                        [propValList3,isSpecVec3]=getval(outCell);
                        mlunitext.assert_equals(true,isequal(reg,reg3));
                        mlunitext.assert_equals(true,isequal(propValList3,propValList));
                        mlunitext.assert_equals(true,isequal(isSpecVec,isSpecVec3));
                    end
                end
                %
                function [propValList,isSpecVec]=getval(outCell)
                    propValList=outCell(1:nPairs);
                    isSpecVec=[outCell{nPairs+1:nPairs*2}];
                end
            end
        end
        function self=test_parseparams_negative(self)
            inpArgList={'alpha',1,3,'beta',1,'gamma',1};
            %
            [reg1,prop1]=modgen.common.parseparams(inpArgList);
            [reg2,prop2]=modgen.common.parseparams(inpArgList,[]);
            %
            mlunitext.assert_equals(true,isequal(reg1,reg2));
            mlunitext.assert_equals(true,isequal(prop1,prop2));
            %
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],0);',...
                ':wrongParamList');
            modgen.common.parseparams(inpArgList,[],3);
            modgen.common.parseparams(inpArgList,[],3,[]);
            modgen.common.parseparams(inpArgList,[],3,2);
            modgen.common.parseparams(inpArgList,[],[],2);
            modgen.common.parseparams(inpArgList,[],[3,3]);
            modgen.common.parseparams(inpArgList,[],[3,3],[]);
            modgen.common.parseparams(inpArgList,[],[3,6],2);
            modgen.common.parseparams(inpArgList,[],[0,3],2);
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],3,3);',...
                ':wrongParamList');
            %
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[0,3],2.5);',...
                ':wrongInput');
            %
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[],3);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],3.5,3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[-3 3],2);',...
                ':wrongInput');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[3.5 3.4],3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[3.5 3.4],3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[4 4],2);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[4 6],2);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[0 2],2);',...
                ':wrongParamList');
        end
        function self=test_getfirstdimsize(self)
            expSizeVec=[2,3];
            inpArray=rand([expSizeVec,4,5]);
            mlunitext.assert_equals(expSizeVec,...
                modgen.common.getfirstdimsize(inpArray,2));
            expSizeVec=[2,3,1];
            inpArray=rand([expSizeVec,1,1]);
            mlunitext.assert_equals(expSizeVec,...
                modgen.common.getfirstdimsize(inpArray,3));
            mlunitext.assert_equals([expSizeVec,[1 1]],...
                modgen.common.getfirstdimsize(inpArray,5));
            mlunitext.assert_equals(true,...
                isempty(modgen.common.getfirstdimsize(inpArray,0)));
            self.runAndCheckError(...
                'modgen.common.getfirstdimsize(inpArray,-1)',...
                ':wrongInput');
            %
        end
        function self=test_auxchecksize(self)
            mlunitext.assert_equals(true,auxchecksize(rand(2,3),[2,3,1]));
            mlunitext.assert_equals(true,auxchecksize(rand(2,3),[2,3]));
            mlunitext.assert_equals(false,auxchecksize(rand(2,4),[2,3]));
            mlunitext.assert_equals(false,auxchecksize(rand(2,4,5),[2,4]));
            mlunitext.assert_equals(true,auxchecksize([],[]));
            mlunitext.assert_equals(false,auxchecksize(1,[]));
        end
        function self=test_cat(self)
            typeList={'int8','double','logical','struct'};
            for iType=1:length(typeList)
                for jType=1:length(typeList)
                    iObj=modgen.common.createarray(typeList{iType},[]);
                    jObj=modgen.common.createarray(typeList{jType},[]);
                    res=modgen.common.cat(1,iObj,jObj);
                    mlunitext.assert_equals(true,...
                        isa(res,typeList{iType}));
                end
            end
        end
    end
end