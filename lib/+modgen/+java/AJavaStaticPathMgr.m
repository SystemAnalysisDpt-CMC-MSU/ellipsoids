classdef AJavaStaticPathMgr<modgen.common.obj.StaticPropStorage
    %JAVASTATICPATHCONFIG Summary of this class goes here
    %   Detailed explanation goes here
    %
    properties (Access=protected)
        classPathFileName
    end
    methods (Abstract)
        %returns a list of jar files to be put on a static java path
        fileNameList=getJarFileNameList(~)
    end
    methods
        function self=AJavaStaticPathMgr(classPathFileName)
            self.classPathFileName=classPathFileName;
        end
        function setUp(self)
            import modgen.common.throwwarn;
            import modgen.common.throwerror;
            jarFileNameList=self.getJarFileNameList();
            toAddPathList=cellfun(@which,jarFileNameList,...
                'UniformOutput',false);
            isEmptyVec=cellfun('isempty',toAddPathList);
            if any(isEmptyVec)
                throwerror('noJarFilesOnMatlabPath',...
                    'Files %s cannot be found on Matlab path',...
                    list2str(jarFileNameList(isEmptyVec)));
            end
            if verLessThan('matlab', '8.2')
                throwwarn('wrongMatlabVer',...
                    'Matlab version 8.2/2013b or higher is expected');
                javaaddpath(toAddPathList);
            else
                if ~self.isPrefDirClassPathSet()
                    missingPathList=toAddPathList;
                    isnThereVec=true(size(toAddPathList));
                else
                    existingUserPathList=self.readPrefDirClassPath();
                    isnThereVec=~ismember(toAddPathList,existingUserPathList);
                    missingPathList=toAddPathList(isnThereVec);
                end
                %
                fullStaticPathList=javaclasspath('-static');
                isnFullThereVec=~ismember(toAddPathList,fullStaticPathList);
                if ~any(isnFullThereVec)
                    fprintf('Files %s are already on static java classpath\n',...
                        list2str(toAddPathList));
                end
                %
                if ~all(isnThereVec==isnFullThereVec)
                    isInFullStaticVec=~isnFullThereVec&isnThereVec;
                    isInUserStaticVec=isnFullThereVec&~isnThereVec;
                    globalClassPathFile=[prefdir,filesep,'javaclasspath.txt'];
                    throwerror('wrongStaticPath',...
                        ['files %s are in current static path but not\n',...
                        'in %s while files %s are in %s but not in\n',...
                        'current static path.\n',...
                        'It can be that %s file contains the same entries as %s.\n',...
                        'If that is the case please remove those entries and restart Matlab!'],...
                        list2str(toAddPathList(isInFullStaticVec)),...
                        self.classPathFileName,...
                        list2str(toAddPathList(isInUserStaticVec)),...
                        self.classPathFileName,globalClassPathFile,...
                        self.classPathFileName);
                end
                %
                self.addToPrefDirClassPath(missingPathList);
                if any(isnFullThereVec)
                    throwwarn('restartMatlab',['files %s have been added ',...
                        'to Java static path,\n ',...
                        '          <<<<------ PLEASE RESTART MATLAB ------->>>>'],...
                        list2str(missingPathList));
                end
            end
        end
    end
    methods (Access=private)
        function isPos=isPrefDirClassPathSet(self)
            isPos=modgen.system.ExistanceChecker.isFile(...
                self.classPathFileName,false);
        end
        function pathList=readPrefDirClassPath(self)
            [fid,errMsg]=fopen(self.classPathFileName,'r');
            if fid<0
                throwerror('cannotOpenFile',errMsg);
            end
            try
                resCell=textscan(fid,'%s\n');
                pathList=resCell{1};
            catch meObj
                fclose(fid);
                rethrow(meObj);
            end
            fclose(fid);
        end
        function addToPrefDirClassPath(self,pathList)
            import modgen.common.throwerror;
            [fid,errMsg]=fopen(self.classPathFileName,'a');
            if fid<0
                throwerror('cannotOpenFile',errMsg);
            end
            try
                if ~isempty(pathList)
                    msgStr=sprintf('adding %s to %s',...
                        list2str(pathList),self.classPathFileName);
                    fprintf(fid,'\n%s',pathList{:});
                    disp([msgStr,' :done']);
                else
                    fprintf('Nothing to add to %s\n',self.classPathFileName);
                end
            catch meObj
                fclose(fid);
                rethrow(meObj);
            end
            fclose(fid);
        end
    end
end
%
function outStr=list2str(inpList)
outStr=sprintf('\n[%s]\n',modgen.string.catwithsep(inpList,sprintf(',\n')));
end

