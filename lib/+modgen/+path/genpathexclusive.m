function pathList=genpathexclusive(pathToIncludeCVec,pathPatternToExclude)
% GENPATHEXCLUSIVE recursively generates a list of path based on a list of 
% root path and a regular expression exclusion pattern. 
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2009-02-06 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2009 $

pathStrCVec=cellfun(@genpath,pathToIncludeCVec,'UniformOutput',false);
pathSepStr=pathsep;
pathSplitCVec=cellfun(@(x)regexp(x,pathSepStr,'split'),pathStrCVec,'UniformOutput',false);
isPathRemainedCVec=cellfun(@(x)cellfun(@(y)isempty(regexp(y,pathPatternToExclude,'once')),x),pathSplitCVec,'UniformOutput',false);
pathSplitCVec=cellfun(@(x,y)x(y),pathSplitCVec,isPathRemainedCVec,'UniformOutput',false);
pathList=[pathSplitCVec{:}];
isEmptyVec=cellfun(@isempty,pathList);
pathList=pathList(~isEmptyVec);