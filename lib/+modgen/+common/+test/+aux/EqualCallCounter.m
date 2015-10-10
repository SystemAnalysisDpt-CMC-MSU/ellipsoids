classdef EqualCallCounter<modgen.common.obj.StaticPropStorage
    methods (Static)
        function [propVal,isThere]=getProp(propName,varargin)
            branchName=mfilename('class');
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,varargin{:});
        end
        function setProp(propName,propVal)
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        function flush()
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.flushInternal(branchName);
        end
        function val=getEqCounter()
            import modgen.common.test.aux.EqualCallCounter;
            [val,isThere]=EqualCallCounter.getProp('isEqCallCount',true);
            if ~isThere
                val=0;
            end
        end
        function setEqCounter(val)
            modgen.common.test.aux.EqualCallCounter.setProp(...
                'isEqCallCount',val);
        end
        function incEqCounter(valInc)
            import modgen.common.test.aux.EqualCallCounter;
            val=EqualCallCounter.getEqCounter();
            val=val+valInc;
            EqualCallCounter.setEqCounter(val);
        end
        %
        function checkNCallsEquality(fList)
            nFunc=numel(fList);
            callNumVec=nan(1,nFunc);
            for iFunc=1:nFunc
                callNumVec(iFunc)=getNCalls(fList{iFunc});
            end
            isOk=isequal(callNumVec(1:end-1),callNumVec(2:end));
            mlunitext.assert(isOk);
        end
        %
        function checkNotSortableCalls(objVec)
            import modgen.common.test.aux.EqualCallCounter;            
            EqualCallCounter.checkNCallsEquality({...
                @()modgen.common.ismemberjoint({objVec},{objVec(2:end)}),...
                @()ismember(objVec,objVec(2:end))});
            EqualCallCounter.checkNCallsEquality({...
                @()modgen.common.ismemberjoint({objVec},{objVec}),...
                @()ismember(objVec,objVec)});
            EqualCallCounter.checkNCallsEquality({...
                @()unique(objVec),...
                @()modgen.common.uniquejoint({objVec})});
        end
        %
        function checkCalls(objVec,isBuiltInsChecked)
            import modgen.common.test.aux.EqualCallCounter;
            if nargin<2
                isBuiltInsChecked=true;
            end
            nRels=numel(objVec);
            %
            check(@()(isequal(objVec(1),objVec(2))),1);
            check(@()(isequaln(objVec(1),objVec(2))),1);
            check(@()(isequalwithequalnans(objVec(1),objVec(2))),1); %#ok<DISEQN>
            %
            nSortCalls=getNCalls(@()sort(objVec));
            sortedObjVec=sort(objVec);
            nDoubleSortCalls=getNCalls(@()sort([sortedObjVec,sortedObjVec]));
            doubleSortedObjVec=sort([sortedObjVec,sortedObjVec]);
            nHandleComparisons=sum(eq(doubleSortedObjVec(1:end-1),...
                doubleSortedObjVec(2:end),'asHandle',true));
            fUniqCplx=@(x)(x-1+nSortCalls);
            fIsMembCplx=@(x)(2*fUniqCplx(x)+2*x-1-nHandleComparisons+nDoubleSortCalls);
            %
            nCallsForBuiltInUniq=fUniqCplx(nRels);
            if ismethod(objVec,'sort')
                nCallsForUniqJoint=nCallsForBuiltInUniq;
            else
                nCallsForUniqJoint=nRels*(nRels-1)*0.5;
            end
            %
            if isBuiltInsChecked
                check(@()unique(objVec),nCallsForBuiltInUniq);
            end
            check(@()modgen.common.uniquejoint({objVec}),nCallsForUniqJoint);
            %
            nEqCallsForBuiltInIsMember=fIsMembCplx(nRels);
            if isBuiltInsChecked
                check(@()ismember(objVec,objVec),nEqCallsForBuiltInIsMember);
            end
            check(@()modgen.common.ismemberjoint({objVec},{objVec}),...
                nEqCallsForBuiltInIsMember);
            check(@()modgen.common.ismember(objVec,objVec),...
                nEqCallsForBuiltInIsMember);            
            %
            function check(fHandle,nExpCalls)
                nCalls=getNCalls(fHandle);
                isOk=isequal(nExpCalls,nCalls);
                mlunitext.assert(isOk);
            end
        end
        function nCalls=getNCalls(fHandle)
            nCalls=getNCalls(fHandle);
        end
    end
end
function nCalls=getNCalls(fHandle)
modgen.common.test.aux.EqualCallCounter.setEqCounter(0);
%
feval(fHandle);
%
nCalls=modgen.common.test.aux.EqualCallCounter.getEqCounter();

end
