classdef PathUtils
    methods (Static)
        function pathStr=rmLastPathParts(pathStr,nPartsToRemove)
            % RMLASTPATHPARTS removes a specified number of path parts
            % (directory names) starting from the tail
            %
            % Input:
            %   regular:
            %       pathStr: char[1,] - directory name
            %       nPartsToRemove: double[1,1] - number of path parts to
            %           remove
            %
            % Output:
            %   pathStr: char[1,] - resulting path
            %            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2009-2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            if isempty(pathStr)
                modgen.common.throwerror('wrongInput',...
                    'pathStr cannot be empty');
            end
            indVec=regexp(pathStr,filesep);
            nPartsInTotal=numel(indVec);
            if nPartsToRemove>0
                pathStr=pathStr(1:(indVec(nPartsInTotal-nPartsToRemove+1)-1));
            end
        end
        function pathList=genPathByRootList(pathToIncludeCVec,...
                pathPatternToExclude)
            % GENPATHBYROOTLIST recursively generates a list of path based
            % on a list of root path and a regular expression exclusion
            % pattern.
            %
            % Input:
            %   regular:
            %       pathToIncludeCVec: cell[1,] of char[1,] - list of
            %           directory names to scan recursively for
            %           generating a path list
            %       pathPatternToExclude: char[1,] - regex pattern for
            %           directory names to exclude (".git|.svn" for instance)
            %
            % Output:
            %   pathList: cell[1,] of char[1,] - list of generated
            %       directory names
            %            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2009-2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            
            pathListOfLists=cellfun(@(x)modgen.io.listdirsrecursive(x,...
                ['regex:^(?:(?!(',pathPatternToExclude,')).)*$'],Inf),...
                pathToIncludeCVec,'UniformOutput',false);
            pathList=vertcat(pathListOfLists{:}).';
        end
    end
end