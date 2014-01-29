function [ ellResVec] = minkSumEa( ellObjVec, dirMat )
% MINKSUMEA - computes tight external ellipsoidal approximation for
%             Minkowsky sum of the set of generalized ellipsoids
%
% Input:
%   regular:
%       ellObjVec: GenEllipsoid: [kSize,mSize] - vector of  generalized
%                                           ellipsoid
%       dirMat: double[nDim,nDir] - matrix whose columns specify
%           directions for which approximations should be computed
% Output:
%   ellResVec: GenEllipsoid[1,nDir] - vector of generalized ellipsoids of
%       external approximation of the dirrence of first and second 
%       generalized ellipsoids
% 
% Example:
%   firstEllObj = elltool.core.GenEllipsoid([1;1],eye(2));
%   secEllObj = elltool.core.GenEllipsoid([5;0],[3 0; 0 2]);
%   ellVec = [firstEllObj secEllObj];
%   dirsMat = [1 3; 2 4];
%   ellResVec  = minkSumEa(ellVec, dirsMat )
%  
%   Structure(1)
%      |    
%      |----- q : [6 1]
%      |          -----------------
%      |----- Q : |7.50584|0      |
%      |          |0      |5.83164|
%      |          -----------------
%      |          -----
%      |-- QInf : |0|0|
%      |          |0|0|
%      |          -----
%      O
%  
%   Structure(2)
%      |    
%      |----- q : [6 1]
%      |          -----------------
%      |----- Q : |7.48906|0      |
%      |          |0      |5.83812|
%      |          -----------------
%      |          -----
%      |-- QInf : |0|0|
%      |          |0|0|
%      |          -----
%      O
%
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    
% $Date: 2012-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import elltool.core.GenEllipsoid;
import modgen.common.throwerror
%
modgen.common.type.simple.checkgenext(@(x,y)isa(x,...
    'elltool.core.GenEllipsoid')&&ismatrix(y),2,ellObjVec,dirMat)
%
ellObjVec=ellObjVec(:).';
fSizeFirst=@(ellObj)size(ellObj.diagMat,1);
dimsSpaceVec=arrayfun(fSizeFirst,ellObjVec);
minDimSpace=min(min(dimsSpaceVec));
maxDimSpace=max(max(dimsSpaceVec));
if (minDimSpace~=maxDimSpace)
    throwerror('wrongSizes',...
        ['ellipsoids of the array ',...
        'must be in the same vector space']);
end
dimSpace=maxDimSpace;
%
[mDirSize nDirSize]=size(dirMat);
if (mDirSize~=dimSpace)
    msgStr=sprintf(...
        'second argument must be vector(s) in R^%d',...
        dimSpace);
    throwerror('wrongDir',msgStr);
end
%
absTol=ellObjVec(1).CHECK_TOL;
%
[mSize kSize]=size(ellObjVec);
if (mSize==1) && (kSize==1)
    ellResVec=ellObjVec;
else
    ellResVec(nDirSize)=GenEllipsoid();
    for iDir=1:nDirSize;
        curDirVec=dirMat(:,iDir);
        ellObjCVec=num2cell(ellObjVec);
        [isInfCMat allInfDirCMat]=cellfun(...
            @GenEllipsoid.findAllInfDir,ellObjCVec,...
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
                ellResVec(iDir)=findFD(ellObjVec,curDirVec,...
                    dimSpace,isDirInKerVec,absTol);
            end
        end
    end
end
end
%
function resEllObj=findINF(ellObjVec,curDirVec,dimSpace,areAllInf,...
    allInfDirMat,absTol)
import elltool.core.GenEllipsoid;
if areAllInf
    %all are infinite
    resEllObj=GenEllipsoid(Inf*ones(dimSpace,1));
else
    %Infinite eigenvalues present
    [ infBasMat,  finBasMat, infIndVec, finIndVec] = ...
        GenEllipsoid.findSpaceBas( allInfDirMat,absTol );
    projCurDirVec=finBasMat.'*curDirVec;
    if all(abs(projCurDirVec)<absTol)
        %direction lies in the space of infinite directions
        resEllObj=GenEllipsoid(Inf*ones(dimSpace,1));
    else
        %Find those directions for with eg.vl. is zero and
        %Ql=0 and they are not equal to infinite
        %directions, i.e. orthogonal to L1
        nEllObj=length(ellObjVec);
        ellObjCVec=num2cell(ellObjVec);
        cmptAllZeroDirFin=@(ellObj)findAllZeroDirFin(ellObj,...
            finBasMat,projCurDirVec,absTol);
        [allZeroDirFCMat]=cellfun(cmptAllZeroDirFin,...
            ellObjCVec,'UniformOutput', false);
        allZeroFDirMat=cell2mat(allZeroDirFCMat);
        if ~isempty(allZeroFDirMat)
            [ finBasMat,  infBasMat, finIndVec, infIndVec] =...
                GenEllipsoid.findSpaceBas( allZeroFDirMat,absTol );
            projCurDirVec=finBasMat.'*curDirVec;
        end
        isBeenFirstNonDeg=false;
        for iEll=1:nEllObj
            eigviMat=ellObjVec(iEll).eigvMat;
            diagiMat=ellObjVec(iEll).diagMat;
            isInfHereVec=diag(diagiMat)==Inf;
            diagiMat(isInfHereVec,isInfHereVec)=0;
            projQMat=GenEllipsoid.findMatProj(eigviMat,diagiMat,...
                finBasMat);
            projCenVec=...
                finBasMat.'*ellObjVec(iEll).centerVec;
            curPNum=...
                realsqrt(projCurDirVec.'*projQMat*projCurDirVec);
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
        infDimSpace=size(infBasMat,2);
        [resDiagVec, resFinMat]=GenEllipsoid.findConstruction(...
            resEllMat,finBasMat,infBasMat,finIndVec,infIndVec,...
            Inf*ones(1,infDimSpace));
        resFinMat=resFinMat/norm(resFinMat);
        qCenVec=zeros(dimSpace,1);
        qCenVec(finIndVec)=cenVec;
        resFinMat=0.5*(resFinMat+resFinMat);
        resEllObj=GenEllipsoid(qCenVec,resDiagVec,resFinMat);
    end
end
end
%
function resEllObj=findFND(ellObjVec,curDirVec)
import elltool.core.GenEllipsoid;
nEllObj=length(ellObjVec);
for iEll=1:nEllObj;
    eigviMat=ellObjVec(iEll).eigvMat;
    diagiMat=ellObjVec(iEll).diagMat;
    auxVec=eigviMat.'*curDirVec;
    curPNum=realsqrt(auxVec.'*diagiMat*auxVec);
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
resEllObj=GenEllipsoid(cenVec,resEllMat);
end
%
function resEllObj=findFD(ellObjVec,curDirVec,dimSpace,isDirInKerVec,...
    absTol)
import elltool.core.GenEllipsoid;
%Aim: find direction correspoding to zero e.vl. among ellipsoids
%for which Q*l=0;
nEllObj=length(ellObjVec);
indDegEllVec=(1:nEllObj).';
indDegEllVec=indDegEllVec(isDirInKerVec);
ellObjCVec=num2cell(ellObjVec);
findAZD=@(ellObj)findAllZeroDir(ellObj,absTol);
[~, allZeroDirCMat]=cellfun(findAZD,...
    ellObjCVec(indDegEllVec),'UniformOutput', false);
allZeroDirMat=cell2mat(allZeroDirCMat);
%Construnct orthogonal basis
[ zeroBasMat,  nonZeroBasMat, zeroIndVec, nonZeroIndVec] = ...
    GenEllipsoid.findSpaceBas( allZeroDirMat,absTol );
projCurDirVec=zeroBasMat.'*curDirVec;
%find projection of all ellipsoids on zeroBasMat
isBeenFirstNonDeg=false;
for iEll=1:nEllObj
    eigviMat=ellObjVec(iEll).eigvMat;
    diagiMat=ellObjVec(iEll).diagMat;
    projQMat=GenEllipsoid.findMatProj(eigviMat,diagiMat,zeroBasMat);
    projCenVec=zeroBasMat.'*ellObjVec(iEll).centerVec;
    curPNum=realsqrt(projCurDirVec.'*projQMat*projCurDirVec);
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
nonZeroDimSpace=size(nonZeroBasMat,2);
[resDiagVec, resFinMat]=GenEllipsoid.findConstruction(resEllMat,...
    zeroBasMat,nonZeroBasMat,zeroIndVec,nonZeroIndVec,...
    Inf*ones(1,nonZeroDimSpace));
resFinMat=resFinMat/norm(resFinMat);
qCenVec=zeros(dimSpace,1);
qCenVec(zeroIndVec)=cenVec;
resFinMat=0.5*(resFinMat+resFinMat);
resEllObj=GenEllipsoid(qCenVec,resDiagVec,resFinMat);
end
function [isZeroVec zeroDirEigMat] = findAllZeroDir(ellObj,absTol)
isZeroVec=(abs(diag(ellObj.diagMat))<absTol);
eigvMat=ellObj.eigvMat;
zeroDirEigMat=eigvMat(:,isZeroVec);
end
function [zeroDirEigMat] = findAllZeroDirFin(ellObj,finBasMat,curDirVec,...
    absTol)
import elltool.core.GenEllipsoid;
eigvMat=ellObj.eigvMat;
diagMat=ellObj.diagMat;
isZeroVec=abs(diag(diagMat))<absTol;
isInfHereVec=diag(diagMat)==Inf;
diagMat(isInfHereVec,isInfHereVec)=0;
projQMat=GenEllipsoid.findMatProj(eigvMat,diagMat,finBasMat);
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