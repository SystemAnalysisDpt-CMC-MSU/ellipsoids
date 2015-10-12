classdef HandleObjectClonerTC < mlunitext.test_case
    methods
        function self = HandleObjectClonerTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function testUniqueNotInBinaryMode(self)
            objVec=modgen.common.obj.test.HandleObjectClonerAdv.create(...
                [1,2,1],[1,2,2]);
            isOk=eq(objVec(1),objVec(3));
            mlunitext.assert(isOk);
            isOk=isEqual(objVec(1),objVec(3),'asBlob',true);
            mlunitext.assert(~isOk);
            isOk=isEqual(objVec(1),objVec(3),'asHandle',true);
            mlunitext.assert(~isOk);
            self.runAndCheckError(...
                'isOk=isEqual(objVec(1),objVec(3),''asHandle'',true,''asBlob'',true);',...
                'wrongInput:blobAndHandleIncompatible');
            %
            unqVec=unique(objVec);
            sortVec=sort(objVec);
            isOk=numel(unqVec)==3;
            mlunitext.assert(isOk);
            isOk=~any(isEqualElem(unqVec(1:end-1),unqVec(2:end),'asBlob',true));
            mlunitext.assert(isOk);
            isOk=all(isEqualElem(unqVec,sortVec,'asBlob',true));
            mlunitext.assert(isOk);
            isOk=isEqual(unqVec,sortVec,'asBlob',true);
            mlunitext.assert(isOk);
        end
        function testEqAsHandle(self)
            obj=modgen.common.obj.test.HandleObjectCloner(1);
            self.checkEqAsHandle(obj);
        end
        function testAtemptToSortNotInBinaryMode(self)
            objVec=modgen.common.obj.test.HandleObjectCloner.create(2);
            self.runAndCheckError(@()modgen.algo.sort.mergesort(objVec),...
                'wrongInput:signNotDefForAllElems');
        end
        function testUniqueIsmemberCallNumber(~)
            import modgen.common.test.aux.EqualCallCounter;
            %
            nObjVec=[3,2,5];
            for iCase=1:numel(nObjVec)
                nObj=nObjVec(iCase);
                objVec=...
                    modgen.common.obj.test.HandleObjectClonerTrickyCount.create(nObj);
                EqualCallCounter.checkCalls(objVec);
            end
        end        
    end
    methods (Static)
        function checkEqAsHandle(obj)
            obj2=obj.clone;
            check(false,'asHandle',true);
            check(true);
            %
            function check(isPosExpected,varargin)
                chk(@isequal);
                chk(@eq);
                chk(@(varargin)~ne(varargin{:}));
                chk(@isequaln);
                chk(@isequalwithequalnans);
                function chk(fOp)
                isEq=fOp(obj,obj2,varargin{:});
                mlunitext.assert_equals(isEq,isPosExpected);
                end
            end            
        end
    end
end