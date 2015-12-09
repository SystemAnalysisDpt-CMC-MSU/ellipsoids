classdef EllTubeProj<gras.ellapx.smartdb.rels.ATypifiedAdjustedRel&...
        gras.ellapx.smartdb.rels.EllTubeProjBasic
    % EllTubeProj - collection of projected ellipsoidal tubes
    % 
    % Public properties:
    %       - in addition to the fields of gras.ellapx.smartdb.rels.EllTube
    %       this class has the following public fields
    %
    %   projSTimeMat: cell[nProjTubes,1] of double[nProjDims,nDims] - list 
    %       of projection matrices at time t_s that were used for calculating 
    %       the corresponding ellipsoidal tube via projection, where
    %       nProjDims is the dimensionality of space on which projection is
    %       performed and nDims is the dimensionality of the original space
    %
    %   projArray: cell[nProjTubes,1] of double[nProjDims,nDims,nTimePoints] -
    %       list of projection matrix arrays i.e. same as projSTimeMat but
    %       for all time points, not just for t_s=sTime
    %
    %   projType: gras.ellapx.enums.EProjType[nProjTubes,1] - vector of
    %       projection types for each tube, can be
    %           "DynamicAlongGoodCurve" - projection is performed on a 
    %           dynamic subspace that is build based on columns of
    %           transition matrix X(t,s).'. Such projections has an
    %           important propety - if ellipsoidal tube projection
    %           EP[t] touches reachability set projection RP[t] at time t
    %           along l(t) then it touches this projection at all times
    %           (because projection matrix changes dynamically to track
    %           l(t) dynamics)
    %     
    %   ltGoodDirNormOrigVec: cell[nProjTubes,1] of double[1,nTimePoints] 
    %       - list of vectors of
    %       ||l(t)|| i.e. norms of good directions prior to projection i.e.
    %       norms of full-dimensional good directions
    %
    %   lsGoodDirNormOrig: double[nProjTubes,1] - vector of
    %       full-dimensional ||l(t_s)|| i.e. same as ltGoodDirNormOrigVec
    %       but just for one time point t_s=sTime
    %
    %   ltGoodDirOrigMat: cell[nProjTubes,1] of double[nDims,nTimePoints] 
    %       - list of matrices of original (i.e. prior to projection) l(t) 
    %       vectors
    %
    %   lsGoodDirOrigVec: cell[nProjTubes,1] of double[nDims,1] - same as 
    %       ltGoodDirOrigMat but just for one time point t_s=sTime
    %
    %   ltGoodDirNormOrigProjVec: cell[nProjTubes,1] of
    %       double[1,nTimePoints] - list of vectors of norms of projected
    %       l(t) i.e. vectors of ||P(t)l(t)|| where P(t) is projection
    %       matrix at time t.
    %
    %   ltGoodDirOrigProjMat: cell[nProjTubes,1] of
    %       double[nProjDim,nTimePoints] - list of arrays composed from
    %       projected l(t) for each tube.        
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-2015 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2015 $
    %
    methods (Access=protected,Static,Hidden)
        function outObj=loadobj(inpObj)
            import gras.ellapx.smartdb.rels.ATypifiedAdjustedRel;
            outObj=ATypifiedAdjustedRel.loadObjViaConstructor(...
                mfilename('class'),inpObj);
        end
    end
   
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    methods
        function self=EllTubeProj(varargin)
            self=self@gras.ellapx.smartdb.rels.ATypifiedAdjustedRel(...
                varargin{:}); 
        end
        
    end
end