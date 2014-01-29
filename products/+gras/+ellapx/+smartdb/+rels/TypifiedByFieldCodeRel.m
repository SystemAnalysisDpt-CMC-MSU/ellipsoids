classdef TypifiedByFieldCodeRel<smartdb.relations.ATypifiedByFieldCodeRel
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    methods 
        function self=TypifiedByFieldCodeRel(varargin)
            self=self@smartdb.relations.ATypifiedByFieldCodeRel(varargin{:});
         
        end
    end
    methods (Access=protected)
        function fObj=getFieldDefObject(~)
            fObj=gras.ellapx.smartdb.F();
        end
    end    
end
