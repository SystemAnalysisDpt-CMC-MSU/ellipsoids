function [vertMat,faceMat,edgeMidMat]=spheretri(depth)
% SPHERETRI builds a triangulation of a unit sphere based on recursive
% partitioning each of Icosahedron faces into 4 triangles with vertices in
% the middles of original face edgeMidMat
%
% Input:
%   depth: double[1,1] - depth of partitioning, use 1 for the first level of
%       Icosahedron partitioning, and greater value for a greater level
%       of partitioning
%
% Output:
%   vertMat: double[nVerts,3] - (x,y,z) coordinates of triangulation
%       vertices
%   faceMat: double[nFaces,3] - indices of face verties in vertMat
%
%   edgeMidMat: double[nPrevStepEdges,3] - two first columns contain
%       indices of edges from the previous level of partitioning (for depth=1
%       it will be indices of Icosahedron edges) and the third column will
%       contain indices of the middles of these edges. Thus number of
%       actual edges is 4 * nPrevStepEdges
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-21$ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $

%
if ~(numel(depth)&&isnumeric(depth)&&depth>0&&fix(depth)==depth)
    modgen.common.throwerror('wrongInput',...
        'depth is expected to be a positive integer scalar');
end
[N_MAX_VERTS,N_MAX_FACES,N_MAX_PREV_EDGES]=getVertFaceEdgeNum(depth);
vertMat=zeros(N_MAX_VERTS,3);
faceMat=zeros(N_MAX_FACES,3);
faceCopyMat=zeros(N_MAX_FACES,3);
edgeMidMat=zeros(N_MAX_PREV_EDGES,3);
nVerts=0;
nFaces=0;
nEdges=0;
%
isFoundEdgeVec=zeros(N_MAX_PREV_EDGES,3);
%
preparation();
if depth>0;
    granulate(depth);
end
vertMat=vertMat(1:nVerts,:);
faceMat=faceMat(1:nFaces,:);
if nargout>2
    edgeMidMat=edgeMidMat(1:nEdges,:);
end

    function preparation()
        pi = 4 * atan(1.0);
        tau = (realsqrt(5.0) + 1)/2;
        r = tau - 0.5;
        vertMat(1,:)=[0.0, 0.0, 1.0];
        for iPoint=0:4
            alpha = -pi/5 + iPoint * pi/2.5;
            vertMat(2+iPoint,:)=[ cos(alpha)/r, sin(alpha)/r, 0.5/r];
        end
        for iPoint=0:4
            alpha = iPoint * pi/2.5;
            vertMat(7+iPoint,:)=[cos(alpha)/r, sin(alpha)/r, -0.5/r];
        end
        vertMat(12,:)=[ 0.0, 0.0, -1.0];
        nVerts = 12;nFaces=0;nEdges=0;
        for iPoint=0:3
            subdivide(1, 2+iPoint, 3+iPoint);
        end
        subdivide(1,6,2);
        %
        for iPoint=0:3
            subdivide(2+iPoint, 7+iPoint, 3+iPoint);
        end
        subdivide(6,11,2);
        %
        for iPoint=0:3
            subdivide(7+iPoint,8+iPoint,iPoint+3);
        end
        subdivide(11,7, 2);
        for iPoint=0:3
            subdivide(iPoint+7, 12, iPoint+8);
        end
        subdivide(11,12,7);
        normalizeVert(13);
    end
    %
    function subdivide(A, B,C)
        %
        xP = (vertMat(B,1) + vertMat(C,1))/2;
        yP = (vertMat(B,2) + vertMat(C,2))/2;
        zP = (vertMat(B,3) + vertMat(C,3))/2;
        %
        xQ = (vertMat(C,1) + vertMat(A,1))/2;
        yQ = (vertMat(C,2) + vertMat(A,2))/2;
        zQ = (vertMat(C,3) + vertMat(A,3))/2;
        %
        xR = (vertMat(A,1) + vertMat(B,1))/2;
        yR = (vertMat(A,2) + vertMat(B,2))/2;
        zR = (vertMat(A,3) + vertMat(B,3))/2;
        %
        P=midpnt(B, C,xP, yP, zP);
        Q=midpnt(C, A,xQ, yQ, zQ);
        R=midpnt(A, B,xR, yR, zR);
        %
        storeface(A, R, Q);
        storeface(R, B, P);
        storeface(Q, P, C);
        storeface(Q, R, P);
    end
    %
    function storeface(i,j,k)
        nFaces=nFaces+1;
        faceMat(nFaces,:)=[i,j,k];
    end
    %
    function pP=midpnt(B,C,x,y,z)
        % Point (x, y, z) is midpoint of BC.
        % If it is a new vertex, store it and write it to the object file,
        % using a new vertex number. If not, find its vertex number.
        % The vertex number is to be assigned to *pP anyway.
        %
        if (C < B)
            tmp = B; B = C; C = tmp;
        end
        % B, C in increasing order, for the sake of uniqueness */
        isFoundEdgeVec=edgeMidMat(1:nEdges,1)==B&edgeMidMat(1:nEdges,2)==C;
        e=find(isFoundEdgeVec(1:nEdges),1,'first');
        if isempty(e)
            e=nEdges+1;
        end
        if (e > nEdges)   %Not found, so we have a new vertex
            edgeMidMat(e,1) = B;
            edgeMidMat(e,2) = C;
            nVerts=nVerts+1;
            nEdges=nEdges+1;
            pP=nVerts;
            edgeMidMat(e,3) = pP;
            vertMat(pP,:)=[ x, y, z];
        else
            pP = edgeMidMat(e,3);
        end
        % Edge BC has been dealt with before, so the vertex is not new
    end
    %
    function granulate(depth)
        
        for iDepth=1:depth-1
            tmp=nFaces;
            nFaces=0;
            nEdges=0;
            for s=1:tmp
                faceCopyMat(s,:)=faceMat(s,:);
            end
            nCurVerts=nVerts;
            for s=1:tmp
                subdivide(faceCopyMat(s,1),faceCopyMat(s,2) ,faceCopyMat(s,3));
            end
            normalizeVert(nCurVerts+1);
        end
    end
    function normalizeVert(indStart)
        normVec=realsqrt(sum(vertMat(indStart:nVerts,:).*...
            vertMat(indStart:nVerts,:),2));
        vertMat(indStart:nVerts,:)=vertMat(indStart:nVerts,:)./...
            repmat(normVec,1,3);
    end
end
function [nVerts,nFaces,nEdgeMidPrev]=getVertFaceEdgeNum(depth)
if depth>0
    [nPrevVerts,nPrevFaces,nPrevEdgeMidPrev]=getVertFaceEdgeNum(depth-1);
    nVerts=nPrevVerts+nPrevEdgeMidPrev*4;
    nFaces=nPrevFaces*4;
    nEdgeMidPrev=nPrevEdgeMidPrev*4;
else
    nVerts=12;
    nFaces=20;
    nEdgeMidPrev=7.5;
end
end
