fromMatEllTube.getNTuples()
%
% ans =
% 
%      1
% 
fromEllArrayEllTube.getNTuples()
%
% ans =
% 
%      1
% 
origFromMatEllTube=fromMatEllTube.getCopy();
fromMatEllTube.unionWith(fromEllArrayEllTube);
%
% ans =
% 
%      2
% 
fromMatEllTube.getNTuples()
isOk=fromMatEllTube.getTuples(1).isEqual(origFromMatEllTube)
%
% isOk =
%
%     1

isOk=fromMatEllTube.getTuples(2).isEqual(fromEllArrayEllTube)

%
% isOk =
%
%     1
