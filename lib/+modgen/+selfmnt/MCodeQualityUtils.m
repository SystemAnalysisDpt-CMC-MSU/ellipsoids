% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef MCodeQualityUtils
    methods (Static)
        function varargout=mlintScanAll()
            import modgen.selfmnt.OwnPathUtils;
            [dirList,patternToExclude]=...
                OwnPathUtils.getOwnCodeDirList();
            %
            if nargout==0
                modgen.dev.MLintScanner.scanWithHtmlReport(dirList,...
                    patternToExclude);
            else
                varargout=cell(1,nargout);
                [varargout{:}]=...
                    modgen.dev.MLintScanner.scanWithHtmlReport(...
                    dirList,patternToExclude);
            end
        end
        function fileList=smartIdentAll()
            import modgen.selfmnt.OwnPathUtils;
            fileList=OwnPathUtils.getFileListByExtensionList({'m'});
            %
            cellfun(@applySmartIndent,fileList);
        end
    end
end
function applySmartIndent(fileName)
h = matlab.desktop.editor.openDocument(fileName);
h.smartIndentContents();
h.save();
h.close();
delete(h);
end