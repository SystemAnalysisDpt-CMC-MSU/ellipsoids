classdef ATypifiedAdjustedRel<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    methods 
        function self=ATypifiedAdjustedRel(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(varargin{:});
         
        end
        function [isOk,reportStr]=isEqual(self,varargin)
            [isOk,reportStr]=self.isEqualAdjustedInternal(varargin{:});
        end
    end
    methods (Abstract,Access=protected)
        [isOk,reportStr]=isEqualAdjustedInternal(self,varargin)
    end
end
