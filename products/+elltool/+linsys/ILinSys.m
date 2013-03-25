classdef ILinSys < handle
% Linear system object of the Ellipsoidal Toolbox.
%
% 
%  LinSys         - Constructor of linear system object.
%  dimension      - Returns state space dimension, number of inputs, number of
%                   outputs and number of disturbance inputs.
%  isempty        - Checks if the linear system object is empty.
%  isdiscrete     - Returns 1 if linear system is discrete-time,
%                   0 - if continuous-time.
%  islti          - Returns 1 if the system is time-invariant, 0 - otherwise.
%  hasdisturbance - Returns 1 if unknown bounded disturbance is present,
%                   0 - if there is no disturbance, or disturbance vector is fixed.
%  hasnoise       - Returns 1 if unknown bounded noise at the output is present,
%                   0 - if there is no noise, or noise vector is fixed.
%
%
% $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%           Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
%           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

    methods (Abstract)
        aMat = getAtMat(self)
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   aMat: double[aMatDim, aMatDim].
        %
        
        bMat = getBtMat(self)
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   bMat: double[bMatDim, bMatDim].
        %
        
        uEll = getUBoundsEll(self)
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   uEll: ellipsoid[1, 1].
        %        
        
        gMat = getGtMat(self)
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   gMat: double[gMatDim, gMatDim].
        %
        
        distEll = getDistBoundsEll(self)
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   distEll: ellipsoid[1, 1].
        %
        
        cMat = getCtMat(self)
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   cMat: double[cMatDim, cMatDim].
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
        %   inpDimArr: double[nDims1, nDims2,...] - array of input dimensions.
        %
        %   outDimArr: double[nDims1, nDims2,...] - array of output dimensions.
        %
        %   distDimArr: double[nDims1, nDims2,...] - array of
        %       disturbance dimensions.
        %   
        
        display(self)
        %
        % Displays the details of linear system object.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   None.
        %
        
        isDisturbanceArr = hasdisturbance(self)
        %
        % HASDISTURBANCE checks if linear system has unknown bounded disturbance.
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
        %   isDiscreteMat: logical[nDims1, nDims2,...] - array such that it's
        %       element at each position is true if corresponding
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