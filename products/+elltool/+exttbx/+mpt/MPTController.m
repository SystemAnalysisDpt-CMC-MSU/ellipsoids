classdef MPTController < elltool.exttbx.IExtTBXController
    properties (GetAccess=private,Constant)
        MPT_SETUP_FUNC_NAME='mpt_init.m';
        MPT_GLOBAL_OPT = 'MPTOPTIONS';
        
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
                mpt_init();
                mptopt('abs_tol',absTol,'rel_tol',relTol,'verbose',verbose);
                self.checkIfSetUp();
            end
        end
        %
        function checkSettings(self,absTol,relTol,isVerbose)
            import modgen.common.throwerror;
            if~((absTol == self.getAbsTol()) && ...
                (relTol == self.getRelTol()) && ...
                (isVerbose == self.getIsVerbosityEnabled))
                throwerror('mptError', 'wrong mpt properties');
            end
        end
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
        %
        function checkIfOnPath(self)
            N_HOR_LINE_CHARS=60;
            if ~self.isOnPath()
                horLineStr=['\n',repmat('-',1,N_HOR_LINE_CHARS),'\n'];
                msgStr=sprintf(['\n',horLineStr,...
                    '\nMPT is not found!!! \n',...
                    'Please put MPT into "externals\mpt" ',...
                    'folder next to "products" folder ',horLineStr]);
                modgen.common.throwerror('mptNotFound',msgStr);
            end
        end
        %
        function isVerb = getIsVerbosityEnabled(self)
            global MPTOPTIONS;
            checkIfSetUp(self);            
            isVerb = MPTOPTIONS.verbose > 1;
        end
        %
        function absTol = getAbsTol(self)
            global MPTOPTIONS;
            checkIfSetUp(self);            
            absTol = MPTOPTIONS.abs_tol;
        end
        %
        function relTol = getRelTol(self)
            global MPTOPTIONS;
            checkIfSetUp(self);            
            relTol = MPTOPTIONS.rel_tol;
        end
    end
end