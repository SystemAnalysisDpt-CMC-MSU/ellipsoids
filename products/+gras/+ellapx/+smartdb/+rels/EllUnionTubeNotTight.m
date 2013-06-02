classdef EllUnionTubeNotTight < ...
        gras.ellapx.smartdb.rels.AEllTubeNotTight & ...
        gras.ellapx.smartdb.rels.AEllUnionTubeNotTight & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    % EllUnionTubeNotTight - class which keeps ellipsoidal tubes by the instant of
    %               time
    %
    % Fields:
    %   QArray:cell[1, nElem] - Array of ellipsoid matrices
    %   aMat:cell[1, nElem] - Array of ellipsoid centers
    %   scaleFactor:double[1, 1] - Tube scale factor
    %   MArray:cell[1, nElem] - Array of regularization ellipsoid matrices
    %   dim :double[1, 1] - Dimensionality
    %   sTime:double[1, 1] - Time s
    %   approxSchemaName:cell[1,] - Name
    %   approxSchemaDescr:cell[1,] - Description
    %   approxType:gras.ellapx.enums.EApproxType - Type of approximation
    %                 (external, internal, not defined
    %   timeVec:cell[1, m] - Time vector
    %   calcPrecision:double[1, 1] - Calculation precision
    %   indSTime:double[1, 1]  - index of sTime within timeVec
    %   ltGoodDirMat:cell[1, nElem] - Good direction curve
    %   lsGoodDirVec:cell[1, nElem] - Good direction at time s
    %   ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve
    %   lsGoodDirNorm:double[1, 1] - Norm of good direction at time s
    %   ellUnionTimeDirection:gras.ellapx.enums.EEllUnionTimeDirection -
    %                      Direction in time along which union is performed
    %
    % TODO: correct description of the fields in
    %     gras.ellapx.smartdb.rels.EllUnionTubeNotTight
    %
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
        %
        function checkDataConsistency(self)
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeNotTight(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllUnionTubeNotTight(self);
        end
    end
    %
    methods
        function self=EllUnionTubeNotTight(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
        %
        function [ellTubeProjRel,indProj2OrigVec]=project(self,projType,...
                varargin)
            import gras.ellapx.smartdb.rels.EllUnionTubeNotTightStaticProj;
            import gras.ellapx.enums.EProjType;
            import modgen.common.throwerror;
            %
            if self.getNTuples()>0
                if projType~=EProjType.Static
                    throwerror('wrongInput',...
                        'only projections on Static subspace are supported');
                end
                
                [SProjData,indProj2OrigVec]=self.projectInternal(...
                    projType,varargin{:});
                projRel=smartdb.relations.DynamicRelation(SProjData);
                projRel.catWith(self.getTuples(indProj2OrigVec),...
                    'duplicateFields','useOriginal');
                ellTubeProjRel=EllUnionTubeNotTightStaticProj(projRel);
            else
                ellTubeProjRel=EllUnionTubeNotTightStaticProj();
            end
        end
    end
    %
    methods (Static)
        function ellUnionTubeRel=fromEllTubes(ellTubeRel)
            % FROMELLTUBES - returns union of the ellipsoidal tubes on time
            %
            % Input:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1]/
            %       smartdb.relation.DynamicRelation[1, 1] - relation
            %       object
            %
            % Output:
            % ellUnionTubeRel: ellapx.smartdb.rel.EllUnionTubeNotTight - union of the
            %             ellipsoidal tubes
            %
            import gras.ellapx.smartdb.rels.EllUnionTubeNotTight
            import gras.ellapx.smartdb.rels.AEllUnionTubeNotTight
            %
            SData = AEllUnionTubeNotTight.fromEllTubesInternal(ellTubeRel);
            ellUnionTubeRel = EllUnionTubeNotTight(SData);
        end
    end
end