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
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   aMat: double[aMatDim, aMatDim]/cell[nDim, nDim] - matrix A.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   aMat = dsys.getAtMat();
        %
        aMat = getAtMat(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   bMat: double[bMatDim, bMatDim]/cell[bMatDim, bMatDim] - matrix B.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   bMat = dsys.getBtMat();
        %
        bMat = getBtMat(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   uEll: ellipsoid[1, 1]/struct[1, 1] - control bounds ellipsoid.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   uEll = dsys.getUBoundsEll();
        %
        uEll = getUBoundsEll(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   cMat: double[cMatDim, cMatDim]/cell[cMatDim, cMatDim] - matrix C.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   gMat = sys.getCtMat();
        %
        gMat = getCtMat(self)
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[1, 1] - linear system.
        %
        % Output:
        %   distEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds ellipsoid.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   distEll = sys.getDistBoundsEll();
        %
        distEll = getDistBoundsEll(self)
        %
        % DIMENSION - returns dimensions of state, input, output and disturbance
        %             spaces.
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of 
        %             linear systems.
        %
        % Output:
        %   stateDimArr: double[nDims1, nDims2,...] - array of state space 
        %       dimensions.
        %
        %   inpDimArr: double[nDims1, nDims2,...] - array of input dimensions.
        %
        %   distDimArr: double[nDims1, nDims2,...] - array of disturbance
        %         dimensions.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   [stateDimArr, inpDimArr, outDimArr, distDimArr] = sys.dimension()
        %
        %   stateDimArr = 
        %      
        %        2
        %
        %
        %   inpDimArr = 
        %      
        %        2
        %
        %
        %
        %   distDimArr = 
        %      
        %        0
        %
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   dsys.dimension();
        %
        [stateDimArr, inpDimArr, distDimArr] =...
            dimension(self)
        % HASDISTURBANCE - returns true if system has disturbance
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of 
        %             linear systems.
        %   optional:
        %       isMeaningful: logical[1,1] - if true(default), treat constant 
        %                     disturbance vector as absence of disturbance
        %
        % Output:
        %   isDisturbanceArr: logical[nDims1, nDims2,...] - array such that it's  
        %       element at each position is true if corresponding linear system  
        %       has disturbance, and false otherwise.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   sys.hasDisturbance()
        %
        %   ans = 
        %      
        %        0
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   dsys.hasDisturbance();
        %
        isDisturbanceArr = hasDisturbance(self)
        %
        %
        % ISEMPTY - checks if linear system is empty.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of linear 
        %             systems.
        %
        % Output:
        %   isEmptyMat: logical[nDims1, nDims2,...] - array such that it's element at  
        %       each position is true if corresponding linear system is empty, and  
        %       false otherwise.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   sys.isEmpty()
        %
        %   ans = 
        %      
        %        0
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   dsys.isEmpty();
        %
        isEmptyArr = isEmpty(self)
        %
        % ISLTI - checks if linear system is time-invariant.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of linear  
        %             systems.
        %
        % Output:
        %   isLtiMat: logical[nDims1, nDims2,...] -array such that it's element at  
        %       each position is true if corresponding linear system is 
        %       time-invariant, and false otherwise.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   isLtiArr = sys.isLti();
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   isLtiArr = dsys.isLti();
        %
        isLtiArr = isLti(self)
        %
        % GETABSTOL - gives array the same size as linsysArr with values of absTol  
        %             properties for each hyperplane in hplaneArr.
        % 
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of linear 
        %             systems.
        %
        % Output:
        %   absTolArr: double[nDims1, nDims2,...] - array of absTol properties for  
        %       linear systems in self.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   sys.getAbsTol();
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   dsys.getAbsTol();
        %
        %
        % $Author: Zakharov Eugene  <justenterrr@gmail.com> $    
        % $Date: 17-november-2012 $
        % $Copyright: Moscow State University,
        %             Faculty of Computational Mathematics
        %             and Computer Science,
        %             System Analysis Department 2012 $
        %
        absTolArr = getAbsTol(self)
        %
        % GETCOPY - gives array the same size as linsysArr with with copies of 
        %           elements of self.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ALinSys[nDims1, nDims2,...] - an array of 
        %             linear systems.
        %
        % Output:
        %   copyLinSysArr: elltool.linsys.LinSys[nDims1, nDims2,...] -  an array of 
        %      copies of elements of self.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   newSys = sys.getCopy();
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   newDSys = dsys.getCopy();
        %
        copyLinSysArr = getCopy(self)
        %
        % ISEQUAL - produces produces logical array the same size as
        %           self/compLinSysArr (if they have the same).
        %           isEqualArr[iDim1, iDim2,...] is true if corresponding 
        %           linear systems are equal and false otherwise.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.ILinSys[nDims1, nDims2,...] -  an array of 
        %            linear systems.
        %       compLinSysArr: elltool.linsys.ILinSys[nDims1,...nDims2,...] - an 
        %            array of linear systems.
        % 
        % Output:
        %   isEqualArr: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of 
        %       logical values.
        %       isEqualArr[iDim1, iDim2,...] is true if corresponding linear systems 
        %       are equal and false otherwise.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   newSys = sys.getCopy();
        %   isEqual = sys.isEqual(newSys)
        %
        %   isEqual =
        %
        %        1
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   newDSys = sys.getCopy();
        %   isEqual = dsys.isEqual(newDSys)
        %
        %   isEqual =
        %
        %        1       
        isEqualArr = isEqual(self, compLinSysArr)
        
    end
end