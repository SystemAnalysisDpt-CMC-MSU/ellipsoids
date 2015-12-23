function changeShapeMatInternal(ellObj,isModScal,modMat)
if isModScal
    eigvMat=modMat*ellObj.eigvMat;
else
    eigvMat=modMat*ellObj.eigvMat;
end
ellObj.eigvMat=eigvMat;
end