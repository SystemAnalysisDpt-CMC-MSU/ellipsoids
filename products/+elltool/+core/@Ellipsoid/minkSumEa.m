function [ ellResVec] = minkSumEa( ellObjVec, dirMat )
    import elltool.core.Ellipsoid;
    import modgen.common.throwerror
    %
    absTol=Ellipsoid.CHECK_TOL;
    %
    modgen.common.type.simple.checkgenext(@(x,y)isa(x,...
        'elltool.core.Ellipsoid')&&ismatrix(y),2,ellObjVec,dirMat)
    %
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
    else
        ellResVec(nDirSize)=Ellipsoid();
        for iDir=1:nDirSize;
            curDirVec=dirMat(:,iDir);
            ellObjCVec=num2cell(ellObjVec);
            [isInfCMat allInfDirCMat]=cellfun(@findAllInfDir,ellObjCVec,...
                  'UniformOutput', false);
             isInfMat=cell2mat(isInfCMat);
             allInfDirMat=cell2mat(allInfDirCMat);
             isInfCase=~all(isInfMat(:)==0);
             if isInfCase
                areAllInf=all(isInfMat(:)==1); 
                ellResVec(iDir)=findINF(ellObjVec,curDirVec,dimSpace,...
                    areAllInf,allInfDirMat,absTol);
             else
                findDK=@(ellObj)findDirInKer(ellObj,curDirVec,absTol);
                isDirInKerVec=arrayfun(findDK,ellObjVec);
                isDRKCase=~all(isDirInKerVec==0);
                if~isDRKCase
                    %Finite, non-degenerate case
                    ellResVec(iDir)=findFND(ellObjVec,curDirVec);
                else
                    %Finite, degenerate
                    ellResVec(iDir)=findFD(ellObjVec,curDirVec,dimSpace,...
                        isDirInKerVec,absTol);
                end
             end    
        end
    end
end
%
%
%
function resEllObj=findINF(ellObjVec,curDirVec,dimSpace,areAllInf,allInfDirMat,absTol)
    import elltool.core.Ellipsoid;
    if areAllInf
        %all are infinite
        resEllObj=Ellipsoid(Inf*ones(dimSpace,1));
    else
        %Infinite eigenvalues present
        %Construnct orthogonal basis 
        [orthBasMat rangL1]=findBasRang(allInfDirMat,absTol);    
         %nNonInf=dimSpace-rangL1;
        %rang L1>0 since there are Inf elements
        infIndVec=1:rangL1;
        finIndVec=(rangL1+1):dimSpace;
        infBasMat=orthBasMat(:,infIndVec);
        nonInfBasMat = orthBasMat(:,finIndVec);
        %
        projCurDirVec=nonInfBasMat.'*curDirVec;
        if all(abs(projCurDirVec)<absTol)
            %direction lies in the space of infinite directions
            resEllObj=Ellipsoid(Inf*ones(dimSpace,1));
        else
              %Find those directions for with eg.vl. is zero and
              %Ql=0 and they are not equal to infinite
              %directions, i.e. orthogonal to L1
              nEllObj=length(ellObjVec);
              %indDegEllVec=(1:nEllObj).';
              %indDegEllVec=indDegEllVec(isDirInKerVec);
              ellObjCVec=num2cell(ellObjVec);                     
              cmptAllZeroDirFin=@(ellObj)findAllZeroDirFin(ellObj,...
                  nonInfBasMat,projCurDirVec,absTol);
              [allZeroDirFCMat]=cellfun(cmptAllZeroDirFin,...
                    ellObjCVec,'UniformOutput', false);
                %isZeroMat=cell2mat(isZeroCMat);
                allZeroFDirMat=cell2mat(allZeroDirFCMat); 
                if ~isempty(allZeroFDirMat)
                    %Construnct orthogonal basis  
                    [orthBasZFMat rangZL1]=findBasRang(allZeroFDirMat,absTol);
                    %rang ZL1>0 since there are Zero elements
                    zeroIndVec=1:rangZL1;
                    nonZeroIndVec=(rangZL1+1):dimSpace;
                    zeroBasMat=orthBasZFMat(:,zeroIndVec);
                    %So zeroBasMat form basis among finite
                    %dimenstions corresponding to zero eig. vl.
                    %And infBasMat - basis of infinite dimensions.
                    %We have to find projections on zeroBasMat and
                    %all the rest directions will be infinite
                    nonZeroBasMat = orthBasZFMat(:,nonZeroIndVec);
                    projCurDirVec=zeroBasMat.'*curDirVec;
                    %find projection of all ellipsoids on zeroBasMat
                    isBeenFirstNonDeg=false;
                    for iEll=1:nEllObj
                        eigviMat=ellObjVec(iEll).eigvMat;
                        diagiMat=ellObjVec(iEll).diagMat;
                        curEllMat=eigviMat*diagiMat*eigviMat.';
                        projQMat=zeroBasMat.'*curEllMat*zeroBasMat;
                        projCenVec=zeroBasMat.'*ellObjVec(iEll).centerVec;
                        curPNum=sqrt(projCurDirVec.'*projQMat*projCurDirVec);
                        if (abs(curPNum)>absTol)
                            if (~isBeenFirstNonDeg)
                                cenVec=projCenVec;
                                sumMat=1/(curPNum)*projQMat;
                                sumPNum=curPNum;
                                isBeenFirstNonDeg=true;
                            else
                                cenVec=cenVec+projCenVec;
                                sumMat=sumMat+1/(curPNum)*projQMat;
                                sumPNum=sumPNum+curPNum;
                            end
                        end
                    end 
                    resEllMat=0.5*sumPNum*(sumMat+sumMat.');
                    [eigvProjZMat diagZeroMat]=eig(resEllMat);
                    %find eigenvector whose projections are eigvProjMat
                    zeroEigvMat=zeroBasMat*eigvProjZMat;
                    %Construnct the result
                    resFinMat=zeros(dimSpace);
                    resFinMat(:,zeroIndVec)=zeroEigvMat; 
                    resFinMat(:,nonZeroIndVec)=nonZeroBasMat;
                    resFinMat=resFinMat/norm(resFinMat);
                    resDiagVec=zeros(dimSpace,1);    
                    resDiagVec(zeroIndVec)=diag(diagZeroMat);
                    resDiagVec(nonZeroIndVec)=Inf;
                    qCenVec=zeros(dimSpace,1);
                    qCenVec(zeroIndVec)=cenVec;
                    resFinMat=0.5*(resFinMat+resFinMat);
                    resEllObj=Ellipsoid(qCenVec,resDiagVec,resFinMat); 
                else
                    %find projection of all ellipsoids on zeroBasMat
                    isBeenFirstNonDeg=false;
                    for iEll=1:nEllObj
                        eigviMat=ellObjVec(iEll).eigvMat;
                        diagiMat=ellObjVec(iEll).diagMat;
                        isInfHereVec=diag(diagiMat)==Inf;
                        diagiMat(isInfHereVec,isInfHereVec)=0;
                        curEllMat=eigviMat*diagiMat*eigviMat.';
                        projQMat=nonInfBasMat.'*curEllMat*nonInfBasMat;
                        projCenVec=nonInfBasMat.'*ellObjVec(iEll).centerVec;
                        curPNum=sqrt(projCurDirVec.'*projQMat*projCurDirVec);
                        if (abs(curPNum)>absTol)
                            if (~isBeenFirstNonDeg)
                                cenVec=projCenVec;
                                sumMat=1/(curPNum)*projQMat;
                                sumPNum=curPNum;
                                isBeenFirstNonDeg=true;
                            else
                                cenVec=cenVec+projCenVec;
                                sumMat=sumMat+1/(curPNum)*projQMat;
                                sumPNum=sumPNum+curPNum;
                            end
                        end
                    end 
                    resEllMat=0.5*sumPNum*(sumMat+sumMat.');
                    [eigvProjNIMat diagNInfMat]=eig(resEllMat);
                    %find eigenvector whose projections are eigvProjMat
                    nonInfEigvMat=nonInfBasMat*eigvProjNIMat;
                    %Construnct the result
                    resFinMat=zeros(dimSpace);
                    resFinMat(:,finIndVec)=nonInfEigvMat; 
                    resFinMat(:,infIndVec)=infBasMat;
                    resFinMat=resFinMat/norm(resFinMat);
                    resDiagVec=zeros(dimSpace,1);    
                    resDiagVec(finIndVec)=diag(diagNInfMat);
                    resDiagVec(infIndVec)=Inf;
                    qCenVec=zeros(dimSpace,1);
                    qCenVec(finIndVec)=cenVec;
                    resFinMat=0.5*(resFinMat+resFinMat);
                    resEllObj=Ellipsoid(qCenVec,resDiagVec,resFinMat); 
                end
        end
     end
end
function resEllObj=findFND(ellObjVec,curDirVec)
    import elltool.core.Ellipsoid;
    nEllObj=length(ellObjVec);
    for iEll=1:nEllObj;
        eigviMat=ellObjVec(iEll).eigvMat;
        diagiMat=ellObjVec(iEll).diagMat;
        auxVec=eigviMat.'*curDirVec;
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
    resEllObj=Ellipsoid(cenVec,resEllMat);
end
%
function resEllObj=findFD(ellObjVec,curDirVec,dimSpace,isDirInKerVec,absTol)
    import elltool.core.Ellipsoid;
    %Aim: find direction correspoding to zero e.vl. among ellipsoids
    %for wich Q*l=0;
    nEllObj=length(ellObjVec);
    indDegEllVec=(1:nEllObj).';
    indDegEllVec=indDegEllVec(isDirInKerVec);
    ellObjCVec=num2cell(ellObjVec);
    findAZD=@(ellObj)findAllZeroDir(ellObj,absTol);
    [~, allZeroDirCMat]=cellfun(findAZD,...
        ellObjCVec(indDegEllVec),'UniformOutput', false);
    %isZeroMat=cell2mat(isZeroCMat);
    allZeroDirMat=cell2mat(allZeroDirCMat); 
    %Construnct orthogonal basis 
    [orthBasZMat rangZL1]=findBasRang(allZeroDirMat,absTol);
    %rang ZL1>0 since there are Zero elements
    zeroIndVec=1:rangZL1;
    nonZeroIndVec=(rangZL1+1):dimSpace;
    zeroBasMat=orthBasZMat(:,zeroIndVec);
    nonZeroBasMat = orthBasZMat(:,nonZeroIndVec);
    projCurDirVec=zeroBasMat.'*curDirVec;
    %find projection of all ellipsoids on zeroBasMat
    isBeenFirstNonDeg=false;
    for iEll=1:nEllObj
        eigviMat=ellObjVec(iEll).eigvMat;
        diagiMat=ellObjVec(iEll).diagMat;
        curEllMat=eigviMat*diagiMat*eigviMat.';
        projQMat=zeroBasMat.'*curEllMat*zeroBasMat;
        projCenVec=zeroBasMat.'*ellObjVec(iEll).centerVec;
        curPNum=sqrt(projCurDirVec.'*projQMat*projCurDirVec);
        if (abs(curPNum)>absTol)
            if (~isBeenFirstNonDeg)
                cenVec=projCenVec;
                sumMat=1/(curPNum)*projQMat;
                sumPNum=curPNum;
                isBeenFirstNonDeg=true;
            else
                cenVec=cenVec+projCenVec;
                sumMat=sumMat+1/(curPNum)*projQMat;
                sumPNum=sumPNum+curPNum;
            end
        end
    end 
    resEllMat=0.5*sumPNum*(sumMat+sumMat.');
    [eigvProjZMat diagZeroMat]=eig(resEllMat);
    %find eigenvector whose projections are eigvProjMat
    zeroEigvMat=zeroBasMat*eigvProjZMat;
    %Construnct the result
    resFinMat=zeros(dimSpace);
    resFinMat(:,zeroIndVec)=zeroEigvMat; 
    resFinMat(:,nonZeroIndVec)=nonZeroBasMat;
    resFinMat=resFinMat/norm(resFinMat);
    resDiagVec=zeros(dimSpace,1);    
    resDiagVec(zeroIndVec)=diag(diagZeroMat);
    resDiagVec(nonZeroIndVec)=Inf;
    qCenVec=zeros(dimSpace,1);
    qCenVec(zeroIndVec)=cenVec;
    resFinMat=0.5*(resFinMat+resFinMat);
    resEllObj=Ellipsoid(qCenVec,resDiagVec,resFinMat); 
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
function [isInfVec infDirEigMat] = findAllInfDir(ellObj)
    isInfVec=(diag(ellObj.diagMat)==Inf);
    eigvMat=ellObj.eigvMat;
    infDirEigMat=eigvMat(:,isInfVec);
end
function [isZeroVec zeroDirEigMat] = findAllZeroDir(ellObj,absTol)
    isZeroVec=(abs(diag(ellObj.diagMat))<absTol);
    eigvMat=ellObj.eigvMat;
    zeroDirEigMat=eigvMat(:,isZeroVec);
end
function [zeroDirEigMat] = findAllZeroDirFin(ellObj,finBasMat,curDirVec,absTol)
    eigvMat=ellObj.eigvMat;
    diagMat=ellObj.diagMat;
    isZeroVec=abs(diag(diagMat))<absTol;
    isInfHereVec=diag(diagMat)==Inf;
    diagMat(isInfHereVec,isInfHereVec)=0;
    projQMat=eigvMat*diagMat*eigvMat.';
    projQMat=finBasMat.'*projQMat*finBasMat;
    projDirVec=curDirVec;
    isZero=all(abs(projQMat*projDirVec)<absTol);
    if (isZero)    
        zeroDirEigMat=eigvMat(:,isZeroVec);
    else
        zeroDirEigMat=[];
    end
    
end
function isDirInKer=findDirInKer(ellObj,curDir,absTol)
    ellQMat=ellObj.eigvMat*ellObj.diagMat*...
            ellObj.eigvMat.';             
    isDirInKer=all(abs(ellQMat*curDir)<absTol);   
end
function [orthBasMat rang]=findBasRang(qMat,absTol)
    [orthBasMat rBasMat]=qr(qMat);
    if size(rBasMat,2)==1
        isNeg=rBasMat(1)<0;
        orthBasMat(:,isNeg)=-orthBasMat(:,isNeg);
    else
        isNegVec=diag(rBasMat)<0;
        orthBasMat(:,isNegVec)=-orthBasMat(:,isNegVec);
    end
    tolerance = absTol*norm(qMat,'fro');
    rang = sum(abs(diag(rBasMat)) > tolerance);
    rang = rang(1); %for case where rBasZMat is vector.
end              
