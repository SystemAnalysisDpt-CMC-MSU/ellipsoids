classdef TEllApxBuilder < gras.ellapx.uncertcalc.EllApxBuilder
    %TELLAPXBUILDER Subclass to choose handles that are tested for absTol,
    %relTol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods (Static, Access = public)
        function fHandle = getApxBuilder(apxName,schemaName)
            import gras.ellapx.*
            fHandle = function_handle.empty;
            switch apxName
                case 'internalApx'
                    switch schemaName
                        case 'noUncertSqrtQ'
                            fHandle = @lreachplain.test.TIntEllApxBuilder;
                        case 'noUncertJustQ'
                            fHandle = @lreachplain.test.TIntProperEllApxBuilder;
                        case 'uncertMixed'
                            fHandle = @lreachuncert.test.TMixedIntEllApxBuilder;
                    end
                case 'externalApx'
                    switch schemaName
                        case 'justQ'
                            fHandle = @lreachplain.test.TExtEllApxBuilder;
                    end
                case 'extIntApx'
                    switch schemaName
                        case 'uncert'
                            fHandle = @lreachuncert.test.TExtIntEllApxBuilder;
                    end
            end
            if isempty(fHandle)
                modgen.common.throwerror('wrongInput', ...
                    'Unsupported schema: %s.%s', apxName, schemaName);
            end
        end
    end
    %
    methods
        function self = TEllApxBuilder(confRepoMgr,pDynObj,goodDirSetObj)
            self = self@gras.ellapx.uncertcalc.EllApxBuilder(...
                confRepoMgr,pDynObj,goodDirSetObj);
        end
    end
end