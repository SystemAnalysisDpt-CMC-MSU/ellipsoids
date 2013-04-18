function convert(filename)

    import gras.ellapx.enums.EApproxType;
    import gras.ellapx.smartdb.rels.EllTube;

    % temporary
    filename = 'run\example_1_config_1\data.mat';
    
    FortranData = load(filename);

    sysDim = FortranData.nx;
    nGoodDirs = FortranData.nl;
    nTimePoints = FortranData.nt;
    
    timeVec = FortranData.tVec.';
    calcPrecision = FortranData.tolerance;
    
    qArrayList = cell(1, nGoodDirs);
    aMat = zeros(sysDim, nTimePoints);
    ltGoodDirArray = zeros(sysDim, nGoodDirs, nTimePoints);
    
    for iGoodDir = 1:nGoodDirs
        qArrayList{iGoodDir} = zeros(sysDim, sysDim, nTimePoints);
    end
    
    for iTimePoint = 1:nTimePoints
        [atVec, ~, ltMat, qtArray] = unpack(FortranData.yMat(:,iTimePoint));
        
        aMat(:,iTimePoint) = atVec;
        ltGoodDirArray(:,:,iTimePoint) = ltMat;
        
        for iGoodDir = 1:nGoodDirs
            qArrayList{iGoodDir}(:,:,iTimePoint) = qtArray(:,:,iGoodDir);
        end
    end
    
    % doesn't work yet because of EllTube consistency checks
    ellTubeRel = EllTube.fromQArrays(qArrayList, aMat, timeVec,...
        ltGoodDirArray, timeVec(end), EApproxType.Internal,...
        'UncertMixed', 'UncertMixed', calcPrecision);
    
    function [atVec, xtMat, ltMat, qtArray] = unpack(ytVec)
        k = 0;
        atVec = ytVec(k+1:k+sysDim);
        
        k = k + numel(atVec);
        xtMat = reshape(ytVec(k+1:k+sysDim*sysDim), sysDim, sysDim);
        
        k = k + numel(xtMat);
        ltMat = reshape(ytVec(k+1:k+sysDim*nGoodDirs), sysDim, nGoodDirs);
        
        k = k + numel(ltMat);
        qtArray = zeros(sysDim, sysDim, nGoodDirs);        
        
        for j = 1:nGoodDirs
            for i = 1:sysDim
                qtArray(1:i, i, j) = ytVec(k+1:k+i);
                qtArray(i, 1:i, j) = ytVec(k+1:k+i);
                k = k + i;
            end
        end
    end

end