classdef mlunit_test_common < mlunitext.test_case
    properties
    end
    
    methods
        function self = mlunit_test_common(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
            %
        end
        %
        function DISABLED_test_xlswrite(self)
            N_MAX_ROWS=65536;
            N_MAX_COLS=256;
            s=warning('off',...
                'MODGEN:MICROSOFT:OFFICE:XLSWRITE:resultFileTypeChange');
            check(cell(0,0));
            check(cell(N_MAX_ROWS+1,1));
            check(cell(1,N_MAX_COLS+1));
            warning(s);
            check(cell(1,1));
            %
            function check(dataCell)
                import modgen.test.TmpDataManager;
                import modgen.system.ExistanceChecker;
                import modgen.microsoft.office.xlswrite;
                
                if ~ispc()
                    return;
                end
                dirName=TmpDataManager.getDirByCallerKey();
                filePath=[dirName,filesep,'tmp.xls'];
                try
                    h=actxserver('Excel.Application');
                    h.delete();
                    isExcelInstalled=true;
                catch meObj
                    isExcelInstalled=false;
                end
                %
                isTooBig=size(dataCell,1)>N_MAX_ROWS|...
                    size(dataCell,2)>N_MAX_COLS;
                isEmpty=numel(dataCell)==0;
                %
                mlunitext.assert_equals(false,...
                    ExistanceChecker.isFile(filePath));
                [~,~,resFilePath]=xlswrite(filePath,dataCell);
                if isExcelInstalled&&~isEmpty&&~isTooBig
                    mlunitext.assert_equals(true,...
                        ExistanceChecker.isFile(filePath));
                    mlunitext.assert_equals(true,...
                        strcmp(resFilePath,filePath));
                else
                    mlunitext.assert_equals(true,...
                        strcmp(strrep(resFilePath,...
                        'csv','xls'),filePath));
                    mlunitext.assert_equals(true,...
                        ExistanceChecker.isFile(resFilePath));
                end
            end
        end
    end
end