classdef PicGenController<modgen.common.obj.StaticPropStorage
    % PicGenController - a static class, providing methods to generate the
    % name for the picture and save the figure.
    %
    % $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $
    % $Date: <6 October 2013> $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Cybernetics,
    %            System Analysis Department 2013 $
    
    methods(Static, Access = public)
        
        function picDestDir = getPicDestDir
            branchName = mfilename('class');
            [picDestDir,~] = ...
                modgen.common.obj.StaticPropStorage.getPropInternal(...
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
    end
    
    methods(Static, Access = private)
        
        function hcombinedFig = createCombinedFigure(hFigHandleVec,...
                nFigRows, nFigCols, figRegExpList,...
                cameraPositionsList, viewAngleList)
            % CREATECOMBINEDFIGURE - combines figures from hfigHandleVec
            % forming one combined figure with 4 axes.
            % Input:
            %   regular:
            %       hfigHandleVec:  double [,1] - figures to combine.
            %       nFigRows:  double [1,1] - number of axes' rows (first
            %                  parameter in subplot).
            %       nFigCols: double [1,1] - number of axes' columnes
            %                 (second parameter in subplot).
            %       figRegExpList: cell [1, nFigRows*nFigCols] of char [1,]
            %                      - list of regular expressions for
            %                      searching figures to copy in axes
            %                      of combined figure.
            %       cameraPositionsList: cell [nFigRows*nFigCols, 1] of
            %       double [1, 3]/{} - list of camera's positions for axes.
            %       viewAngleList: cell [nFigRows*nFigCols, 1]
            %       of double[1,1]/[]/double [1,2]
            %                        - list of values for axes' view
            %                        properties in combined figure.
            % Output:
            %    regular:
            %        hcombinedFig: double [1,1] - combined figure.
            % Example:
            %   elltool.doc.picgen.PicGenController.createCombinedFigure...
            %   (hFigHandleVec, nFigRows, nFigCols, figRegExpList,...
            %   cameraPositionsList, viewAngleList);
            %
            hcombinedFig = figure;
            iElemVec = 1:nFigRows*nFigCols;
            axesTitlesVec(iElemVec) = char(96+iElemVec);
            labelPropVec = ['X' 'Y' 'Z'];
            
            for iElem = 1:nFigRows*nFigCols
                axesVec(iElem) = subplot(nFigRows, nFigCols, iElem);
                grid on
                title(axesVec(iElem), axesTitlesVec(iElem));
                if   ~isempty(viewAngleList{iElem})
                    view(viewAngleList{iElem});
                end
                if   ~isempty(cameraPositionsList)
                    set(axesVec(iElem),  'CameraPosition',...
                        cameraPositionsList{iElem});
                end
                hFigVec =  findobj(hFigHandleVec, '-regexp','Name',...
                    figRegExpList{iElem});
                
                for jElem = 1:size(hFigVec, 1)
                    movedContent = get(findobj(hFigVec(jElem),'Type',...
                        'axes'), 'Children');
                    copyobj(movedContent, axesVec(iElem));
                    for kElem = 1:3
                        labelNameVec(kElem) = copyobj(get(findobj(...
                            hFigVec(jElem), 'Type','axes'),...
                            [labelPropVec(kElem) 'Label']), axesVec(iElem));
                        set(axesVec(iElem), [labelPropVec(kElem) 'Label'],...
                            labelNameVec(kElem));
                    end
                end
            end
            
        end
        
        
        
        function fullPicFileName = getPicFileNameByCaller()
            
            % GETPICFILENAMEBYCALLER - generates the full name for a picture
            % in order to save it later.
            % Output:
            %    regular:
            %       fullPicFileName: char [1, ] - full file name for a picture.
            % Example:
            %   elltool.doc.picgen.PicGenController.getPicFileNameByCaller()
            %
            picGenFunctionName = modgen.common.getcallername(3);
            picFileName = modgen.string.splitpart(picGenFunctionName, '.',...
                'last');
            picFileName = modgen.string.splitpart(picFileName, '_gen', 1);
            picFileName = strcat (picFileName, '.png');
            fullPicFileName = ...
                [elltool.doc.picgen.PicGenController.getPicDestDir()...
                filesep picFileName];
        end
        
    end
    
    methods(Static)
        
        function savePicFileNameByCaller(hFigHandleVec, figWidth,...
                figHeight, nFigRows, nFigCols, varargin)
            
            % SAVEPICFILENAMEBYCALLER - combines figures from hFigHandleVec
            %  in one, changes combined figure's size and then saves it.
            % Input:
            %   regular:
            %       figHandle:  double [1,1] - figures to combine.
            %       figWidth:   double [1,1] - combined figure's width to set.
            %       figHeight:  double [1,1] - combined figure's height to set.
            %       nFigRows:  double [1,1] - number of axes' rows in combined
            %       figure.
            %       nFigCols: double [1,1] - number of axes' columnes in
            %                 combined figure.
            %    properties:
            %       'figRegExpList': cell [1, nFigRows*nFigCols] - list of
            %                        regular expressions for searching figures
            %                        to copy in axes of combined figure.
            %                        Default value is '[a-zA-Z_0-9:;,-\]\[\s]*'
            %       'cameraPositionsList': cell [nFigRows*nFigCols, 1]
            %       of double [1, 3]/{}  - list of camera's positions for axes.
            %                              Default value is {}.
            %       'viewAngleList': cell [nFigRows*nFigCols, 1]
            %        of double[1,1]/[]/double [1,2]
            %                        - list of values for axes' view
            %                        properties in combined figure. Default
            %                        value is {}.
            % Example:
            % elltool.doc.picgen.PicGenController.savePicFileNameByCaller...
            % (hFigHandleVec, 0.6, 0.6, 2, 2,'figRegExpList', figRegExpList,...
            %  'cameraPositionsList', cameraPositionsList, 'viewAngleList',...
            %  viewAngleList);
            %
            [~,~,figRegExpList, cameraPositionsList,...
                viewAngleList]= modgen.common.parseparext(varargin,...
                {'figRegExpList','cameraPositionsList','viewAngleList';...
                {'[a-zA-Z_0-9:;,-\]\[\s]*'},{},{}});
            if nFigRows == 1 && nFigCols == 1
                hfigHandle = findobj('Type','figure', '-regexp','Name',...
                    figRegExpList{1});
            else
                hfigHandle =...
                    elltool.doc.picgen.PicGenController.createCombinedFigure(...
                    hFigHandleVec, nFigRows, nFigCols, figRegExpList,...
                    cameraPositionsList, viewAngleList);
            end
            set(hfigHandle, 'Units','normalized');
            set(hfigHandle,'WindowStyle','normal');
            set(hfigHandle, 'Position', [0 0 figWidth figHeight]);
            drawnow
            picFileName =...
                elltool.doc.picgen.PicGenController.getPicFileNameByCaller();
            print(hfigHandle,'-dpng', picFileName);
            
        end
        
        
    end
    
end