function propValMat = getProperty(ellMat,propName)
%GETPROPERTY gives matrix the same size as ellMat with values of propName properties
%for each ellipsoid in ellMat. Private method, used in every public
%property getter.
%
% Input:
%   regular:
%       ellMat:ellipsoid[nRows, nCols] - matrix of ellipsoids
%
% Output:
%   propValMat:double[nRows, nCols]- matrix of propName properties for
%                                   ellipsoids in ellMat
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
    import modgen.common.throwerror;
    [nRows, nCols] = size(ellMat);
    propValMat = zeros(nRows,nCols);
    for iRows = 1:nRows
        for jCols = 1:nCols
            switch propName
                case 'absTol'
                    propValMat(iRows,jCols) = ellMat(iRows,jCols).absTol;
                case 'relTol'
                    propValMat(iRows,jCols) = ellMat(iRows,jCols).relTol;
                case 'nPlot2dPoints'
                    propValMat(iRows,jCols) = ellMat(iRows,jCols).nPlot2dPoints;
                case 'nPlot3dPoints'
                    propValMat(iRows,jCols) = ellMat(iRows,jCols).nPlot3dPoints;
                otherwise
                    throwerror('wrongInput',[propName,':no such property']);
            end
        end
    end
end