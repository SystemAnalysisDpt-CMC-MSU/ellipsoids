classdef SuiteBasic < mlunitext.test_case
    properties
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        
        function testPicGen(~)
            import modgen.io.TmpDataManager;
            import elltool.doc.picgen.PicGenController;
            testFileName = modgen.common.getcallername(1);
            [pathstrVec, ~, ~] = fileparts(which(testFileName));
            TmpDataManager.setRootDir(pathstrVec);
            testDirPath = TmpDataManager.getDirByCallerKey('test', 1);
            PicGenController.setPicDestDir(testDirPath);
            
            picFileNameVec = [];
            picgenDirName = [modgen.path.rmlastnpathparts(pathstrVec, 2)...
                filesep '*.m'];
            SPicgenFilesArray = dir(picgenDirName);
            for iElem = 1 : size(SPicgenFilesArray, 1)
                picgenFileName = modgen.string.splitpart...
                    (SPicgenFilesArray(iElem).name, '.', 'first');
                picFileName = strcat(modgen.string.splitpart(...
                    picgenFileName, '_gen', 1), '.png');
                picFileNameVec = [picFileNameVec picFileName];
                picgenFunctionName =  strcat('elltool.doc.picgen.',...
                    picgenFileName);
                fPicGen = str2func(picgenFunctionName);
                fPicGen();
                isFileExistVec(iElem) = ...
                    modgen.system.ExistanceChecker.isFile(...
                    [testDirPath filesep picFileName]);
            end
            close all;
            PicGenController.flush();
            rmdir(testDirPath,'s');
            isOk=isequal(isFileExistVec, ones(1, iElem));
            mlunitext.assert_equals(true,isOk);
        end
        
    end
end