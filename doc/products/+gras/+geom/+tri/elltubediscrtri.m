function facets = elltubediscrtri(nDim, mDim)
% elltubediscrtri - generates triangular facets to be used
%                    in PATCH function call.
%
%
% Description:
% ------------
%
%    elltubediscrtri(N, M)  Generates triangular facets
%           for the PATCH call.
%
%
% Output:
% -------
%
%    Array of facets.
%
%
% See also:
% ---------
%
%    PATCH, CONVHULLN.
%

%$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-06-29 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
%

facets = zeros(mDim,(nDim+1));
for iTime = 1:mDim
    f2Mat = repmat((iTime-1)*nDim,...
        size(nDim+1))+[1:nDim 1];
    facets(iTime,:)...
        = f2Mat;
end
end