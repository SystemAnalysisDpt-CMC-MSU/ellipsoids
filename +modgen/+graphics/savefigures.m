function savefigures(hFigureVec,resFolderName,formatNameList,fileNameList)
% SAVEFIGURES saves all figures to a specified folder in
% 'fig' format
%
% Input:
%   regular:
%       hFigureVec: double[1,nFigures] - vector of figure handles
%       resFolderName: char[1,] - destination folder name
%   optional:
%       formatNameList: char[1,]/cell[1,] of char[1,]
%           - list of format names accepted by the built-in
%           "saveas" function, default value is 'fig';
%       fileNameList: cell[1,] of char[1,] - list of resulting file names,
%           if not specified file names are generated based on figure names
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 01-June-2015 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
import modgen.logging.log4j.Log4jConfigurator;
import modgen.common.type.simple.checkcellofstr;
import modgen.common.genfilename;
%
DEFAULT_RESOLUTION='-r200';
%
nFigures=length(hFigureVec);
if nargin<4
    fileNameList=arrayfun(@(x)genfilename(get(x,'Name')),hFigureVec,...
        'UniformOutput',false);
    if nargin<3
        formatNameList={'fig'};
    end
end
%refresh figures
drawnow expose;
%
logger=Log4jConfigurator.getLogger();

formatNameList=checkcellofstr(formatNameList);
nFormats=length(formatNameList);
tmpDir=modgen.io.TmpDataManager.getDirByCallerKey();
for iFigure=1:nFigures
    hFigure=hFigureVec(iFigure);
    if ~ishandle(hFigure)
        logger.warn(sprintf(...
            ['Handle %d doesn''t exists, probably figure ',...
            'has been closed manually'],hFigure));
    else
        paperPosMode=get(hFigure,'PaperPositionMode');
        outerPosVec=get(hFigure,'outerPosition');
        unitsName=get(hFigure,'Units');
        windowStyle=get(hFigure,'WindowStyle');
        %
        try
            set(hFigure,'PaperPositionMode','auto',...
                'WindowStyle','normal',...
                'Units','normalized','OuterPosition',[0 0 1 1]);
            shortFigFileName=fileNameList{iFigure};
            %
            for iFormat=1:nFormats
                formatName=formatNameList{iFormat};
                figFileName=[resFolderName,filesep,...
                    shortFigFileName,'.',formatName];
                msgStr=['saving file ',figFileName,' to disk'];
                logger.debug([msgStr,'...']);
                %
                tmpFileName=[tmpDir,filesep,hash(figFileName),'.',...
                    formatName];
                %
                if strcmp(formatName,'fig')
                    saveas(hFigure,tmpFileName,formatName);
                else
                    print(hFigure,['-d',formatName],DEFAULT_RESOLUTION,...
                        tmpFileName);
                end
                modgen.io.copyfile(tmpFileName,figFileName);
                %
                if ~modgen.system.ExistanceChecker.isFile(figFileName)
                    error([upper(mfilename),':wrongInput'],...
                        'file %s was not created',figFileName);
                end
                logger.debug([msgStr,': done']);
            end
            set(hFigure,'PaperPositionMode',paperPosMode,...
                'OuterPosition',outerPosVec,'Units',unitsName,...
                'WindowStyle',windowStyle);
        catch meObj
            set(hFigure,'PaperPositionMode',paperPosMode,...
                'OuterPosition',outerPosVec,'Units',unitsName,...
                'WindowStyle',windowStyle);
            rethrow(meObj)
        end
    end
end
modgen.io.rmdir(tmpDir,'s');
end