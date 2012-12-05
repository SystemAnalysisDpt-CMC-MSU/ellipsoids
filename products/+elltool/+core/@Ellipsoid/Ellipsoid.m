classdef Ellipsoid < handle
% ELLIPSOID - class of generalized ellipsoids
%
% Input:
%   Case1:
%     regular:
%       qVec: double[nDim,1] - ellipsoid center
%       qMat: double[nDim,nDim] / qVec: double[nDim,1] - ellipsoid matrix
%           or diagonal vector of eigenvalues, that may contain infinite
%           or zero elements
%
%   Case2:
%     regular:
%       qMat: double[nDim,nDim] / qVec: double[nDim,1] - diagonal matrix or
%           vector, may contain infinite or zero elements
%
%   Case3:
%     regular:
%       qVec: double[nDim,1] - ellipsoid center
%       dMat: double[nDim,nDim] / dVec: double[nDim,1] - diagonal matrix or
%           vector, may contain infinite or zero elements
%       wMat: double[nDim,nDim] - any square matrix
%
%
% Output:
%   self: Ellipsoid[1,1] - created generalized ellipsoid
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
    properties (Access = private)
        centerVec
        diagMat
        eigvMat
    end
    properties (Constant,GetAccess = private)
        CHECK_TOL=1e-09;
    end
    methods
        function ellObj = Ellipsoid(varargin)
            import modgen.common.throwerror
            import elltool.core.Ellipsoid;
            %
            absTol=ellObj.CHECK_TOL;
            %
            nInput=nargin;
            if  nInput>3
                throwerror('wrongParameters',...
                    'Incorrect number of parameters');
            elseif nInput==1
                ellMat=varargin{1};
                [mSize nSize]=size(ellMat);
                isPar2Vector= nSize==1;
                %
                if isPar2Vector
                    ellObj.diagMat=diag(ellMat);
                    ellObj.eigvMat=eye(size(ellObj.diagMat));
                elseif (mSize~=nSize) ||...
                        (min(min((ellMat == ellMat.'))) == 0)
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
                elseif (mSize~=nSize)
                    throwerror('wrongMatrix',...
                        'Input should be a symmetric matrix or a vector.');
                else
                    isDiagonalMat=ellMat==(ellMat.*eye(mSize));
                    if  all(isDiagonalMat(:))
                        ellObj.diagMat=ellMat;
                        ellObj.eigvMat=eye(mSize);
                    else
                        if ~(all(all(( ellMat - ellMat.')<absTol)))
                            %matrix should be symmetric
                            throwerror('wrongMatrix',...
                                ['Input should be a ',...
                                'symmetric matrix or a vector.']);
                        else
                            [ellObj.eigvMat ellObj.diagMat]=eig(ellMat);
                        end
                    end
                end
                if nCenSize~=1
                    throwerror('wrongCenter','Center must be a vector');
                end
                if mSize~=mCenSize
                    throwerror('wrongDimensions',...
                        ['Dimension of center vector must ',...
                        'be the same as matrix']);
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
                        ['Input matrices and center vector must ',...
                        'be of the same dimension']);
                end
                if (nDSize>1)
                    if nDSize~=mDSize
                        throwerror('wrongDiagonal',...
                            ['Second argument should be either ',...
                            'diagonal matrix or a vector']);
                    end
                    isDiagonal=all(all(ellDiagMat==...
                        (ellDiagMat.*eye(mDSize))));
                    if ~isDiagonal
                        throwerror('wrongDiagonal',...
                            ['Second argument should be either ',...
                            'diagonal matrix or a vector']);
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
                if all(all(abs(abs(wRMat)-eye(size(wRMat)))<absTol))
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
                    %Find rank L1, here rankL1>0
                    tolerance = absTol*norm(allInfMat,'fro');
                    rankL1 = sum(abs(diag(rBasMat)) > tolerance);
                    rankL1 = rankL1(1);%for case where rBasMat is a vector.
                    %L1 - first rankL1 columns of orthBasMat.
                    infIndVec=1:rankL1;
                    finIndVec=(rankL1+1):mWSize;
                    nonInfBasMat = orthBasMat(:,finIndVec);
                    %Projecton of directions on L2. Is finite then is finite
                    diagResVec=zeros(mDSize,1);
                    if ~isempty(nonInfBasMat)
                        projMat=nonInfBasMat.'*ellWMat;
                        isZeroProjVec=all(abs(projMat)<absTol,1);
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
                if (minEigVal<0 && abs(minEigVal)> absTol)
                    throwerror('wrongMatrix',...
                        ['Ellipsoid matrix should be positive ',...
                        'semi-definite.'])
                end
            end
        end
    end
    methods
        function cVec=getCenter(self)
            cVec=self.centerVec;
        end
        function eigMat=getEigvMat(self)
            eigMat=self.eigvMat;
        end
        function diagMat=getDiagMat(self)
            diagMat=self.diagMat;
        end
    end
    methods (Static)
        function tol=getCheckTol()
            import elltool.core.Ellipsoid;
            tol=Ellipsoid.CHECK_TOL;
        end
    end
    methods (Static,Access = private)
        [isOk, pPar] = findIsGoodDir(ellQ1Mat,ellQ2Mat,dirVec)
        sqMat = findSqrtOfMatrix(qMat,absTol)
        isBigger=checkBigger(ellObj1,ellObj2,nDimSpace,absTol)
        [isInfVec infDirEigMat] = findAllInfDir(ellObj)
        [orthBasMat rank]=findBasRank(qMat,absTol)
        [ spaceBasMat,  oSpaceBasMat, spaceIndVec, oSpaceIndVec] =...
            findSpaceBas( dirMat,absTol )
        [ projQMat ] = findMatProj( eigvMat,diagMat,basMat )
        [diagQVec, resQMat]=findConstruction(firstEllMat,...
            firstBasMat,secBasMat,firstIndVec,secIndVec,secDiagVec)
        resQMat=findDiffEaND(ellQ1Mat, ellQ2Mat,curDirVec,absTol)
        [resEllMat ] = findDiffFC( fMethod, ellQ1Mat, ellQ2Mat,...
            curDirVec,absTol )
        [ resQMat diagQVec ] = findDiffINFC(fMethod, ellObj1,...
            ellObj2,curDirVec,isInf1Vec,absTol)
        resQMat=findDiffIaND(ellQ1Mat, ellQ2Mat,curDirVec,absTol)
    end
end