function [ ellResVec ] = minkSumIa(ellObjVec, dirMat )
% MINKSUMIA - computes tight internal ellipsoidal approximation for
% Minkowsky sum of the set of generalized ellipsoids
%
% Input:
%   regular:
%       ellObjVec: Ellipsoid: [kSize,mSize] - vector of  generalized
%                                           ellipsoid
%       dirMat: double[nDim,nDir] - matrix whose columns specify
%           directions for which approximations should be computed
% Output:
%   ellResVec: Ellipsoid[1,nDir] - vector of generalized ellipsoids of
%       internal approximation of the dirrence of first and second
%       generalized ellipsoids
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 2012-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
%
import elltool.core.Ellipsoid;
import modgen.common.throwerror
%
modgen.common.type.simple.checkgenext(@(x,y)isa(x,...
    'elltool.core.Ellipsoid')&&ismatrix(y),2,ellObjVec,dirMat)
%
ellObjVec=ellObjVec(:).';
fSizeFirst=@(ellObj)size(ellObj.diagMat,1);
dimsSpaceVec=arrayfun(fSizeFirst,ellObjVec);
minDimSpace=min(min(dimsSpaceVec));
maxDimSpace=max(max(dimsSpaceVec));
if (minDimSpace~=maxDimSpace)
    throwerror('wrongSizes',...
        ['ellipsoids of the array must ',...
        'be in the same vector space']);
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
absTol=ellObjVec.CHECK_TOL;
%
[mSize kSize]=size(ellObjVec);
if (mSize==1) && (kSize==1)
    ellResVec=ellObjVec;
else
    nEllObj=length(ellObjVec);
    ellResVec(nDirSize)=Ellipsoid(1);
    for iDir=1:nDirSize
        curDirVec=dirMat(:,iDir);
        %find all Inf directions
        ellObjCVec=num2cell(ellObjVec);
        [isInfCMat allInfDirCMat]=cellfun(...
            @Ellipsoid.findAllInfDir,ellObjCVec,...
            'UniformOutput', false);
        isInfMat=cell2mat(isInfCMat);
        allInfDirMat=cell2mat(allInfDirCMat);
        if all(all(isInfMat==1))
            %all are infinite
            ellResVec(iDir)=Ellipsoid(Inf*ones(dimSpace,1));
        elseif ~all(isInfMat(:)==0)
            %Infinite eigenvalues present
            %Construnct orthogonal basis
            [ infBasMat,  nonInfBasMat, infIndVec, finIndVec] = ...
                Ellipsoid.findSpaceBas( allInfDirMat,absTol );
            projCurDirVec=nonInfBasMat.'*curDirVec;
            if all(abs(projCurDirVec)<absTol)
                %direction lies in the space of infinite directions
                ellResVec(iDir)=Ellipsoid(Inf*ones(dimSpace,1));
            else
                %find projection of all ellipsoids on this
                isBeenFirst=false;
                for iEll=1:nEllObj
                    eigvMat=ellObjVec(iEll).eigvMat;
                    diagMat=ellObjVec(iEll).diagMat;
                    isInfHereVec=diag(diagMat)==Inf;
                    diagMat(isInfHereVec,isInfHereVec)=0;
                    projQMat=Ellipsoid.findMatProj(eigvMat,diagMat,...
                        nonInfBasMat);
                    projCenVec=nonInfBasMat.'*...
                        ellObjVec(iEll).centerVec;
                    %add to the total sum of projection, finding a
                    %proper approximation
                    nNonInf=size(nonInfBasMat,2);
                    projQMat=Ellipsoid.findSqrtOfMatrix(...
                        projQMat,absTol);
                    if (iEll==1)
                        qNICenVec=projCenVec;
                        firstVec=projQMat*projCurDirVec;
                        if all(abs(firstVec)<absTol)
                            sumNIMat=0;
                        else
                            sumNIMat=projQMat;
                            isBeenFirst=true;
                        end
                    else
                        qNICenVec=qNICenVec+projCenVec;
                        curAuxVec=projQMat*projCurDirVec;
                        if all(abs(curAuxVec)<absTol)
                            %in the ker
                            orthSNIMat=0;
                        else
                            if (isBeenFirst)
                                orthSNIMat=...
                                    gras.la.orthtransl(curAuxVec,firstVec);
                            else
                                firstVec=curAuxVec;
                                orthSNIMat=eye(nNonInf);
                            end
                        end
                        sumNIMat=sumNIMat+orthSNIMat*projQMat;
                    end
                end
                % Constructing resulting ellipsoid
                sumNIMat=sumNIMat.'*sumNIMat;
                sumNIMat=0.5*(sumNIMat+sumNIMat);
                infDimSpace=size(infBasMat,2);
                [resDiagVec, resEllMat]=Ellipsoid.findConstruction(...
                    sumNIMat,nonInfBasMat,infBasMat,finIndVec,...
                    infIndVec,Inf*ones(1,infDimSpace));
                resEllMat=resEllMat/norm(resEllMat);
                qCenVec=zeros(dimSpace,1);
                qCenVec(finIndVec)=qNICenVec;
                resEllMat=0.5*(resEllMat+resEllMat);
                ellResVec(iDir)=Ellipsoid(qCenVec,...
                    resDiagVec,resEllMat);
            end
        else %finite case, degenerate included
            isBeenFirst=false;
            for iEll=1:nEllObj
                diagVec=diag(ellObjVec(iEll).diagMat);
                eigvMat=ellObjVec(iEll).eigvMat;
                ellQMat=eigvMat*diag(sqrt(abs(diagVec)))*eigvMat.';
                if (iEll==1)
                    qCenVec=ellObjVec(iEll).centerVec;
                    firstVec=ellQMat*curDirVec;
                    if (all(abs(firstVec)<absTol))
                        sumMat=eye(dimSpace);
                    else
                        sumMat=ellQMat;
                        isBeenFirst=true;
                    end
                else
                    qCenVec=qCenVec+ellObjVec(iEll).centerVec;
                    auxVec=ellQMat*curDirVec;
                    if (all(abs(auxVec)<absTol))
                        orthSMat=0;
                    else
                        if (isBeenFirst)
                            orthSMat=...
                                gras.la.orthtransl(auxVec,firstVec);
                        else
                            orthSMat=eye(dimSpace);
                            isBeenFirst=true;
                        end
                    end
                    sumMat=sumMat+orthSMat*ellQMat;
                end
            end
            sumMat=sumMat.'*sumMat;
            sumMat=0.5*(sumMat+sumMat.');
            ellResVec(iDir)=Ellipsoid(qCenVec,sumMat);
        end
    end
end
end