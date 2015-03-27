classdef IControlVectFunction<handle
% IControlVectFunction - provides computing of control synthesis in
%   specified point (t,x)
% 
% Methods:
%   evaluate() - returns the control synthesis in points (x,t), where x is
%       a fixed point in space and t is a vector of time moments we are
%       interested in
% 

    methods (Abstract)
        res=evaluate(self,x,timeVec)
        % EVALUATE - returns the control synthesis in points (x,timeVec)
        %
        % Input:
        %   x: double[n,1] - vector in phase space in which we compute
        %       control synthesis
        %   
        %   timeVec: double[1,nTime] - vector of time momets in which we
        %       compute control synthesis
    end
end