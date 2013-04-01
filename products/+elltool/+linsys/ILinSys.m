classdef ILinSys < handle
    %
    %  Interface class of linear system class of the Ellipsoidal Toolbox.
    %
    %
    % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
    %           Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
    %           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
    %           Igor Kitsenko <kitsenko@gmail.com> $              $Date: March-2013 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    methods (Abstract)
        aMat = getAtMat(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   aMat: double[aMatDim, aMatDim]/cell[nDim, nDim] - matrix A.
        %
        
        bMat = getBtMat(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   bMat: double[bMatDim, bMatDim]/cell[bMatDim, bMatDim] -
        %       matrix B.
        %
        
        uEll = getUBoundsEll(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   uEll: ellipsoid[1, 1]/struct[1, 1] - control bounds ellipsoid.
        %
        
        gMat = getGtMat(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   gMat: double[gMatDim, gMatDim]/cell[gMatDim, gMatDim] -
        %       matrix G.
        %
        
        distEll = getDistBoundsEll(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   distEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds
        %       ellipsoid.
        %
        
        cMat = getCtMat(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   cMat: double[cMatDim, cMatDim]/cell[cMatDim, cMatDim] -
        %       matrix C.
        %
        
        noiseEll = getNoiseBoundsEll(self)
        
        [stateDimArr, inpDimArr, outDimArr, distDimArr] =...
            dimension(self)
        %
        % DIMENSION - returns dimensions of state,
        %     input, output and disturbance spaces.
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   stateDimArr: double[nDims1, nDims2,...] - array of
        %       state space dimensions.
        %
        %   inpDimArr: double[nDims1, nDims2,...] - array of input
        %       dimensions.
        %
        %   outDimArr: double[nDims1, nDims2,...] - array of output
        %       dimensions.
        %
        %   distDimArr: double[nDims1, nDims2,...] - array of
        %       disturbance dimensions.
        %
        
        display(self)
        %
        % DISPLAY displays the details of linear system object.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   None.
        %
        
        isDisturbanceArr = hasdisturbance(self)
        %
        % HASDISTURBANCE checks if linear system has unknown bounded
        %   disturbance.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isDisturbanceArr: logical[nDims1, nDims2,...] - array such that
        %       it's element at each position is true if corresponding
        %       linear system has disturbance, and false otherwise.
        %
        
        isNoiseArr = hasnoise(self)
        %
        % HASNOISE checks if linear system has unknown bounded noise.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isNoiseMat: logical[nDims1, nDims2,...] - array such that it's
        %       element at each position is true if corresponding
        %       linear system has noise, and false otherwise.
        %
        
        isDiscreteArr = isdiscrete(self)
        %
        % ISDISCRETE checks if linear system is discrete-time.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isDiscreteMat: logical[nDims1, nDims2,...] - array such that
        %       it's element at each position is true if corresponding
        %       linear system is discrete-time, and false otherwise.
        %
        
        isEmptyArr = isempty(self)
        %
        % ISEMPTY checks if linear system is empty.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isEmptyMat: logical[nDims1, nDims2,...] - array such that it's
        %       element at each position is true if corresponding
        %       linear system is empty, and false otherwise.
        %
        
        isLtiArr = islti(self)
        %
        % ISLTI checks if linear system is time-invariant.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isLtiMat: logical[nDims1, nDims2,...] -array such that it's
        %       element at each position is true if corresponding
        %       linear system is time-invariant, and false otherwise.
        %
        
        absTolArr = getAbsTol(self)
        %
        % GETABSTOL gives array the same size as linsysArr with
        % values of absTol properties for each hyperplane in hplaneArr.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   absTolArr: double[nDims1, nDims2,...] - array of absTol
        %       properties for linear systems in self.
        %
        % $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        
    end
end