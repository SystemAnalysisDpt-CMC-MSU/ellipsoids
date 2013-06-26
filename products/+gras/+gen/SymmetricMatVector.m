classdef SymmetricMatVector<gras.gen.SquareMatVector
    %SYMMETRICMATVECTOR Summary of this class goes here
    %   Detailed explanation goes here
    methods (Static)
        function OutArray=lrSvdMultiply(InpBArray,InpAArray,flag)
            import gras.gen.MatVector;
            import gras.gen.SquareMatVector;
            import modgen.common.throwerror;
            if isequal(nargin,2)
                flag='R';
            end;
            [uArray, sArray] = arraysvd(InpBArray);            
            switch flag
                case 'L',
                    uaArray = SquareMatVector.rMultiply(uArray, ...
                        MatVector.transpose(InpAArray));
                case 'R',
                    uaArray = SquareMatVector.rMultiply(uArray, InpAArray);
                otherwise,
                    throwerror('wrongInput',...
                        sprintf('flag %s is not supported',flag));
            end
            OutArray = SquareMatVector.lrMultiply(sArray, uaArray, flag);
        end
        function outVecArray=rSvdMultiplyByVec(inpMatArray, inpVecArray)
            import gras.gen.MatVector;
            import modgen.common.throwerror;
            %
            [uArray, sArray] = arraysvd(inpMatArray);
            uvArray = MatVector.rMultiplyByVec(uArray, inpVecArray);
            if ~ismatrix(inpVecArray)
                throwerror('wrongInput',...
                    'inpVecArray is expected to be 2-dimensional array');
            end
            mSizeVec = size(sArray);
            vSizeVec = size(uvArray);
            outVecArray = zeros([mSizeVec(1), vSizeVec(2)]);
            for t = 1:1:vSizeVec(2)
                outVecArray(:,t) = (uArray(:,:,t))' * sArray(:,:,t) * ...
                    uvArray(:,t);
            end;
        end
        function OutVec=lrSvdMultiplyByVec(InpBArray,InpAArray)
            import gras.gen.MatVector;
            import gras.gen.SquareMatVector;
            %
            [uArray, sArray] = arraysvd(InpBArray);
            uaArray = MatVector.rMultiplyByVec(uArray, InpAArray);
            OutVec = SquareMatVector.lrMultiplyByVec(sArray, uaArray);
        end
        function outVec=lrSvdDivideVec(InpBArray,InpAArray)
            import gras.gen.MatVector;
            import gras.gen.SquareMatVector;
            %
            [uArray, sArray] = arraysvd(InpBArray);
            uaArray = MatVector.rMultiplyByVec(uArray, InpAArray);
            %
            ASizeVec=size(InpAArray);
            nElems=ASizeVec(2);
            %
            nMatElems=size(InpBArray,3);
            if nMatElems==1
                bInvMat = diag(1 ./ diag(sArray));
                outVec=sum((bInvMat*uaArray).*uaArray,1);
            else
                outVec=zeros(1,nElems);
                for iElem=1:nElems
                    bInvMat = diag(1 ./ diag(sArray(:,:,iElem)));
                    outVec(iElem) = transpose(uaArray(:,iElem)) * ...
                        (bInvMat * uaArray(:,iElem));
                end
            end
        end
    end  
end
function [uArray, sArray] = arraysvd(symArray)
    sizeVec = size(symArray);
    if length(sizeVec) == 2
        sizeVec = horzcat(sizeVec, 1);
    end
    uArray = zeros(sizeVec);
    sArray = zeros(sizeVec);
    for t = 1:sizeVec(3)
        [uArray(:,:,t), sArray(:,:,t)] = eig(symArray(:,:,t));
    end
end

