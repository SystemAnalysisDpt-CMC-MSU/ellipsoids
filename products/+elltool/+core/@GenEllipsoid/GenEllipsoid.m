classdef GenEllipsoid < elltool.core.AEllipsoid
    % GENELLIPSOID - class of generalized ellipsoids
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
    %       wMat: double[nDim,nDim] - square matrix contained orthogonal
    %       basis with respect to finite eigen values provided by dMat and
    %       basis along Inf directions
    %
    % Output:
    %   self: GenEllipsoid[1,1] - created generalized ellipsoid
    %
    % Example:
    %   ellObj = elltool.core.GenEllipsoid([5;2], eye(2));
    %   ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
    %
    %$Author: Vitaly Baranov  <vetbar42@gmail.com> $
    %$Date: Nov-2012$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    properties(Access = private)
        diagMat
        eigvMat
    end
    properties (Constant,GetAccess = private)
        CHECK_TOL=1e-09;
    end
    properties (Access = protected, Dependent)
        shapeMat
    end
    
    methods (Access = protected)
        function [isEqualArr, reportStr] = isEqualInternal(ellFirstArr,...
                ellSecArr, ~)
            import modgen.struct.structcomparevec;
            import gras.la.sqrtmpos;
            import elltool.conf.Properties;
            import modgen.common.throwerror;
            %
            nFirstElems = numel(ellFirstArr);
            nSecElems = numel(ellSecArr);
            
            firstSizeVec = size(ellFirstArr);
            secSizeVec = size(ellSecArr);
            reportStr = '';
            if (nFirstElems == 0 && nSecElems == 0)
                isEqualArr = true;
                return;
            elseif (nFirstElems == 0 || nSecElems == 0)%why not just return false?
                throwerror('wrongInput:emptyArray',...
                    'input ellipsoidal arrays should be empty at the same time');
            end
            if nFirstElems ~= 1 && nSecElems ~= 1 ...
                    && ~isequal(firstSizeVec, secSizeVec)
                throwerror('wrongInput:wrongSizes',...
                    'sizes of ellipsoidal arrays do not... match');
            end
            if nFirstElems > 1 && nSecElems > 1 
                compare()
            elseif nFirstElems > 1
                ellSecArr = repmat(ellSecArr, firstSizeVec);
                compare()
            else
                ellFirstArr = repmat(ellFirstArr, secSizeVec);
                compare()
            end
            function compare()
                absTol = ellFirstArr.getAbsTol;
                relTol = ellFirstArr.getRelTol;
                isEqualArr = arrayfun(@(x, y, z, r) checkGenEq(x, y, z, r), ...
                    ellFirstArr, ellSecArr, absTol, relTol, ...
                    'UniformOutput', true);
            end
            function isEqual = checkGenEq(ellFirstObj, ellSecObj, ...
                    absTol, relTol)
                fstCenVec = ellFirstObj.getRegCenter();
                secCenVec = ellSecObj.getRegCenter();
                if numel(fstCenVec) ~= numel(secCenVec)
                    isEqual = false;
                    reportStr = [reportStr, ...
                        'Ellipsoids must have equal dimensions\n'];
                    return;
                end
                [isEqual, ~, ~, ~, ~, reportStr] = ...
                    modgen.common.absrelcompare(fstCenVec, secCenVec, ...
                    absTol, relTol); 
                if ~isEqual
                    reportStr = [reportStr, 'Centers vectors', ...
                        ' are not equal.\n'];
                    return;
                end
                fstShapeMat = ellFirstObj.getShapeMat();
                secShapeMat = ellSecObj.getShapeMat();
                [isEqual, ~, ~, ~, ~, reportStr] = ...
                    modgen.common.absrelcompare(fstCenVec, secCenVec, ...
                    absTol, relTol); 
                if ~isEqual
                    reportStr = [reportStr, 'Shape matrices are not equal.\n'];
                    return;
                end
                isEqual = checkBasisEq(ellFirstObj.getInfProj, ...
                    ellSecObj.getInfProj, absTol);
                if ~isEqual
                    reportStr = [reportStr, ...
                        'Linear spaces along Inf directions are not equal\n'];
                    return;
                end
            end
            function isEqual = checkBasisEq(basFirstMat, basSecMat, absTol)
                nFirstRank = rank(basFirstMat, absTol);
                nSecRank = rank(basSecMat, absTol);
                nTogetherRank = rank([basFirstMat, basSecMat], absTol);
                isEqual = nFirstRank == nSecRank ...
                    && nSecRank == nTogetherRank;
            end            
        end
    end
    
    methods
        function shapeMat=get.shapeMat(self)
            % function return configuration matrix corresponded only to 
            % finit values in diagMat
            finDiagVec = diag(self.diagMat);
            isInfDiagVec = finDiagVec == Inf;
            finDiagVec(isInfDiagVec) = 0;
            finEigvMat = self.eigvMat;
            finEigvMat(:, isInfDiagVec) = 0;
            shapeMat = finEigvMat * diag(finDiagVec) * finEigvMat.';
            shapeMat = 0.5 * (shapeMat + shapeMat.');
        end
        
        function obj = set.shapeMat(self, shMat)
            import modgen.common.throwerror;
            [self.eigvMat, self.diagMat] = eig(shMat);
        end
        
        function isOk=getIsGoodDir(ellObj1,ellObj2,curDirVec)
            % Example:
            %   firstEllObj = elltool.core.GenEllipsoid([10;0], 2*eye(2));
            %   secEllObj = elltool.core.GenEllipsoid([0;0], [1 0; 0 0.1]);
            %   curDirMat = [1; 0];
            %   isOk=getIsGoodDir(firstEllObj,secEllObj,dirsMat)
            %
            %   isOk =
            %
            %        1
            %
            import elltool.core.GenEllipsoid;
            absTol=GenEllipsoid.getCheckTol();
            eigv1Mat=ellObj1.getEigvMat();
            eigv2Mat=ellObj2.getEigvMat();
            diag1Vec=diag(ellObj1.getDiagMat());
            diag2Vec=diag(ellObj2.getDiagMat());
            isInf1Vec=diag1Vec==Inf;
            if ~all(~isInf1Vec)
                %Infinite case
                allInfDirMat=eigv1Mat(:,isInf1Vec);
                [orthBasMat, rangInf]=ellObj1.findBasRank(allInfDirMat,absTol);
                %    infIndVec=1:rangInf;
                nDimSpace=length(diag1Vec);
                finIndVec=(rangInf+1):nDimSpace;
                finBasMat = orthBasMat(:,finIndVec);
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
                [eigv1Mat, diag1Mat]=eig(ellQ1Mat);
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
                    [orthBasMat, rangZ]=ellObj1.findBasRank(zeroDirMat,absTol);
                    %rangZ>0 since there is at least one zero e.v. Q1
                    %zeroIndVec=1:rangZ;
                    nDimSpace=length(diag1Vec);
                    nonZeroIndVec=(rangZ+1):nDimSpace;
                    nonZeroBasMat = orthBasMat(:,nonZeroIndVec);
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
        %This function return new ellipsoid with sorted eigen values
        %and regular center
        function ellObj = getCopyWithDecomposition(obj)
            ellDiagMat = obj.getDiagMat;
            ellWMat = obj.getEigvMat;
            %
            [ellDiagSortedVec, indSortedDiagVec] = sort(diag(ellDiagMat));
            ellObj = elltool.core.GenEllipsoid();
            ellObj.diagMat = diag(ellDiagSortedVec);
            ellObj.eigvMat = ellWMat(:, indSortedDiagVec);
            ellObj.centerVec = obj.getRegCenter();
        end
        function ellObj = getOldVertionCopyWithDecomposition(obj)
            ellCenterVec = obj.getCenter;
            ellDiagMat = obj.getDiagMat;
            ellWMat = obj.getEigvMat;
            absTol = obj.CHECK_TOL;
            [mCenSize, nCenSize] = size(ellCenterVec);
            [mDSize, nDSize] = size(ellDiagMat);
            [mWSize, nWSize] = size(ellWMat);
            
            if (nDSize == 1)
                diagVec = ellDiagMat;
            else
                diagVec = diag(ellDiagMat);
            end
            isInfVec = diagVec == Inf;
            allInfMat = ellWMat(:,isInfVec);
            %L1 and L2 Basis
            [orthBasMat, rBasMat] = qr(allInfMat);
            if size(rBasMat,2 )== 1
                isNeg = rBasMat(1)<0;
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
            [sortedDiagVec, indSortedVec] = sort(diagResVec);
            ellObj.diagMat=diag(sortedDiagVec);
            ellObj.eigvMat=eigvResMat(:, indSortedVec);
            ellObj.centerVec=ellCenterVec;
        end
        
        function ellObj = GenEllipsoid(varargin)
            import modgen.common.throwerror
            import elltool.core.GenEllipsoid;
            import modgen.common.checkmultvar;
            import modgen.common.checkvar;
            import gras.la.ismatsymm;
            import gras.la.ismatposdef;
            
            ellObj = ellObj@elltool.core.AEllipsoid();
            
            NEEDED_PROP_NAME_LIST = {'absTol','relTol','nPlot2dPoints','nPlot3dPoints'};
            [regParamList, propNameValList] = ...
                 modgen.common.parseparams(varargin, NEEDED_PROP_NAME_LIST);
            [absTolVal, relTolVal, ...
             nPlot2dPointsVal, nPlot3dPointsVal] = ...
             elltool.conf.Properties.parseProp(propNameValList, ...
                                               NEEDED_PROP_NAME_LIST);
            %
            absTol = ellObj.CHECK_TOL;
            %
            %nInput=nargin;
            nInput = numel(regParamList);
            if  nInput > 3
                throwerror('wrongParameters',...
                    'Incorrect number of parameters');
            elseif nInput == 1
                checkvar(regParamList{1}, ...
                         @(x) isa(x,'double') && isreal(x),...
                         'errorTag', 'wrongInput:imagArgs',...
                         'errorMessage', 'shapeMat matrix must be real.');
                ellMat = regParamList{1};
                nShDims = ndims(ellMat);
                if nShDims > 2
                    throwerror('wrongParameters', ...
                        'Shape matrix have to be 2-dimentional matrix');
                end
                %
                [mSize, nSize] = size(ellMat);
                isPar2Vector = nSize == 1;
                isMatSquare = mSize == nSize;
                
                %
                if isPar2Vector
                    if any(ellMat < -absTol)
                        throwerror('wrongInput', ...
                            'Input vector must be non-negative.');
                    end
                    ellObj.diagMat = diag(ellMat);
                    ellObj.eigvMat = eye(size(ellObj.diagMat));
                elseif ~isMatSquare
                    throwerror('wrongInput',...
                               'Input matrix must be square');
                elseif ~ismatsymm(ellMat, absTol)
                    throwerror('wrongInput',...
                               'Input matrix must be symmetric.');
                else
                    isDiagonalMat = all(all(ellMat == diag(diag(ellMat))));
                    if all(isDiagonalMat(:))
                        if any(diag(ellMat) < -absTol)
                            throwerror('wrongInput', ...
                                'Input matrix must be non-negative!');
                        end
                        ellObj.diagMat = ellMat;
                        ellObj.eigvMat = eye(mSize);
                    elseif any(any(ellMat == Inf))
                        throwerror('wrongInput', ...
                            'Non diagonal Matrix must be finit.');
                    else %ordinary square matrix 
                        [eigvCheckMat, evalCheckMat] = eig(ellMat);
                        evalCheckVec = diag(evalCheckMat);
                        if ~all(evalCheckVec > -absTol) ...
                                && ~all(evalCheckVec < absTol)
                            throwerror('wrongInput', ...
                                'Input Matrix must be non-negative.');
                        elseif any(evalCheckVec < -absTol)
                            eigvCheckMat = -eigvCheckMat;
                            evalCheckVec = -evalCheckVec;
                        end
                        ellObj.eigvMat = eigvCheckMat;
                        ellObj.diagMat = diag(evalCheckVec);
                        
                    end
                end
                ellObj.centerVec=zeros(mSize,1);
            elseif nInput == 2
                checkmultvar(@(x,y) isa(x,'double') && isa(y,'double') && ...
                    isreal(x) && isreal(y),2,regParamList{1},regParamList{2}, ...
                    'errorTag','wrongInput:imagArgs',...
                    'errorMessage','centerVec and shapeMat matrix must be real.');
                ellCenterVec = regParamList{1};
                ellMat = regParamList{2};
                
                nShDims = ndims(ellMat);
                nCentDims = ndims(ellCenterVec);
                checkmultvar(...
                    @(x,y)(x==2&&y==2)||x==y+1, 2, nShDims, nCentDims,...
                    'errorTag','wrongInput',...
                    'errorMessage', ['centerVec and shapeMat matrix must ',...
                    'differ in dimensionality by 1.']);
                centDimsVec(1:nCentDims) = size(ellCenterVec);
                shDimsVec(1:nShDims) = size(ellMat);
                checkmultvar(@(x,y) all(x==y), 2, centDimsVec(2:end),...
                    shDimsVec(3:end), 'errorTag','wrongInput',...
                    'errorMessage',...
                    'additional dimensions must agree');
                
                [mCenSize, nCenSize] = size(ellCenterVec);
                [mSize, nSize] = size(ellMat);
                isPar2Vector = nSize == 1;
                isMatSquare = mSize == nSize;
                %
                
                if nCenSize ~= 1
                    throwerror('wrongInput:wrongCenter', ...
                        'Center must be a vector');
                end
                if mSize ~= mCenSize
                    throwerror('wrongInput:wrongDimensions',...
                        ['Dimension of center vector must ',...
                        'be the same as matrix']);
                end
                if isPar2Vector
                    if any(ellMat < -absTol)
                        throwerror('wrongInput', ...
                            'Input vector must be non-negative.');
                    end
                    ellObj.diagMat = diag(ellMat);
                    ellObj.eigvMat = eye(size(ellObj.diagMat));
                elseif ~isMatSquare
                    throwerror('wrongInput',...
                        'Input matrix must be square.');
                elseif ~ismatsymm(ellMat, absTol) 
                    throwerror('wrongInput',...
                        'Input matrix must be symmetric.');
                else
                    isDiagonalMat = all(all(ellMat == diag(diag(ellMat))));
                    if  all(isDiagonalMat(:))
                        if any(diag(ellMat) < -absTol)
                            throwerror('wrongInput', ...
                                'Input matrix must be non-negative!');
                        end
                        ellObj.diagMat = ellMat;
                        ellObj.eigvMat = eye(mSize);
                    elseif any(any(ellMat == Inf))
                        throwerror('wrongInput', ...
                            'Non diagonal Matrix must be finit.');
                    else %ordinary square matrix 
                        [eigvCheckMat, evalCheckMat] = eig(ellMat);
                        evalCheckVec = diag(evalCheckMat);
                        if ~all(evalCheckVec > -absTol) ...
                                && ~all(evalCheckVec < absTol)
                            throwerror('wrongInput', ...
                                'Input Matrix must be non-negative.');
                        elseif any(evalCheckVec < -absTol)
                            eigvCheckMat = -eigvCheckMat;
                            evalCheckVec = -evalCheckVec;
                        end
                        ellObj.eigvMat = eigvCheckMat;
                        ellObj.diagMat = diag(evalCheckVec);
                    end
                end
                ellObj.centerVec = ellCenterVec;
            elseif nInput == 3
                checkmultvar(@(x,y,z) isa(x,'double') && isa(y,'double') ...
                    && isa(z, 'double') && isreal(x) && isreal(y) && isreal(z), ...
                    3, regParamList{1}, regParamList{2}, regParamList{3}, ...
                    'errorTag', 'wrongInput:imagArgs',...
                    'errorMessage', 'centerVec and shapeMat matrix must be real.');
                ellCenterVec = regParamList{1};
                ellDiagMat = regParamList{2};
                ellWMat = regParamList{3};
                %
                [mCenSize, nCenSize] = size(ellCenterVec);
                [mDSize, nDSize] = size(ellDiagMat);
                [mWSize, nWSize] = size(ellWMat);
                %
                if (nCenSize ~= 1)
                    throwerror('wrongInput:wrongCenter', ...
                               'Center must be a vector');
                end
                if (mCenSize ~= mDSize || mCenSize ~= mWSize)
                    throwerror('wrongInput:wrongDimensions',...
                        ['Input matrices and center vector must ',...
                        'be of the same dimension']);
                end
                if (nDSize == 1)
                    diagVec = ellDiagMat;
                    ellDiagMat = diag(diagVec);
                else
                    diagVec = diag(ellDiagMat);
                end
                if (nDSize > 1)
                    if nDSize ~= mDSize
                        throwerror('wrongInput:wrongDiagonal',...
                            ['Second argument should be either ',...
                            'diagonal matrix or a vector']);
                    end
                    isDiagonal = all(all(ellDiagMat == ...
                        diag(diagVec)));
                    if ~isDiagonal
                        throwerror('wrongInput:wrongDiagonal',...
                            ['Second argument should be either ',...
                            'diagonal matrix or a vector']);
                    elseif any(diagVec < -absTol)
                        throwerror('wrongIput:wrongDiagonal', ...
                            'Second argument must not have negative elements.');
                    end
                elseif any(diagVec < -absTol)
                    throwerror('wrongIput:wrongDiagonal', ...
                        'Second argument must not have negative elements.');
                end
                %check whether ellWMat is not singular
                if (nWSize ~= mWSize)
                    throwerror('wrongInput:wrongParameters',...
                        'Third parameter must be a square matrix');
                end
                
                isInfVec = diagVec == Inf;
                if checkOrth(ellWMat)
                    %ellWMat consists of orthogonal vectors
                    diagResVec = diagVec;
                    eigvResMat = ellWMat;
                elseif all(~isInfVec)
                    ellAuxMat = ellWMat * diag(diagVec) * ellWMat.';
                    [eigvResMat, diagResMat] = eig(ellAuxMat);
                    diagResVec = diag(diagResMat);
                    if ~all(diagResVec > -absTol ) 
                        throwerror('wrongInput:nonNegativeRequiared', ...
                            'Resulting shape matrix must be non negative.');
                    elseif any(diagResVec < absTol)
                        diagResVec(diagResVec < absTol) = 0;
                    end
                elseif all(isInfVec)
                    %Whole space represented. Any basis is proper.
                    diagResVec = diagVec;
                    eigvResMat = eye(nDSize);
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
					projMat=nonInfBasMat.'*ellWMat;
					isZeroProjVec=all(abs(projMat)<absTol,1);
					if ~all(isZeroProjVec)
						diagVec(isInfVec)=0;
						ellAuxMat=projMat*diag(diagVec)*projMat.';
						[~,nonInfDMat]=eig(ellAuxMat);
						diagResVec(finIndVec)=diag(nonInfDMat);
					end
                    diagResVec(infIndVec)=Inf;
                    eigvResMat=orthBasMat;
                end
                ellObj.diagMat = diag(diagResVec);
                ellObj.eigvMat = eigvResMat;
                ellObj.centerVec = ellCenterVec;
            end            
            ellObj.absTol = absTolVal;
            ellObj.relTol = relTolVal;
            ellObj.nPlot2dPoints = nPlot2dPointsVal;
            ellObj.nPlot3dPoints = nPlot3dPointsVal;
            function isOrth = checkOrth(vecMat)
                isOrth = max(max(abs(vecMat * vecMat.' - eye(size(vecMat))))) ...
                    < absTol;
            end
        end
        
        function ellObj = create(self, varargin)
            ellObj = elltool.core.GenEllipsoid(varargin{:});
        end
    end
    methods (Access = protected)
        checkDoesContainArgs(fstEllArr,secObjArr)
    end
    methods (Static)
        checkIsMe(someObj,varargin)
        ellArr = fromRepMat(varargin)
        ellArr = fromStruct(SEllArr)
    end
    methods
        function cVec = getCenter(self)
            % Example:
            %   ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
            %   ellObj.getCenter()
            %
            %   ans =
            %
            %        5
            %        2
            %
            cVec=self.centerVec;
        end
        function eigMat = getEigvMat(self)
            % Example:
            %   ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
            %   ellObj.getEigvMat()
            %
            %   ans =
            %
            %       0.9034   -0.4289
            %      -0.4289   -0.9034
            %
            eigMat=self.eigvMat;
        end
        function diagMat = getDiagMat(self)
            % Example:
            %   ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
            %   ellObj.getDiagMat()
            %
            %   ans =
            %
            %       0.9796         0
            %            0   50.0204
            %
            
            diagMat = self.diagMat;
        end
        function infProjMat = getInfProj (self)
            % Example:
            %   ellObj = elltool.core.GenEllipsoid([0; Inf]);
            %   ellObj.getInfProj()
            %
            %   ans =
            %
            %            0         0
            %            0         1
            %
            isInfDiagVec = diag(self.diagMat) == Inf;
            infProjMat = zeros(size(self.eigvMat));
            infProjMat(:, isInfDiagVec) = self.eigvMat(:, isInfDiagVec);
        end
        function regCenVec = getRegCenter (self)
            % Example:
            %   ellObj = elltool.core.GenEllipsoid([1; 4], [Inf; Inf]);
            %   ellObj.getRegCenter()
            %
            %   ans =
            %
            %            0 
            %            0         
            %
            isInfVec = diag(self.diagMat) == Inf;
            regCenVec = self.centerVec;
            if any(isInfVec)
                nDiagInf = sum(isInfVec);
                infDirMat = self.eigvMat(:, isInfVec);
                regCenMat = repmat(regCenVec, 1, nDiagInf); 
                scalInfDirVec = dot(regCenMat, infDirMat);
                scalInfDirMat = repmat(scalInfDirVec, size(isInfVec, 1), 1);
                projInfDirVec = sum(infDirMat .* scalInfDirMat, 2);
                regCenVec = regCenVec - projInfDirVec; 
            end
        end
    end
    methods (Static)
        function tol = getCheckTol()
            % Example:
            %   ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
            %   ellObj.getCheckTol()
            %
            %   ans =
            %
            %      1.0000e-09
            %
            tol = elltool.core.GenEllipsoid.CHECK_TOL;
        end
    end
    methods (Static,Access = private)
        [isOk, pPar] = getIsGoodDirForMat(ellQ1Mat,ellQ2Mat,dirVec,absTol)
        sqMat = findSqrtOfMatrix(qMat,absTol)
        isBigger = checkBigger(ellObj1,ellObj2,nDimSpace,absTol)
        [isInfVec, infDirEigMat] = findAllInfDir(ellObj)
        [orthBasMat, rank] = findBasRank(qMat,absTol)
        [ spaceBasMat,  oSpaceBasMat, spaceIndVec, oSpaceIndVec] = ...
            findSpaceBas( dirMat,absTol )
        [ projQMat ] = findMatProj( eigvMat, diagMat, basMat )
        [diagQVec, resQMat] = findConstruction(firstEllMat,...
            firstBasMat, secBasMat, firstIndVec, secIndVec, secDiagVec)
        resQMat = findDiffEaND(ellQ1Mat, ellQ2Mat, curDirVec, absTol)
        [resEllMat ] = findDiffFC( fMethod, ellQ1Mat, ellQ2Mat,...
            curDirVec, absTol )
        [ resQMat, diagQVec ] = findDiffINFC(fMethod, ellObj1,...
            ellObj2, curDirVec, isInf1Vec, isInfForFinBas, absTol)
        resQMat = findDiffIaND(ellQ1Mat, ellQ2Mat, curDirVec, absTol)
    end
    
    methods (Access = protected, Static)
        function SComp = formCompStruct(SEll, SFieldNiceNames, absTol, isPropIncluded)
            if (~isempty(SEll.diagMat) && ~isempty(SEll.eigvMat))                
                dMat = SEll.diagMat;
                vMat = SEll.eigvMat;
                dVec = diag(dMat);
                if any(dVec < -absTol)
                    throwerror('wrongInput:notPosSemDef',...
                        'input matrix is expected to be positive semi-definite');
                end
                %
                isZeroVec = dVec < absTol;
                dVec(isZeroVec) = 0;
                dMat = diag(dVec);
                dMat = realsqrt(dMat);
                
                SComp.diagMat = dMat;
                SComp.eigvMat = vMat;
            else
                SComp.diagMat = [];
                SComp.eigvMat = [];
            end
            SComp.(SFieldNiceNames.centerVec) = SEll.centerVec;
            if (isPropIncluded)
                SComp.(SFieldNiceNames.absTol) = SEll.absTol;
                SComp.(SFieldNiceNames.relTol) = SEll.relTol;
                SComp.(SFieldNiceNames.nPlot2dPoints) = SEll.nPlot2dPoints;
                SComp.(SFieldNiceNames.nPlot3dPoints) = SEll.nPlot3dPoints;
            end
        end
        
    end
    
end