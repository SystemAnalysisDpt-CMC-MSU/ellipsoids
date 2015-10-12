function [isThereVec,varargout]=ismember(leftVec,rightVec,varargin)
% ISMEMBER - ismember implementation for arrays of any type
%
% Usage: [isThereVec,indThereVec]=modgen.common.ismember(leftVec,...
%   rightVec);
%
% Input:
%   regular:
%       leftVec: any[nObjectsLeft,1]
%       rightVec: any[nObjectsRight,1]
%
% Output:
%   isThereVec: logical[nObjectsLeft,1]
%   indThereVec: double[nObjectsLeft,1]
% 
% Examples:
%
%   leftVec={struct('a',1,'b',2)}
%   rightVec={struct('a',2,'b',2); struct('a',111,'g','555')}
%   [isThereVec,indThereVec]=modgen.common.ismember(leftVec,rightVec,...
%       @(x,y)x.a==y.a)
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 09-Oct-2015 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
varargout=cell(1,max(0,nargout-1));
[isThereVec,varargout{:}]=modgen.common.ismemberjoint(...
    {leftVec},{rightVec});    