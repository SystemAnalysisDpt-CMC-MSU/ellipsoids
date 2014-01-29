classdef SquareMatVector<gras.gen.MatVector
    %MATVECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        function invDataArray=inv(dataArray)
            sizeVec=[size(dataArray), 1];
            invDataArray=zeros(sizeVec);
            for t=1:1:sizeVec(3)
                invDataArray(:,:,t)=inv(dataArray(:,:,t));
            end
        end
        function sqrtDataArray=sqrtmpos(dataArray)
            sizeVec=size(dataArray);
            if length(sizeVec)==2
                sizeVec(3)=1;
            end;
            sqrtDataArray=zeros(sizeVec);
            for t=1:sizeVec(3)
                if isnan(dataArray(:,:,t))
                    sqrtDataArray(:,:,t)=nan;
                    continue;
                end;
                sqrtDataArray(:,:,t) = ...
                    gras.la.sqrtmpos(squeeze(dataArray(:,:,t)));
            end
        end
        function dataArray=makePosDefiniteOrNan(dataArray)
            sizeVec=size(dataArray);
            if length(sizeVec)==2
                sizeVec(3)=1;
            end;
            smin=zeros(1,sizeVec(3));
            for t=1:1:sizeVec(3)
                smin(t)=min(eig(squeeze(dataArray(:,:,t))));
            end;
            dataArray(:,:,smin<=0)=nan;
        end
        function dataArray=makePosDefiniteByEig(dataArray,value)
            EPS=1e-12;
            if nargin<2
                value=EPS;
            end
            sizeVec=size(dataArray);
            if length(sizeVec)==2
                sizeVec(3)=1;
            end;
            res=zeros(sizeVec);
            for t=1:1:sizeVec(3)
                [V,D] = eig(squeeze(dataArray(:,:,t)));
                d=diag(D);
                d(d<0)=value;
                res(:,:,t)=real(V*diag(d)*V');
            end
        end
        %
        function OutArray=lrMultiply(InpBArray,InpAArray,flag)
            import modgen.common.throwerror;
            if isequal(nargin,2)
                flag='R';
            end;
            BSizeVec=size(InpBArray);
            ASizeVec=size(InpAArray);
            if length(BSizeVec)==2
                BSizeVec(3)=1;
            end;
            switch flag
                case 'L',
                    OutArray=zeros([ASizeVec(1) ASizeVec(1) BSizeVec(3)]);
                    for t=1:1:BSizeVec(3)
                        OutArray(:,:,t)=InpAArray(:,:,t)*...
                            InpBArray(:,:,t)*transpose(InpAArray(:,:,t));
                    end;
                case 'R',
                    OutArray=zeros([ASizeVec(2) ASizeVec(2) BSizeVec(3)]);
                    for t=1:1:BSizeVec(3)
                        OutArray(:,:,t)=transpose(...
                            InpAArray(:,:,t))*InpBArray(:,:,t)*...
                            InpAArray(:,:,t);
                    end;
                otherwise,
                    throwerror('wrongInput',...
                        sprintf('flag %s is not supported',flag));
            end
        end
        function OutVec=lrMultiplyByVec(InpBArray,InpAArray)
            import modgen.common.throwerror;
            ASizeVec=size(InpAArray);
            nElems=ASizeVec(2);
            %
            nMatElems=size(InpBArray,3);
            if nMatElems==1
                indMatVec=ones(1,nElems);
            else
                indMatVec=1:nElems;
            end
            OutVec=zeros(1, nElems);
            for iElem=1:nElems
                OutVec(:,iElem)=transpose(InpAArray(:,iElem))*...
                    InpBArray(:,:,indMatVec(iElem))*InpAArray(:,iElem);
            end
        end
        function outVec=lrDivideVec(InpBArray,InpAArray)
            import modgen.common.throwerror;
            ASizeVec=size(InpAArray);
            nElems=ASizeVec(2);
            %
            nMatElems=size(InpBArray,3);
            if nMatElems==1
                outVec=sum((InpBArray\InpAArray).*InpAArray,1);
            else
                outVec=zeros(1,nElems);
                if size(InpAArray,2)==1
                    for iElem=1:nMatElems
                        outVec(iElem)=transpose(InpAArray)*...
                            (InpBArray(:,:,iElem)\InpAArray);
                    end
                else
                    for iElem=1:nElems
                        outVec(iElem)=transpose(InpAArray(:,iElem))*...
                            (InpBArray(:,:,iElem)\InpAArray(:,iElem));
                    end
                end
            end
        end
    end
end
