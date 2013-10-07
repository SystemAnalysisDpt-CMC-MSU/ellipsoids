  function  [qArrayListITube, ltGoodDirArrayITube]=fCalcTube1(probDynObj,  ...
                   xDim, timeVec, ...
                  lMat,  isDisturb, isMinMax, approxType,...
                   fMinkmp,  fMinksum, fMinkdiff, isBack, l0Mat)
               
               
                qMat = probDynObj.getX0Mat;
                qMat = 0.5 * (qMat + qMat');
                %
                %qArrayList{iTube}(:, :, 1) = qMat;
                qArrayListITube(:,:,1)=qMat;
                %lVec = l0Mat(:, iTube);
                lVec = l0Mat;
                lMat(:, 1) = lVec;
                for iTime = 1:(length(timeVec) - 1)  
                    aMat = probDynObj.getAtDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    aInvMat = inv(aMat);
                    bpbMat = probDynObj.getBPBTransDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    bpbMat = 0.5 * (bpbMat + bpbMat');
                    if isDisturb
                        gqgMat = probDynObj.getCQCTransDynamics(). ...
                            evaluate(timeVec(iTime + isBack));
                    end
                    qMat = aMat * qMat * aMat';
                    qMat = 0.5 * (qMat + qMat');
                    lVec = aInvMat' * lVec;
                    lVec = lVec / norm(lVec);
                    if isDisturb
                        if isMinMax
                            eEll = fMinkmp(ellipsoid(0.5 * (qMat + qMat')),...
                                ellipsoid(0.5 * (gqgMat + gqgMat')),...
                                ellipsoid(0.5 * (bpbMat + bpbMat')), lVec);
                        else
                            eEll = fMinksum([ellipsoid(0.5 * (qMat + qMat'))...
                                ellipsoid(0.5 * (bpbMat + bpbMat'))], lVec);
                            eEll = fMinkdiff(eEll, ...
                                ellipsoid(0.5 * (gqgMat + gqgMat')), lVec);
                        end
                    else
                        eEll = fMinksum([ellipsoid(0.5 * (qMat + qMat')) ...
                            ellipsoid(0.5 * (bpbMat + bpbMat'))], lVec);
                    end
                    %
                    if ~isempty(eEll)
                        qMat = double(eEll);
                    else
                        qMat = zeros(xDim, xDim);
                    end
                    qMat = 0.5 * (qMat + qMat');
                    %qArrayList{iTube}(:, :, iTime + 1) = qMat;
                    qArrayListITube(:, :, iTime + 1) = qMat;
                    lMat(:, iTime + 1) = aInvMat' * lMat(:, iTime);
                end
                %qArrayListITube=qArrayList{iTube}(:, :, :)
                %ltGoodDirArray(:, iTube, :) = lMat;
                
                %ltGoodDirArrayITube=ltGoodDirArray(:, iTube, :);
                ltGoodDirArrayITube=lMat;
       %save('C:\Users\Ivan\my_branch\products\+elltool\+pcalc\args5.mat', 'qArrayList');
       %save('C:\Users\Ivan\my_branch\products\+elltool\+pcalc\args6.mat', 'ltGoodDirArray');
       
    
    
    
    end