classdef TypifiedByFieldCodeRel<smartdb.relations.ATypifiedByFieldCodeRel
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-2015 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2015 $  
    %
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
