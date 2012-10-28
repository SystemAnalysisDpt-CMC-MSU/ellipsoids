classdef F
    %Standard fields
    properties (Constant)
        DIM='dim'
        DIM_D='Dimensionality';
        DIM_T={'double'}
        %
        Q_ARRAY='QArray'
        Q_ARRAY_D='Array of ellipsoid matrices';
        Q_ARRAY_T={'cell','double'}
        %
        M_ARRAY='MArray'
        M_ARRAY_D='Array of regularization ellipsoid matrices ';
        M_ARRAY_T={'cell','double'}        
        %
        A_MAT='aMat'
        A_MAT_D='Array of ellipsoid centers';
        A_MAT_T={'cell','double'}
        %
        APPROX_SCHEMA_NAME='approxSchemaName'
        APPROX_SCHEMA_NAME_D='Name';
        APPROX_SCHEMA_NAME_T={'cell','char'}
        %
        APPROX_SCHEMA_DESCR='approxSchemaDescr'
        APPROX_SCHEMA_DESCR_D='Description';
        APPROX_SCHEMA_DESCR_T={'cell','char'}
        %
        APPROX_TYPE='approxType';
        APPROX_TYPE_D='Type of approximation (external, internal, not defined';
        APPROX_TYPE_T={'gras.ellapx.enums.EApproxType'};
        %
        PROJ_TYPE='projType';
        PROJ_TYPE_D='Projection type';
        PROJ_TYPE_T={'gras.ellapx.enums.EProjType'};
        %
        V_MAT='vMat'
        V_MAT_D='Vertices matrix';
        V_MAT_T={'cell','double'}
        %
        F_MAT='fMat'
        F_MAT_D='Face matrix';
        F_MAT_T={'cell','double'}
        %
        PROJ_S_DIM_VEC='projSpecDimVec';
        PROJ_S_DIM_VEC_D='Dimensions on which projection is performed at time s';
        PROJ_S_DIM_VEC_T={'cell','logical'};
        %
        PROJ_MAT_ARRAY='projMatArray';
        PROJ_MAT_ARRAY_D='Array of projection matrices for each time moment';
        PROJ_MAT_ARRAY_T={'cell','double'};
        %
        LS_GOOD_DIR_VEC='lsGoodDirVec';
        LS_GOOD_DIR_VEC_D='Good direction at time s';
        LS_GOOD_DIR_VEC_T={'cell','double'};
        %
        LT_GOOD_DIR_MAT='ltGoodDirMat';
        LT_GOOD_DIR_MAT_D='Good direction curve';
        LT_GOOD_DIR_MAT_T={'cell','double'};
        %
        S_TIME='sTime';
        S_TIME_D='Time s';
        S_TIME_T={'double'};
        %
        IND_S_TIME='indSTime';
        IND_S_TIME_D='index of sTime within timeVec';
        IND_S_TIME_T={'double'};
        %
        XS_TOUCH_VEC='xsTouchVec';
        XS_TOUCH_VEC_D='Touch point at time s';
        XS_TOUCH_VEC_T={'cell','double'};
        %
        XS_TOUCH_OP_VEC='xsTouchOpVec';
        XS_TOUCH_OP_VEC_D='Touch point at time s';
        XS_TOUCH_OP_VEC_T={'cell','double'};
        %
        X_TOUCH_CURVE_MAT='xTouchCurveMat';
        X_TOUCH_CURVE_MAT_D='Touch point curve for good direction';
        X_TOUCH_CURVE_MAT_T={'cell','double'};
        %
        X_TOUCH_OP_CURVE_MAT='xTouchOpCurveMat';
        X_TOUCH_OP_CURVE_MAT_D=...
            'Touch point curve for direction opposite to good direction';
        X_TOUCH_OP_CURVE_MAT_T={'cell','double'};
        %
        TIME_VEC='timeVec';
        TIME_VEC_D='Time vector';
        TIME_VEC_T={'cell','double'};
        %
        LT_GOOD_DIR_NORM_VEC='ltGoodDirNormVec';
        LT_GOOD_DIR_NORM_VEC_D='Norm of good direction curve';
        LT_GOOD_DIR_NORM_VEC_T={'cell','double'};
        %
        LS_GOOD_DIR_NORM='lsGoodDirNorm';
        LS_GOOD_DIR_NORM_D='Norm of good direction at time s';
        LS_GOOD_DIR_NORM_T={'double'};
        %
        LT_GOOD_DIR_NORM_ORIG_VEC='ltGoodDirNormOrigVec';
        LT_GOOD_DIR_NORM_ORIG_VEC_D='Norm of the original (not projected) good direction curve';
        LT_GOOD_DIR_NORM_ORIG_VEC_T={'cell','double'};
        %
        LS_GOOD_DIR_NORM_ORIG='lsGoodDirNormOrig';
        LS_GOOD_DIR_NORM_ORIG_D='Norm of the original (not projected) good direction at time s';
        LS_GOOD_DIR_NORM_ORIG_T={'double'};
        %
        LS_GOOD_DIR_ORIG_VEC='lsGoodDirOrigVec';
        LS_GOOD_DIR_ORIG_VEC_D='Original (not projected) good direction at time s';
        LS_GOOD_DIR_ORIG_VEC_T={'cell','double'};
        %
        CALC_PRECISION='calcPrecision';
        CALC_PRECISION_D='Calculation precision';
        CALC_PRECISION_T={'double'};
        %
        ELL_UNION_TIME_DIRECTION='ellUnionTimeDirection';
        ELL_UNION_TIME_DIRECTION_D='Direction in time along which union is performed';
        ELL_UNION_TIME_DIRECTION_T={'gras.ellapx.enums.EEllUnionTimeDirection'};
        %
        IS_LS_TOUCH='isLsTouch';
        IS_LS_TOUCH_D='Indicates whether a touch takes place along LS';
        IS_LS_TOUCH_T={'logical'};
        %
        IS_LS_TOUCH_OP='isLsTouchOp';
        IS_LS_TOUCH_OP_D='Indicates whether a touch takes place along LS opposite';
        IS_LS_TOUCH_OP_T={'logical'};
        %
        %
        IS_LT_TOUCH_VEC='isLtTouchVec';
        IS_LT_TOUCH_VEC_D='Indicates whether a touch takes place along LT';
        IS_LT_TOUCH_VEC_T={'cell','logical'};
        %
        IS_LT_TOUCH_OP_VEC='isLtTouchOpVec';
        IS_LT_TOUCH_OP_VEC_D='Indicates whether a touch takes place along LT opposite';
        IS_LT_TOUCH_OP_VEC_T={'cell','logical'};
        %
        TIME_TOUCH_END_VEC='timeTouchEndVec';
        TIME_TOUCH_END_VEC_D='Touch point curve for good direction';
        TIME_TOUCH_END_VEC_T={'cell','double'};
        %
        TIME_TOUCH_OP_END_VEC='timeTouchOpEndVec';
        TIME_TOUCH_OP_END_VEC_D='Touch point curve for good direction';
        TIME_TOUCH_OP_END_VEC_T={'cell','double'};
        %
        %
        SCALE_FACTOR='scaleFactor';
        SCALE_FACTOR_D='Tube scale factor';
        SCALE_FACTOR_T={'double'};        
    end
    methods (Static)
        function nameList=getNameList(idList)
            import gras.ellapx.smartdb.F;
            nameList=cell(size(idList));
            for iDescr=1:length(idList)
                nameList{iDescr}=F.(idList{iDescr});
            end
        end
        function descrList=getDescrList(idList)
            import gras.ellapx.smartdb.F;
            descrList=cell(size(idList));
            for iDescr=1:length(descrList)
                descrList{iDescr}=F.([idList{iDescr},'_D']);
            end
        end
        function typeSpecList=getTypeSpecList(idList)
            import gras.ellapx.smartdb.F;
            typeSpecList=cell(size(idList));
            for iType=1:length(typeSpecList)
                typeSpecList{iType}=F.([idList{iType},'_T']);
            end
        end
        function [nameList,descrList,typeSpecList]=getDefs(idList,...
                addNameCMat,isAddedToEnd)
            import gras.ellapx.smartdb.F;
            import modgen.common.type.simple.lib.*;
            import modgen.common.type.simple.checkgen;
            %
            if nargin<3
                isAddedToEnd=true;
                if nargin<2
                    addNameCMat=cell(3,0);
                end
            end
            nameList=F.getNameList(idList);
            descrList=F.getDescrList(idList);
            typeSpecList=F.getTypeSpecList(idList);
            %
            checkgen(addNameCMat,@(x)size(x,1)==3);
            checkgen(addNameCMat(1:2,:),@(x)iscellofstring(x));
            checkgen(addNameCMat(3,:),@(x)all(cellfun(@iscellofstring,x)));
            if isAddedToEnd
                nameList=[nameList,addNameCMat(1,:)];
                descrList=[descrList,addNameCMat(2,:)];
                typeSpecList=[typeSpecList,addNameCMat(3,:)];
            else
                nameList=[addNameCMat(1,:),nameList];
                descrList=[addNameCMat(2,:),descrList];
                typeSpecList=[addNameCMat(3,:),typeSpecList];
            end
        end
    end
end
