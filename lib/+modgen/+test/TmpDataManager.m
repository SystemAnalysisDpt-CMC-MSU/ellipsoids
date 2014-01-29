classdef TmpDataManager<modgen.io.TmpDataManager
    % TMPDATAMANAGER provides a basic functionality for managing temporary
    % data folders, root folder name is determined automatically
    %
    methods (Static)
        function setRootDir()
            ANCHOR_FILE_NAME='modgen.test.run_public_tests';
            curFilePath=which(ANCHOR_FILE_NAME);
            if isempty(curFilePath)
                modgen.common.throwerror('anchorNotFound',...
                    sprintf('location of anchor file %s not found',...
                    curFilePath));
            end
            %
            dirName=[modgen.path.rmlastnpathparts(...
                curFilePath,3),...
                filesep,'TTD'];
            %
            modgen.io.TmpDataManager.setRootDir(dirName);
        end
        function resDir=getDirByKey(keyName)
            % GETDIRBYKEY returns a unique temporary directory name based on
            % specified key and makes sure that this directory is empty
            %
            % Input:
            %   regular:
            %       keyName: char[1,] key name
            %
            % Output:
            %   resDir: char[1,] - resulting directory name
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-18 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %
            modgen.test.TmpDataManager.setRootDir();
            %
            resDir=modgen.io.TmpDataManager.getDirByKey(keyName);
        end
        function resDir=getDirByCallerKey(keyName)
            % GETDIRBYCALLERKEY returns a unique temporary directory name
            % based on caller name and optionally based on a specified key
            % and makes sure that this directory is empty
            %
            % Input:
            %   optional:
            %       keyName: char[1,] key name
            %
            % Output:
            %   resDir: char[1,] - resulting directory name
            %
            %
            if nargin<1
                keyName='';
            end
            modgen.test.TmpDataManager.setRootDir();
            resDir=modgen.io.TmpDataManager.getDirByCallerKey(...
                keyName,3);
        end
    end
end