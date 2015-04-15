classdef ClassSubstitute < handle
    properties (GetAccess=public,SetAccess=private)
        idMat
    end
    
    methods
        function self=ClassSubstitute(inpIdMat)
            self.idMat=inpIdMat;
        end
    end
end