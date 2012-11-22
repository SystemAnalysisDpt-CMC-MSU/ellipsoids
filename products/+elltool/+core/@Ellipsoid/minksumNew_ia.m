function [ ellResVec ] = minksumNew_ia(ellObjVec, dirMat )
    import elltool.core.Ellipsoid;
    import modgen.common.throwerror
    import elltool.conf.Properties;    
    ABS_TOL = Properties.getAbsTol(); 
        
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
            isInfDirVec=findInfDir(ellObjVec,nEllObj);
            if all(isInfDirVec==1)
                %all are infinite
                ellResVec(iDir)=Ellipsoid(Inf*ones(dimSpace,1));
            elseif ~all(isInfDirVec==0)
                %here infinite present
                nInf=sum(isInfDirVec);
                nNonInf=dimSpace-nInf;
                %create nonInfDirMat of vectors
                %orthogonal to infDirMat
                %resDiagVec(isInfDirVec)=Inf;
                firstEllQMat=ellObjVec(1).eigvMat;
                nonInfDirMat=firstEllQMat(:,~isInfDirVec);
                projCurDirVec=nonInfDirMat.'*curDirVec;
                if (abs(projCurDirVec)<ABS_TOL)
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
                        curEllMat=eigvMat*diagMat*eigvMat;
                        projQMat=nonInfDirMat.'*curEllMat*nonInfDirMat;
                        projCenVec=nonInfDirMat.'*ellObjVec(iEll).centerVec;
                        %add to the total sum of projection, finding a proper
                        %approximation
                        if (iEll==1)
                            qNICenVec=projCenVec;
                            firstVec=projQMat*projCurDirVec;
                            if all(abs(firstVec)<ABS_TOL)
                                sumNIMat=0;
                            else
                                sumNIMat=projQMat;
                                wasFirst=true;
                            end
                        else
                            qNICenVec=qNICenVec+projCenVec;
                            curAuxVec=projQMat*projCurDirVec;
                            if all(abs(curAuxVec)<ABS_TOL)
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
                    [notInfEigvMat notInfDiagMat]=eig(sumNIMat);
                    resEllMat=zeros(dimSpace,dimSpace);
                    resEllMat(:,isInfDirVec)=firstEllQMat(:,isInfDirVec);
                    resEllMat(~isInfDirVec,~isInfDirVec)=notInfEigvMat;
                    resDiagVec(isInfDirVec)=Inf;
                    resDiagVec(~isInfDirVec)=diag(notInfDiagMat);
                    qCenVec=zeros(dimSpace,1);
                    qCenVec(~isInfDirVec)=qNICenVec;
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
                        if (all(abs(firstVec)<ABS_TOL))
                            sumMat=eye(dimSpace);
                        else
                            sumMat=ellQMat;
                            wasFirst=true;
                        end
                    else
                        qCenVec=qCenVec+ellObjVec(iEll).centerVec;
                        auxVec=ellQMat*curDirVec;
                        if (all(abs(auxVec)<ABS_TOL))
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

function  [isInfDirVec]=findInfDir(ellObjVec,nEllObj)
    import elltool.core.Ellipsoid;
    [mSize kSize]=size(ellObjVec(1).eigvMat);
    isInfDirVec=zeros(mSize,1);
    %infDirMat=[];
   
    for iEll=1:nEllObj
        %eigvMat=ellObjVec(iEll).eigvMat;
        isHereInfDirVec=diag(ellObjVec(iEll).diagMat)==Inf;
            
        %infDirMat=[infDirMat; eigvMat(:,isHereInfDirVec)];
        isInfDirVec=isInfDirVec+isHereInfDirVec;
    end
    isInfDirVec=isInfDirVec>0;
end
           
