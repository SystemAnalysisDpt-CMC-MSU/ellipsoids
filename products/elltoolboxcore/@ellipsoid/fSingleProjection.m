function fSingleProjection(ellObj,ortBasisMat)
ellObj.shapeMat=ortBasisMat'*ellObj.getShapeMat*ortBasisMat;
ellObj.centerVec=ortBasisMat'*ellObj.centerVec;
end