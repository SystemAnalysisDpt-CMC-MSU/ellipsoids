classdef EllTubeNotTightProj < ...
        gras.ellapx.smartdb.rels.AEllTubeNotTight & ...
        gras.ellapx.smartdb.rels.AEllTubeNotTightProj & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
        %
        function checkDataConsistency(self)
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeNotTight(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeNotTightProj(self);
        end
        %
        function dependencyFieldList=getTouchCurveDependencyFieldList(varargin)
            dependencyFieldList=getTouchCurveDependencyFieldList@...
                gras.ellapx.smartdb.rels.AEllTubeNotTightProj(varargin{:});
        end
        %
        function figureGroupKeyName=figureGetGroupKeyFunc(varargin)
            figureGroupKeyName=figureGetGroupKeyFunc@...
                gras.ellapx.smartdb.rels.AEllTubeNotTightProj(varargin{:});
        end
        %
        function figureSetPropFunc(varargin)
            figureSetPropFunc@...
                gras.ellapx.smartdb.rels.AEllTubeNotTightProj(varargin{:});
        end
        %
        function hVec=axesSetPropBasicFunc(varargin)
            hVec=axesSetPropBasicFunc@...
                gras.ellapx.smartdb.rels.AEllTubeNotTightProj(varargin{:});
        end
    end
    %
    methods
        function plObj=plot(varargin)
            plObj=plot@...
                gras.ellapx.smartdb.rels.AEllTubeNotTightProj(varargin{:});
        end
        %
        function self=EllTubeNotTightProj(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(varargin{:}); 
        end
    end
end