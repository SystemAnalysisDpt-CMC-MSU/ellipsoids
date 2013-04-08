classdef (Abstract) IExtTBXController  
    methods(Abstract,Static)
        fullSetup(self,arg)
        isOnPath(self)
        checkIfSetUp(self)
        checkIfOnPath(self)
        checkSettings(self)
    end
end