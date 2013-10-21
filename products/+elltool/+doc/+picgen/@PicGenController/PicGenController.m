classdef PicGenController<modgen.common.obj.StaticPropStorage
% PicGenController - a static class, providing methods to generate the
% name for the picture and save the figure in doc/pic.
%
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <6 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    
     methods(Static)
         
         function picDestDir = getPicDestDir
            branchName=mfilename('class');
            [picDestDir,~]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName, 'picDestDir');
         end
        
         function setPicDestDir(picDestDir)
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,'picDestDir',picDestDir);
         end
        
         function flush()
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.flushInternal(branchName);
         end 
         
         function hcombinedFig = createCombinedFigure(hfigHandleVec, figPositionsVec, cameraPositionsMat)
            % CREATECOMBINEDFIGURE - combines figures from hfigHandleVec forming one 
            % combined figure with 4 axes.
            % Input:
            %   regular:
            %       hfigHandleVec:  double [,1] - figures to combine.
            %       figPositionsVec:   double [1,] - vector of axes' numbers 
            %       in combined figure for copying figure from hfigHandleVec.
            %       cameraPositionsMat:  double [4,3] - defines 'CameraPosition'
            %       property for each axes. If it is empty, then 'default' value
            %       is used. 
            % Output:
            %    regular:
            %        hcombinedFig: double [1,1] - combined figure.
            % Example:
            %   elltool.doc.picgen.PicGenController.createCombinedFigure(hfigHandleVec, figPositionsVec, cameraPositionsMat)
            %
            hcombinedFig = figure;
            axesTitlesVec = ['a'; 'b'; 'c'; 'd'];
            axesPositionsMat = [ 0.1300    0.5838    0.3005    0.3412;...
                                 0.5703    0.5838    0.3347    0.3412;...
                                 0.1300    0.1100    0.3005    0.3412;...
                                 0.5703    0.1100    0.3347    0.3412];
            for iElem = 1:4                 
            movedContent = findobj(hfigHandleVec(find(figPositionsVec == iElem, 1)),...
                           'Type','axes');
            axesVec(iElem) = copyobj(movedContent, hcombinedFig);
            title(axesVec(iElem), axesTitlesVec(iElem));
            set(axesVec(iElem),  'Position', axesPositionsMat(iElem, 1:4));
            if   ~isempty(cameraPositionsMat)
                  set(axesVec(iElem),  'CameraPosition',...
                      cameraPositionsMat(iElem, 1:3));
            end
            cla(axesVec(iElem));
            end

            for iElem = 1:size(hfigHandleVec, 1)
                 movedContent = get(findobj(hfigHandleVec(iElem),'Type','axes'), 'Children');
                 copyobj(movedContent, axesVec(figPositionsVec(iElem)));
            end    
                 
         end 
         
        function fullPicFileName = getPicFileNameByCaller()
        
        % GETPICFILENAMEBYCALLER - generates the full name for a picture
        % in order to save it later in doc/pic.
        % Output:
        %    regular:
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
            fullPicFileName = [dirName filesep elltool.doc.picgen.PicGenController.getPicDestDir()...
                               filesep picFileName];
        end
        
        function savePicFileNameByCaller(figHandle, figWidth, figHeight)
            
        % SAVEPICFILENAMEBYCALLER - changes figure's size and then
        % saves it in doc/pic.
        % Input:
        %   regular:
        %       figHandle:  double [1,1] - figure to save.
        %       figWidth:   double [1,1] - figure's width to set. 
        %       figHeight:  double [1,1] - figure's height to set.
        % Example:
        % elltool.doc.picgen.PicGenController.savePicFileNameByCaller(figHandle)
        %
            
            picFileName = elltool.doc.picgen.PicGenController.getPicFileNameByCaller();
            set(figHandle, 'Units','normalized');
            set(figHandle,'WindowStyle','normal'); 
            set(figHandle, 'Position', [0.2 0.2 figWidth figHeight]);
            set(figHandle, 'Position', [0.2 0.2 figWidth figHeight]);
            print(figHandle,'-depsc', picFileName);
        end
        
        
    end
    
end