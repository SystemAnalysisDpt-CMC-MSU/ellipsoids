classdef AConfRepoMgr<handle
    properties (Constant,GetAccess=private)
        COL_SEP=' ';
    end
    methods (Static)
        function val=putStorageHook(val,~)
            import gras.ellapx.uncertmixcalc.conf.sysdef.AConfRepoMgr;
            nRows=size(val,1);
            nCols=size(val,2);
            if nCols==nRows
                if iscellstr(val)
                    val=modgen.string.catcellstrwithsep(val,...
                        AConfRepoMgr.COL_SEP);
                elseif isnumeric(val)
                    val=mat2cell(val,ones(nRows,1),nCols);
                end
            end
        end
        function val=getStorageHook(val,~)
            import gras.ellapx.uncertmixcalc.conf.sysdef.AConfRepoMgr;
            import modgen.common.iscellnumeric;
            nCols=size(val,2);
            %
            if nCols==1
                if iscellstr(val)
                    val=modgen.string.sepcellstrbysep(val,...
                        AConfRepoMgr.COL_SEP);
                elseif iscellnumeric(val)
                    val=vertcat(val{:});
                end
            end
        end
    end    
end
