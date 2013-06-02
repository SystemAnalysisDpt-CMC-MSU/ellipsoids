classdef EllTubeFactory < handle
    properties(Access=private)
        isTight
    end
    %
    properties (Access=private,Constant,Hidden)
        DEFAULT_SCALE_FACTOR = 1
    end
    %
    methods
        function self = EllTubeFactory(ellTubeType)
            if nargin == 0
                self.isTight = true;
            else
                self.isTight = strcmp(ellTubeType, 'tight');
            end
        end
        %
        function ellTubeRel = fromEllArray(self, qEllArray, varargin)
            %
            % FROMELLARRAY  - creates a relation object using an array of ellipsoids
            %
            % Input:
            %   regular:
            %     qEllArray: ellipsoid[nDim1, nDim2, ..., nDimN] - array of ellipsoids
            %
            %   optional:
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %        object
            %
            nPoints = length(qEllArray);
            nDims = size(parameters(qEllArray(1)), 1);
            mArray = zeros(nDims,nDims,nPoints);
            ellTubeRel = self.fromEllMArray(qEllArray,mArray,varargin{:});
        end
        %
        function ellTubeRel = fromEllMArray(self, qEllArray, mArray, varargin)
            %
            % FROMELLMARRAY  - creates a relation object using an array of ellipsoids.
            %                  This method uses regularizer in the form of a matrix
            %                  function.
            %
            % Input:
            %   regular:
            %     qEllArray: ellipsoid[nDim1, nDim2, ..., nDimN] - array of ellipsoids
            %     ellMArr: double[nDim1, nDim2, ..., nDimN] - regularization ellipsoid
            %         matrices
            %
            %   optional:
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %          object
            %
            nPoints = length(qEllArray);
            nDims = size(parameters(qEllArray(1)), 1);
            qArray = zeros(nDims,nDims,nPoints);
            aMat = zeros(nDims,nPoints);
            arrayfun(@fCalcAMatAndQArray, 1:nPoints);
            %
            ellTubeRel = self.fromQMScaledArrays({qArray}, aMat,...
                {mArray},varargin{:},self.DEFAULT_SCALE_FACTOR);
            %
            function fCalcAMatAndQArray(iPoint)
                [aMat(:, iPoint), qArray(:,:,iPoint)] = ...
                    parameters(qEllArray(iPoint));
            end
        end
        %
        function ellTubeRel = fromQArrays(self, QArrayList, aMat, varargin)
            %
            % FROMQARRAYS  - creates a relation object using an array of ellipsoids,
            %                described by the array of ellipsoid matrices and
            %                array of ellipsoid centers.This method used default
            %                scale factor.
            %
            % Input:
            %   regular:
            %     QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            %         matrices
            %     aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers
            %
            % Optional:
            %    MArrayList:cell[1, nElem] - array of regularization ellipsoid matrices
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %        object
            %
            MArrayList = cellfun(@(x)zeros(size(x)),QArrayList,...
                'UniformOutput',false);
            ellTubeRel = self.fromQMScaledArrays(QArrayList,aMat,...
                MArrayList,varargin{:},self.DEFAULT_SCALE_FACTOR);
        end
        %
        function ellTubeRel = fromQMArrays(self, QArrayList, aMat, MArrayList,...
                varargin)
            %
            % FROMQMARRAYS  - creates a relation object using an array of ellipsoids,
            %                 described by the array of ellipsoid matrices and
            %                 array of ellipsoid centers. Also this method uses
            %                 regularizer in the form of a matrix function. This method
            %                 used default scale factor.
            %
            % Input:
            %   regular:
            %   QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            %         matrices
            %   aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers
            %   MArrayList: double[nDim1, nDim2, ..., nDimN] - ellipsoid  matrices of
            %         regularization
            %
            %  optional:
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %          object
            %
            ellTubeRel = self.fromQMScaledArrays(QArrayList,aMat,...
                MArrayList,varargin{:},self.DEFAULT_SCALE_FACTOR);
        end
        %
        function ellTubeRel = fromQMScaledArrays(self, QArrayList, aMat,...
                MArrayList, timeVec, ltGoodDirArray, sTime, approxType,...
                approxSchemaName, approxSchemaDescr, calcPrecision,...
                scaleFactorVec)
            %
            % FROMQMSCALEDARRAYS  - creates a relation object using an array of ellipsoids,
            %                       described by the array of ellipsoid matrices and
            %                       array of ellipsoid centers. Also this method uses
            %                       regularizer in the form of a matrix function.
            %
            %
            % Input:
            %   regular:
            %     QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            %         matrices
            %     aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers
            %     MArrayList: double[nDim1, nDim2, ..., nDimN] - ellipsoid matrices
            %               of regularization
            %     scaleFactor:double[1, 1] - tube scale factor
            %
            %  optional:
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %          object
            %
            import modgen.common.throwerror
            import gras.gen.SquareMatVector
            import gras.ellapx.smartdb.rels.EllTube
            import gras.ellapx.smartdb.rels.EllTubeNotTight
            import modgen.common.type.simple.checkgenext
            %
            checkgenext(['numel(x1)==numel(x2)&&isrow(x1)&&isrow(x2)',...
                '&&isrow(x3)&&isnumeric(x3)'],3,...
                QArrayList,MArrayList,scaleFactorVec);
            %
            indSTime=find(sTime==timeVec,1,'first');
            if isempty(indSTime)
                throwerror('wrongInput:sTimeOutOfBounds',...
                    'sTime is expected to be among elements of timeVec');
            end
            %
            nLDirs=length(QArrayList);
            %
            if length(scaleFactorVec) == 1
                scaleFactorVec=repmat(scaleFactorVec,1,nLDirs);
            end
            if length(approxType) == 1
                approxType=repmat(approxType,nLDirs,1);
            end
            if ~iscell(approxSchemaName)
                approxSchemaName=repmat({approxSchemaName},nLDirs,1);
            end
            if ~iscell(approxSchemaDescr)
                approxSchemaDescr=repmat({approxSchemaDescr},nLDirs,1);
            end
            %
            STubeData=struct;
            STubeData.QArray=QArrayList.';
            STubeData.aMat=repmat({aMat},nLDirs,1);
            STubeData.MArray=MArrayList.';
            STubeData.dim=repmat(size(aMat,1),nLDirs,1);
            STubeData.sTime=repmat(sTime,nLDirs,1);
            STubeData.indSTime=repmat(indSTime,nLDirs,1);
            STubeData.timeVec=repmat({timeVec},nLDirs,1);
            STubeData.approxType=approxType;
            STubeData.approxSchemaName=approxSchemaName;
            STubeData.approxSchemaDescr=approxSchemaDescr;
            STubeData.lsGoodDirVec=cell(nLDirs,1);
            STubeData.ltGoodDirMat=cell(nLDirs,1);
            STubeData.lsGoodDirNorm=zeros(nLDirs,1);
            STubeData.ltGoodDirNormVec=cell(nLDirs,1);
            STubeData.calcPrecision=repmat(calcPrecision,nLDirs,1);
            STubeData.scaleFactor=ones(nLDirs,1);
            %
            for iLDir=1:1:nLDirs
                lsGoodDirVec=ltGoodDirArray(:,iLDir,indSTime);
                ltGoodDirMat=squeeze(ltGoodDirArray(:,iLDir,:));
                %
                STubeData.ltGoodDirMat{iLDir}=ltGoodDirMat;
                STubeData.ltGoodDirNormVec{iLDir}=realsqrt(sum(...
                    ltGoodDirMat.*ltGoodDirMat,1));
                STubeData.lsGoodDirVec{iLDir}=lsGoodDirVec;
                STubeData.lsGoodDirNorm(iLDir)=...
                    realsqrt(sum(lsGoodDirVec.*lsGoodDirVec));
            end
            %
            if self.isTight
                STubeData = EllTube.scaleTubeData(STubeData,scaleFactorVec.');
                STubeData = EllTube.calcTouchCurveData(STubeData);
                ellTubeRel = EllTube(STubeData);
            else
                STubeData = EllTubeNotTight.scaleTubeData(STubeData,scaleFactorVec.');
                ellTubeRel = EllTubeNotTight(STubeData);
            end
        end
    end
end