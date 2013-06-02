classdef EllUnionTubeNotTightStaticProj < ...
        gras.ellapx.smartdb.rels.AEllTubeNotTight & ...
        gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
        %
        function checkDataConsistency(self)
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeNotTight(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllUnionTubeNotTight(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeNotTightProj(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj(self);
        end
        %
        function hVec=plotCreateReachTubeFunc(varargin)
            hVec=plotCreateReachTubeFunc@...
                gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj(varargin{:});
        end
        %
        function [cMat,cOpMat]=getGoodDirColor(varargin)
            [cMat,cOpMat]=getGoodDirColor@...
                gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj(varargin{:});
        end
        %
        function figureGroupKeyName=figureGetGroupKeyFunc(varargin)
            figureGroupKeyName=figureGetGroupKeyFunc@...
                gras.ellapx.smartdb.rels.AEllTubeNotTightProj(varargin{:});
        end
        %
        function figureSetPropFunc(varargin)
            figureSetPropFunc@...
                gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj(varargin{:});
        end
        %
        function hVec=axesSetPropBasicFunc(varargin)
            hVec=axesSetPropBasicFunc@...
                gras.ellapx.smartdb.rels.AEllTubeNotTightProj(varargin{:});
        end
        %
        function axesName=axesGetKeyTubeFunc(varargin)
            axesName=axesGetKeyTubeFunc@...
                gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj(varargin{:});
        end
        %
        function [patchColor,patchAlpha]=getPatchColorByApxType(varargin)
            [patchColor,patchAlpha]=getPatchColorByApxType@...
                gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj(varargin{:});
        end       
        %
        function fieldList=getPlotArgumentsFieldList(varargin)
            fieldList=getPlotArgumentsFieldList@...
                gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj(varargin{:});
        end
    end
    %
    methods
        function plObj=plot(varargin)
            plObj=plot@...
                gras.ellapx.smartdb.rels.AEllUnionTubeNotTightStaticProj(varargin{:});
        end
        %
        function self=EllUnionTubeNotTightStaticProj(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
    end
end