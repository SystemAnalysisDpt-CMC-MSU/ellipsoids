classdef MPTController < elltool.exttbx.IExtTBXController
    properties (GetAccess=private,Constant)
        MPT_SETUP_FUNC_NAME='mpt_init';
        MPT_GLOBAL_OPT = 'mptOptions';
    end
    methods
        function fullSetup(self,absTol,relTol,isVerbose)
            self.checkIfOnPath();
            if isempty(whos('global',self.MPT_GLOBAL_OPT))
                if isVerbose
                    verbose = 2;
                else
                    verbose = 1;
                end
                mpt_init('abs_tol',absTol,'rel_tol',relTol,'verbose',...
                    verbose);
                self.checkIfSetUp();
            end
        end
        %
        function checkSettings(self,absTol,relTol,isVerbose)
            %here we make sure that the settings specified in fullSetup are
            %not changed manually via direct mpt calls like mpt_init
        end
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