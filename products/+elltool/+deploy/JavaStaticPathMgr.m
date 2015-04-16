classdef JavaStaticPathMgr<modgen.deployment.JavaPublicStaticPathMgr
    methods
        function self=JavaStaticPathMgr(varargin)
            self=self@modgen.deployment.JavaPublicStaticPathMgr(varargin{:});
        end
        function fileNameList=getJarFileNameList(self)
            fileNameList=[{},...%here we will specify the list of jar files
                getJarFileNameList@modgen.deployment.JavaPublicStaticPathMgr(self)];
        end
    end
end