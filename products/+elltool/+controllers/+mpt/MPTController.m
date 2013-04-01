classdef MPTController < elltool.controllers.interface.IntExtTBXController
    properties (GetAccess=private,Constant)
        MPT_SETUP_FUNC_NAME='mpt_init';
        MPT_GLOBAL_OPT = 'mptOptions';
    end
    methods
        function fullSetup(self,setUpDataCVec)
            self.checkIfOnPath();
            if isempty(whos('global',self.MPT_GLOBAL_OPT))
                absTol = setUpDataCVec{1};
                relTol = setUpDataCVec{2};
                isVerbose = setUpDataCVec{3};
                if isVerbose
                    verbose = 2;
                else
                    verbose = 1;
                end
                mpt_init('abs_tol',absTol,'rel_tol',relTol,'verbose',verbose);
                self.checkIfSetUp();
            end
        end
    end
    methods(Access = private)
        %
        function isPositive=isOnPath(self)
            isPositive=modgen.system.ExistanceChecker.isFile(...
                self.MPT_SETUP_FUNC_NAME);
        end
        %
        function checkIfSetUp(self)
            import modgen.common.throwerror;
            if isempty(whos('global',self.MPT_GLOBAL_OPT))
                throwerror('mptNotSetUp','MPT is not set up');
            end
        end
        function checkIfOnPath(self)
            N_HOR_LINE_CHARS=60;
            if ~self.isOnPath()
                horLineStr=['\n',repmat('-',1,N_HOR_LINE_CHARS),'\n'];
                msgStr=sprintf(['\n',horLineStr,...
                    '\nMTP is not found!!! \n',...
                    'Please put MTP into "mtp" ',...
                    'folder next to "products" folder ',horLineStr]);
                modgen.common.throwerror('mptNotFound',msgStr);
            end
        end
    end
end