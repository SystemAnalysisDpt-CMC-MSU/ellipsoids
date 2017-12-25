classdef GenEllipsoid < elltool.core.AEllipsoid
    % GENELLIPSOID - class of generalized ellipsoids
    %
    properties(Access=protected)
        shapeMat
        diagMat
        eigvMat
    end
    methods(Access=protected,Static)
        checkIsMe(ellArr,varargin)
    end
    methods(Access=protected)
        shapeSingleInternal(ellObj,isModScal,modMat)
        projectionSingleInternal(ellObj,ortBasisMat)
        function checkIsMeVirtual(ellArr,varargin)
            elltool.core.GenEllipsoid.checkIsMe(ellArr,varargin)
        end
        copyEllObj=getSingleCopy(ellObj)
    end
    methods
        polar=getScalarPolarInternal(self,isRobustMethod)
        [ellCenterVec,ellDiagMat,ellEigvMat]=parameters(ell)
        function isOk=getIsGoodDir(ellObj1,ellObj2,curDirVec)
            % Example:
            %   firstEllObj=elltool.core.GenEllipsoid([10;0],2*eye(2));
            %   secEllObj=elltool.core.GenEllipsoid([0;0],[1 0; 0 0.1]);
            %   curDirMat=[1; 0];
            %   isOk=getIsGoodDir(firstEllObj,secEllObj,dirsMat)
            %
            %   isOk =
            %
            %        1
            %
            import elltool.core.GenEllipsoid;
            ellObj=feval(class(ellObj1));
            absTol=ellObj.getAbsTol();
            eigv1Mat=ellObj1.getEigvMat();
            eigv2Mat=ellObj2.getEigvMat();
            diag1Vec=diag(ellObj1.getDiagMat());
            diag2Vec=diag(ellObj2.getDiagMat());
            isInf1Vec=diag1Vec==Inf;
            if ~all(~isInf1Vec)
                %Infinite case
                allInfDirMat=eigv1Mat(:,isInf1Vec);
                [orthBasMat,rangInf]=ellObj1.findBasRank(allInfDirMat,...
                    absTol);
                %    infIndVec=1:rangInf;
                nDimSpace=length(diag1Vec);
                finIndVec=(rangInf+1):nDimSpace;
                finBasMat=orthBasMat(:,finIndVec);
                %Find projections on nonInf directions
                isInf2Vec=diag(ellObj2.getDiagMat())==Inf;
                diag1Vec(isInf1Vec)=0;
                diag2Vec(isInf2Vec)=0;
                curEllMat=eigv1Mat*diag(diag1Vec)*eigv1Mat.';
                ellQ1Mat=finBasMat.'*curEllMat*finBasMat;
                ellQ1Mat=0.5*(ellQ1Mat+ellQ1Mat.');
                curEllMat=eigv2Mat*diag(diag2Vec)*eigv2Mat.';
                ellQ2Mat=finBasMat.'*curEllMat*finBasMat;
                ellQ2Mat=0.5*(ellQ2Mat+ellQ2Mat.');
                curDirVec=finBasMat.'*curDirVec;
                [eigv1Mat,diag1Mat]=eig(ellQ1Mat);
                diag1Vec=diag(diag1Mat);
            else
                ellQ1Mat=eigv1Mat*diag(diag1Vec)*eigv1Mat.';
                ellQ2Mat=eigv2Mat*diag(diag2Vec)*eigv2Mat.';
            end
            if all(abs(curDirVec)<absTol)
                isOk=true;
            else
                %find projection on nonzero space for ell1
                isZeroVec=abs(diag1Vec)<absTol;
                if ~all(~isZeroVec)
                    zeroDirMat=eigv1Mat(:,isZeroVec);
                    % Find basis in all space
                    [orthBasMat,rangZ]=ellObj1.findBasRank(zeroDirMat,absTol);
                    %rangZ>0 since there is at least one zero e.v. Q1
                    %zeroIndVec=1:rangZ;
                    nDimSpace=length(diag1Vec);
                    nonZeroIndVec=(rangZ+1):nDimSpace;
                    nonZeroBasMat=orthBasMat(:,nonZeroIndVec);
                    curDirVec=nonZeroBasMat.'*curDirVec;
                    ellQ1Mat=nonZeroBasMat.'*ellQ1Mat*nonZeroBasMat;
                    ellQ2Mat=nonZeroBasMat.'*ellQ2Mat*nonZeroBasMat;
                    ellQ1Mat=0.5*(ellQ1Mat+ellQ1Mat.');
                    ellQ2Mat=0.5*(ellQ2Mat+ellQ2Mat.');
                end
                isOk=ellObj1.getIsGoodDirForMat(ellQ1Mat,ellQ2Mat,...
                    curDirVec,absTol);
            end
        end
    end
    methods
        function disp(ellArr)
            % Example:
            %   ellObj=elltool.core.GenEllipsoid([5;2],eye(2),[1 3; 4 5]);
            %   ellObj.disp()
            %      |
            %      |----- q : [5 2]
            %      |          -------
            %      |----- Q : |10|19|
            %      |          |19|41|
            %      |          -------
            %      |          -----
            %      |-- QInf : |0|0|
            %      |          |0|0|
            %      |          -----
            modgen.struct.strucdisp(ellArr(:).toStruct());
        end
    end
    methods
        function ellObj=GenEllipsoid(varargin)
            % GENELLIPSOID - class of generalized ellipsoids
            %
            % Input:
            %   Case1:
            %     regular:
            %       qVec: double[nDim,1] - ellipsoid center
            %       qMat: double[nDim,nDim] / qVec: double[nDim,1] - ellipsoid
            %           matrix or diagonal vector of eigenvalues,that may
            %           contain infinite or zero elements
            %
            %   Case2:
            %     regular:
            %       qMat: double[nDim,nDim] / qVec: double[nDim,1] - diagonal
            %           matrix or vector,may contain infinite or zero elements
            %
            %   Case3:
            %     regular:
            %       qVec: double[nDim,1] - ellipsoid center
            %       dMat: double[nDim,nDim] / dVec: double[nDim,1] - diagonal
            %           matrix or vector,may contain infinite or zero elements
            %       wMat: double[nDim,nDim] - any square matrix
            %
            %
            % Output:
            %   self: GenEllipsoid[1,1] - created generalized ellipsoid
            %
            % Example:
            %   ellObj=elltool.core.GenEllipsoid([5;2],eye(2));
            %   ellObj=elltool.core.GenEllipsoid([5;2],eye(2),[1 3; 4 5]);
            %
            %$Author: Vitaly Baranov  <vetbar42@gmail.com> $
            %$Date: Nov-2012$
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            import modgen.common.throwerror
            import elltool.core.GenEllipsoid;
            import gras.la.ismatsymm;
            import gras.la.ismatposdef;
            %
            NEEDED_PROP_NAME_LIST = {'absTol','relTol',...
                'nPlot2dPoints','nPlot3dPoints'};
            [regList,~,...
                propNameValList]=modgen.common.parseparext(...
                varargin,NEEDED_PROP_NAME_LIST,[0 3],'propRetMode','list');
            [absTolVal, relTolVal,nPlot2dPointsVal,nPlot3dPointsVal] =...
                elltool.conf.Properties.parseProp(propNameValList,...
                NEEDED_PROP_NAME_LIST);
            ellObj.centerVec=[];
            ellObj.shapeMat=[];
            ellObj.absTol=absTolVal;
            ellObj.relTol=relTolVal;
            ellObj.nPlot2dPoints=nPlot2dPointsVal;
            ellObj.nPlot3dPoints=nPlot3dPointsVal;
            absTol=ellObj.absTol;
            %
            nRegInputs=numel(regList);
            if nRegInputs==1
                ellMat=regList{1};
                [mSize,nSize]=size(ellMat);
                isPar2Vector=nSize==1;
                isMatSquare=mSize == nSize;
                %
                if isPar2Vector
                    ellObj.diagMat=diag(ellMat);
                    ellObj.eigvMat=eye(size(ellObj.diagMat));
                elseif ~isMatSquare
                    throwerror('wrongInputMat',...
                        'Input matrix must be square');
                elseif ~ismatsymm(ellMat)
                    throwerror('wrongInputMat',...
                        'Input matrix must be symmetric.');
                else
                    isDiagonalMat=ellMat==(ellMat.*eye(mSize));
                    if all(isDiagonalMat(:))
                        ellObj.diagMat=ellMat;
                        ellObj.eigvMat=eye(mSize);
                    else %ordinary square matrix
                        [ellObj.eigvMat,ellObj.diagMat]=eig(ellMat);
                    end
                end
                ellObj.centerVec=zeros(mSize,1);
            elseif nRegInputs==2
                ellCenterVec=regList{1};
                ellMat=regList{2};
                [mCenSize,nCenSize]=size(ellCenterVec);
                [mSize,nSize]=size(ellMat);
                isPar2Vector=nSize==1;
                isMatSquare=mSize == nSize;
                %
                if isPar2Vector
                    ellObj.diagMat=diag(ellMat);
                    ellObj.eigvMat=eye(size(ellObj.diagMat));
                elseif ~isMatSquare
                    throwerror('wrongInputMat',...
                        'Input matrix must be square.');
                elseif ~ismatsymm(ellMat)
                    throwerror('wrongInputMat',...
                        'Input matrix must be symmetric.');
                else
                    isDiagonalMat=ellMat==(ellMat.*eye(mSize));
                    if  all(isDiagonalMat(:))
                        ellObj.diagMat=ellMat;
                        ellObj.eigvMat=eye(mSize);
                    else
                        [ellObj.eigvMat,ellObj.diagMat]=eig(ellMat);
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
            elseif nRegInputs == 3
                ellCenterVec=regList{1};
                ellDiagMat=regList{2};
                ellWMat=regList{3};
                [mCenSize,nCenSize]=size(ellCenterVec);
                [mDSize,nDSize]=size(ellDiagMat);
                [mWSize,nWSize]=size(ellWMat);
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
                    [eigvResMat,diagResMat]=eig(ellAuxMat);
                    eigvResMat=-eigvResMat;
                    diagResVec=diag(diagResMat);
                else
                    allInfMat=ellWMat(:,isInfVec);
                    %L1 and L2 Basis
                    [orthBasMat,rBasMat]=qr(allInfMat);
                    if size(rBasMat,2)==1
                        isNeg=rBasMat(1)<0;
                        orthBasMat(:,isNeg)=-orthBasMat(:,isNeg);
                    else
                        isNegVec=diag(rBasMat)<0;
                        orthBasMat(:,isNegVec)=-orthBasMat(:,isNegVec);
                    end
                    %Find rank L1,here rankL1>0
                    tolerance=absTol*norm(allInfMat,'fro');
                    rankL1=sum(abs(diag(rBasMat)) > tolerance);
                    rankL1=rankL1(1);%for case where rBasMat is a vector.
                    %L1 - first rankL1 columns of orthBasMat.
                    infIndVec=1:rankL1;
                    finIndVec=(rankL1+1):mWSize;
                    nonInfBasMat=orthBasMat(:,finIndVec);
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
            if (nRegInputs~=0)
                isNotInfIndVec=~(diag(ellObj.diagMat)==Inf);
                if any(isNotInfIndVec)
                    if ~ismatposdef(ellObj.diagMat(isNotInfIndVec,...
                            isNotInfIndVec),absTol,1)
                        throwerror('wrongInputMat',...
                            ['GenEllipsoid matrix should be positive ',...
                            'semi-definite.'])
                    end
                end
            end
        end
    end
    methods
        function eigMat=getEigvMat(self)
            % Example:
            %   ellObj=elltool.core.GenEllipsoid([5;2],eye(2),[1 3; 4 5]);
            %   ellObj.getEigvMat()
            %
            %   ans =
            %
            %       0.9034   -0.4289
            %      -0.4289   -0.9034
            %
            eigMat=self.eigvMat;
        end
        function diagMat=getDiagMat(self)
            % Example:
            %   ellObj=elltool.core.GenEllipsoid([5;2],eye(2),[1 3; 4 5]);
            %   ellObj.getDiagMat()
            %
            %   ans =
            %
            %       0.9796         0
            %            0   50.0204
            %
            diagMat=self.diagMat;
        end
        function shapeMat=getShapeMat(self)
            % Example:
            %   ellObj=elltool.core.GenEllipsoid([5;2],eye(2),[1 3; 4 5]);
            %   ellObj.getDiagMat()
            %
            %   ans =
            %
            %       10.0      19.0
            %       19.0      41.0     
            %
            shapeMat=self.eigvMat*self.diagMat*self.eigvMat.';
            shapeMat=0.5*(shapeMat+shapeMat.');
        end
        function qInfMat=getQInfMat(self)
            % Example:
            %   ellObj=elltool.core.GenEllipsoid([5;2],[4;Inf]);
            %   ellObj.getQInfMat()
            %
            %   ans =
            %
            %       0      0
            %       0      1     
            %
            diagVec=diag(self.diagMat);
            isInfVec=diagVec==Inf;
            eigvInfMat=self.eigvMat(:,isInfVec);
            qInfMat=eigvInfMat*eigvInfMat.';
        end
    end
    methods (Static)
        ellArr=fromRepMat(varargin)
        ellArr=fromStruct(SEllArr)
    end
    methods (Static,Access=private)
        [isOk,pPar]=getIsGoodDirForMat(ellQ1Mat,ellQ2Mat,dirVec,absTol)
        sqMat=findSqrtOfMatrix(qMat,absTol)
        isBigger=checkBigger(ellObj1,ellObj2,nDimSpace,absTol)
        [isInfVec,infDirEigMat]=findAllInfDir(ellObj)
        [orthBasMat,rank]=findBasRank(qMat,absTol)
        [ spaceBasMat, oSpaceBasMat,spaceIndVec,oSpaceIndVec] =...
            findSpaceBas( dirMat,absTol )
        [ projQMat ]=findMatProj( eigvMat,diagMat,basMat )
        [diagQVec,resQMat]=findConstruction(firstEllMat,...
            firstBasMat,secBasMat,firstIndVec,secIndVec,secDiagVec)
        resQMat=findDiffEaND(ellQ1Mat,ellQ2Mat,curDirVec,absTol)
        [resEllMat ]=findDiffFC( fMethod,ellQ1Mat,ellQ2Mat,...
            curDirVec,absTol )
        [ resQMat,diagQVec ]=findDiffINFC(fMethod,ellObj1,...
            ellObj2,curDirVec,isInf1Vec,isInfForFinBas,absTol)
        resQMat=findDiffIaND(ellQ1Mat,ellQ2Mat,curDirVec,absTol)
    end
end