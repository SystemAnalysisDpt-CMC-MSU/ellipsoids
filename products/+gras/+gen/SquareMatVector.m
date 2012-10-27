classdef SquareMatVector<gras.gen.MatVector
    %MATVECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        function invDataArray=inv(dataArray)
            sizeVec=size(dataArray);
            invDataArray=zeros(sizeVec);
            for t=1:1:sizeVec(3)
                invDataArray(:,:,t)=inv(dataArray(:,:,t));
            end
        end
        function resArray=evalMFunc(fHandle,dataArray,varargin)
            import modgen.common.throwerror;
            [~,~,isUniformOutput,isSizeKept]=modgen.common.parseparext(varargin,...
                {'UniformOutput','keepSize';...
                true,false;...
                'islogical(x)&&isscalar(x)','islogical(x)&&isscalar(x)'},0);
            nElems=size(dataArray,3);
            if ~isUniformOutput
                resArray=cell(nElems,1);
                for iElem=1:nElems
                    resArray{iElem}=fHandle(dataArray(:,:,iElem));
                end
            else
                if isSizeKept
                    resArray=dataArray;
                    for iElem=1:nElems
                        resArray(:,:,iElem)=fHandle(dataArray(:,:,iElem));
                    end
                else
                    resArray=zeros(nElems,1);
                    for iElem=1:nElems
                        resArray(iElem)=fHandle(dataArray(:,:,iElem));
                    end
                end
            end
        end
        function sqrtDataArray=sqrtm(dataArray)
            sizeVec=size(dataArray);
            if length(sizeVec)==2
                sizeVec(3)=1;
            end;
            sqrtDataArray=zeros(sizeVec);
            for t=1:1:sizeVec(3)
                if isnan(dataArray(:,:,t))
                    sqrtDataArray(:,:,t)=nan;
                    continue;
                end;
                [V,D] = eig(squeeze(dataArray(:,:,t)));
                d=diag(D);
                sqrtDataArray(:,:,t)=real(V*diag(sqrt(abs(d)))*V');
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
            OutArray=zeros([ASizeVec(1) ASizeVec(1) BSizeVec(3)]);
            switch flag
                case 'L',
                    for t=1:1:BSizeVec(3)
                        OutArray(:,:,t)=InpAArray(:,:,t)*...
                            InpBArray(:,:,t)*transpose(InpAArray(:,:,t));
                    end;
                case 'R',
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
                bInvMat=inv(InpBArray);
                outVec=sum((bInvMat*InpAArray).*InpAArray,1);
            else
                outVec=zeros(1,nElems);
                for iElem=1:nElems
                    outVec(iElem)=transpose(InpAArray(:,iElem))*...
                        (InpBArray(:,:,iElem)\InpAArray(:,iElem));
                end
            end
        end           
    end
end
