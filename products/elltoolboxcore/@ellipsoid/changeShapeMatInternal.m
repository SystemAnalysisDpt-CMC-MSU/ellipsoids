function changeShapeMatInternal(ellObj,isModScal,modMat)
if isModScal
    shMat=modMat*modMat*ellObj.getShapeMat();
else
    shMat=modMat*(ellObj.getShapeMat())*modMat';
    shMat=0.5*(shMat + shMat');
end
ellObj.shapeMat=shMat;
end