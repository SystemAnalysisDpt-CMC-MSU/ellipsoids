classdef TypifiedStaticRelation<smartdb.relations.ATypifiedStaticRelation
    methods
        function self=TypifiedStaticRelation(varargin)
            self=self@smartdb.relations.ATypifiedStaticRelation(varargin{:});
        end
    end
    methods (Access=protected)
        function initialize(self,varargin)
              self.parseAndAssignFieldProps(varargin{:});
        end
    end    
end
