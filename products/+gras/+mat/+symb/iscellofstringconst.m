function isOk=iscellofstringconst(mCMat)
    isOk=all(reshape(cellfun('isempty',strfind(mCMat,'t')),[],1));
end