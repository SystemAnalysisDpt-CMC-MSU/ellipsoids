function propValMat = getProperty(rsMat,propName)
%GETPROPERTY gives matrix the same size as rsMat with values of propName properties
%for each reach set in rsMat. Private method, used in every public
%property getter.
%
% Input:
%   regular:
%       ellMat:ellipsoid[nRows, nCols] - matrix of reach sets
%
% Output:
%   propValMat:double[nRows, nCols]- matrix of propName properties for
%                                   reach sets in rsMat
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
    import modgen.common.throwerror;
    [nRows, nCols] = size(rsMat);
    propValMat = zeros(nRows,nCols);
    for iRows = 1:nRows
        for jCols = 1:nCols
            switch propName
                case 'absTol'
                    propValMat(iRows,jCols) = rsMat(iRows,jCols).absTol;
                case 'relTol'
                    propValMat(iRows,jCols) = rsMat(iRows,jCols).relTol;
                case 'nPlot2dPoints'
                    propValMat(iRows,jCols) = rsMat(iRows,jCols).nPlot2dPoints;
                case 'nPlot3dPoints'
                    propValMat(iRows,jCols) = rsMat(iRows,jCols).nPlot3dPoints;
                case 'nTimeGridPoints'
                    propValMat(iRows,jCols) = rsMat(iRows,jCols).nTimeGridPoints;
                otherwise
                    throwerror('wrongInput',[propName,':no such property']);
            end
        end
    end
end