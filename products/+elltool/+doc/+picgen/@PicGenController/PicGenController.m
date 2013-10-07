classdef PicGenController
%PicGenController - a static class, providing methods to generate the
%name for the picture and save the figure in doc/pic.
%
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <6 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $

    methods(Static)
        function picFileName = getPicFileNameByCaller()
        % Example:
        %   elltool.doc.picgen.PicGenController.getPicFileNameByCaller()
        %
            picGenFunctionName = modgen.common.getcallername(3);
            picFileName = modgen.string.splitpart(picGenFunctionName, '.', 'last');
            picFileName = modgen.string.splitpart(picFileName, '_gen', 1);

        end
        
        function savePicFileNameByCaller(figHandle)
            % Example:
            % elltool.doc.picgen.PicGenController.savePicFileNameByCaller(figHandle)
            %
            [pathstrVec, ~, ~] = fileparts(which(modgen.common.getcallernameext(2)));
            part1ofName = modgen.path.rmlastnpathparts(pathstrVec, 4);
            picFileName = elltool.doc.picgen.PicGenController.getPicFileNameByCaller();
            part2ofName = strcat (picFileName, '.eps');
            picFileName = [part1ofName filesep 'doc' filesep 'pic' filesep part2ofName];
            saveas (figHandle,  picFileName);
        end
        
    end
end