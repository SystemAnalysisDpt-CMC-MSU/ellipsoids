classdef ConfRepoManagerFactory<handle
    properties
        classType
    end
    methods
        function obj=getInstance(self,varargin)
            import modgen.configuration.test.*;
            switch self.classType
                case 'plainver',
                    confPatchRepo=modgen.configuration.test.StructChangeTrackerTest();
                    obj=ConfigurationRMTest(varargin{:});
                    obj.setConfPatchRepo(confPatchRepo);
                case 'adaptivever',
                    confPatchRepo=modgen.configuration.test.StructChangeTrackerTest();
                    obj=AdaptiveConfRepoManagerTest(varargin{:});
                    obj.setConfPatchRepo(confPatchRepo);
                case 'plain',
                    obj=ConfigurationRMTest(varargin{:});
                case 'adaptive',
                    obj=AdaptiveConfRepoManagerTest(varargin{:});
                case 'versioned',
                    obj=VersionedConfRepoManagerTest(varargin{:});
                case 'inmem',
                    obj=modgen.configuration.ConfRepoMgrInMemory();
                otherwise
                    error([upper(mfilename),':unknownType'],'unknown class type');
            end
        end
        function self=ConfRepoManagerFactory(classType)
            self.classType=classType;
        end
    end
end