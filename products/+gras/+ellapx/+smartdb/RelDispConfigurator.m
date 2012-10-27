classdef RelDispConfigurator<modgen.common.obj.StaticPropStorage
    methods (Static)
        function [propVal,isThere]=getProp(propName,varargin)
            branchName=mfilename('class');
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,varargin{:});
        end
        %
        function setProp(propName,propVal)
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        %
        function flush()
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.flushInternal(branchName);
        end
    end    
    %
    properties (Constant,GetAccess=private)
        DEFAULT_VIEW_ANGLE_VEC=[-37.5,30];
        IS_GOOD_CURVES_SEPARATELY=true;
    end
    methods (Static)
        function setViewAngleVec(viewAngleVec)
            gras.ellapx.smartdb.RelDispConfigurator.setProp(...
                'viewAngleVec',viewAngleVec);
        end
        function viewAngleVec=getViewAngleVec()
            import gras.ellapx.smartdb.RelDispConfigurator;
            [viewAngleVec,isSet]=RelDispConfigurator.getProp(...
                'viewAngleVec',true);
            if ~isSet
                viewAngleVec=RelDispConfigurator.DEFAULT_VIEW_ANGLE_VEC;
            end
        end
        function setIsGoodCurvesSeparately(isGoodCurvesSeparately)
            gras.ellapx.smartdb.RelDispConfigurator.setProp(...
                'isGoodCurvesSeparately',isGoodCurvesSeparately);            
        end
        function isGoodCurvesSeparately=getIsGoodCurvesSeparately()
            import gras.ellapx.smartdb.RelDispConfigurator;
            [isGoodCurvesSeparately,isSet]=...
                gras.ellapx.smartdb.RelDispConfigurator.getProp(...
                'isGoodCurvesSeparately',true);
            if ~isSet
                isGoodCurvesSeparately=RelDispConfigurator.IS_GOOD_CURVES_SEPARATELY;
            end
        end        
    end
end
