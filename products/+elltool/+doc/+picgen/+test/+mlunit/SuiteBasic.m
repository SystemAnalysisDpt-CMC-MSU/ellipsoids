classdef SuiteBasic < mlunitext.test_case
    properties
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        
        function testPicGen(~)
            testFileName = modgen.common.getcallername(1);
            [pathstrVec, ~, ~] = fileparts(which(testFileName));
            modgen.io.TmpDataManager.setRootDir(pathstrVec);
            testDirPath = modgen.io.TmpDataManager.getDirByCallerKey('test', 1);
            testDirName = modgen.string.splitpart(testDirPath, filesep, 'last');
            elltool.doc.picgen.PicGenController.setPicDestDir(['products'...
            filesep '+elltool' filesep '+doc' filesep '+picgen' filesep...
            '+test' filesep '+mlunit' filesep testDirName]);
            elltool.doc.picgen.PicGenController.getPicDestDir();
             picFileNameVec = [];
             picgenDirName = [modgen.path.rmlastnpathparts(pathstrVec, 2) filesep '*.m'];
             picgenFilesVec = dir(picgenDirName);            
             for iElem = 1 : size(picgenFilesVec, 1)
                 picgenFileName = modgen.string.splitpart(picgenFilesVec(iElem).name, '.', 'first');
                 picFileName = strcat(modgen.string.splitpart(picgenFileName,'_gen', 1), '.eps');
                 picFileNameVec = [picFileNameVec picFileName];
                 picgenFunctionName =  strcat('elltool.doc.picgen.', picgenFileName);
                picgenFunction = str2func(picgenFunctionName);
                picgenFunction();
             end
            cmpPicgenFileNameVec = dir([testDirPath filesep '*.eps']);
            cmpPicFileNameVec = [];
            for iElem = 1 : size(cmpPicgenFileNameVec, 1)
                cmpPicgenFileName = modgen.string.splitpart(cmpPicgenFileNameVec(iElem).name, '.', 'first');
                cmpPicFileName = strcat(modgen.string.splitpart(cmpPicgenFileName,'_gen', 1), '.eps');
                cmpPicFileNameVec = [cmpPicFileNameVec cmpPicFileName];
            end
            elltool.doc.picgen.PicGenController.flush();
            isOk=strcmp(cmpPicFileNameVec, picFileNameVec);
            mlunitext.assert_equals(true,isOk);
        end
        
    end
end