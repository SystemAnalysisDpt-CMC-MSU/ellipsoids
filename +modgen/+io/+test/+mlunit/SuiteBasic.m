classdef SuiteBasic < mlunitext.test_case
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testCopyIsFileDir(~)
            FILE_NAME='1.mat';
            resTmpDir=modgen.test.TmpDataManager.getDirByCallerKey();
            isOk=modgen.io.isdir(resTmpDir);
            mlunitext.assert(isOk);
            %
            modgen.io.rmdir(resTmpDir);
            isOk=modgen.io.isdir(resTmpDir);
            mlunitext.assert(~isOk);
            %
            resTmpDir=modgen.test.TmpDataManager.getDirByCallerKey();
            srcFileName=[resTmpDir,filesep,FILE_NAME];
            aVar=1;
            save(srcFileName,'aVar');
            isOk=modgen.io.isfile(srcFileName);
            mlunitext.assert(isOk);
            %
            modgen.io.rmdir(resTmpDir,'s');
            isOk=modgen.io.isfile(srcFileName);
            mlunitext.assert(~isOk);
            %
            %test copyfile on long path
            resTmpDir=modgen.test.TmpDataManager.getDirByCallerKey();
            save(srcFileName,'aVar');
            dstDir=[resTmpDir,repmat([filesep,repmat('a',1,50)],1,6)];
            modgen.io.mkdir(dstDir);
            isOk=modgen.io.isdir(resTmpDir);
            mlunitext.assert(isOk);            
            modgen.io.copyfile(srcFileName,dstDir);
            dstFileName=[dstDir,filesep,FILE_NAME];
            isOk=modgen.io.isfile(dstFileName);
            mlunitext.assert(isOk);
            modgen.io.rmdir(dstDir,'s');
            isOk=modgen.io.isdir(dstDir);
            mlunitext.assert(~isOk);
            isOk=modgen.io.isdir(resTmpDir);
            mlunitext.assert(isOk);
            modgen.io.rmdir(resTmpDir,'s');
            isOk=modgen.io.isdir(resTmpDir);
            mlunitext.assert(~isOk);
        end
        %
        function testRmMkDir(~)
            checkMaster({},{},'1');
            checkMaster({},{'s'},'1');
            checkMaster({},{'s'},['1',filesep,'2']);
            %
            function checkMaster(mkArgList,rmArgList,subDir)
                resTmpDir=modgen.test.TmpDataManager.getDirByCallerKey();
                dirToCreate=[resTmpDir,filesep,subDir];
                checkIfExists(dirToCreate,false);
                modgen.io.mkdir(dirToCreate,mkArgList{:});
                checkIfExists(dirToCreate,true);
                [isSuccess,msgStr,messageId]=modgen.io.mkdir(dirToCreate,...
                    mkArgList{:});
                checkIfExists(dirToCreate,true);
                checkOk(false);
                modgen.io.rmdir(dirToCreate,rmArgList{:});
                checkIfExists(dirToCreate,false);
                [isSuccess,msgStr,messageId]=modgen.io.rmdir(dirToCreate,...
                    rmArgList{:});
                checkOk(false);
                function checkOk(isOk)
                    mlunitext.assert_equals(isSuccess,isOk);
                    mlunitext.assert_equals(isempty(msgStr),isOk);
                    mlunitext.assert_equals(isempty(messageId),isOk);
                end
            end
            function checkIfExists(dirName,isExists)
                mlunitext.assert_equals(isExists,...
                    modgen.system.ExistanceChecker.isDir(dirName));
            end
        end
        %
    end
end
