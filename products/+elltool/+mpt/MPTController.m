classdef MPTController
    properties (GetAccess=private,Constant)
        MPT_SETUP_FUNC_NAME='mpt_init';
        MPT_GLOBAL_OPT = 'mptOptions';
    end
    methods (Static)
        %
        function isPositive=isOnPath()
            import elltool.mpt.MPTController;
            isPositive=modgen.system.ExistanceChecker.isFile(...
                MPTController.MPT_SETUP_FUNC_NAME);
        end
        %
        function checkIfSetUp()
            import elltool.mpt.MPTController;
            import modgen.common.throwerror;
            if isempty(whos('global',MPTController.MPT_GLOBAL_OPT))
                throwerror('mptNotSetUp','MPT is not set up');
            end
        end
        function checkIfOnPath()
            import elltool.mpt.MPTController;
            N_HOR_LINE_CHARS=60;
            if ~MPTController.isOnPath()
                horLineStr=['\n',repmat('-',1,N_HOR_LINE_CHARS),'\n'];
                msgStr=sprintf(['\n',horLineStr,...
                    '\nMTP is not found!!! \n',...
                    'Please put MTP into "mtp" ',...
                    'folder next to "products" folder ',horLineStr]);
                modgen.common.throwerror('mptNotFound',msgStr);
            end
        end
        function setUpIfNot(setUpDataCVec)
            import elltool.mpt.MPTController;
            
            MPTController.checkIfOnPath();
            if isempty(whos('global',MPTController.MPT_GLOBAL_OPT))
                absTol = setUpDataCVec{1};
                relTol = setUpDataCVec{2};
                isVerbose = setUpDataCVec{3};
                if isVerbose
                    verbose = 2;
                else
                    verbose = 1;
                end
                mpt_init('abs_tol',absTol,'rel_tol',relTol,'verbose',verbose);
                MPTController.checkIfSetUp();
            end
        end
    end
end