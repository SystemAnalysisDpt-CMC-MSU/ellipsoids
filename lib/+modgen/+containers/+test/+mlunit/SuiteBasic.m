classdef SuiteBasic < mlunitext.test_case
    properties
        map
        mapFactory
        rel1
        rel2
        testParamList
    end
    %
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testMapExtendedTricky(~)
            lenVec=1:200;
            nTries=length(lenVec);
            for iTry=1:nTries
                curLength=lenVec(iTry);
                key1=repmat('-',1,curLength);
                key2=[key1,'-'];
                check();
            end
            for iTry=1:nTries
                curLength=lenVec(iTry);
                keyPref=repmat('-',1,curLength);
                key1=[keyPref,'a',keyPref];
                key2=[keyPref,'b',keyPref];
                check();
            end            
            function SRes=check()
                import modgen.containers.MapExtended;
                mp=MapExtended({key1,key2},{1,2});
                SRes=mp.toStruct();
            end
        end
        function testMapExtendedSimple(~)
            key1='regTube_static_sp[x_1,x_2]_st5, lsGoodDirVec=[0;1],sTime=5_g1';
            key2='regTube_static_sp[x_1,x_2]_st5, lsGoodDirVec=[1;0],sTime=5_g1';
            check();
            %
            key1='---------------------------a----------------';
            key2='---------------------------b----------------';
            check();
            %
            key1='a';
            key2='b';
            SRes=check();
            SExp=struct('a',1,'b',2);
            %
            mlunitext.assert_equals(true,isequal(SRes,SExp));
            %
            key1=sprintf(['Diameters for ',...
                '\nlsGoodDirVec=[0;0;0;0;1;0;0;0],sTime=4']);
            key2=sprintf(['Ellipsoid matrix traces for ',...
                '\nlsGoodDirVec=[0;0;0;0;1;0;0;0],sTime=4']);
            check();
            %
            key1='reachTube_dynamicalonggoodcurve_sp[x_1,x_3]_st4, lsGoodDirVec=[0;0;0;0;1;0;0;0],sTime=4_g1';
            key2='reachTube_dynamicalonggoodcurve_sp[x_1,x_3]_st4, lsGoodDirVec=[0;0;0.70711;0.70711;0;0;0;0],sTime=4_g1';
            check();
            %
            function SRes=check()
                import modgen.containers.MapExtended;
                mp=MapExtended({key1,key2},{1,2});
                SRes=mp.toStruct();
            end
        end
        function self=aux_testMapExtended(self,aKey,bKey,cKey,dKey,eKey)
            import modgen.containers.MapExtended;
            mp=MapExtended();
            mp(aKey)=1;
            mp(bKey)=2;
            mp(cKey)=MapExtended({dKey,eKey},{1,2});
            SRes=mp.toStruct();
            %
            key2FieldName=@MapExtended.key2FieldName;
            aVarKey=key2FieldName(aKey);
            bVarKey=key2FieldName(bKey);
            cVarKey=key2FieldName(cKey);
            dVarKey=key2FieldName(dKey);
            eVarKey=key2FieldName(eKey);
            %
            SExp=struct(aVarKey,1,bVarKey,2,cVarKey,...
                struct(dVarKey,1,eVarKey,2));
            %
            mlunitext.assert_equals(true,isequal(SRes,SExp));
            mp2=mp.getCopy();
            checkIfEqual(true);
            mp(aKey)=2;
            checkIfEqual(false);
            %
            mp=MapExtended();
            mp2=mp.getCopy();
            checkIfEqual(true);
            mp(aKey)=2;
            checkIfEqual(false);
            
            function checkIfEqual(isPos)
                isPosExp=isequal(mp,mp2);
                [isPosAct,reportStr]=mp.isEqual(mp2);
                mlunitext.assert_equals(isPosAct,isPosExp);
                mlunitext.assert_equals(isPos,isPosAct,reportStr);
                mp3=mp.getCopy();
                isOk=isequal(mp,mp3);
                mlunitext.assert(isOk);
                [isOk,reportStr]=mp.isEqual(mp3);
                mlunitext.assert(isOk,reportStr);
                %
                if modgen.common.isunique([mp.keys,mp2.keys])
                    mpA=mp.getUnionWith(mp2);
                    mpB=mp2.getUnionWith(mp);
                    [isOk,reportStr]=mpA.isEqual(mpB);
                    mlunitext.assert(isOk,reportStr);
                end
            end
        end
        %
        function self=test_MapExtended(self,varargin)
            self.aux_testMapExtended('a','b','c','d','e');
        end
        %
        function self=test_MapExtended_ArbKey(self,varargin)
            self.aux_testMapExtended('a a','b b','c c','d d','e e');
        end
        %
        %
        function self=test_MapExtended_LongKey(self,varargin)
            self.aux_testMapExtended(repmat('a',1,300),...
                repmat('a',1,301),'c c','d d','e e');
        end
    end
end