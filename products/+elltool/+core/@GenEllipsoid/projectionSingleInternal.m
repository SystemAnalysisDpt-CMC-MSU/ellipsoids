function projectionSingleInternal(ellObj,ortBasisMat)
ellObj.eigvMat=ortBasisMat'*ellObj.eigvMat;
ellObj.centerVec=ortBasisMat'*ellObj.centerVec;
end