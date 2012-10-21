classdef TmpDataManager<modgen.common.obj.StaticPropStorage
    %TMPDATAMANAGER implements a basic functionality for managing temporary
    %data folders
    
    methods (Static)
        function setRootDir(dirName)
            % SETROOTDIR sets up a root of temporary folders directory tree
            modgen.io.TmpDataManager.setPropInternal('rootDir',dirName);
        end
        function resDir=getDirByCallerKey(keyName,nStepsUp)
            % GETDIRBYCALLERKEY returns a unique temporary directory name 
            % based on caller name and optionally based on a specified key
            % and makes sure that this directory is empty
            %
            % Input:
            %   optional:
            %       keyName: char[1,] key name
            %       nStepsUp: numeric[1,1] - number of steps 
            %           up in the call stacks,  =1 by default
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
            import modgen.common.type.simple.checkgen;
            if nargin<2
                nStepsUp=2;
                if nargin<1
                    keyName='';
                else
                    checkgen(keyName,'isstring(x)');
                end
            else
                checkgen(nStepsUp,'isnumeric(x)&&isscalar(x)');
            end
            callerName=modgen.common.getcallername(nStepsUp,'full');
            resDir=modgen.io.TmpDataManager.getDirByKey(...
                [callerName,'.',keyName]);            
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
            modgen.common.type.simple.checkgen(keyName,'isstring(x)');
            [rootDir,isThere]=...
                modgen.io.TmpDataManager.getPropInternal('rootDir',true);
            if ~isThere
                error([upper(mfilename),':wrongInput'],...
                    'root directory is not set');
            end
            curTaskName=modgen.system.getpidhost();
            keyDirName=hash({curTaskName,keyName});
            resDir=[rootDir,filesep,keyDirName];
            if modgen.system.ExistanceChecker.isDir(resDir)
                rmdir(resDir,'s');
            end
            mkdir(resDir);
        end
        
    end
    %
    methods (Access=protected,Static)
        function [propVal,isThere]=getPropInternal(propName,isPresenceChecked)
            % GETPROPINTERNAL gets corresponding property from storage
            %
            % Usage: [propVal,isThere]=...
            %            getPropInternal(propName,isPresenceChecked)
            %
            % input:
            %   regular:
            %     propName: char - property name
            %     isPresenceChecked: logical [1,1] - if true, then presence
            %         of given property is checked before its value is
            %         retrieved from the storage, otherwise value is
            %         retrieved without any check (that may lead to error
            %         if property is not yet logged into the storage)
            % output:
            %   regular:
            %     propVal: empty or matrix of some type - value of given
            %         property in the storage (if it is absent, empty is
            %         returned)
            %   optional:
            %     isThere: logical [1,1] - if true, then property is in the
            %         storage, otherwise false
            %
            %
            branchName=mfilename('class');
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,isPresenceChecked);
        end
        %
        function setPropInternal(propName,propVal)
            % SETPROPINTERNAL sets value for corresponding property within
            % storage
            %
            % Usage: setPropInternal(propName,propVal)
            %
            % input:
            %   regular:
            %     propName: char - property name
            %     propVal: matrix of some type - value of given property to
            %         be set in the storage
            %
            %
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
    end
    
end