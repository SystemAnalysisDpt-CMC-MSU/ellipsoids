classdef TmpDataManager<modgen.io.TmpDataManager
    % TMPDATAMANAGER provides a basic functionality for managing temporary
    % data folders, root folder name is determined automatically
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$    
    %
    methods (Static)
        function setRootDir()
            curFilePath=which('modgen.test.run_tests');
            %
            dirName=[rmlastnpathparts(...
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

            if nargin<1
                keyName='';
            end
            modgen.test.TmpDataManager.setRootDir();
            resDir=modgen.io.TmpDataManager.getDirByCallerKey(...
                keyName,3);
        end
    end
end
