function [ ellResVec ] = minksumIa(ellObjVec, dirMat )
    import elltool.core.Ellipsoid;
    import modgen.common.throwerror
    CHECK_TOL=1e-12;
              
    if (~isa(ellObjVec,'Ellipsoid'))
        throwerror('notEllipsoid','MINKSUM_IA: first argument must be array of ellipsoids');
    end
    
    ellObjVec=ellObjVec(:).';
    dimsSpaceVec=ellSpaceDimension(ellObjVec);
    minDimSpace=min(min(dimsSpaceVec));
    maxDimSpace=max(max(dimsSpaceVec));
    if (minDimSpace~=maxDimSpace)
        throwerror('wrongSizes','MINKSUM_IA: ellipsoids of the array must be in the same vector space');
    end
    dimSpace=maxDimSpace;
    %
    [mDirSize nDirSize]=size(dirMat);
    if (mDirSize~=dimSpace)
        msgStr=sprintf('MINKSUM_IA: second argument must be vector(s) in R^%d',dimSpace);
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
                [orthBasMat rBasMat]=qr(allInfDirMat);
                %L2 Basis
                if size(rBasMat,2)==1
                    isNeg=rBasMat(1)<0;
                    orthBasMat(:,isNeg)=-orthBasMat(:,isNeg);
                else
                    isNegVec=diag(rBasMat)<0;
                    orthBasMat(:,isNegVec)=-orthBasMat(:,isNegVec);
                end
                tolerance = CHECK_TOL*norm(allInfDirMat,'fro');
                rangL1 = sum(abs(diag(rBasMat)) > tolerance);
                rangL1 = rangL1(1); %for case where rBasMat is vector.
                nNonInf=dimSpace-rangL1;
                %rang L1>0 since there are Inf elements
                infIndVec=1:rangL1;
                finIndVec=(rangL1+1):dimSpace;
                infBasMat=orthBasMat(:,infIndVec);
                nonInfBasMat = orthBasMat(:,finIndVec);
                %
                projCurDirVec=nonInfBasMat.'*curDirVec;
                if all(abs(projCurDirVec)<CHECK_TOL)
                    %direction lies in the space of infinite directions
                    ellResVec(iDir)=Ellipsoid(Inf*ones(dimSpace,1));
                else
                    %find projection of all ellipsoids on this 
                    wasFirst=false;
                    for iEll=1:nEllObj
                        eigvMat=ellObjVec(iEll).eigvMat;
                        diagMat=ellObjVec(iEll).diagMat;
                        isInfHereVec=diag(diagMat)==Inf;
                        diagMat(isInfHereVec,isInfHereVec)=0;
                        curEllMat=eigvMat*diagMat*eigvMat.';
                        projQMat=nonInfBasMat.'*curEllMat*nonInfBasMat;
                        projCenVec=nonInfBasMat.'*ellObjVec(iEll).centerVec;
                        %add to the total sum of projection, finding a proper
                        %approximation
                        projQMat=sqrtm(projQMat);
                        if (iEll==1)
                            qNICenVec=projCenVec;
                            firstVec=projQMat*projCurDirVec;
                            if all(abs(firstVec)<CHECK_TOL)
                                sumNIMat=0;
                            else
                                sumNIMat=projQMat;
                                wasFirst=true;
                            end
                        else
                            qNICenVec=qNICenVec+projCenVec;
                            curAuxVec=projQMat*projCurDirVec;
                            if all(abs(curAuxVec)<CHECK_TOL)
                                %in the ker
                                orthSNIMat=0;
                            else
                                if (wasFirst)
                                    orthSNIMat=ell_valign(firstVec,curAuxVec);
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
                    ellResVec(iDir)=Ellipsoid(qCenVec,resDiagVec,resEllMat);
                end
            else %finite case, degenerate included
                wasFirst=false;
                for iEll=1:nEllObj
                    ellQMat=ellObjVec(iEll).eigvMat*sqrtm(ellObjVec(iEll).diagMat)*...
                        ellObjVec(iEll).eigvMat.'; %Square root of ellQMat.
                    if (iEll==1)
                        qCenVec=ellObjVec(iEll).centerVec;
                        firstVec=ellQMat*curDirVec;
                        if (all(abs(firstVec)<CHECK_TOL))
                            sumMat=eye(dimSpace);
                        else
                            sumMat=ellQMat;
                            wasFirst=true;
                        end
                    else
                        qCenVec=qCenVec+ellObjVec(iEll).centerVec;
                        auxVec=ellQMat*curDirVec;
                        if (all(abs(auxVec)<CHECK_TOL))
                            orthSMat=0;
                        else
                            if (wasFirst)
                                orthSMat=ell_valign(firstVec,auxVec);
                            else
                                orthSMat=eye(dimSpace);
                                wasFirst=true;
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
