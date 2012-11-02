function dif = derivativesupportfunction(t, x, aMat, bMat, pVec, pMat, nElem)

y = x(1 : nElem);

dif = zeros(nElem + 1, 1);
dif(1 : nElem) = -(aMat(t).') * y;
dif(nElem + 1) =...
    (y.') * bMat(t) * pVec(t) +...
    sqrt((y.') * bMat(t) * pMat(t) * (bMat(t).') * y);