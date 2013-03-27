classdef LinSysContinuous < elltool.linsys.ALinSys
%
% $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%           Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
%           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

    methods
        function self = LinSysContinuous(varargin)
        %
        % LINSYS - constructor for linear system object.
        %
        % Continuous-time linear system:
        %                   dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  G(t) v(t)
        %                    y(t)  =  C(t) x(t)  +  w(t)
        %
        % Discrete-time linear system:
        %                  x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  G[k] v[k]
        %                    y[k]  =  C[k] x[k]  +  w[k]
        %
        % Input:
        %   regular:
        %       atInpMat: double[nDim, nDim]/cell[nDim, nDim].
        %
        %       btInpMat: double[nDim, kDim]/cell[nDim, kDim].
        %
        %       uBoundsEll: ellipsoid[1, 1]/struct[1, 1].
        %
        %       gtInpMat: double[nDim, lDim]/cell[nDim, lDim].
        %
        %       distBoundsEll: ellipsoid[1, 1]/struct[1, 1].
        %
        %       ctInpMat: double[mDim, nDim]/cell[mDim, nDim].
        %
        %       noiseBoundsEll: ellipsoid[1, 1]/struct[1, 1].
        %
        %       discrFlag: char[1, 1] - if discrFlag set:
        %           'd' - to discrete-time linSys
        %           not 'd' - to continuous-time linSys.
        %
        % Output:
        %   self: elltool.linsys.LinSys[1, 1].
        %
            self = self@elltool.linsys.ALinSys(varargin{:});
            self.isDiscr  = false;
        end
        
        function display(self)
            fprintf('\n');
            disp([inputname(1) ' =']);
            %%
            if self.isempty()
                fprintf('Empty linear system object.\n\n');
                return;
            end
            %%
%             if self.isDiscr
%                 s0 = '[k]';
%                 s1 = 'x[k+1]  =  ';
%                 s2 = '  y[k]  =  ';
%                 s3 = ' x[k]';
%             else
                s0 = '(t)';
                s1 = 'dx/dt  =  ';
                s2 = ' y(t)  =  ';
                s3 = ' x(t)';
%             end
            %%
            fprintf('\n');
            if iscell(self.atMat)
%                 if self.isDiscr
%                     fprintf('A[k]:\n');
%                     s4 = 'A[k]';
%                 else
                    fprintf('A(t):\n');
                    s4 = 'A(t)';
%                 end
            else
                fprintf('A:\n');
                s4 = 'A';
            end
            disp(self.atMat);
            if iscell(self.btMat)
                fprintf('\nB(t):\n');
                s5 = '  +  B(t)';
            else
                fprintf('\nB:\n');
                s5 = '  +  B';
            end
            disp(self.btMat);
            %%
            fprintf('\nControl bounds:\n');
            s6 = [' u' s0];
            if isempty(self.controlBoundsEll)
                fprintf('     Unbounded\n');
            elseif isa(self.controlBoundsEll, 'ellipsoid')
                [qVec, qMat] = parameters(self.controlBoundsEll);
                fprintf('   %d-dimensional constant ellipsoid with center\n',...
                    size(self.btMat, 2));
                disp(qVec);
                fprintf('   and shape matrix\n');
                disp(qMat);
            elseif isstruct(self.controlBoundsEll)
                uEll = self.controlBoundsEll;
                fprintf('   %d-dimensional ellipsoid with center\n',...
                    size(self.btMat, 2));
                disp(uEll.center);
                fprintf('   and shape matrix\n');
                disp(uEll.shape);
            elseif isa(self.controlBoundsEll, 'double')
                fprintf('   constant vector\n');
                disp(self.controlBoundsEll);
                s6 = ' u';
            else
                fprintf('   vector\n');
                disp(self.controlBoundsEll);
            end
            %%
            if ~(isempty(self.gtMat)) && ~(isempty(self.disturbanceBoundsEll))
                if iscell(self.gtMat)
                    fprintf('\nG(t):\n');
                    s7 = '  +  G(t)';
                else
                    fprintf('\nG:\n');
                    s7 = '  +  G';
                end
                disp(self.gtMat);
                fprintf('\nDisturbance bounds:\n');
                s8 = [' v' s0];
                if isa(self.disturbanceBoundsEll, 'ellipsoid')
                    [qVec, qMat] = parameters(self.disturbanceBoundsEll);
                    fprintf('   %d-dimensional constant ellipsoid with center\n',...
                        size(self.gtMat, 2));
                    disp(qVec);
                    fprintf('   and shape matrix\n');
                    disp(qMat);
                elseif isstruct(self.disturbanceBoundsEll)
                    uEll = self.disturbanceBoundsEll;
                    fprintf('   %d-dimensional ellipsoid with center\n',...
                        size(self.gtMat, 2));
                    disp(uEll.center);
                    fprintf('   and shape matrix\n');
                    disp(uEll.shape);
                elseif isa(self.disturbanceBoundsEll, 'double')
                    fprintf('   constant vector\n');
                    disp(self.disturbanceBoundsEll);
                    s8 = ' v';
                else
                    fprintf('   vector\n');
                    disp(self.disturbanceBoundsEll);
                end
            else
                s7 = '';
                s8 = '';
            end
            %%
            if iscell(self.ctMat)
                fprintf('\nC(t):\n');
                s9 = 'C(t)';
            else
                fprintf('\nC:\n');
                s9 = 'C';
            end
            disp(self.ctMat);
            %%
            s10 = ['  +  w' s0];
            if ~(isempty(self.noiseBoundsEll))
                fprintf('\nNoise bounds:\n');
                if isa(self.noiseBoundsEll, 'ellipsoid')
                    [qVec, qMat] = parameters(self.noiseBoundsEll);
                    fprintf('   %d-dimensional constant ellipsoid with center\n',...
                        size(self.ctMat, 1));
                    disp(qVec);
                    fprintf('   and shape matrix\n');
                    disp(qMat);
                elseif isstruct(self.noiseBoundsEll)
                    uEll = self.noiseBoundsEll;
                    fprintf('   %d-dimensional ellipsoid with center\n',...
                        size(self.ctMat, 1));
                    disp(uEll.center);
                    fprintf('   and shape matrix\n');
                    disp(uEll.shape);
                elseif isa(self.noiseBoundsEll, 'double')
                    fprintf('   constant vector\n');
                    disp(self.noiseBoundsEll);
                    s10 = '  +  w';
                else
                    fprintf('   vector\n');
                    disp(self.noiseBoundsEll);
                end
            else
                s10 = '';
            end
            %%
            fprintf('%d-input, ', size(self.btMat, 2));
            fprintf('%d-output ', size(self.ctMat, 1));
            fprintf('continuous-time linear ');
            if self.isTimeInv
                fprintf('time-invariant system ');
            else
                fprintf('system ');
            end
            fprintf('of dimension %d', size(self.atMat, 1));
            if ~(isempty(self.gtMat))
                if size(self.gtMat, 2) == 1
                    fprintf('\nwith 1 disturbance input');
                elseif size(self.gtMat, 2) > 1
                    fprintf('\nwith %d disturbance input',...
                        size(self.gtMat, 2));
                end
            end
            fprintf(':\n%s%s%s%s%s%s%s\n%s%s%s%s\n\n',...
                s1, s4, s3, s5, s6, s7, s8, s2, s9, s3, s10);
            return; 
        end
    end
end