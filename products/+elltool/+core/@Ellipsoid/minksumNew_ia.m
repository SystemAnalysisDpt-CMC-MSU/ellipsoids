function [ ellResVec ] = minksumNew_ia(ellObjVec, dirMat )
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
    %
    [mDirSize nDirSize]=size(dirMat);
    if (mDirSize~=dimSpace)
        msgStr=sprintf('MINKSUM_EA: second argument must be vector(s) in R^%d',dimSpace);
        throwerror('wrongDir',msgStr);
    end
    %
    [mSize kSize]=size(ellObjVec);
    if (mSize==1) && (kSize==1)
        ellResVec=ellObjVec;
    else%Now only for degenerate case
        nEllObj=length(ellObjVec);
        ellResVec(nDirSize)=Ellipsoid(1);
        for iDir=1:nDirSize
            curDirVec=dirMat(:,iDir);
            for iEll=1:nEllObj
                ellQMat=ellObjVec(iEll).eigvMat*sqrtm(ellObjVec(iEll).diagMat)*...
                    ellObjVec(iEll).eigvMat.'; %Square root of ellQMat.
                if (iEll==1)
                    qCenVec=ellObjVec(iEll).centerVec;
                    firstVec=ellQMat*curDirVec;
                    sumMat=ellQMat;
                else
                    qCenVec=qCenVec+ellObjVec(iEll).centerVec;
                    orthSMat=ell_valign(firstVec,ellQMat*curDirVec);
                    sumMat=sumMat+orthSMat*ellQMat;
                end
            end
            sumMat=sumMat.'*sumMat;
            sumMat=0.5*(sumMat+sumMat.');
            ellResVec(iDir)=Ellipsoid(qCenVec,sumMat);
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


