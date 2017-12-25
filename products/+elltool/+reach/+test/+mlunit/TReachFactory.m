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
    methods (Static, Access = protected)
        function contReachObj = createContReachObjInstance(varargin)
            contReachObj = elltool.reach.test.mlunit.TReachContinuous(...
                varargin{:});
        end
        function discrReachObj = createDiscrReachObjInstance(varargin)
            discrReachObj = elltool.reach.test.mlunit.TReachDiscrete(...
                varargin{:});
        end
    end
    %
    methods
        function self = TReachFactory(varargin)
            self = self@elltool.reach.ReachFactory(varargin{:});
        end
    end
end

