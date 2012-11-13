classdef LinSys<handle
    % am i write to use public access?
    properties (Access = public)
        A              = [];
        B              = [];
        control        = [];
        G              = [];
        disturbance    = [];
        C              = [];
        noise          = [];
        lti            = false;
        dt             = false;
        constantbounds = false(1, 3);
    end
    methods
        function self = LinSys(varargin)
            %
        end
        %
        function [N, I, O, D] = dimension(self)
            %
        end
        %
        function isEmptyMat = isempty(self)
            %
        end
        %
        function isDiscreteMat = isdiscrete(self)
            isDiscreteMat = self.dt;
        end
        %
        function isLtiMat = islti(self)
            isLtiMat = self.lti;
        end
        %
        function hasDistMat = hasdisturbance(self)
            %
        end
        %
        function hasNoiseMat = hasnoise(self)
            %
        end
    end
    
end