function shapeSingleInternal(ellObj,isModScal,modMat) %#ok<INUSL>
eigvMat=modMat*ellObj.eigvMat;
ellObj.eigvMat=eigvMat;
end