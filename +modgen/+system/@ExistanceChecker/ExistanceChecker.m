classdef ExistanceChecker
    %EXISTANCECHECKER is a wrapper class around exist function
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    
    properties (Constant)
        FILE_IS_ON_DISK=2
        VAR_IS_IN_WORKSPACE=1
        DIRECTORY_ON_DISK=7
    end
    properties (Constant, Hidden)
        classLoc='modgen.system.ExistanceChecker';
    end
    methods (Static)
        function res=exist(varargin)
            inpArg=['exist(''',cell2sepstr([],varargin,''','''),''')'];
            res=evalin('caller',inpArg);
        end
        function isPositive=isVar(nameStr)
            import modgen.system.ExistanceChecker;
            %
            inpArg=[ExistanceChecker.classLoc,'.exist(''',nameStr,''',''var'')==',...
                ExistanceChecker.classLoc,'.VAR_IS_IN_WORKSPACE'];
            isPositive=evalin('caller',inpArg);
        end
        function isPositive=isDir(nameStr)
            import modgen.system.ExistanceChecker;            
            inpArg=[ExistanceChecker.classLoc,'.exist(''',nameStr,''',''dir'')==',...
                ExistanceChecker.classLoc,'.DIRECTORY_ON_DISK'];
            isPositive=evalin('caller',inpArg);
        end
        function isPositive=isFile(nameStr)
            import modgen.system.ExistanceChecker;            
            inpArg=[ExistanceChecker.classLoc,'.exist(''',nameStr,''',''file'')==',...
                ExistanceChecker.classLoc,'.FILE_IS_ON_DISK'];
            isPositive=evalin('caller',inpArg);
        end
    end
    
end