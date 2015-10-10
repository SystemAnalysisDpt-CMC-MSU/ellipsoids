function [outUnqVec,indRightToLeftVec,indLeftToRightVec]=...
    uniquebyfunc(inpVec,fCompare,algoName)
% UNIQUEBYFUNC unique for arrays of any type where an
%   element comparison is performed by a specified function
%
% Usage: [outUnqVec,indRightToLeftVec,indLeftToRightVec]=uniquebyfunc(...
%           inpVec,fCompare);
%
% Input:
%   regular:
%       inpVec: any[nObjects,1] - input vector of objects
%   optional:
%       fCompare: function_handle[1,1] - an element comparison function,
%           default is @isequaln
%       algoName: char[1,] - can be one of
%           'memhungry' - faster but requires more RAM
%           'mempreserve' (DEFAULT) - RAM preserving but slower
%
% Output:
%   outUnqVec: cell[nUniqObjects,1]
%   indRightToLeftVec: double[nUniqObjects] : all
%       fCompare(inpVec(indRightToLeftVec)==outUnqVec)==true
%   indLeftToRightVec: double[nObjects,1] : all
%       all(fCompare(outUnqVec(indLeftToRightVec)==inpVec))
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
import modgen.common.ismemberbyfunc;
import modgen.common.throwerror;
%
DEFAULT_ALGO_NAME='mempreserve';
%
if nargin<3
    algoName=DEFAULT_ALGO_NAME;
    if nargin<2
        fCompare=@isequaln;
    end
end
%
switch algoName
    case 'memhungry'
        [isThereVec,indLeftToRightVec]=ismemberbyfunc(inpVec,inpVec,fCompare); %#ok<ASGLU>
        indVec=1:numel(indLeftToRightVec);
        indVec=indVec.';
        if isrow(inpVec)
            indLeftToRightVec=indLeftToRightVec.';
        end
        %
        isInUniq=ismember(indVec,indLeftToRightVec);        
        indRightToLeftVec=find(isInUniq);
        [isThereVec,indLeftToRightVec]=ismember(indLeftToRightVec,...
            indRightToLeftVec); %#ok<ASGLU>
        outUnqVec=inpVec(isInUniq);
    case 'mempreserve'
        % more memory preserving
        outUnqVec=[];
        indRightToLeftVec=[];
        indLeftToRightVec=nan(numel(inpVec),1);
        for iObj=1:numel(inpVec)
            [isThereVec,indThereVec]=ismemberbyfunc(inpVec(iObj),outUnqVec,fCompare);
            if ~isThereVec
                outUnqVec=[outUnqVec; inpVec(iObj)]; %#ok<AGROW>
                indRightToLeftVec=[indRightToLeftVec; iObj]; %#ok<AGROW>
                indLeftToRightVec(iObj)=length(outUnqVec);
            else
                indLeftToRightVec(iObj)=indThereVec;
            end
        end
        if isrow(inpVec)
            outUnqVec=outUnqVec.';
        end
    otherwise,
        throwerror('wrongInput','algorithm %s is not supported',algoName);
end