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
%       fileNameList: cell[1,nFigures] of char[1,] - list of resulting file names,
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
import modgen.common.checkmultvar;
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
%
formatNameList=checkcellofstr(formatNameList);
checkmultvar(['all(ishghandle(x1))&&isvec(x1)&&',...
    '(numel(x1)==numel(x4))&&iscellofstring(x4)&&isstring(x2)'],4,...
    hFigureVec,resFolderName,formatNameList,fileNameList);
%
drawnow expose;
%
logger=Log4jConfigurator.getLogger();
%
tmpDir=modgen.io.TmpDataManager.getDirByCallerKey();
%
isFigThereVec=strcmp('fig',formatNameList);
%
if any(isFigThereVec)
    formatNameList=formatNameList(~isFigThereVec);
    isFig=true;
else
    isFig=false;
end
%
for iFigure=1:nFigures
    hFigure=hFigureVec(iFigure);
    if ~ishandle(hFigure)
        logger.warn(sprintf(...
            ['Handle %d doesn''t exists, probably figure ',...
            'has been closed manually'],hFigure));
    else
        %
        if isFig
            shortFigFileName=fileNameList{iFigure};            
            saveInFormat(shortFigFileName,'fig');
        end
        %
        paperPosMode=get(hFigure,'PaperPositionMode');
        outerPosVec=get(hFigure,'outerPosition');
        unitsName=get(hFigure,'Units');
        windowStyle=get(hFigure,'WindowStyle');
        %
        try
            set(hFigure,'PaperPositionMode','auto',...
                'WindowStyle','normal',...
                'Units','normalized','OuterPosition',[0 0 1 1]);
            %
            for iFormat=1:numel(formatNameList)
                saveInFormat(fileNameList{iFigure},formatNameList{iFormat});
            end
            %use separate calls for setting properties and set 'Units'
            %prior to setting OuterPosition to prevent a crash on
            %Matlab2015a
            %
            set(hFigure,'Units',unitsName,'OuterPosition',outerPosVec);
            set(hFigure,'PaperPositionMode',paperPosMode);
			set(hFigure,'WindowStyle',windowStyle);
            %
        catch meObj
            set(hFigure,'Units',unitsName,'OuterPosition',outerPosVec);
            set(hFigure,'PaperPositionMode',paperPosMode);
			set(hFigure,'WindowStyle',windowStyle);
            rethrow(meObj)
        end
    end
end
modgen.io.rmdir(tmpDir,'s');
    function saveInFormat(shortFigFileName,formatName)
        figFileName=[resFolderName,filesep,...
            shortFigFileName,'.',formatName];
        msgStr=['saving file ',figFileName,' to disk'];
        logger.debug([msgStr,'...']);
        %
        tmpFileName=[tmpDir,filesep,modgen.common.hash(figFileName),'.',...
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
end