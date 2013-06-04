classdef EllUnionTubeStaticProj < ...
        gras.ellapx.smartdb.rels.AEllTube & ...
        gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    %   TODO: correct description of the fields in
    %     gras.ellapx.smartdb.rels.EllUnionTubeStaticProj
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
        %
        function checkDataConsistency(self)
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTube(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllUnionTube(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeProj(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(self);
        end
        %
        function dependencyFieldList=getTouchCurveDependencyFieldList(varargin)
            dependencyFieldList=getTouchCurveDependencyFieldList@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function hVec=plotCreateReachTubeFunc(varargin)
            hVec=plotCreateReachTubeFunc@...
                gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(varargin{:});
        end
        %
        function hVec=plotCreateTubeTouchCurveFunc(varargin)
            hVec=plotCreateTubeTouchCurveFunc@...
                gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(varargin{:});
        end
        %
        function [cMat,cOpMat]=getGoodDirColor(varargin)
            [cMat,cOpMat]=getGoodDirColor@...
                gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(varargin{:});
        end
        %
        function figureGroupKeyName=figureGetGroupKeyFunc(varargin)
            figureGroupKeyName=figureGetGroupKeyFunc@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function figureSetPropFunc(varargin)
            figureSetPropFunc@...
                gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(varargin{:});
        end
        %
        function hVec=axesSetPropBasicFunc(varargin)
            hVec=axesSetPropBasicFunc@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function axesName=axesGetKeyTubeFunc(varargin)
            axesName=axesGetKeyTubeFunc@...
                gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(varargin{:});
        end
        %
        function [patchColor,patchAlpha]=getPatchColorByApxType(varargin)
            [patchColor,patchAlpha]=getPatchColorByApxType@...
                gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(varargin{:});
        end
        %
        function checkTouchCurves(varargin)
            checkTouchCurves@...
                gras.ellapx.smartdb.rels.AEllTubeProj(varargin{:});
        end
        %
        function fieldList=getPlotArgumentsFieldList(varargin)
            fieldList=getPlotArgumentsFieldList@...
                gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(varargin{:});
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
            % ellUnionTubeRel: ellapx.smartdb.rel.EllUnionTubeStaticProj - union of the
            %             ellipsoidal tubes
            %
            import gras.ellapx.smartdb.rels.EllUnionTubeStaticProj
            %
            SData = EllUnionTubeStaticProj.fromEllTubesInternal(ellTubeRel);
            ellUnionTubeRel = EllUnionTubeStaticProj(SData);
        end
    end
    %
    methods
        function plObj=plot(varargin)
            plObj=plot@...
                gras.ellapx.smartdb.rels.AEllUnionTubeStaticProj(varargin{:});
        end
        %
        function self=EllUnionTubeStaticProj(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
    end
end