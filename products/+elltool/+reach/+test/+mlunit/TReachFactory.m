classdef TReachFactory < elltool.reach.ReachFactory
    %TREACHFACTORY Factory that creates TReachContinuous and TReachDiscrete
    %objects instead of their subclasses
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods (Access = protected, Static)
        function name = getContReachName()
            name = 'elltool.reach.test.mlunit.TReachContinuous';
        end
        function name = getDiscrReachName()
            name = 'elltool.reach.test.mlunit.TReachDiscrete';
        end
    end
    %
    methods
        function self = TReachFactory(varargin)
            self = self@elltool.reach.ReachFactory(varargin{:});
        end
    end
end

