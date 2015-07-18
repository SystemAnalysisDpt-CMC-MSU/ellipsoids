classdef JavaPublicStaticPathMgr<modgen.java.AJavaStaticPathMgr
    methods
        function self=JavaPublicStaticPathMgr(varargin)
            self=self@modgen.java.AJavaStaticPathMgr(varargin{:});
        end
        function fileNameList=getJarFileNameList(~)
            fileNameList={'modgenfileutils.jar'};
        end
    end
end