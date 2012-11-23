classdef Ellipsoid < handle
    properties (SetAccess = private)
        centerVec
        diagMat
        eigvMat
    end
    methods
        function ellObj = Ellipsoid(varargin)
            import modgen.common.throwerror
            CHECK_TOL=1e-12;
            %
            nInput=nargin;
            if  nInput>3
                throwerror('wrongParameters','Incorrect number of parameters');
            elseif nInput==1   
                ellMat=varargin{1};
                [mSize nSize]=size(ellMat);
                isPar2Vector= nSize==1;
                %
                if isPar2Vector
                    ellObj.diagMat=diag(ellMat);
                    ellObj.eigvMat=eye(size(ellObj.diagMat));
                elseif (mSize~=nSize) || (min(min((ellMat == ellMat.'))) == 0)
                    throwerror('wrongMatrix',...
                        'Input should be a symmetric matrix or a vector.');
                else
                    isDiagonalMat=ellMat==(ellMat.*eye(mSize));
                    if all(isDiagonalMat(:))
                      ellObj.diagMat=ellMat;
                        ellObj.eigvMat=eye(mSize);
                    else %ordinary square matrix
                        [ellObj.eigvMat ellObj.diagMat]=eig(ellMat);
                
                    end
                end
                ellObj.centerVec=zeros(mSize,1);                
            elseif nInput==2
                ellCenterVec=varargin{1};
                ellMat=varargin{2};
                [mCenSize nCenSize]=size(ellCenterVec);
                [mSize nSize]=size(ellMat);
                isPar2Vector= nSize==1;
                %
                if isPar2Vector
                    ellObj.diagMat=diag(ellMat);
                    ellObj.eigvMat=eye(size(ellObj.diagMat));
                elseif (mSize~=nSize) || (min(min((ellMat == ellMat.'))) == 0)
                    throwerror('wrongMatrix',...
                        'Input should be a symmetric matrix or a vector.');
                else
                    isDiagonalMat=ellMat==(ellMat.*eye(mSize));
                    if  all(isDiagonalMat(:))
                        ellObj.diagMat=ellMat;
                        ellObj.eigvMat=eye(mSize);
                    else %ordinary square matrix
                        [ellObj.eigvMat ellObj.diagMat]=eig(ellMat);
                    end
                end
                if nCenSize~=1
                    throwerror('wrongCenter','Center must be a vector');
                end
                if mSize~=mCenSize
                    throwerror('wrongDimensions',...
                        'Dimension of center vector must be the same as matrix');
                end
                ellObj.centerVec=ellCenterVec;                
            elseif nInput == 3
                ellCenterVec=varargin{1};
                ellDiagMat=varargin{2};
                ellWMat=varargin{3};
                [mCenSize nCenSize]=size(ellCenterVec);
                [mDSize nDSize]=size(ellDiagMat);
                [mWSize nWSize]=size(ellWMat);
                %
                if (nCenSize~=1)
                    throwerror('wrongCenter','Center must be a vector');
                end
                if (mCenSize ~=mDSize || mCenSize~=mWSize)
                    throwerror('wrongDimensions',...
                    'Input matrices and center vector must be of the same dimension');
                end
                if (nDSize>1) 
                    if nDSize~=mDSize  
                        throwerror('wrongDiagonal',...
                        'Second argument should be either diagonal matrix or a vector');
                    end
                    isDiagonal=ellDiagMat==(ellDiagMat.*eye(mDSize));
                    if ~isDiagonal
                        throwerror('wrongDiagonal',...
                        'Second argument should be either diagonal matrix or a vector');
                    end            
                end
                if (nWSize~=mWSize)
                    throwerror('wrongParameters',...
                        'Third parameter should be a square matrix');
                end
                if (nDSize==1)
                    diagVec=ellDiagMat;
                else
                    diagVec=diag(ellDiagMat);
                end
                isInfVec=diagVec==Inf;
                [~,wRMat]=qr(ellWMat);
                if all(all(abs(abs(wRMat)-eye(size(wRMat)))<CHECK_TOL))
                    %W is orthogonal
                    diagResVec=diagVec;
                    eigvResMat=ellWMat;
                elseif all(~isInfVec)
                    ellAuxMat=ellWMat*diag(diagVec)*ellWMat.';
                    [eigvResMat diagResMat]=eig(ellAuxMat);
                    eigvResMat=-eigvResMat;
                    diagResVec=diag(diagResMat);
                else
                    allInfMat=ellWMat(:,isInfVec);
                    %L1 and L2 Basis
                    [orthBasMat rBasMat]=qr(allInfMat);
                    if size(rBasMat,2)==1
                        isNeg=rBasMat(1)<0;
                        orthBasMat(:,isNeg)=-orthBasMat(:,isNeg);
                    else
                        isNegVec=diag(rBasMat)<0;
                        orthBasMat(:,isNegVec)=-orthBasMat(:,isNegVec);
                    end
                    %Find rang L1, here rangL1>0
                    tolerance = CHECK_TOL*norm(allInfMat,'fro');
                    rangL1 = sum(abs(diag(rBasMat)) > tolerance);
                    rangL1 = rangL1(1);%for case where rBasMat is a vector.
                    %L1 - first rangL1 columns of orthBasMat.
                    infIndVec=1:rangL1;
                    finIndVec=(rangL1+1):mWSize;
                    nonInfBasMat = orthBasMat(:,finIndVec);
                    %Projecton of directions on L2. Is finite then is finite 
                    diagResVec=zeros(mDSize,1);  
                    if ~isempty(nonInfBasMat)
                        projMat=nonInfBasMat.'*ellWMat;
                        isZeroProjVec=all(abs(projMat)<CHECK_TOL,1);
                        if ~all(isZeroProjVec)
                            diagVec(isInfVec)=0;
                            ellAuxMat=projMat*diag(diagVec)*projMat.';
                            [~,nonInfDMat]=eig(ellAuxMat);
                            diagResVec(finIndVec)=diag(nonInfDMat);
                        end
                    end
                    diagResVec(infIndVec)=Inf;
                    eigvResMat=orthBasMat;
                end
                ellObj.diagMat=diag(diagResVec);
                ellObj.eigvMat=eigvResMat;
                ellObj.centerVec=ellCenterVec;
            end
            if (nInput~=0)
                minEigVal=min(diag(ellObj.diagMat));       
                if (minEigVal<0 && abs(minEigVal)> CHECK_TOL)
                    throwerror('wrongMatrix',...
                        'Ellipsoid matrix should be positive semi-definite.')
                end
            end
        end
        ellObj = inv (ellObj)
        ellObjVec = minksumNew_ea(ellObjVec, dirMat)
        ellObjVec = minksumIa(ellObjVec, dirMat)
        ellObjVec = minkdiffNew_ia(ellObj1, ellObj2, dirMat)
        ellObjVec = minkdiffEa(ellObj1, ellObj2, dirMat)
        distVec = distace(ellObjVec, objVec)
    end
end

