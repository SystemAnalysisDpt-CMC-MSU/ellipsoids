function testSpline(m, n, timeVec)

    nTimePoints = numel(timeVec);
    mArray = rand(m, n, nTimePoints);
    
    for iTimePoint = 1:nTimePoints
        mArray(:,:,iTimePoint) = 1 + 0.01*mArray(:,:,iTimePoint);
    end
    
    splineObj = gras.interp.MatrixColCubicSpline(mArray, timeVec);

    aArray = zeros(m, n, nTimePoints);
    bArray = zeros(m, n, nTimePoints);
    
    tic;
    for iTimePoint = 2:nTimePoints
        timePoint = ( timeVec(iTimePoint - 1) + timeVec(iTimePoint) ) / 2;
        aArray(:,:,iTimePoint) = splineObj.evaluate(timePoint);
    end
    t1 = toc;
    
    tic;
    for iTimePoint = 2:nTimePoints
        timePoint = ( timeVec(iTimePoint - 1) + timeVec(iTimePoint) ) / 2;
        bArray(:,:,iTimePoint) = splineObj.evaluate2(timePoint);
    end
    t2 = toc;
        
    tArray = aArray - bArray;
    d = max(abs(tArray(:)));
    if( d > 1e-15 )
        error(['precision error: ', num2str(d)]);
    end
    
    fprintf('Old method: %f sec\n', t1);
    fprintf('New method: %f sec\n', t2);
    
    if t2 < t1
        fprintf('Result: %f times FASTER\n', t1/t2);
    else
        fprintf('Result: %f times SLOWER\n', t2/t1);
    end

end

