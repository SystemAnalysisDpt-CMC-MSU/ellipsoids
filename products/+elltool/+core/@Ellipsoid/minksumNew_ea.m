function [ ellResVec] = minksumNew_ea( ellObjVec, dirMat )
    global ellOptions    
    import elltool.core.Ellipsoid;
    import modgen.common.throwerror
          
    if (~isa(ellObjVec,'Ellipsoid'))
        throwerror('notEllipsoid','MINKSUM_EA: first argument must be array of ellipsoids');
    end
    
    ellObjVec=ellObjVec(:).';
    dimsSpaceVec=ellSpaceDimension(ellObjVec);
    minDimSpace=min(min(dimsSpaceVec));
    maxDimSpace=max(max(dimsSpaceVec));
    if (minDimSpace~=maxDimSpace)
        throwerror('wrongSizes','MINKSUM_EA: ellipsoids of the array must be in the same vector space');
    end
    dimSpace=maxDimSpace;
    
    [mDirSize nDirSize]=size(dirMat);
    if (mDirSize~=dimSpace)
        msgStr=sprintf('MINKSUM_EA: second argument must be vector(s) in R^%d',dimSpace);
        throwerror('wrongDir',msgStr);
    end
    
    [mSize kSize]=size(ellObjVec);
    if (mSize==1) && (kSize==1)
        ellResVec=ellObjVec;
    else
        nEllObj=size(ellObjVec,2);
        ellResVec(nDirSize)=Ellipsoid(1);
        for iDir=1:nDirSize;
            curDir=dirMat(:,iDir);
            isDirInKerVec=findDirInKer(ellObjVec,curDir);
            if all(isDirInKerVec==0)%Non-degenerate Case
                for iEll=1:nEllObj;
                    eigviMat=ellObjVec(iEll).eigvMat;
                    diagiMat=ellObjVec(iEll).diagMat;
                    auxVec=eigviMat.'*curDir;
                    curPNum=sqrt(auxVec.'*diagiMat*auxVec);
                    if (iEll==1)
                        cenVec=ellObjVec(iEll).centerVec;
                        sumMat=1/(curPNum)*eigviMat*diagiMat*eigviMat.';
                        sumPNum=curPNum;
                    else
                        cenVec=cenVec+ellObjVec(iEll).centerVec;
                        sumMat=sumMat+1/(curPNum)*eigviMat*diagiMat*eigviMat.';
                        sumPNum=sumPNum+curPNum;
                    end
                end
                resEllMat=0.5*sumPNum*(sumMat+sumMat.');
                ellResVec(iDir)=Ellipsoid(cenVec,resEllMat);
            else
                indDegEllVec=(1:nEllObj).';
                indDegEllVec=indDegEllVec(isDirInKerVec);
                diagNewVec=zeros(dimSpace,1);
                eigNewMat=zeros(dimSpace,dimSpace);
                sumMat=zeros(nEllObj);
                isZeroMat=zeros(dimSpace,nEllObj);
                for iDegEll=1:length(indDegEllVec)
                    curEllipsoid=ellObjVec(indDegEllVec(iDegEll));
                    isZeroMat(:,indDegEllVec(iDegEll))=...
                        (diag(curEllipsoid.diagMat)==0);
                end
                isInKerAndZero=logical(sum(isZeroMat,2)>0);
                diagNewVec(~isInKerAndZero)=Inf;
                eigNewMat(~isInKerAndZero,~isInKerAndZero)=eye(sum(~isInKerAndZero));
                wasFirstNonDeg=false;
                for iEll=1:nEllObj
                    if ~isDirInKerVec(iEll)
                        eigviMat=ellObjVec(iEll).eigvMat;
                        diagiMat=ellObjVec(iEll).diagMat;
                        auxVec=eigviMat.'*curDir;
                        curPNum=sqrt(auxVec.'*diagiMat*auxVec);
                        if (~wasFirstNonDeg)
                            cenVec=ellObjVec(iEll).centerVec;
                            sumMat=1/(curPNum)*eigviMat*diagiMat*eigviMat.';
                            sumPNum=curPNum;
                            wasFirstNonDeg=true;
                        else
                            cenVec=cenVec+ellObjVec(iEll).centerVec;
                            sumMat=sumMat+1/(curPNum)*eigviMat*diagiMat*eigviMat.';
                            sumPNum=sumPNum+curPNum;
                        end
                    end
                end
                resEllMat=0.5*sumPNum*(sumMat+sumMat.');
                resEllMat=resEllMat(isInKerAndZero,isInKerAndZero);
                [eigvNonZeroMat diagNonZeroMat]=eig(resEllMat);
                diagNewVec(isInKerAndZero)=diag(diagNonZeroMat);%...
                    %diag(diagNonZeroMat(isInKerAndZero,isInKerAndZero));
                eigNewMat(isInKerAndZero,isInKerAndZero)=eigvNonZeroMat;%(isInKerAndZero,isInKerAndZero);
                ellResVec(iDir)=Ellipsoid(cenVec,diagNewVec,eigNewMat);
            end
        end
    end
end

function dimsMat=ellSpaceDimension(ellObjMat)
    import elltool.core.Ellipsoid;
    [mSize kSize]=size(ellObjMat);
    dimsMat=zeros(mSize,kSize);
    for iInd=1:mSize
        for jInd=1:kSize
            dimsMat(iInd,jInd)=size(ellObjMat(iInd,jInd).diagMat,1);
        end
    end
end

function isZeroMat=findZeroEig(ellObjVec,nDim)
   nSize=size(ellObjVec,2);
    isZeroVec=zeros(nDim,nSize);
    for iInd=1:nSize
        isZeroMat(:,iInd)=(diag(ellObjVec(iInd).diagMat)==0);
    end   
end

function isDirInKerVec=findDirInKer(ellObjVec,curDir)
    global ellOptions  
    nSize=size(ellObjVec,2);
    for iInd=1:nSize
        ellQMat=ellObjVec(iInd).eigvMat*ellObjVec(iInd).diagMat*...
            ellObjVec(iInd).eigvMat.';             
        isDirInKerVec(iInd)=all(abs(ellQMat*curDir)<ellOptions.abs_tol);
    end
end
