function [unionCell,indLeft,indRight,indLocLeftVec,indLocRightVec]=unionjoint(leftCell,rightCell)
% UNIONJOINT calculates union of corresponding elements of two cell arrays
% jointly accross all cell array elements
%
% Usage: [unionCell,indLeft,indRight,indLocLeftVec,indLocRightVec]=unionjoint(leftCell,rightCell)
%   
% Input: 
%   regular:
%       leftCell: cell [n_1,n_2,...,n_k] - first cell array
%
%       rightCell: cell [n_1,n_2,...,n_k] - second cell array
%       
% Output: 
%   unionCell: cell [n_1,n_2,...,n_k] - resulting cell array
%
%   indLeft: double [1,m_1] - indices of corresponding elements of leftCell
%      within unionCell
%
%   indRight: double [1,m_2] - indices of corresponding elements of
%      rightCell in unionCell
%
%   indLocLeftVec: double[1,max(m_1,m_2)] - for each element of unionCell
%       contains indices of elements of leftCell or zero otherwise
%
%   indLocRightVec: double[1,max(m_1,m_2)] - for each element of unionCell
%       contains indices of elements of rightCell or zero otherwise
% 
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
%%
% TODO 1) insert proper checks, optimize the code
%
catCell=cellfun(@smartcat,leftCell,rightCell,'UniformOutput',false);
%
unionCell=uniquejoint(catCell);
[~,indLeft]=ismemberjoint(leftCell,unionCell);
[~,indRight]=ismemberjoint(rightCell,unionCell);
nUnionElems=max(max(indLeft),max(indRight));
indLocLeftVec=zeros(1,nUnionElems);
indLocRightVec=indLocLeftVec;
%
indLocLeftVec(indLeft)=1:numel(indLeft);
indLocRightVec(indRight)=1:numel(indRight);
%

function catArray=smartcat(xArray,yArray)
%
isXOk=numel(xArray)==length(xArray);
isYOk=numel(yArray)==length(yArray);
%
if ~(isXOk||isYOk)
    error('UNIONJOINT:incorrectInput','corresponding cell items in input cell arrays should be both either rows or colums');
end
isXRow=size(xArray,1)==1;
isYRow=size(xArray,1)==1;
catDim=max(isXRow,isYRow)+1;
catArray=cat(catDim,xArray,yArray);