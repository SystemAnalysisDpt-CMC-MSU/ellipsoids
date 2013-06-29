classdef SuiteTri < mlunitext.test_case
    properties(Access=private)
        rootDataDir
    end
    properties (Constant, GetAccess=private)
        TRI1_VERT=[1 0 0;0 1 0;0 0 1];
        TRI1_FACE=[1 2 3];        
        %
        TRI2_VERT=[1 0 0;0 1 0;0 0 1;1 0 1];
        TRI2_FACE=[1 2 3;1 3 4;1 2 4;2 3 4];
        %
        TRI3_VERT=[0 0 0;1 0 0;0 1 0;-0.5 0 0;0 -0.5 0];
        TRI3_FACE=[1 2 3;1 3 4;1 5 2];
        TRI3_EDGE=[1 2;1 3;1 4;1 5;2 3;2 5;3 4];
        TRI3_F2E=[1 5 2;2 7 3;4 6 1];
        TRI3_F2E_DIR=[true true true;true true true;true false true];
        
        %
        TRI31_VERT=[0 0 0;1 0 0;0 1 0;-0.5 0 0];
        TRI31_FACE=[1 2 3;1 3 4];        
    end
    methods
        function dirName=getDataDir(self)
            dirName=[self.rootDataDir,filesep,self.name];
        end
        function S=loadData(self,fileName)
            S=load([self.getDataDir,filesep,fileName]);
        end
        %
        function S=saveData(self,fileName,SInp)
            save([self.getDataDir,filesep,fileName],'-struct','SInp');
        end
        %
        function self = SuiteTri(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self.rootDataDir=[fileparts(mfilename('fullpath')),...
                filesep,'TestData'];
        end
        %
        function self = set_up_param(self,varargin)
        end
        function testShrinkFaceTriOneFace(self)
            vMat=self.TRI1_VERT;
            fMat=self.TRI1_FACE;
            [v1Mat,f1Mat]=self.aux_shrinkfacetri(vMat,fMat,0,1);
            v1ExpMat=[1 0 0;0 1 0;0 0 1;0.5 0.5 0;0.5 0 0.5;0 0.5 0.5];
            f1ExpMat=[4 6 5;4 5 1;6 4 2;5 6 3];
            mlunitext.assert_equals(true,isequal(v1Mat,v1ExpMat));
            mlunitext.assert_equals(true,isequal(f1Mat,f1ExpMat));
            fMat=[3 2 1];
            [~,~]=self.aux_shrinkfacetri(vMat,fMat,0,1);
            fMat=[2 3 1];
            [~,~]=self.aux_shrinkfacetri(vMat,fMat,0,1);
            fMat=[3 1 2];
            [~,~]=self.aux_shrinkfacetri(vMat,fMat,0,1);
            [~,~]=self.aux_shrinkfacetri(vMat,fMat,0,4);
            %
        end
        function testShrinkFaceTri3Faces(self)
            vMat=self.TRI2_VERT;
            fMat=self.TRI2_FACE;
            [~,~]=self.aux_shrinkfacetri(vMat,fMat,0,2);
        end
        %
        function testShrinkFaceTri2Face1Part(self)
            vMat=self.TRI31_VERT;
            fMat=self.TRI31_FACE;
            [~,~]=self.aux_shrinkfacetri(vMat,fMat,realsqrt(2)-0.001,1);
        end
        %
        function testShrinkFaceTri3Face1Part(self)
            import gras.geom.tri.*;
            vMat=self.TRI3_VERT;
            fMat=self.TRI3_FACE;
            [v1Mat,f1Mat]=self.aux_shrinkfacetri(vMat,fMat,realsqrt(2)-0.001,...
                1,@(x)(x+repmat([0 0 0.2],size(x,1),1)));
            %
            %patch('Vertices',v1Mat,'Faces',f1Mat,'FaceColor','g',...
            %    'EdgeColor','black')
            %
            isFaceThereVec=isface(v1Mat,f1Mat,[1 6 2;1 7 3]);
            mlunitext.assert_equals(true,all(isFaceThereVec));
            %
            [v2Mat,f2Mat]=self.aux_shrinkfacetri(v1Mat,f1Mat,0,...
                3,@(x)(x+repmat([0 0 0.2],size(x,1),1)));            
        end
        %
        function testIsFace(self)
            import gras.geom.tri.*;
            %
            vMat=self.TRI3_VERT;
            fMat=self.TRI3_FACE;
            isFaceThereVec=isface(vMat,fMat,[1 5 4;fMat;2 5 4]);
            mlunitext.assert_equals(true,isequal(isFaceThereVec,...
                [false;true;true;true;false]));
        end
        %
        function testMapFace2Edge(self)
            import gras.geom.tri.*;
            vMat=self.TRI3_VERT;
            fMat=self.TRI3_FACE;
            eExpMat=self.TRI3_EDGE;
            f2eExpMat=self.TRI3_F2E;
            f2eExpIsDirMat=self.TRI3_F2E_DIR;
            [eMat,f2eMat,f2eIsDirMat] = mapface2edge(vMat,fMat);
            mlunitext.assert_equals(true,isequal(eMat,eExpMat));
            mlunitext.assert_equals(true,isequal(f2eMat,f2eExpMat));
            mlunitext.assert_equals(true,isequal(f2eIsDirMat,f2eExpIsDirMat));
        end
        %
        function testShrinkFaceTri(self)
            MAX_DIST=0.5;
            N_DATA_SETS=2;
            for iDataSet=N_DATA_SETS:-1:1
                SInp=self.loadData(['inp',num2str(iDataSet)]);
                [v0Mat,f0Mat]=deal(SInp.v0,SInp.f0);
                [v1Mat,f1Mat]=shrink(v0Mat,f0Mat);
                %% check that no vertices is deleted
                isOldVertsKept=all(ismember(v0Mat,v1Mat,'rows'));
                mlunitext.assert_equals(true,isOldVertsKept);
                %% check that all edges are short enough
                tr=TriRep(f1Mat,v1Mat);
                e1Mat=tr.edges();
                dMat=v1Mat(e1Mat(:,1),:)-v1Mat(e1Mat(:,2),:);
                maxEdgeLength=max(realsqrt(sum(dMat.*dMat,2)));
                mlunitext.assert_equals(true,maxEdgeLength<=MAX_DIST);
                %% regression test
                [SOut.v0,SOut.f0]=deal(v1Mat,f1Mat);
                %
                %self.saveData(['out',num2str(iDataSet)],SOut);
                %
                SEOut=self.loadData(['out',num2str(iDataSet)]);
                mlunitext.assert_equals(true,isequal(SOut,SEOut));
            end
            function [v1Mat,f1Mat]=shrink(v0Mat,f0Mat)
                import gras.geom.tri.*;
                %% shrink faces
                [v1Mat,f1Mat,S1Stat]=self.aux_shrinkfacetri(v0Mat,...
                    f0Mat,MAX_DIST);
                %% Perform additional checks
                [v2Mat,f2Mat,S2Stat]=self.aux_shrinkfacetri(v0Mat,...
                    f0Mat,MAX_DIST,S1Stat.nSteps);
                mlunitext.assert_equals(true,isequal(v1Mat,v2Mat));
                mlunitext.assert_equals(true,isequal(f1Mat,f2Mat));
                mlunitext.assert_equals(true,isequal(S1Stat,S2Stat));
                %
                checkStepWise(v0Mat,f0Mat,0,3);
                checkStepWise(v0Mat,f0Mat,MAX_DIST);
            end
            function checkStepWise(vInpMat,fInpMat,maxTol,varargin)
                import gras.geom.tri.*;
                MAX_TOL=1e-14;
                [vResMat,fResMat,SStat]=self.aux_shrinkfacetri(vInpMat,...
                    fInpMat,maxTol,varargin{:});
                nSteps=SStat.nSteps;
                if nSteps>1
                    [v1Mat,f1Mat,S1Stat]=self.aux_shrinkfacetri(vInpMat,...
                        fInpMat,maxTol,nSteps-1);
                    [v2Mat,f2Mat,S2Stat]=self.aux_shrinkfacetri(v1Mat,...
                        f1Mat,maxTol,1);
                    [isPos,reportStr]=istriequal(vResMat,fResMat,...
                        v2Mat,f2Mat,MAX_TOL);
                    mlunitext.assert_equals(true,isPos,reportStr);
                end
            end
        end
        %
        function [vMat,fMat,SStats]=aux_shrinkfacetri(~,vMat,fMat,varargin)
            import gras.geom.tri.*;
            [vMat,fMat,SStats,eMat,f2eMat]=shrinkfacetri(...
                vMat,fMat,varargin{:});
            nEdges=size(eMat,1);
            mlunitext.assert_equals(nEdges,length(unique(f2eMat)));
        end
        function testSphereTri(~)
            MAX_TOL=1e-13;
            MAX_DEPTH=4;
            for curDepth=1:MAX_DEPTH
                check(curDepth);
            end
            
            function check(depth)
                [v0,f0]=gras.geom.tri.spheretri(depth);
                checkRegress(v0,f0,depth-1);
                checkVert(v0);
                %
                [v1,f1]=gras.geom.tri.spheretri(depth+1);
                checkRegress(v1,f1,depth);
                checkVert(v1);
                [cf0,vol0]=convhull(v0);
                [cf1,vol1]=convhull(v1);
                mlunitext.assert_equals(true,vol1>vol0);
                mlunitext.assert_equals(true,vol1<pi*4/3);
                mlunitext.assert_equals(true,size(cf0,1)*4==size(cf1,1));
                %
                function checkRegress(v1,f1,depth)
                    [vReg1,fReg1]=gras.geom.tri.test.srebuild3d(depth);
                    checkVert(vReg1);
                    vReg1=vReg1./repmat(realsqrt(sum(vReg1.*vReg1,2)),1,3);
                    [isPos,reportStr]=gras.geom.tri.istriequal(...
                        vReg1,fReg1,v1,f1,MAX_TOL);
                    mlunitext.assert_equals(true,isPos,reportStr);
                end
                function checkVert(v)
                    normVec=realsqrt(sum(v.*v,2));
                    isPos=max(abs(normVec-1))<=MAX_TOL;
                    mlunitext.assert_equals(true,isPos,...
                        'not all vertices are on the unit sphere');
                end
                
            end
        end
        function testSphereTriExt(~)
            import gras.geom.tri.spheretriext
            dim = 2;
            N_POINTS = 500;
            RIGHT_POINTS_3D = 642;
            [vMat ~] = spheretriext(dim, N_POINTS);
            mlunitext.assert_equals(size(vMat,1),N_POINTS);
            dim = 3;
            [vMat ~] = spheretriext(dim, N_POINTS);
            mlunitext.assert_equals(size(vMat,1),RIGHT_POINTS_3D);
        end
        function testEllTube2Tri(~)
            import gras.geom.tri.elltube2tri
            xMat = [0 0 0; 0 0 1; 0 1 0;1 0 0; 1 0 1; 1 1 0];
            fMat = elltube2tri(3,2);
            patch('Vertices', xMat,'Faces',fMat,'FaceColor',[1 0 0]);
            close all;
        end
        function testEllTubeDiscrTri(~)
            import gras.geom.tri.elltubediscrtri
            xMat = [0 0 0; 0 0 1; 0 1 0;1 0 0; 1 0 1; 1 1 0];
            fMat = elltubediscrtri(3,2);
            patch('Vertices', xMat,'Faces',fMat,'FaceColor',[1 0 0]);
            close all;
        end
    end
end