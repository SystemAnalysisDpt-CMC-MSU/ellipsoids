classdef PicGenController
% PicGenController - a static class, providing methods to generate the
% name for the picture and save the figure in doc/pic.
%
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <6 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $

    methods(Static)
        function fullPicFileName = getPicFileNameByCaller()
        
        % getPicFileNameByCaller - generates the full name for a picture
        % in order to save it later in doc/pic.
        % Output:
        %        fullPicFileName: char [1, ] - full file name for a picture.
        % Example:
        %   elltool.doc.picgen.PicGenController.getPicFileNameByCaller()
        %
            picGenFunctionName = modgen.common.getcallername(3);
            picFileName = modgen.string.splitpart(picGenFunctionName, '.', 'last');
            picFileName = modgen.string.splitpart(picFileName, '_gen', 1);
            [pathstrVec, ~, ~] = fileparts(which(modgen.common.getcallernameext(3)));
            dirName = modgen.path.rmlastnpathparts(pathstrVec, 4);
            picFileName = strcat (picFileName, '.eps');
            fullPicFileName = [dirName filesep 'doc' filesep 'pic' filesep picFileName];
        end
        
        function savePicFileNameByCaller(figHandle, figWidth, figHeight)
            
        % savePicFileNameByCaller - changes figure's size and then
        % saves it in doc/pic.
        % Input:
        %        figHandle:  figure [1,1] - figure to save.
        %        figWidth:   numeric[1,1] - figure's width to set. 
        %        figHeight:  numeric[1,1] - figure's height to set.
        % Example:
        % elltool.doc.picgen.PicGenController.savePicFileNameByCaller(figHandle)
        %
            
            picFileName = elltool.doc.picgen.PicGenController.getPicFileNameByCaller();
            set(figHandle, 'Units','normalized');
            set(figHandle,'WindowStyle','normal'); 
            set(figHandle, 'Position', [0.2 0.2 figWidth figHeight]);
            get(figHandle, 'Position')
            set(figHandle, 'Position', [0.2 0.2 figWidth figHeight]);
            get(figHandle, 'Position')
            print(figHandle,'-depsc', picFileName);
        end
        
    end
end