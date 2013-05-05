function TMat = orthtranslqr(aVec, bVec)
    dim = length(aVec);
    %
    [QMat,RMat] = qr([aVec,bVec],0);
    %
    c = dot(aVec,bVec) / realsqrt(dot(aVec,aVec)*dot(bVec,bVec));
    s = -realsqrt(1 - c*c);
    if RMat(1, 1)*RMat(2, 2) < 0 
        s = -s;
    end
    %
    QSMat = zeros(dim, 2);
    QSMat(:, 1) = QMat(:, 1)*(c-1) + QMat(:, 2)*s;
    QSMat(:, 2) = -QMat(:, 1)*s + QMat(:, 2)*(c-1);
    %
    TMat = eye(dim) + QSMat*(QMat.'); 
end

