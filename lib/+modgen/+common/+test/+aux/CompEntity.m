classdef CompEntity<handle
    properties (Access=protected)
        alpha
    end
    %
    methods
        function self=CompEntity(alpha)
            self.alpha=alpha;
        end
        function isOk=isequal(varargin)
            sizeVec=size(varargin{1});
            isOk=modgen.common.checksize(varargin{2:end},sizeVec);
            if isOk
                isOkArr=eq(varargin{:});
                isOk=all(isOkArr(:));
            end
        end
        function isOk=isequaln(varargin)
            isOk=isequal(varargin{:});
        end
        function isOk=isequalwithequalnans(varargin)
            isOk=isequal(varargin{:});
        end
        function isPosArr=ne(self,otherObj)
            isPosArr=compare(self,otherObj,@ne,false);
        end
        %
        function isPosArr=eq(self,otherObj,varargin)
            import modgen.common.parseparext;
            [~,~,isAsHandle]=parseparext(varargin,...
                {'asHandle';false},0);
            if isAsHandle
                isPosArr=eq@handle(self,otherObj);
            else
                isPosArr=compare(self,otherObj,@eq,false);
            end
        end
        %
        function isPosArr=le(self,otherObj)
            isPosArr=compare(self,otherObj,@le);
        end
        %
        function isPosArr=lt(self,otherObj)
            isPosArr=compare(self,otherObj,@lt);
        end
        %
        function isPosArr=gt(self,otherObj)
            isPosArr=compare(self,otherObj,@gt);
        end
        %
        function isPosArr=ge(self,otherObj)
            isPosArr=compare(self,otherObj,@ge);
        end
        %
        function isEqArr=compare(self,otherObj,fComp,isCountEqHandles)
            if nargin<4
                isCountEqHandles=true;
            end
            %
            isEqArr=false(size(self));
            nLeftElems=numel(self);
            nRightElems=numel(otherObj);
            %
            nResElems=max(nLeftElems,nRightElems);
            for iElem=1:nResElems
                iLeftElem=min(iElem,nLeftElems);
                iRightElem=min(iElem,nRightElems);
                %
                isEqArr(iElem)=...
                    fComp(self(iLeftElem).alpha,...
                    otherObj(iRightElem).alpha);
            end
            nCalls=nResElems;
            if ~isCountEqHandles
                isEqHandleArr=eq(self,otherObj,'asHandle',true);
                nCalls=nCalls-sum(isEqHandleArr(:));
            end
            incCounter(nCalls);
        end
        function disp(self)
            valArr=arrayfun(@(x)x.alpha,self);
            disp(valArr);
        end
    end
    %
end
function incCounter(nCalls)
modgen.common.test.aux.EqualCallCounter.incEqCounter(nCalls);
end