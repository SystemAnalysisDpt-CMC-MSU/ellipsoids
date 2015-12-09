classdef ExamplesTC < mlunitext.test_case
    methods
        function self = ExamplesTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
        %
        function test_examples(~)
            import modgen.common.throwerror;
            curDirName=fileparts(mfilename('fullpath'));
            className=mfilename('class');
            examplePkgName=[className(1:find(className=='.',2,'last')-1),...
                '.examples'];
            examplesDirName=...
                [modgen.path.rmlastnpathparts(curDirName,1),filesep,...
                '+examples'];
            SDir=dir([examplesDirName,filesep,'example_*']);
            exampleNameList={SDir.name};
            nExamples=numel(exampleNameList);
            for iExample=1:nExamples
                try
                    exampleName=[examplePkgName,'.',...
                        exampleNameList{iExample}(1:end-2)];
                    evalc(exampleName);
                catch meObj
                    newMeObj=throwerror('testRunProblem','failed to run %s',...
                        exampleName');
                    newMeObj=addCause(newMeObj,meObj);
                    throw(newMeObj);
                end
            end
        end
    end
end

