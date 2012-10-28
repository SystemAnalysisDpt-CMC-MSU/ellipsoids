classdef UntypifiedStaticRelation<smartdb.relations.AStaticRelation
    %VAMetricConfList Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function self=UntypifiedStaticRelation(varargin)
            varargin=smartdb.cubes.CubeStruct.inferFieldNamesFromSData(varargin);
            self=self@smartdb.relations.AStaticRelation(varargin{:});
        end
    end
    methods (Access=protected)
        function initialize(self,varargin)
              self.parseAndAssignFieldProps(varargin{:});
        end
    end
end
