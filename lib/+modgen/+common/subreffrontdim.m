function resArray=subreffrontdim(inpArray,curInd)
resArray=inpArray(curInd,:);
newSizeVec=size(inpArray);
newSizeVec(1)=size(resArray,1);
resArray=reshape(inpArray(curInd,:),newSizeVec);