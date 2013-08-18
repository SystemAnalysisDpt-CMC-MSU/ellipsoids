function test
axis manual;
axis normal;

angleVal=pi*0.65;
rotMat=[cos(angleVal) -sin(angleVal);sin(angleVal) cos(angleVal)];
%
ltMat=cat(2,[0;1],rotMat*[0;1]);
q1Arr=cat(3,diag([2 1]),rotMat*diag([2 1])*rotMat.');
q2Arr=cat(3,diag([4 1]),rotMat*diag([4 1])*rotMat.');
%
timeVec=0.4;
nTimes=length(timeVec);
for iTime=1:nTimes
    cla;
    curTime=timeVec(iTime);
    leftWeight=(1-curTime);
    rightWeight=curTime;
    %
    q1MidMat=matInterp(q1Arr,leftWeight,rightWeight);
    q2MidMat=matInterp(q2Arr,leftWeight,rightWeight);
    %
    q1TouchLeftVec=getTouchVec(q1Arr(:,:,1),ltMat(:,1));
    %q2TouchLeftVec=getTouchVec(q1Arr(:,:,1),ltMat(:,1));
    %
    q1TouchRightVec=getTouchVec(q1Arr(:,:,end),ltMat(:,end));
    %q2TouchRightVec=getTouchVec(q1Arr(:,:,end),ltMat(:,end));
    q1TouchMidInterpVec=(q1TouchLeftVec*leftWeight+q1TouchRightVec*rightWeight);
    q1Val=q1TouchMidInterpVec.'*(einv(q1MidMat)*q1TouchMidInterpVec);
    q1MidMat=q1MidMat*q1Val;
    q2Val=q1TouchMidInterpVec.'*(einv(q2MidMat)*q1TouchMidInterpVec);
    q2MidMat=q2Val*q2MidMat;
    
    % q1MidMat=matInterpInv(q1Arr);
    % q2MidMat=matInterpInv(q2Arr);
    dot(einv(q2MidMat)*(q1TouchMidInterpVec),q1TouchMidInterpVec)
    dot(einv(q1MidMat)*(q1TouchMidInterpVec),q1TouchMidInterpVec)
    
    lMidVec=einv(q2MidMat)*q1TouchMidInterpVec;

    %
    q1TouchMidVec=getTouchVec(q1MidMat,lMidVec);
    q2TouchMidVec=getTouchVec(q2MidMat,lMidVec);
    %
    %q1TouchLeftVec-q2TouchLeftVec
    q1TouchMidVec-q2TouchMidVec
    %q1TouchRightVec-q2TouchRightVec
    %
    plotEll(q1Arr(:,:,1),ltMat(:,1),'g');
    plotEll(q2Arr(:,:,1),ltMat(:,1),'g');
    %
    plotEll(q1Arr(:,:,2),ltMat(:,2),'b');
    plotEll(q2Arr(:,:,2),ltMat(:,2),'b');
    %
    %
    plotEll(q1MidMat,lMidVec,'r');
    plotEll(q2MidMat,lMidVec,'r');    
    %
    if iTime~=nTimes
        pause();
    end
end


end

function invMat=einv(qMat)
[oMat,dMat]=eig(qMat);
invMat=oMat*diag(1./diag(dMat))*oMat.';
end

function touchVec=getTouchVec(q1MidMat,lMidVec)
touchVec=q1MidMat*lMidVec/sqrt(lMidVec.'*q1MidMat*lMidVec);
end
%

function q1MidMat=matInterp(q1Arr,leftWeight,rightWeight)
leftMat=q1Arr(:,:,1);
rightMat=q1Arr(:,:,end);
q1MidMat=einv(einv(leftMat)*leftWeight+einv(rightMat)*rightWeight);
%q1MidMat=q1MidMat.'*q1MidMat;
end
function plotEll(qMat,lVec,colorSpec)
dirMat=gras.geom.circlepart(200).';
xyMat=transpose(sqrtm(qMat)*dirMat);
plot(xyMat(:,1),xyMat(:,2),colorSpec);
hold on;
touchVec=getTouchVec(qMat,lVec);
plot(touchVec(1),touchVec(2),[colorSpec,'*']);
hold on;
compass(lVec(1),lVec(2),colorSpec);
end


    


