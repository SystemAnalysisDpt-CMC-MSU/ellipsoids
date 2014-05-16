% An example of concatenating ellipsoid tube objects containing random 
% number of ellipsoid tubes (from one to ten tubes).
%
nTubes = randi(10,1);
nPoints = 20;
type = 1;
timeBeg1 = 0;
timeEnd1 = 1;
firstEllTubeObj =...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg1,timeEnd1,type,nPoints);
timeBeg2 = 1;
timeEnd2 = 2;
secondEllTubeObj =...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg2,timeEnd2,type,nPoints);
%
% Concatenating firstEllTube and secondEllTube on [timeBeg1, timeEnd2]
% vector of time.
%
resEllTubeObj = firstEllTubeObj.cat(secondEllTubeObj);
%
% Concatenating the same firstEllTube and secondEllTube on [timeBeg1,timeEnd2]
% vector of time, but the sTime and values of properties corresponding to 
% sTime are taken from secondEllTube.
%
resEllTubeObj = firstEllTubeObj.cat(secondEllTubeObj,'isReplacedByNew',true);
%
% Concatenating the same firstEllTube and secondEllTube on [timeBeg1,timeEnd2]
% vector of time, but the sTime and values of properties corresponding to 
% sTime are taken from firstEllTube.
%
resEllTubeObj = firstEllTubeObj.cat(secondEllTubeObj,'isReplacedByNew',false);
%
% Note that we cannot concatenate ellipsoid tubes with  overlapping time
% limits.
%


