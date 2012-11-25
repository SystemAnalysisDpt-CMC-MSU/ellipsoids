classdef MatrixOperationsFactory<modgen.common.obj.StaticPropStorage
    properties (Constant,GetAccess=public)
        USE_SPLINE_INTERPOLATION = true;
        CONF_REPO_MGR_PROP='confRepoMgr';
    end
    methods(Static)
        function obj =create(timeVec)
            import gras.ellapx.uncertcalc.MatrixOperationsFactory;
            import modgen.common.throwerror;
            [crmObj,isThere]=MatrixOperationsFactory.getProp(...
                MatrixOperationsFactory.CONF_REPO_MGR_PROP);
            if ~isThere
                throwerror('confRepoMgrNotSet',['Configuration repo ',...
                    'manager is not set via setConfRepoMgr method']);
            end
            isSplineUsed=crmObj.getParam(...
                'genericProps.isSplineForMatrixCalcUsed');
            if isSplineUsed
                obj = gras.interp.SplineMatrixOperations(timeVec);
            else
                obj = gras.mat.fcnlib.CompositeMatrixOperations();
            end
        end
        function setConfRepoMgr(crmObj)
            import gras.ellapx.uncertcalc.MatrixOperationsFactory;
            MatrixOperationsFactory.setProp(...
                MatrixOperationsFactory.CONF_REPO_MGR_PROP,crmObj);
        end
    end
    methods (Static, Access=private)
        function [propVal,isThere]=getProp(propName,varargin)
            branchName=mfilename('class');
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,varargin{:});
        end
        function setProp(propName,propVal)
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        function flush()
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.flushInternal(branchName);
        end 
    end
end