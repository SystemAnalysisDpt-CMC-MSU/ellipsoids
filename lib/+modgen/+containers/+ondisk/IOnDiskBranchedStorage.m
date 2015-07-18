classdef IOnDiskBranchedStorage<modgen.containers.IGenericBranchedStorage
    methods
        branchKey=getStorageBranchKey(self)
        storageLocation=getStorageLocation(self)
        storageLocationRoot=getStorageLocationRoot(self)
        fullFileName=getFileNameByKey(self,keyStr,varargin)
    end
end