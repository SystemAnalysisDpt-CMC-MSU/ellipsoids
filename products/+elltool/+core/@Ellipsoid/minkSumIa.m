function [ ellResVec ] = minkSumIa(ellObjVec, dirMat )
% MINKSUMIA - computes tight internal ellipsoidal approximation for 
%              Minkowsky sum of the set of generalized ellipsoids
%
% Input:
%       ellObjVec: Ellipsoid: [kSize,mSize] - vector of  generalized 
%                                           ellipsoid   
%       dirMat: double[nDim,nDir] - matrix whose columns specify 
%       directions for which approximations should be computed
% Output:
%   ellResVec: Ellipsoid[1,nDir] - vector of generalized ellipsoids of 
%   internal approximation of the dirrence of first and second generalized
%   ellipsoids
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
    absTol=Ellipsoid.CHECK_TOL;          
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
            'MINKSUM_IA: ellipsoids of the array must be in the same vector space');
    end
    dimSpace=maxDimSpace;
    %
    [mDirSize nDirSize]=size(dirMat);
    if (mDirSize~=dimSpace)
        msgStr=sprintf(...
            'MINKSUM_IA: second argument must be vector(s) in R^%d',...
            dimSpace);
        throwerror('wrongDir',msgStr);
    end
    %
    [mSize kSize]=size(ellObjVec);
    if (mSize==1) && (kSize==1)
        ellResVec=ellObjVec;
    else 
        nEllObj=length(ellObjVec);
        ellResVec(nDirSize)=Ellipsoid(1);
        for iDir=1:nDirSize
            curDirVec=dirMat(:,iDir);
            resDiagVec=zeros(dimSpace,1); 
            %find all Inf directions
            ellObjCVec=num2cell(ellObjVec);
            [isInfCMat allInfDirCMat]=cellfun(@findAllInfDir,ellObjCVec,...
                 'UniformOutput', false);
            isInfMat=cell2mat(isInfCMat);
            allInfDirMat=cell2mat(allInfDirCMat);  
            if all(all(isInfMat==1))
                %all are infinite
                ellResVec(iDir)=Ellipsoid(Inf*ones(dimSpace,1));
            elseif ~all(isInfMat(:)==0)
                %Infinite eigenvalues present
                %Construnct orthogonal basis 
                [orthBasMat rangL1]=findBasRang(allInfDirMat,absTol);
                nNonInf=dimSpace-rangL1;
                %rang L1>0 since there are Inf elements
                infIndVec=1:rangL1;
                finIndVec=(rangL1+1):dimSpace;
                infBasMat=orthBasMat(:,infIndVec);
                nonInfBasMat = orthBasMat(:,finIndVec);
                %
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
                        curEllMat=eigvMat*diagMat*eigvMat.';
                        projQMat=nonInfBasMat.'*curEllMat*nonInfBasMat;
                        projQMat=0.5*(projQMat+projQMat.');
                        projCenVec=nonInfBasMat.'*...
                            ellObjVec(iEll).centerVec;
                        %add to the total sum of projection, finding a 
                        %proper approximation
                        projQMat=findSqrtOfMatrix(projQMat,absTol);
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
                    [eigvProjMat, notInfDiagMat]=eig(sumNIMat);
                    notInfDiagMat=abs(notInfDiagMat);
                    %find eigenvector whose projections are eigvProjMat
                    notInfEigvMat=nonInfBasMat*eigvProjMat;
                    resEllMat=zeros(dimSpace);
                    resEllMat(:,infIndVec)=infBasMat;
                    resEllMat(:,finIndVec)=notInfEigvMat;
                    resEllMat=resEllMat/norm(resEllMat);
                    resDiagVec(infIndVec)=Inf;
                    resDiagVec(finIndVec)=diag(notInfDiagMat);
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
                    ellQMat=eigvMat*diag(abs(diagVec).^(0.5))*eigvMat.';
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
function [isInfVec infDirEigMat] = findAllInfDir(ellObj)
    isInfVec=(diag(ellObj.diagMat)==Inf);
    eigvMat=ellObj.eigvMat;
    infDirEigMat=eigvMat(:,isInfVec);
end