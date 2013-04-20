function regMat = getRegMat(inpMat, regTol)
[vMat, dMat] = eig(inpMat, 'nobalance');
mMat = diag(max(diag(dMat), regTol));
mMat = vMat * mMat * transpose(vMat);
regMat = 0.5 * (mMat + mMat.');
end