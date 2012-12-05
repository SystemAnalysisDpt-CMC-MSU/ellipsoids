classdef hyperplane < handle
%HYPERPLANE - a class for hyperplanes
    properties (Access=private)
        normal
        shift
        absTol
    end
    methods

        function HA = hyperplane(v, c,varargin)
        % HYPERPLANE - creates hyperplane structure (or array of hyperplane structures).
        %
        %
        % Description:
        % ------------
        %
        %    H  = HYPERPLANE(v, c)  Create hyperplane
        %                               H = { x in R^n : <v, x> = c }, with current "Properties"..
        %                           Here v must be vector in R^n, and c - scalar.
        %    HA = HYPERPLANE(V, C)  If V is matrix in R^(n x m) and C is array of
        %                           numbers of length m or 1, then m hyperplane
        %                           structures are created and returned in
        %                           array HA, with current "Properties".
        %
        %    HA = HYPERPLANE(V, C,'absTol',absTolVal) the same as HA = HYPERPLANE(V, C)
        %                                             but with absTol prop
        %                                             equals absTolVal
        % Output:
        % -------
        %
        %    H - hyperplane structure:
        %           H.normal - vector in R^n,
        %           H.shift  - scalar;
        %        or array of such structures.
        %
        %
        % See also:
        % ---------
        %
        %    ELLIPSOID/ELLIPSOID.
        %

        %
        % Author:
        % -------
        %
        %    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
        %
          neededPropNameList = {'absTol'};
          absTolVal =  elltool.conf.Properties.parseProp(varargin,neededPropNameList);
          if nargin == 0
            HA = hyperplane(0);
            return;
          end

          if nargin < 2
            c = 0;
          end

          if ~(isa(v, 'double')) | ~(isa(c, 'double'))
            error('ELL_HYPERPLANE: both arguments must be of type ''double''.');
          end

          [n, m] = size(v);
          [k, l] = size(c);
          if k > 1
            if m > 1
              error(sprintf('ELL_HYPERPLANE: second argument must be a scalar, or an array of %d scalars.', m));
            else
              error('ELL_HYPERPLANE: second argument must be a scalar.');
            end
          end
          if (l ~= 1) & (l ~= m)
            error(sprintf('ELL_HYPERPLANE: second argument must be a single scalar, or an array of %d scalars.', m));
          end


          import modgen.common.type.simple.checkgenext;  
          checkgenext('~(any( isnan(x1(:)) ) || any(isinf(x1(:))) || any(isnan(x2(:))) || any(isinf(x2(:))))',2,v,c); 


          if l == 1
            c(1:m) = c;
          end
            
          
          if m == 1
              normVal = real(v);
              shiftVal = real(c);
              if (norm(normVal) <= absTolVal) && (shiftVal > absTolVal)
                normVal = 0;
                shiftVal  = 0;
              end
              HA.normal = normVal;
              HA.shift  = shiftVal;
              HA.absTol = absTolVal;
          else
              
              normVal = real(v(:,1));
              shiftVal = real(c(1));
              if (norm(normVal) <= absTolVal) && (shiftVal > absTolVal)
                normVal = 0;
                shiftVal  = 0;
              end
              HA.normal = normVal;
              HA.shift  = shiftVal;
              HA.absTol = absTolVal;
              
              for i = 2:m
                normVal = real(v(:, i));
                shiftVal = real(c(i));
                if (norm(normVal) <= absTolVal) && (shiftVal > absTolVal)
                  normVal = 0;
                  shiftVal  = 0;
                end
                H = hyperplane(normVal,shiftVal,'absTol',absTolVal);
            %    if H.shift < 0
            %      H.normal = - H.normal;
            %      H.shift  = - H.shift;
            %    end
                HA = [HA H];
              end 
          end
          
        end
    end
end