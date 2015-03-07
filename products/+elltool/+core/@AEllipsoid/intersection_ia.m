function outEllArr = intersection_ia(myEllArr, objArr)
%
% INTERSECTION_IA - internal ellipsoidal approximation of the
%                   intersection of ellipsoid and ellipsoid,
%                   or ellipsoid and halfspace, or ellipsoid
%                   and polytope.
%
%   outEllArr = INTERSECTION_IA(myEllArr, objArr) - Given two
%       ellipsoidal matrixes of equal sizes, myEllArr and
%       objArr = ellArr, or, alternatively, myEllMat or ellMat must be
%       a single ellipsoid, comuptes the internal ellipsoidal
%       approximations of intersections of two corresponding ellipsoids
%       from myEllMat and from ellMat.
%   outEllArr = INTERSECTION_IA(myEllArr, objArr) - Given matrix of
%       ellipsoids myEllArr and matrix of hyperplanes objArr = hypArr
%       whose sizes match, computes the internal ellipsoidal
%       approximations of intersections of ellipsoids and halfspaces
%       defined by hyperplanes in hypMat.
%       If v is normal vector of hyperplane and c - shift,
%       then this hyperplane defines halfspace
%                  <v, x> <= c.
%   outEllArr = INTERSECTION_IA(myEllArr, objArr) - Given matrix of
%       ellipsoids  myEllArr and matrix of polytopes objArr = polyArr
%       whose sizes match, computes the internal ellipsoidal
%       approximations of intersections of ellipsoids myEllArr
%       and polytopes polyArr.
%
%   The method used to compute the minimal volume overapproximating
%   ellipsoid is described in "Ellipsoidal Calculus Based on
%   Propagation and Fusion" by Lluis Ros, Assumpta Sabater and
%   Federico Thomas; IEEE Transactions on Systems, Man and Cybernetics,
%   Vol.32, No.4, pp.430-442, 2002. For more information, visit
%   http://www-iri.upc.es/people/ros/ellipsoids.html
%
%   The method used to compute maximum volume ellipsoid inscribed in 
%   intersection of ellipsoid and polytope, is modified version of 
%   algorithm of finding maximum volume ellipsoid inscribed in intersection 
%   of ellipsoids discribed in Stephen Boyd and Lieven Vandenberghe "Convex
%   Optimization". It works properly for nondegenerate ellipsoid, but for
%   degenerate ellipsoid result would not lie in this ellipsoid. The result
%   considered as empty ellipsoid, when maximum absolute velue of element 
%   in its matrix is less than myEllipsoid.getAbsTol().
%
% Input:
%   regular:
%       myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
%           of ellipsoids.
%       objArr: ellipsoid / hyperplane /
%           / polytope [nDims1,nDims2,...,nDimsN]/[1,1]  - array of
%           ellipsoids or hyperplanes or polytopes of the same sizes.
%
% Output:
%    outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of internal
%       approximating ellipsoids; entries can be empty ellipsoids
%       if the corresponding intersection is empty.
%
% Example:
%   firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   secEllObj = firstEllObj + [5; 5];
%   ellVec = [firstEllObj secEllObj];
%   thirdEllObj  = ell_unitball(2);
%   internalEllVec = ellVec.intersection_ia(thirdEllObj)
% 
%   internalEllVec =
%   1x2 array of ellipsoids.
% 
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import modgen.common.throwerror;
import modgen.common.checkmultvar;
ellipsoid.checkIsMe(myEllArr,'first');
% modgen.common.checkvar(objArr,@(x) isa(x, 'ellipsoid') ||...
%     isa(x, 'hyperplane') || isa(x, 'polytope'),...
%     'errorTag','wrongInput', 'errorMessage',...
%     'second input argument must be ellipsoid,hyperplane or polytope.');
modgen.common.checkvar(objArr,@(x) isa(x, 'ellipsoid') || isa(x, 'elltool.core.GenEllipsoid') ||...
    isa(x, 'hyperplane') || isa(x, 'polytope'),...
    'errorTag','wrongInput', 'errorMessage',...
    'second input argument must be ellipsoid,hyperplane or polytope.');

isPoly = isa(objArr, 'polytope');

nDimsArr  = dimension(myEllArr);
if isPoly
    [~,nCols] = size(objArr);
    nObjDimsArr = zeros(1, nCols);
    for iCols = 1:nCols
        nObjDimsArr(iCols) = dimension(objArr(iCols));
    end
else
    nObjDimsArr = dimension(objArr);
end
isEllScal = isscalar(myEllArr);
isObjScal = isscalar(objArr);

checkmultvar( 'all(size(x1)==size(x2)) || x3 || x4',...
        4,myEllArr,objArr,isEllScal,isObjScal,...
    'errorTag','wrongSizes',...
    'errorMessage','sizes of input arrays do not match.');
checkmultvar('(x1(1)==x2(1))&&all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
        2,nDimsArr,nObjDimsArr,...
    'errorTag','wrongSizes',...
    'errorMessage','input arguments must be of the same dimension.');

if isObjScal
    nAmount = numel(myEllArr);
    sizeCVec = num2cell(size(myEllArr));
else
    nAmount = numel(objArr);
    sizeCVec = num2cell(size(objArr));
end
% outEllArr(sizeCVec{:}) = ellipsoid;
outEllArr(sizeCVec{:}) = myEllArr(1).create;
indexVec = 1:nAmount;

if ~(isEllScal || isObjScal )
    arrayfun(@(x,y) fChoose(x, y),indexVec,indexVec);
elseif isObjScal
    arrayfun(@(x) fChoose(x, 1),indexVec);
else
    arrayfun(@(x) fChoose(1, x),indexVec);
end
    function fChoose(ellIndex, objIndex)
        singEll = myEllArr(ellIndex);
        obj = objArr(objIndex);
        index = max(ellIndex,objIndex);
        if isPoly
            outEllArr(index) = l_polyintersect(singEll, obj);
        else
            outEllArr(index) = l_intersection_ia(singEll, obj);
        end
    end
end





%%%%%%%%

function outEll = l_intersection_ia(fstEll, secObj)
%
% L_INTERSECTION_IA - computes internal ellipsoidal approximation
%                     of intersection of single ellipsoid with single
%                     ellipsoid or halfspace.
%
% Input:
%   regular:
%       fsrEll: ellipsod [1, 1] - matrix of ellipsoids.
%       secObj: ellipsoid [1, 1] - ellipsoidal matrix
%               of the same size.
%           Or
%           hyperplane [1, 1] - matrix of hyperplanes
%               of the same size.
%
% Output:
%    outEll: ellipsod [1, 1] - internal approximating ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

% if isa(secObj, 'ellipsoid')
if isMe(secObj)
    if fstEll == secObj
        outEll = fstEll;
    elseif ~intersect(fstEll, secObj)
%         outEll = ellipsoid;
        outEll = fstEll.create;
    else
        outEll = ellintersection_ia([fstEll secObj]);
    end
    return;
end

fstEllCentVec = fstEll.centerVec;
fstEllShMat = fstEll.shapeMat;
if rank(fstEllShMat) < size(fstEllShMat, 1)
    fstEllShMat = ell_inv(elltool.core.AEllipsoid.regularize(fstEllShMat,...
        fstEll.absTol));
else
    fstEllShMat = ell_inv(fstEllShMat);
end

[normHypVec, hypScalar] = parameters(-secObj);
hypNormInv = 1/sqrt(normHypVec'*normHypVec);
hypScalar      = hypScalar*hypNormInv;
normHypVec      = normHypVec*hypNormInv;
if (normHypVec'*fstEllCentVec > hypScalar) ...
        && ~(intersect(fstEll, secObj))
    outEll = fstEll;
    return;
end
if (normHypVec'*fstEllCentVec < hypScalar) ...
        && ~(intersect(fstEll, secObj))
%     outEll = ellipsoid;
        outEll = fstEll.create;
    return;
end

[intEllCentVec, intEllShMat] = parameters(hpintersection(fstEll, ...
    secObj));
[~, boundVec] = rho(fstEll, normHypVec);
hEig      = 2*sqrt(maxeig(fstEll));
secCentVec     = intEllCentVec + hEig*normHypVec;
secMat     = (normHypVec*normHypVec')/(hEig^2);
fstCoeff     = (fstEllCentVec - ...
    intEllCentVec)'*fstEllShMat*(fstEllCentVec - intEllCentVec);
secCoeff = (secCentVec - boundVec)'*secMat*(secCentVec - boundVec);
coeffDenomin = 1/(1 - fstCoeff*secCoeff);
fstEllCoeff  = (1 - secCoeff)*coeffDenomin;
secEllCoeff = (1 - fstCoeff)*coeffDenomin;
intEllShMat      = fstEllCoeff*fstEllShMat + secEllCoeff*secMat;
intEllShMat      = 0.5*(intEllShMat + intEllShMat');
intEllCentVec      = ell_inv(intEllShMat)*...
    (fstEllCoeff*fstEllShMat*fstEllCentVec + ...
    secEllCoeff*secMat*secCentVec);
intEllShMat      = intEllShMat/(1 - ...
    (fstEllCoeff*fstEllCentVec'*fstEllShMat*fstEllCentVec + ...
    secEllCoeff*secCentVec'*secMat*secCentVec - ...
    intEllCentVec'*intEllShMat*intEllCentVec));
intEllShMat      = ell_inv(intEllShMat);
intEllShMat      = (1-fstEll.absTol)*0.5*(intEllShMat + intEllShMat');
% outEll      = ellipsoid(intEllCentVec, intEllShMat);
outEll      = fstEll.create(intEllCentVec, intEllShMat);
end





%%%%%%%%

function outEll = l_polyintersect(ell, poly)
%
% L_POLYINTERSECT - computes internal ellipsoidal approximation of
%                   intersection of single ellipsoid with single polytope.
%
% Input:
%   regular:
%       myEllMat: ellipsod [1, 1] - matrix of ellipsoids.
%       polyt: polytope [1, 1] - polytope.
%
% Output:
%    outEll: ellipsod [1, 1] - internal approximating ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    $Date: March-2013 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%

if doesIntersectionContain(ell, poly)
    outEll = getInnerEllipsoid(poly);
elseif ~intersect(ell,poly)
%     outEll = ellipsoid();
    outEll = ell.create();
else
    [ellVec ellMat] = double(ell);
    [n,~] = size(ellMat);
    polyDouble = double(poly);
    polyMat = polyDouble(:,1:end-1);
    polyVec = polyDouble(:,end);
    polyCSize = size(polyMat,1);
    if size(ellMat,2) > rank(ellMat)
        ellMat = elltool.core.AEllipsoid.regularize(ellMat,getAbsTol(ell));
    end
    invEllMat = inv(ellMat);
    ellShift = -invEllMat*ellVec;
    ellConst = ellVec' * invEllMat * ellVec - 1;
    cvx_begin sdp
        variable B(n,n) symmetric
        variable d(n)
        variable l(1)
        maximize( det_rootn( B ) )
        subject to    
            [-l - ellConst + (ellShift)'*(invEllMat\ellShift), zeros(1,n),  (d+invEllMat\ellShift)';...
                zeros(n,1), l.*eye(n), B;...
                d+ invEllMat\ellShift, B, inv(invEllMat)] >= 0;
            for i = 1:polyCSize
                norm(B*polyMat(i,:)',2) + polyMat(i,:)*d <= polyVec(i);
            end

    cvx_end
    Q = (B*B');
    v = d;
    if ~gras.la.ismatposdef(Q,getAbsTol(ell))
%         outEll = ellipsoid(v,zeros(size(Q)));
        outEll = ell.create(v,zeros(size(Q)));
    else
%         outEll = ellipsoid(v,Q);
        outEll = ell.create(v,Q);
    end
end
end
function E = getInnerEllipsoid(Pset,E,Options)
%GETINNERELLIPSOID Computes the largest ellipsoid inscribed in a polytope
%
% E = getInnerEllipsoid(Pset,x0,E,Options)
%
% ---------------------------------------------------------------------------
% DESCRIPTION
% ---------------------------------------------------------------------------
% This function computes the largest ellipsoid inscribed in a polytope. 
% It is also possible to pass an ellipsoid (x-x0) E (x - x0) <= rho and 
% to compute the maximum rho such that the scaled ellipsoid is still contained
% in the polytope.
%
% ---------------------------------------------------------------------------
% INPUT
% ---------------------------------------------------------------------------  
%   Pset    -   Polytope object constraining the ellipsoid
%   E,x0    -   Optional: input ellipsoid with center x0, i.e.
%                           (x-x0) E^(-1) (x - x0) <= rho 
%               given as an ELLIPSOID object
%               The function then computes the maximum rho such that the 
%               ellipsoid is still contained in Pset.
%   Options
%     .plotresult    - If problem is in 2D and flag is set to 1, the result 
%                      will be plotted (Default: 0).
% ---------------------------------------------------------------------------
% OUTPUT
% ---------------------------------------------------------------------------
%  E       -   Maximum volume ellipsoid,  (x-x0) E (x - x0) <= 1, returned as
%              an ELLIPSOID object
%
% ---------------------------------------------------------------------------
% LITERATURE
% ---------------------------------------------------------------------------
%   S. Boyd and L. Vanderberghe, Convex Optimization
%
% see also MPT_PLOTELLIP, GETOUTTERELLIPSOID


% (C) 2005 Michal Kvasnica, Automatic Control Laboratory, ETH Zurich,
%          kvasnica@control.ee.ethz.ch
% (C) 2004 Pascal Grieder, Automatic Control Laboratory, ETH Zurich,
%          grieder@control.ee.ethz.ch

% ---------------------------------------------------------------------------
% Legal note:
%          This program is free software; you can redistribute it and/or
%          modify it under the terms of the GNU General Public
%          License as published by the Free Software Foundation; either
%          version 2.1 of the License, or (at your option) any later version.
%
%          This program is distributed in the hope that it will be useful,
%          but WITHOUT ANY WARRANTY; without even the implied warranty of
%          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%          General Public License for more details.
% 
%          You should have received a copy of the GNU General Public
%          License along with this library; if not, write to the 
%          Free Software Foundation, Inc., 
%          59 Temple Place, Suite 330, 
%          Boston, MA  02111-1307  USA
%
% ---------------------------------------------------------------------------

global MPTOPTIONS

error(nargchk(1,3,nargin));

if nargin < 3,
    Options = [];
end
if ~isfield(Options,'plotresult')
    Options.plotresult=0;
end

[H,K]=double(Pset);
nx=size(H,2);

if(nargin>1)
    %compute the scaled ellipsoid
    [x0, E] = parameters(E);
    E=(E+E')/2;
    iL=inv(E);
    aux=zeros(size(K));
    for i=1:length(K);
        Ai=H(i,:);
        aux(i)=(K(i)-Ai*x0)^2/(Ai*iL*Ai');
    end
    rho=min(aux);
    E=E/rho';
else
    m = size(H,1);
    yalmip('clear' ) ;
    
    B = sdpvar(nx,nx);
    d = sdpvar(nx,1);
    
    myprog = lmi;
    for i=1:m
        myprog = myprog + set('||B*H(i,:)''||+H(i,:)*d<K(i,:)') ;
    end
    myprog=myprog+set('B>0');
    % Ellipsoid E = {Bu+d | ||u||_2 <=1}
    solution = solvesdp(myprog,-logdet(B));
    E   = double(B);
    x0  = double(d);
    E=inv(E)'*inv(E);
end

if nx==2 & Options.plotresult
    plot(Pset)
    hold on
    [xe,ye]=mpt_plotellip(E,x0);
end

E = inv(E);
E = 0.5*(E + E');
% E = ellipsoid(x0, E);
E = create(x0, E);
end