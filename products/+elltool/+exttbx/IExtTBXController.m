classdef (Abstract) IExtTBXController  
    methods(Abstract,Static)
        fullSetup(self,arg)
        isOnPath(self)
        checkIfSetUp(self)
        checkIfOnPath(self)
    end
end