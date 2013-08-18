classdef EllipsoidTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self=EllipsoidTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData', filesep,shortClassName];
        end
        %
        function testRepMat(~)
            shMat=eye(2);
            ell=ellipsoid(shMat);
            ellVec=ell.repMat(2,4);
            ellVec(1).shape(2);
            mlunitext.assert(isequal(ellVec(2).getShapeMat,shMat));
        end
        %
        function testConstructorProps(~)
            nDims=3;
            absTol=1e-7;
            relTol=1e-4;
            nPlot2dPoints=100;
            nPlot3dPoints=200;
            %
            getterList={@getNPlot2dPoints,@getNPlot3dPoints,@getAbsTol,...
                @getRelTol};
            %
            propNameList={'nPlot2dPoints','nPlot3dPoints','absTol',...
                'relTol'};
            valList={nPlot2dPoints,nPlot3dPoints,absTol,relTol};
            check([2 3 1 4]);
            check(1);
            check([1 2]);
            check([2 3]);
            check([2 3]);
            check([1 4]);
            function check(indVec)
                propNameValCMat=[propNameList(indVec);valList(indVec)];
                %
                checkForSize([]);
                checkForSize([2 3 4]);
                %
                function checkForSize(ellArrSizeVec)
                    sizeList=num2cell(ellArrSizeVec);
                    shCArr=arrayfun(@(x)genPosMat(nDims),...
                        ones(sizeList{:}),'UniformOutput',false);
                    shArr=cell2mat(shiftdim(shCArr,-2));
                    ellArr=ellipsoid(shArr,propNameValCMat{:});
                    checkShape();
                    checkProp();
                    ellArr=ellArr.getCopy();
                    checkShape();
                    checkProp();
                    if isempty(ellArrSizeVec)
                        ellArrSizeVec=[ellArrSizeVec, 1];
                    end
                    centArr=rand([nDims ellArrSizeVec]);
                    centCArr=shiftdim(num2cell(centArr,1),1);
                    ellArr=ellipsoid(centArr,shArr,propNameValCMat{:});
                    checkCenter();
                    checkShape();
                    checkProp();
                    ellArr=ellArr.getCopy();
                    checkCenter();
                    checkShape();
                    checkProp();
                    function resMat=genPosMat(nDims)
                        randMat=rand(nDims);
                        resMat=eye(nDims)+randMat*randMat.';
                    end
                    function checkCenter()
                        isOkArr=arrayfun(@(x,y)isequal(x.getCenterVec(),...
                            y{1}),ellArr,centCArr);
                        mlunitext.assert(all(isOkArr(:)));
                    end
                    %
                    function checkShape()
                        isOkArr=arrayfun(@(x,y)isequal(x.getShapeMat(),...
                            y{1}),ellArr,shCArr);
                        mlunitext.assert(all(isOkArr(:)));
                    end
                    function checkProp()
                        arrayfun(@checkPropElem,ellArr);
                    end
                end
                function checkPropElem(ell)
                    nProps=length(indVec);
                    for iProp=1:nProps
                        fGetter=getterList{indVec(iProp)};
                        propVal=feval(fGetter,ell);
                        expPropVal=valList{indVec(iProp)};
                        mlunitext.assert(isequal(propVal,expPropVal));
                    end
                end
            end
        end
        %
        function self = testDistance(self)
            
            import elltool.conf.Properties;
            load(strcat(self.testDataRootDir,filesep,'testEllEllRMat.mat'),...
                'testOrth50Mat','testOrth100Mat','testOrth3Mat','testOrth2Mat');
            %
            %testing vector-ellipsoid distance
            %
            %distance between ellipsoid and two vectors
            absTol = Properties.getAbsTol();
            testEllipsoid = ellipsoid([1,0,0;0,5,0;0,0,10]);
            testPointMat = [3,0,0; 5,0,0].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunitext.assert_equals(true, (abs(testResVec(1)-2)<absTol) &&...
                (abs(testResVec(2)-4)<absTol));
            %
            %distance between ellipsoid and point in the ellipsoid
            %and point on the boader of the ellipsoid
            testEllipsoid = ellipsoid([1,2,3].',4*eye(3,3));
            testPointMat = [2,3,2; 1,2,5].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunitext.assert_equals(true, testResVec(1)==-1 && testResVec(2)==0);
            %
            %distance between two ellipsoids and two vectors
            testEllipsoidVec = [ellipsoid([5,2,0;2,5,0;0,0,1]),...
                ellipsoid([0,0,5].',[4, 0, 0; 0, 9 , 0; 0,0, 25])];
            testPointMat = [0,0,5; 0,5,5].';
            testResVec = distance(testEllipsoidVec, testPointMat);
            mlunitext.assert_equals(true, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %distance between two ellipsoids and a vector
            testEllipsoidVec = [ellipsoid([5,5,0].',[1,0,0;0,5,0;0,0,10]),...
                ellipsoid([0,10,0].',[10, 0, 0; 0, 16 , 0; 0,0, 5])];
            testPointVec = [0,5,0].';
            testResVec = distance(testEllipsoidVec, testPointVec);
            mlunitext.assert_equals(true, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-1)<absTol));
            %
            %negative test: matrix shapeMat of ellipsoid has very large
            %eigenvalues.
            testEllipsoid = ellipsoid([1e+15,0;0,1e+15]);
            testPointVec = [3e+15,0].';
            self.runAndCheckError('distance(testEllipsoid, testPointVec)',...
                'notSecant');
            %
            %random ellipsoid matrix, low dimension case
            nDim=2;
            testEllMat=diag(1:2);
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=ellipsoid(testEllMat);
            testPoint=testOrth2Mat*[10;zeros(nDim-1,1)];
            testRes=distance(testEllipsoid, testPoint);
            mlunitext.assert_equals(true,abs(testRes-9)<absTol);
            %
            %high dimensional tests with rotated ellipsoids
            nDim=50;
            testEllMat=diag(nDim:-1:1);
            testEllMat=testOrth50Mat*testEllMat*testOrth50Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=ellipsoid(testEllMat);
            testPoint=testOrth50Mat*[zeros(nDim-1,1);10];
            testRes=distance(testEllipsoid, testPoint);
            mlunitext.assert_equals(true,abs(testRes-9)<absTol);
            
            %distance between two ellipsoids with random matrices and two vectors
            testEll1Mat=[5,2,0;2,5,0;0,0,1];
            testEll1Mat=testOrth3Mat*testEll1Mat*testOrth3Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=[4,0,0;0,9,0;0,0,25];
            testEll2Mat=testOrth3Mat*testEll2Mat*testOrth3Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth3Mat*[0;0;5];
            testEllipsoidVec = [ellipsoid(testEll1Mat),...
                ellipsoid(testEll2CenterVec,testEll2Mat)];
            testPointMat = testOrth3Mat*([0,0,5; 0,5,5].');
            testResVec = distance(testEllipsoidVec, testPointMat);
            mlunitext.assert_equals(true, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %
            %
            %
            %Testing ellipsoid-ellipsoid distance
            %
            %distance between two ellipsoids
            testEllipsoid1 = ellipsoid([25,0;0,9]);
            testEllipsoid2 = ellipsoid([10;0],[4,0;0,9]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true, (abs(testRes-3)<absTol));
            %
            testEllipsoid1 = ellipsoid([0,-15,0].',[25,0,0;0,100,0;0,0,9]);
            testEllipsoid2 = ellipsoid([0,7,0].',[9,0,0;0,25,0;0,0,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true, (abs(testRes-7)<absTol));
            %
            % case of ellipses with common center
            testEllipsoid1 = ellipsoid([1 2 3].',[1,2,5;2,5,3;5,3,100]);
            testEllipsoid2 = ellipsoid([1,2,3].',[1,2,7;2,10,5;7,5,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true, (abs(testRes)<absTol));
            %
            % distance between two pairs of ellipsoids
            testEllipsoid1Vec=[ellipsoid([0, -6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,-4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testEllipsoid2Vec=[ellipsoid([0, 6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec);
            mlunitext.assert_equals(true, (abs(testResVec(1)-8)<absTol) &&...
                (abs(testResVec(2)-5)<absTol));
            %
            % distance between two ellipsoids and an ellipsoid
            testEllipsoidVec=[ellipsoid([0, 0, 0].',[9,0,0; 0,25,0; 0,0, 1]),...
                ellipsoid([-5,0,0].',[9,0,0; 0, 25,0; 0,0,1])];
            testEllipsoid=ellipsoid([5, 0, 0].',[25,0,0; 0,100,0; 0,0, 1]);
            testResVec=distance(testEllipsoidVec,testEllipsoid);
            mlunitext.assert_equals(true, (abs(testResVec(1))<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %distance between two ellipsoids of high dimensions
            nDim=100;
            testEllipsoid1=ellipsoid(diag(1:2:2*nDim));
            testEllipsoid2=ellipsoid([5;zeros(nDim-1,1)],diag(1:nDim));
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true,abs(testRes-3)<absTol);
            %
            %distance between two vectors of ellipsoids of rather high
            %dimension (12<=nDim<=26) with matrices that have nonzero non
            %diagonal elements
            load(strcat(self.testDataRootDir,filesep,'testEllEllDist.mat'),...
                'testEllipsoid1Vec','testEllipsoid2Vec','testAnswVec','nEllVec');
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec);
            mlunitext.assert_equals(ones(1,nEllVec),...
                abs(testResVec-testAnswVec)<absTol);
            %
            %distance between two ellipsoids and an ellipsoid (of 3-dimension),
            %all matrices with nonzero nondiagonal elements
            testEll1Mat=[9,0,0; 0,25,0; 0,0, 1];
            testEll1Mat=testOrth3Mat*testEll1Mat*testOrth3Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=[9,0,0; 0, 25,0; 0,0,1];
            testEll2Mat=testOrth3Mat*testEll2Mat*testOrth3Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth3Mat*[-5;0;0];
            testEll3Mat=[25,0,0; 0,100,0; 0,0, 1];
            testEll3Mat=testOrth3Mat*testEll3Mat*testOrth3Mat.';
            testEll3Mat=0.5*(testEll3Mat+testEll3Mat.');
            testEll3CenterVec=testOrth3Mat*[5;0;0];
            testEllipsoidVec=[ellipsoid(testEll1Mat),...
                ellipsoid(testEll2CenterVec,testEll2Mat)];
            testEllipsoid=ellipsoid(testEll3CenterVec,testEll3Mat);
            testResVec=distance(testEllipsoidVec,testEllipsoid);
            mlunitext.assert_equals(true, (abs(testResVec(1))<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %distance between two ellipsoids of high dimensions and random
            %matrices
            nDim=100;
            testEll1Mat=diag(1:2:2*nDim);
            testEll1Mat=testOrth100Mat*testEll1Mat*testOrth100Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=diag([25;(1:(nDim-1)).']);
            testEll2Mat=testOrth100Mat*testEll2Mat*testOrth100Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth100Mat*[9;zeros(nDim-1,1)];
            testEllipsoid1=ellipsoid(testEll1Mat);
            testEllipsoid2=ellipsoid(testEll2CenterVec,testEll2Mat);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true,abs(testRes-3)<absTol);
            %
            %
            %
            %
            % distance between single ellipsoid and array of ellipsoids
            load(strcat(self.testDataRootDir,filesep,'testEllEllDist.mat'),...
                'testEllArr','testDistResArr');
            testEll = ellipsoid(eye(2));
            resArr = distance(testEll, testEllArr);
            isOkArr = abs(resArr - testDistResArr) <= elltool.conf.Properties.getAbsTol();
            mlunitext.assert(all(isOkArr(:)));
            %distance between an ellipsoid (with nonzeros nondiagonal elements)
            %and a hyperplane in 2 dimensions
            testEllMat=[9 0; 0 4];
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllCenterVec=testOrth2Mat*[0;5];
            testHypVVec=testOrth2Mat*[0;1];
            testHypC=0;
            testEllipsoid=ellipsoid(testEllCenterVec,testEllMat);
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunitext.assert_equals(true,abs(testRes-3)<absTol);
            %
            %distance between an ellipsoid (with nonzero nondiagonal elements)
            %and a hyperplane in 3 dimensions
            testEllMat=[100,0,0;0,25,0;0,0,9];
            testEllMat=testOrth3Mat*testEllMat*testOrth3Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testHypVVec=testOrth3Mat*[0;1;0];
            testHypC=10;
            testEllipsoid=ellipsoid(testEllMat);
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunitext.assert_equals(true,abs(testRes-5)<absTol);
            %
            %distance between two high dimensional ellipsoids (with nonzero
            %nondiagonal elements) and a hyperplane
            nDim=100;
            testEll1Mat=diag(1:nDim);
            testEll1Mat=testOrth100Mat*testEll1Mat*testOrth100Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll1CenterVec=testOrth100Mat*[-8;zeros(nDim-1,1)];
            testEll2Mat=diag([25;(1:(nDim-1)).']);
            testEll2Mat=testOrth100Mat*testEll2Mat*testOrth100Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth100Mat*[10;zeros(nDim-1,1)];
            testHypVVec=testOrth100Mat*[1;zeros(nDim-1,1)];
            testHypC=0;
            testEllipsoid=[ellipsoid(testEll1CenterVec,testEll1Mat),...
                ellipsoid(testEll2CenterVec,testEll2Mat)];
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunitext.assert_equals(true,abs(testRes(1)-7)<absTol&&...
                abs(testRes(2)-5)<absTol);
            %distance where two ellipsoids have one common point
            % according to existing precision policy elltool.conf.Properties.getAbsTol()
            testEll1=ellipsoid([1+1e-20 0].',[1 0; 0 1]);
            testEll2=ellipsoid([-1 0].',[1 0;0 1]);
            testRes=distance(testEll1,testEll2);
            mlunitext.assert_equals(true,abs(testRes)<elltool.conf.Properties.getAbsTol());
            %negative test: ellipsoid and hyperplane have different dimensions
            testEll = ellipsoid(eye(2));
            testHyp = hyperplane(eye(3));
            self.runAndCheckError('distance(testEll, testHyp)',...
                'wrongInput');
            %
            %
            %DISTANCE FROM VECTOR TO ELLIPSOID
            %IN ELLIPSOID METRIC
            %
            % Test#1. Distance between an ellipsoid and a vector.
            testEllipsoid = ellipsoid([1,0,0;0,5,0;0,0,10]);
            testPointVec = [3,0,0].';
            %
            testRes = distance(testEllipsoid, testPointVec,true);
            ansRes = ellVecDistanceCVX(testEllipsoid, testPointVec,true);
            mlunitext.assert_equals(true, (abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol()));
            %
            % Test#2. Distance between an ellipsoid and a vector.
            testEllipsoid = ellipsoid([2,0,0;0,5,0;0,0,10]);
            testPointVec = [3,0,0].';
            %
            testRes = distance(testEllipsoid, testPointVec,true);
            ansRes = ellVecDistanceCVX(testEllipsoid, testPointVec,true);
            mlunitext.assert_equals(true, (abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol()));
            %
            %Test#3
            % Distance between two ellipsoids and a vector
            testEllipsoidVec = [ellipsoid([5,5,0].',[1,0,0;0,5,0;0,0,10]),...
                ellipsoid([0,10,0].',[10, 0, 0; 0, 16 , 0; 0,0, 5])];
            testPointVec = [0,5,0].';
            %
            testResVec = distance(testEllipsoidVec, testPointVec,true);
            ansResVec(1)=ellVecDistanceCVX(testEllipsoidVec(1), testPointVec,true);
            ansResVec(2)=ellVecDistanceCVX(testEllipsoidVec(2), testPointVec,true);
            mlunitext.assert_equals(true, (abs(testResVec(1)-ansResVec(1))<elltool.conf.Properties.getAbsTol()) &&...
                (abs(testResVec(2)-ansResVec(2))<elltool.conf.Properties.getAbsTol()));
            %
            %Test#4.
            % Random ellipsoid matrix, low dimension case.
            nDim=2;
            testEllMat=diag(1:2);
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=ellipsoid(testEllMat);
            testPointVec=testOrth2Mat*[10;zeros(nDim-1,1)];
            %
            testRes=distance(testEllipsoid, testPointVec,true);
            ansRes = ellVecDistanceCVX(testEllipsoid, testPointVec,true);
            mlunitext.assert_equals(true,abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol());
            %
            %Test#5.
            % Distance between two ellipsoids with random matrices and two vectors
            testEll1Mat=[5,2,0;2,5,0;0,0,1];
            testEll1Mat=testOrth3Mat*testEll1Mat*testOrth3Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=[4,0,0;0,9,0;0,0,25];
            testEll2Mat=testOrth3Mat*testEll2Mat*testOrth3Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth3Mat*[0;0;5];
            testEllipsoid1=ellipsoid(testEll1Mat);
            testEllipsoid2=ellipsoid(testEll2CenterVec,testEll2Mat);
            testEllipsoidVec = [testEllipsoid1,testEllipsoid2];
            testPointMat = testOrth3Mat*([0,0,5; 0,5,5].');
            %
            testResVec = distance(testEllipsoidVec, testPointMat,true);
            ansResVec(1)=distance(testEllipsoid1,testPointMat(:,1),true);
            ansResVec(2)=distance(testEllipsoid2,testPointMat(:,2),true);
            mlunitext.assert_equals(true, all(abs(testResVec-ansResVec)<...
                elltool.conf.Properties.getAbsTol()));
            %
            %DISTANCE FROM ELLIPSOID TO ELLIPSOID
            %IN ELLIPSOIDAL METRIC
            %
            % Test#1.
            % Distance between two ellipsoids
            testEllipsoid1 = ellipsoid([25,0;0,9]);
            testEllipsoid2 = ellipsoid([10;0],[4,0;0,9]);
            testRes=distance(testEllipsoid1,testEllipsoid2,true);
            ansRes=ellEllDistanceCVX(testEllipsoid1,testEllipsoid2,true);
            mlunitext.assert_equals(true, (abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol()));
            %
            % Test#2.
            % Distance between two ellipsoids of high dimensions and random
            % matrices
            nDim=100;
            testEll1Mat=diag(1:2:2*nDim);
            testEll1Mat=testOrth100Mat*testEll1Mat*testOrth100Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=diag([25;(1:(nDim-1)).']);
            testEll2Mat=testOrth100Mat*testEll2Mat*testOrth100Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth100Mat*[9;zeros(nDim-1,1)];
            testEllipsoid1=ellipsoid(testEll1Mat);
            testEllipsoid2=ellipsoid(testEll2CenterVec,testEll2Mat);
            %
            testRes=distance(testEllipsoid1,testEllipsoid2,true);
            ansRes=ellEllDistanceCVX(testEllipsoid1,testEllipsoid2,true);
            mlunitext.assert_equals(true,abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol());
            %
            % Test#3.
            % Distance between two ellipsoids and an ellipsoid (of 3-dimension),
            % all matrices with nonzero nondiagonal elements
            testEll1Mat=[9,0,0; 0,25,0; 0,0, 1];
            testEll1Mat=testOrth3Mat*testEll1Mat*testOrth3Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=[9,0,0; 0, 25,0; 0,0,1];
            testEll2Mat=testOrth3Mat*testEll2Mat*testOrth3Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth3Mat*[-5;0;0];
            testEll3Mat=[25,0,0; 0,100,0; 0,0, 1];
            testEll3Mat=testOrth3Mat*testEll3Mat*testOrth3Mat.';
            testEll3Mat=0.5*(testEll3Mat+testEll3Mat.');
            testEll3CenterVec=testOrth3Mat*[5;0;0];
            testEllipsoidVec=[ellipsoid(testEll1Mat),...
                ellipsoid(testEll2CenterVec,testEll2Mat)];
            testEllipsoid=ellipsoid(testEll3CenterVec,testEll3Mat);
            %
            testResVec=distance(testEllipsoidVec,testEllipsoid,true);
            ansResVec(1)=distance(testEllipsoidVec(1),testEllipsoid,true);
            ansResVec(2)=distance(testEllipsoidVec(2),testEllipsoid,true);
            mlunitext.assert_equals(true, all(abs(testResVec-ansResVec)<...
                elltool.conf.Properties.getAbsTol()));
            %
            % Test #4.
            % distance between two pairs of ellipsoids
            testEllipsoid1Vec=[ellipsoid([0, -6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,-4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testEllipsoid2Vec=[ellipsoid([0, 6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            %
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec,true);
            ansResVec(1)=distance(testEllipsoid1Vec(1),testEllipsoid2Vec(1),true);
            ansResVec(2)=distance(testEllipsoid1Vec(2),testEllipsoid2Vec(2),true);
            mlunitext.assert_equals(true, all(abs(testResVec-ansResVec)<...
                elltool.conf.Properties.getAbsTol()));
        end
        %
        function self = testPropertyGetters(self)
            ellCenter = [1;1];
            ellMat = eye(2);
            testAbsTol = 1;
            testRelTol = 2;
            testNPlot2dPoints = 3;
            testNPlot3dPoints = 4;
            args = {ellCenter,ellMat, 'absTol',testAbsTol,'relTol',testRelTol,...
                'nPlot2dPoints',testNPlot2dPoints,...
                'nPlot3dPoints',testNPlot3dPoints};
            %%
            ellArr = [ellipsoid(args{:}),ellipsoid(args{:});...
                ellipsoid(args{:}),ellipsoid(args{:})];
            ellArr(:,:,2) = [ellipsoid(args{:}),ellipsoid(args{:});...
                ellipsoid(args{:}),ellipsoid(args{:})];
            sizeArr = size(ellArr);
            testAbsTolArr = repmat(testAbsTol,sizeArr);
            testRelTolArr = repmat(testRelTol,sizeArr);
            testNPlot2dPointsArr = repmat(testNPlot2dPoints,sizeArr);
            testNPlot3dPointsArr = repmat(testNPlot3dPoints,sizeArr);
            %%
            isOkArr = (testAbsTolArr == ellArr.getAbsTol()) &(testRelTolArr == ellArr.getRelTol()) &...
                (testNPlot2dPointsArr == ellArr.getNPlot2dPoints()) &...
                (testNPlot3dPointsArr == ellArr.getNPlot3dPoints());
            isOk = all(isOkArr(:));
            mlunitext.assert(isOk);
        end
        %
        function self = testEllipsoid(self)
            %Empty ellipsoid
            testEllipsoid=ellipsoid;
            [testCenterVec, testShapeMat]=double(testEllipsoid);
            isTestRes=isempty(testCenterVec)&&isempty(testShapeMat);
            mlunitext.assert_equals(true, isTestRes);
            
            %One argument
            testEllipsoid=ellipsoid(diag([1 4 9 16]));
            [testCenterVec, testShapeMat]=double(testEllipsoid);
            isTestDiagMat=testShapeMat==diag([1 4  9 16]);
            isTestRes=(numel(testCenterVec)==4) && all(testCenterVec(:)==0)&& all(isTestDiagMat(:));
            mlunitext.assert_equals(true, isTestRes);
            
            %Two arguments
            fCheckForTestEllipsoidAndDouble([1; 2; -1],[2.5 -1.5 0; -1.5 2.5 0; 0 0 9]);
            fCheckForTestEllipsoidAndDouble(-2*ones(5,1),9*eye(5,5));
            
            %High-dimensional ellipsoids
            fCheckForTestEllipsoidAndDouble(diag(1:12));
            fCheckForTestEllipsoidAndDouble((0:0.1:2).',diag(0:10:200));
            fCheckForTestEllipsoidAndDouble(10*rand(100,1), diag(50*rand(1,100)));
            
            %Check wrong inputs
            self.runAndCheckError('ellipsoid([1 1],eye(2,2))','wrongInput');
            self.runAndCheckError('ellipsoid([1 1;0 1])','wrongInput');
            self.runAndCheckError('ellipsoid([-1 0;0 -1])','wrongInput');
            self.runAndCheckError('ellipsoid([1;1],eye(3,3))','wrongInput');
            
            self.runAndCheckError('ellipsoid([1 -i;-i 1])','wrongInput:imagArgs');
            self.runAndCheckError('ellipsoid([1+i;1],eye(2,2))','wrongInput:imagArgs');
            self.runAndCheckError('ellipsoid([1;0],(1+i)*eye(2,2))','wrongInput:imagArgs');
        end
        %
        function self = testDouble(self)
            %Empty ellipsoid
            testEllipsoid=ellipsoid;
            [testCenterVec, testShapeMat]=double(testEllipsoid);
            isTestRes=isempty(testCenterVec)&&isempty(testShapeMat);
            mlunitext.assert_equals(true, isTestRes);
            
            %Chek for one output argument
            testEllipsoid=ellipsoid(-ones(5,1),eye(5,5));
            testShapeMat=double(testEllipsoid);
            isTestEyeMat=testShapeMat==eye(5,5);
            isTestRes=all(isTestEyeMat(:));
            mlunitext.assert_equals(true, isTestRes);
            
            %Chek for two output arguments
            fCheckForTestEllipsoidAndDouble(-(1:10)',eye(10,10));
            
            %High-dimensional ellipsoids
            fCheckForTestEllipsoidAndDouble(diag(1:12));
            fCheckForTestEllipsoidAndDouble((0:0.1:2).', diag(0:0.01:0.2));
            fCheckForTestEllipsoidAndDouble(10*rand(100,1), diag(50*rand(1,100)));
        end
        %
        function self = testParameters(self)
            %Empty ellipsoid
            testEllipsoid=ellipsoid;
            [testCenterVec, testShapeMat]=parameters(testEllipsoid);
            isTestRes=isempty(testCenterVec)&&isempty(testShapeMat);
            mlunitext.assert_equals(true, isTestRes);
            
            %Chek for one output argument
            testEllipsoid=ellipsoid(-ones(5,1),eye(5,5));
            testShapeMat=parameters(testEllipsoid);
            isTestEyeMat=testShapeMat==eye(5,5);
            isTestRes=all(isTestEyeMat(:));
            mlunitext.assert_equals(true, isTestRes);
            
            %Chek for two output arguments
            fCheckForTestParameters(-(1:10)',eye(10,10));
            
            %High-dimensional ellipsoids
            fCheckForTestParameters(diag(1:12));
            fCheckForTestParameters((0:0.1:2).', diag(0:0.01:0.2));
            fCheckForTestParameters(10*rand(100,1), diag(50*rand(1,100)));
        end
        %
        function self = testDimension(self)
            %Chek for one output argument
            %Case 1: Empty ellipsoid
            testEllipsoid=ellipsoid;
            testRes = dimension(testEllipsoid);
            mlunitext.assert_equals(false, testRes);
            %Case 2: Not empty ellipsoid
            testEllipsoid=ellipsoid(0);
            testRes = dimension(testEllipsoid);
            mlunitext.assert_equals(true, testRes);
            
            testEllipsoid=ellipsoid(eye(5,5));
            testRes = dimension(testEllipsoid);
            mlunitext.assert_equals(5, testRes);
            
            %Chek for two output arguments
            %Case 1: Empty ellipsoid
            testEllipsoid=ellipsoid;
            [testDim, testRank]= dimension(testEllipsoid);
            isTestRes=(testDim==0)&&(testRank==0);
            mlunitext.assert_equals(true, isTestRes);
            
            %Case 2: Not empty ellipsoid
            testEllipsoid=ellipsoid(ones(4,1), eye(4,4));
            [testDim, testRank]= dimension(testEllipsoid);
            isTestRes=(testDim==4)&&(testRank==4);
            mlunitext.assert_equals(true, isTestRes);
            
            testAMat=[ 3 1;0 1; -2 1];
            testEllipsoid=ellipsoid(testAMat*(testAMat'));
            [testDim, testRank]= dimension(testEllipsoid);
            isTestRes=(testDim==3)&&(testRank==2);
            mlunitext.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:12)), ellipsoid((0:0.1:1.4).',diag(1:15)), ...
                ellipsoid(rand(20,1),diag(1:20))];
            testDimsVec = dimension(testEllVec);
            isTestRes = all( testDimsVec == [12 15 20] );
            mlunitext.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0:0.1:2).',diag(0:0.01:0.2)), ellipsoid, ellipsoid(rand(50,1),9*eye(50,50));
                ellipsoid, ellipsoid(repmat([diag(0:0.1:5) diag(0:0.1:5)],2,1)), ellipsoid(zeros(30,30))];
            [testDimMat, testRankMat] = dimension(testEllMat);
            isTestDimMat = (testDimMat == [21 0 50; 0 102 30]);
            isTestRankMat = (testRankMat == [20 0 50; 0 50 0]);
            isTestRes = all( isTestDimMat(:)) && all( isTestRankMat(:));
            mlunitext.assert_equals(true, isTestRes);
        end
        %
        function self = testIsDegenerate(self)
            %Empty ellipsoid
            self.runAndCheckError('isdegenerate(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Not degerate ellipsoid
            testEllipsoid=ellipsoid(ones(6,1),eye(6,6));
            isTestRes = isdegenerate(testEllipsoid);
            mlunitext.assert_equals(false, isTestRes);
            
            %Degenerate ellipsoids
            testEllipsoid=ellipsoid(ones(6,1),zeros(6,6));
            isTestRes = isdegenerate(testEllipsoid);
            mlunitext.assert_equals(true, isTestRes);
            
            testAMat=[ 3 1;0 1; -2 1];
            testEllipsoid=ellipsoid(testAMat*(testAMat.'));
            isTestRes=isdegenerate(testEllipsoid);
            mlunitext.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:22)), ellipsoid((0:0.1:1.4).',diag(1:15)), ...
                ellipsoid(rand(21,1),diag(0:20))];
            isTestDegVec = isdegenerate(testEllVec);
            isTestRes = all( isTestDegVec == [false false true] );
            mlunitext.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0:0.1:2).',diag(0:0.01:0.2)), ellipsoid(eye(40,40)), ellipsoid(rand(50,1),9*eye(50,50));
                ellipsoid(diag(10:2:40)), ellipsoid(repmat([diag(0:0.1:5) diag(0:0.1:5)],2,1)), ellipsoid(zeros(30,30))];
            isTestDegMat = isdegenerate(testEllMat);
            isTestMat = ( isTestDegMat == [true false false; false true true] );
            isTestRes = all( isTestMat(:));
            mlunitext.assert_equals(true, isTestRes);
        end
        %
        function self = testIsEmpty(self)
            %Chek realy empty ellipsoid
            testEllipsoid=ellipsoid;
            isTestRes = testEllipsoid.isEmpty();
            mlunitext.assert_equals(true, isTestRes);
            
            %Chek not empty ellipsoid
            testEllipsoid=ellipsoid(eye(10,1),eye(10,10));
            isTestRes =testEllipsoid.isEmpty();
            mlunitext.assert_equals(false, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:22)), ellipsoid((0:0.1:1.4).',diag(1:15)), ...
                ellipsoid(rand(21,1),diag(0:20)), ellipsoid, ellipsoid, ellipsoid(zeros(40,40))];
            isTestEmpVec = testEllVec.isEmpty();
            isTestRes = all( isTestEmpVec == [false false false true true false] );
            mlunitext.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0:0.1:2).',diag(0:0.01:0.2)), ellipsoid(eye(40,40)), ellipsoid;
                ellipsoid, ellipsoid(repmat([diag(0:0.1:5) diag(0:0.1:5)],2,1)), ellipsoid(zeros(30,30))];
            isTestEmpMat = testEllMat.isEmpty();
            isTestMat = ( isTestEmpMat == [false false true;true false false] );
            isTestRes = all( isTestMat(:));
            mlunitext.assert_equals(true, isTestRes);
        end
        %
        function self = testMaxEig(self)
            %Check empty ellipsoid
            self.runAndCheckError('maxeig(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            testEllipsoid1=ellipsoid([1; 1], zeros(2,2));
            testEllipsoid2=ellipsoid(zeros(2,2));
            isTestRes=(maxeig(testEllipsoid1)==0)&&(maxeig(testEllipsoid2)==0);
            mlunitext.assert_equals(true, isTestRes);
            
            %Check on diaganal matrix
            testEllipsoid=ellipsoid(diag(1:0.2:5.2));
            isTestRes=(maxeig(testEllipsoid)==5.2);
            mlunitext.assert_equals(true, isTestRes);
            
            %Check on not diaganal matrix
            testEllipsoid=ellipsoid([1 1 -1; 1 4 -3; -1 -3 9]);
            isTestRes=( (maxeig(testEllipsoid)-max(eig([1 1 -1; 1 4 -3; -1 -3 9])))<=eps );
            mlunitext.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:12)), ellipsoid((0:0.1:1.4).',diag(0.1:0.1:1.5)), ...
                ellipsoid(rand(20,1),diag(1:20))];
            testMaxEigVec = maxeig(testEllVec);
            isTestRes = all( testMaxEigVec == [12 1.5 20] );
            mlunitext.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0:0.1:2).',diag(0:0.01:0.2)), ellipsoid(-10*ones(41,1),diag(20:10:420)), ellipsoid(rand(50,1),9*eye(50,50));
                ellipsoid(5*eye(10,10)), ellipsoid(diag(0:0.0001:0.01)), ellipsoid(zeros(30,30))];
            testMaxEigMat = maxeig(testEllMat);
            isTestMat = (testMaxEigMat == [0.2 420 9; 5 0.01 0]);
            isTestRes = all( isTestMat(:));
            mlunitext.assert_equals(true, isTestRes);
        end
        %
        function self = testMinEig(self)
            %Check empty ellipsoid
            self.runAndCheckError('mineig(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            testEllipsoid1=ellipsoid([-2; -2], zeros(2,2));
            testEllipsoid2=ellipsoid(zeros(2,2));
            isTestRes=(mineig(testEllipsoid1)==0)&&(mineig(testEllipsoid2)==0);
            mlunitext.assert_equals(true, isTestRes);
            
            %Check on diaganal matrix
            testEllipsoid=ellipsoid(diag(4:-0.2:1.2));
            isTestRes=(mineig(testEllipsoid)==1.2);
            mlunitext.assert_equals(true, isTestRes);
            
            %Check on not diaganal matrix
            testEllipsoid=ellipsoid([1 1 -1; 1 4 -4; -1 -4 9]);
            isTestRes=( (mineig(testEllipsoid)-min(eig([1 1 -1; 1 4 -3; -1 -3 9])))<=eps );
            mlunitext.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:12)), ellipsoid((0:0.1:1.4).',diag(0.1:0.1:1.5)), ...
                ellipsoid(rand(21,1),diag(0:20))];
            testMinEigVec = mineig(testEllVec);
            isTestRes = all( testMinEigVec == [1 0.1 0] );
            mlunitext.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0.1:0.1:2).',diag(0.01:0.01:0.2)), ellipsoid(-10*ones(41,1),diag(20:10:420)), ellipsoid(rand(50,1),9*eye(50,50));
                ellipsoid(repmat(diag(1:20),2,2)), ellipsoid(diag(0.0001:0.0001:0.01)), ellipsoid(zeros(30,30))];
            testMinEigMat = mineig(testEllMat);
            isTestMat = (testMinEigMat == [0.01 20 9; 0 0.0001 0]);
            isTestRes = all( isTestMat(:));
            mlunitext.assert_equals(true, isTestRes);
        end
        %
        function self = testTrace(self)
            %Empty ellipsoid
            self.runAndCheckError('trace(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Not empty ellipsoid
            testEllipsoid=ellipsoid(zeros(10,1),eye(10,10));
            isTestRes=trace(testEllipsoid)==10;
            mlunitext.assert_equals(true, isTestRes);
            
            testEllipsoid=ellipsoid(-eye(3,1),[1 0 1; 0 0 0; 1 0 2 ]);
            isTestRes=trace(testEllipsoid)==3;
            mlunitext.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:12)), ellipsoid((0:0.1:1.4).',diag(0.1:0.1:1.5)), ...
                ellipsoid(rand(21,1),diag(0:20))];
            testTraceVec = trace(testEllVec);
            isTestRes = all( testTraceVec == [78 12 210] );
            mlunitext.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0.1:0.1:2).',diag(0.01:0.01:0.2)), ellipsoid(-10*ones(41,1),diag(20:10:420)),...
                ellipsoid(rand(50,1),9*eye(50,50));   ellipsoid(repmat(diag(1:20),2,2)),...
                ellipsoid(diag(0.0001:0.0001:0.01)), ellipsoid(zeros(30,30))];
            testTraceMat = trace(testEllMat);
            isTestMat = ( testTraceMat == [sum(0.01:0.01:0.2) sum(20:10:420) 9*50; 2*sum(1:20) sum(0.0001:0.0001:0.01) 0] );
            isTestRes = all( isTestMat(:));
            mlunitext.assert_equals(true, isTestRes);
        end
        %
        function self = testVolume(self)
            import elltool.conf.Properties;
            absTol = Properties.getAbsTol();
            %Check empty ellipsoid
            self.runAndCheckError('volume(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Check degenerate ellipsoid
            testEllipsoid=ellipsoid([1 0 0;0 1 0;0 0 0]);
            isTestRes=volume(testEllipsoid)==0;
            mlunitext.assert_equals(true, isTestRes);
            
            %Check dim=1 with two different centers
            testEllipsoid1=ellipsoid(2,1);
            testEllipsoid2=ellipsoid(1);
            isTestRes=(volume(testEllipsoid1)==2)&&(volume(testEllipsoid2)==2);
            mlunitext.assert_equals(true, isTestRes);
            
            %Check dim=2 with two different centers
            testEllipsoid1=ellipsoid([1; -1],eye(2,2));
            testEllipsoid2=ellipsoid(eye(2,2));
            isTestRes=( (volume(testEllipsoid1)-pi)<=absTol )&&( (volume(testEllipsoid2)-pi)<=absTol );
            mlunitext.assert_equals(true, isTestRes);
            
            %Chek dim=3 with not diaganal matrix
            testEllipsoid=ellipsoid([1 1 -1; 1 4 -3; -1 -3 9]);
            isTestRes=( (volume(testEllipsoid)-(8*realsqrt(5)*pi/3)<=absTol ) );
            mlunitext.assert_equals(true, isTestRes);
            
            %Check dim=5
            testEllipsoid=ellipsoid(4*ones(5,1),eye(5,5));
            isTestRes=( (volume(testEllipsoid)-(8*pi*pi/15)<=absTol ) );
            mlunitext.assert_equals(true, isTestRes);
            
            %Check dim=6
            testEllipsoid=ellipsoid(-ones(6,1),diag([1, 4, 9, 16,1, 25]));
            isTestRes=( (volume(testEllipsoid)-(20*pi*pi*pi)<=absTol ) );
            mlunitext.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllMat= [ellipsoid((0.1:0.1:2).',diag(0.01:0.01:0.2)), ellipsoid(-10*ones(13,1),diag(0.1:0.1:1.3));
                ellipsoid(rand(20,1),9*diag(0:19)), ellipsoid(diag(1:21));
                ellipsoid(diag(0.1:0.1:10)), ellipsoid(diag(0:0.0001:0.01))];
            testVolMat = volume(testEllMat);
            testRightVolMat = [(pi^6)*realsqrt(prod(0.01:0.01:0.2))/prod(1:6), (pi^6)*(2^7)*realsqrt(prod(0.1:0.1:1.3))/prod(1:2:13);
                0,                                          (pi^10)*(2^11)*realsqrt(prod(1:21))/prod(1:2:21);
                (pi^50)*realsqrt(prod(0.1:0.1:10))/prod(1:50), 0];
            
            isTestEqMat = (testVolMat-testRightVolMat)<=absTol;
            isTestRes = all(isTestEqMat(:));
            mlunitext.assert_equals(true, isTestRes);
        end
        %
        function self = testEq(self)
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            
            testMat = eye(2);
            checkEllEqual(ellipsoid(testMat), ellipsoid(testMat), true, '');
            
            test1Mat = eye(2);
            test2Mat = eye(2) + MAX_TOL;
            checkEllEqual(ellipsoid(test1Mat), ellipsoid(test2Mat), true, '');
            
            test1Mat = eye(2);
            test2Mat = eye(2) - 0.99*MAX_TOL;
            checkEllEqual(ellipsoid(test1Mat), ellipsoid(test2Mat), true, '');
            
            test1Mat = 100*eye(2);
            test2Mat = 100*eye(2) - 0.99*MAX_TOL;
            checkEllEqual(ellipsoid(test1Mat), ellipsoid(test2Mat), true, '');
            %
            %test for maxTolerance
            firstMat = eye(2);
            secMat = eye(2)+1;
            secVec = [1;0];
            maxTol = 1;
            ell1 = ellipsoid(firstMat);
            ell2 = ellipsoid(secVec,secMat);
            [isOk,reportStr]=ell1.isEqual(ell2);
            mlunitext.assert(~isOk,reportStr);
            %
            %
            testEll = ellipsoid(eye(2));
            testEll2 = ellipsoid([1e-3, 0].', eye(2));
            mDim = 10;
            nDim = 15;
            testEllArr = repmat(testEll, mDim, nDim);
            isEqualArr = true(mDim, nDim);
            isnEqualArr = ~isEqualArr;
            mlunitext.assert_equals(isEqualArr, testEll.eq(testEllArr));
            mlunitext.assert_equals(isEqualArr, testEllArr.eq(testEll));
            mlunitext.assert_equals(isnEqualArr, testEll2.eq(testEllArr));
            mlunitext.assert_equals(isnEqualArr, testEllArr.eq(testEll2));
            
            testEll2Arr = repmat(testEll2, mDim, nDim);
            mlunitext.assert_equals(isEqualArr, testEllArr.eq(testEllArr));
            mlunitext.assert_equals(isnEqualArr, testEll2Arr.eq(testEllArr));
            
            self.runAndCheckError...
                ('eq([testEll, testEll2], [testEll; testEll2])','wrongSizes');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testEllipsoidZeros2 ...
                testEllipsoidZeros3 testEllipsoidEmpty] = createTypicalEll(1);
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(1);
            
            
            checkEllEqual(testEllHighDim1, testEllHighDim1, true, '');
            
            checkEllEqual(testEllHighDim1, testEllHighDim2, false, ...
                '\(1).Q-->.*\(2.316625e\+00).*tolerance.\(1.000000e\-05)');
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(2);
            checkEllEqual(testEllHighDim1, testEllHighDim1, true, '');
            
            
            checkEllEqual(testEllHighDim1, testEllHighDim2, false, ...
                '\(1).Q-->.*\(2.316625e\+00).*tolerance.\(1.000000e\-05)');
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(3);
            checkEllEqual(testEllHighDim1, testEllHighDim1, true, '');
            
            checkEllEqual(testEllHighDim1, testEllHighDim2, false, ...
                '\(1).Q-->.*\(2.316625e\+00).*tolerance.\(1.000000e\-05)');
            
            
            checkEllEqual(testEllipsoid1, testEllipsoid1, true, '');
            
            checkEllEqual(testEllipsoid2, testEllipsoid1, false, ...
                '\(1).q-->.*\(1.000000e\+00).*tolerance.\(1.000000e\-05)');
            
            checkEllEqual(testEllipsoid3, testEllipsoid2, false, ...
                '\(1).Q-->.*\(4.142136e\-01).*tolerance.\(1.000000e\-05)');
            
            
            checkEllEqual(testEllipsoid3, testEllipsoid2, false, ...
                '\(1).Q-->.*\(4.142136e\-01).*tolerance.\(1.000000e\-05)');
            
            ansStr = sprintf('(1).Q-->Different sizes (left: [2 2], right: [3 3])\n(1).q-->Different sizes (left: [2 1], right: [3 1])');
            checkEllEqual(testEllipsoidZeros2, testEllipsoidZeros3, false, ansStr);
            
            
            ansStr = sprintf('(1).Q-->Different sizes (left: [2 2], right: [0 0])\n(1).q-->Different sizes (left: [2 1], right: [0 0])');
            checkEllEqual(testEllipsoidZeros2, testEllipsoidEmpty, false, ansStr);
            
            
            checkEllEqual(testEllipsoidEmpty, testEllipsoidEmpty, true, '');
            
            testNotEllipsoid = [];
            %'==: both arguments must be ellipsoids.'
            self.runAndCheckError('eq(testEllipsoidEmpty, testNotEllipsoid)','wrongInput:emptyArray');
            
            %'==: sizes of ellipsoidal arrays do not match.'
            self.runAndCheckError('eq([testEllipsoidEmpty testEllipsoidEmpty], [testEllipsoidEmpty; testEllipsoidEmpty])','wrongSizes');
            
            
            
            ansStr = sprintf('(1).Q-->Different sizes (left: [2 2], right: [3 3])\n(1).q-->Different sizes (left: [2 1], right: [3 1])');
            checkEllEqual([testEllipsoidZeros2 testEllipsoidZeros3], [testEllipsoidZeros3 testEllipsoidZeros3], [false, true], ansStr);
        end
        %
        function self = testNe(self)
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testEllipsoidZeros2 testEllipsoidZeros3 ...
                testEllipsoidEmpty] = createTypicalEll(1);
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(1);
            
            testRes = ne(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(false, testRes);
            
            testRes = ne(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(true, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(2);
            
            testRes = ne(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(false, testRes);
            
            testRes = ne(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(true, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(3);
            
            testRes = ne(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(false, testRes);
            
            testRes = ne(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ne(testEllipsoid1, testEllipsoid1);
            mlunitext.assert_equals(false, testRes);
            
            testRes = ne(testEllipsoid2, testEllipsoid1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ne(testEllipsoid3, testEllipsoid2);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ne(testEllipsoidZeros2, testEllipsoidZeros3);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ne(testEllipsoidZeros2, testEllipsoidEmpty);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ne(testEllipsoidEmpty, testEllipsoidEmpty);
            mlunitext.assert_equals(false, testRes);
            
            testRes = ne([testEllipsoidZeros2 testEllipsoidZeros3], [testEllipsoidZeros3 testEllipsoidZeros3]);
            if (testRes == [1 0])
                testRes = 1;
            else
                testRes = 0;
            end
            mlunitext.assert_equals(true, testRes);
        end
        %
        function self = testGe(self)
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testEllipsoidEmpty] = createTypicalEll(2);
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(1);
            
            testRes = ge(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ge(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(false, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(2);
            
            testRes = ge(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ge(testEllHighDim2, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(3);
            
            testRes = ge(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ge(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(false, testRes);
            
            testRes = ge(testEllipsoid1, testEllipsoid1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ge(testEllipsoid2, testEllipsoid1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = ge(testEllipsoid2, testEllipsoid3);
            mlunitext.assert_equals(false, testRes);
            
            testRes = ge([testEllipsoid2 testEllipsoid1], [testEllipsoid1 testEllipsoid2]);
            if (testRes == [1 0])
                testRes = 1;
            else
                testRes = 0;
            end
            mlunitext.assert_equals(true, testRes);
        end
        %
        function self = testGt(self)
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testEllipsoidEmpty] = createTypicalEll(2);
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(1);
            
            testRes = gt(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = gt(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(false, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(2);
            
            testRes = gt(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = gt(testEllHighDim2, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(3);
            
            testRes = gt(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = gt(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(false, testRes);
            
            testRes = gt(testEllipsoid1, testEllipsoid1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = gt(testEllipsoid2, testEllipsoid1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = gt(testEllipsoid2, testEllipsoid3);
            mlunitext.assert_equals(false, testRes);
            
            testNotEllipsoid = [];
            %'both arguments must be ellipsoids.'
            self.runAndCheckError('gt(testEllipsoidEmpty, testNotEllipsoid)','wrongInput');
            
            %'sizes of ellipsoidal arrays do not match.'
            self.runAndCheckError('gt([testEllipsoidEmpty testEllipsoidEmpty], [testEllipsoidEmpty; testEllipsoidEmpty])','wrongInput:emptyEllipsoid');
            
            testRes = gt([testEllipsoid2 testEllipsoid1], [testEllipsoid1 testEllipsoid2]);
            if (testRes == [1 0])
                testRes = 1;
            else
                testRes = 0;
            end
            mlunitext.assert_equals(true, testRes);
        end
        %
        function self = testLt(self)
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testEllipsoidEmpty] = createTypicalEll(2);
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(1);
            
            testRes = lt(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = lt(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(true, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(2);
            
            testRes = lt(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = lt(testEllHighDim2, testEllHighDim1);
            mlunitext.assert_equals(false, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(3);
            
            testRes = lt(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = lt(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(true, testRes);
            
            testRes = lt(testEllipsoid1, testEllipsoid1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = lt(testEllipsoid2, testEllipsoid1);
            mlunitext.assert_equals(false, testRes);
            
            testRes = lt(testEllipsoid2, testEllipsoid3);
            mlunitext.assert_equals(true, testRes);
            
            testRes = lt([testEllipsoid2 testEllipsoid1], [testEllipsoid1 testEllipsoid2]);
            if (testRes == [0 1])
                testRes = 1;
            else
                testRes = 0;
            end
            mlunitext.assert_equals(true, testRes);
        end
        %
        function self = testLe(self)
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testEllipsoidEmpty] = createTypicalEll(2);
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(1);
            
            testRes = le(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = le(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(true, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(2);
            
            testRes = le(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = le(testEllHighDim2, testEllHighDim1);
            mlunitext.assert_equals(false, testRes);
            
            [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(3);
            
            testRes = le(testEllHighDim1, testEllHighDim1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = le(testEllHighDim1, testEllHighDim2);
            mlunitext.assert_equals(true, testRes);
            
            testRes = le(testEllipsoid1, testEllipsoid1);
            mlunitext.assert_equals(true, testRes);
            
            testRes = le(testEllipsoid2, testEllipsoid1);
            mlunitext.assert_equals(false, testRes);
            
            testRes = le(testEllipsoid2, testEllipsoid3);
            mlunitext.assert_equals(true, testRes);
            
            testRes = le([testEllipsoid2 testEllipsoid1], [testEllipsoid1 testEllipsoid2]);
            if (testRes == [0 1])
                testRes = 1;
            else
                testRes = 0;
            end
            mlunitext.assert_equals(true, testRes);
        end
        %
        function self = testMtimes(self)
            testEllipsoid1 = ellipsoid([1; 1], eye(2));
            
            [testHighDimShapeMat testHighDimMat] = createTypicalHighDimEll(4);
            testEllHighDim = ellipsoid(testHighDimShapeMat);
            
            resEll = mtimes(testHighDimMat, testEllHighDim);
            ansEll = ellipsoid(zeros(12, 1), testHighDimMat*testHighDimShapeMat*testHighDimMat');
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testHighDimShapeMat testHighDimMat] = createTypicalHighDimEll(5);
            testEllHighDim = ellipsoid(testHighDimShapeMat);
            
            resEll = mtimes(testHighDimMat, testEllHighDim);
            ansEll = ellipsoid(zeros(20, 1), testHighDimMat*testHighDimShapeMat*testHighDimMat');
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testHighDimShapeMat testHighDimMat] = createTypicalHighDimEll(6);
            testEllHighDim = ellipsoid(testHighDimShapeMat);
            
            resEll = mtimes(testHighDimMat, testEllHighDim);
            ansEll = ellipsoid(zeros(100, 1), testHighDimMat*testHighDimShapeMat*testHighDimMat');
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            % [~, AMat] = eig(rand(4,4)); fixed case
            AMat = [2.13269424734606 + 0.00000000000000i 0.00000000000000 + 0.00000000000000i 0.00000000000000 + 0.00000000000000i ...
                0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i -0.511574704257189 + 0.00000000000000i ...
                0.00000000000000 + 0.00000000000000i 0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i ...
                0.00000000000000 + 0.00000000000000i 0.255693118460086 + 0.343438979993794i 0.00000000000000 + 0.00000000000000i;...
                0.00000000000000 + 0.00000000000000i 0.00000000000000 + 0.00000000000000i 0.00000000000000 + 0.00000000000000i...
                0.255693118460086 - 0.343438979993794i];
            testEllipsoid3 = ellipsoid(diag(1:1:4));
            resEll = mtimes(AMat, testEllipsoid3);
            ansEll = ellipsoid(zeros(4, 1), AMat*diag(1:1:4)*AMat');
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            AMat = 2*eye(2);
            resEll = mtimes(AMat, testEllipsoid1);
            ansEll = ellipsoid([2; 2], 4*eye(2));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            AMat = eye(3);
            %'MTIMES: dimensions do not match.'
            self.runAndCheckError('mtimes(AMat, testEllipsoid1)','wrongSizes');
            
            AMat = cell(2);
            %'MTIMES: first multiplier is expected to be a matrix or a scalar,\n        and second multiplier - an ellipsoid.'
            self.runAndCheckError('mtimes(AMat, testEllipsoid1)','wrongInput');
            
            AMat = zeros(2);
            resEll = mtimes(AMat, testEllipsoid1);
            ansEll = ellipsoid(zeros(2));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            AMat = [1 2; 3 4; 5 6];
            resEll = mtimes(AMat, testEllipsoid1);
            ansEll = ellipsoid([3; 7; 11], [5 11 17; 11 25 39; 17 39 61]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            testEllipsoid1 = ellipsoid([0; 0], zeros(2));
            resEll = mtimes(AMat, testEllipsoid1);
            ansEll = ellipsoid(zeros(3));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
        end
        %
        function self = testIsBadDirection(self)
            import elltool.conf.Properties;
            absTol=Properties.getAbsTol();
            %positive test
            resObj=isbaddirection(ellipsoid(2*eye(2)),...
                ellipsoid(eye(2)),[1 1]',absTol);
            mlunitext.assert(isa(resObj,'logical'));
            %
            %negative test
            self.runAndCheckError(strcat('isbaddirection(',...
                'ellipsoid(eye(2)),ellipsoid([1 0; 0 0]),',...
                'eye(2),elltool.conf.Properties.getAbsTol())'),...
                'wrongInput:singularMat');
        end
        %
        function self = testFromRepMat(self)
            sizeArr = [2, 3, 3, 5];
            ellArr1 = ellipsoid.fromRepMat(sizeArr);
            isOk1Arr = ellArr1.isEmpty();
            mlunitext.assert(all(isOk1Arr(:)));
            %
            shMat = eye(2);
            cVec = [2; 3];
            absTol = 1e-10;
            ell2 = ellipsoid(cVec,shMat,'absTol',absTol);
            ell2Arr = ellipsoid.fromRepMat(cVec,shMat,sizeArr,'absTol',absTol);
            %
            isOkArr2 = eq(ell2,ell2Arr);
            mlunitext.assert(all(isOkArr2(:)));
            %
            isOkArr3 = ell2Arr.getAbsTol() == absTol;
            mlunitext.assert(all(isOkArr3));
            %
            self.runAndCheckError(strcat('ellipsoid.fromRepMat',...
                '([1; 1], eye(2), ellipsoid(eye(2)))'),...
                'wrongInput');
            %
            self.runAndCheckError(strcat('ellipsoid.fromRepMat',...
                '([1; 1], eye(2), [2; 2; 3.5])'),...
                'wrongInput');
        end
        %
        function self = testMultiDimensionalConstructor(self)
            % one argument
            testShape = [2,0;0,3];
            testEll = ellipsoid(testShape);
            testShMatArray = zeros(2,2,3,4);
            testShMatArray(:,:,1,3) = testShape;
            testEllArray = ellipsoid(testShMatArray);
            mlunitext.assert(eq(testEllArray(1,3),testEll));
            % two arguments and properties
            testShape = [2,0;0,3];
            testCent = [1;5];
            testEll = ellipsoid(testCent, testShape);
            testCentArray = zeros(2,3,4);
            testCentArray(:,1,3) = testCent;
            testEllArray1 = ellipsoid(testCentArray, testShMatArray);
            testEllArray2 = ellipsoid(testCentArray, testShMatArray, ...
                'absTol', 1e-3);
            mlunitext.assert(eq(testEllArray1(1,3),testEll));
            mlunitext.assert(eq(testEllArray2(1,3),testEll));
            %3d constructor case
            testShMatArray = zeros(2,2,3);
            testShMatArray(:,:,1) = testShape;
            testCentArray = zeros(2,3);
            testCentArray(:,1) = testCent;
            testEllArray = ellipsoid(testCentArray, testShMatArray);
            mlunitext.assert(eq(testEllArray(1),testEll));
            % bad dimensions
            self.runAndCheckError(...
                'ellipsoid(zeros(3,4,5,6),zeros(3,3,5,5,6))',...
                'wrongInput');
            self.runAndCheckError(...
                'ellipsoid(zeros(3,4,5,6,7,8),zeros(3,3,5,5,6))',...
                'wrongInput');
            self.runAndCheckError(...
                'ellipsoid(zeros(3,4,5,6,7,8),zeros(3,3,5,5,6,6,6))',...
                'wrongInput');
            self.runAndCheckError(...
                'ellipsoid(zeros(3),zeros(3))',...
                'wrongInput');
        end
        %
        function self = testGetCopy(self)
            ellMat(3, 3) = ellipsoid;
            ellMat(1) = ellipsoid(eye(3));
            ellMat(2) = ellipsoid([0; 1; 2], ones(3));
            ellMat(3) = ellipsoid(eye(4));
            ellMat(4) = ellipsoid(1.0001*eye(3));
            ellMat(5) = ellipsoid(1.0000000001*eye(3));
            ellMat(6) = ellipsoid([0; 1; 2], ones(3));
            ellMat(7) = ellipsoid(eye(2));
            ellMat(8) = ellipsoid(eye(3));
            ellMat(9) = ellipsoid(eye(5));
            copiedEllMat = ellMat.getCopy();
            isEqualMat = copiedEllMat.isEqual(ellMat);
            isOk = all(isEqualMat(:));
            mlunitext.assert_equals(true, isOk);
            firstCutEllMat = ellMat(1 : 2, 1 : 2);
            secondCutEllMat = ellMat(2 : 3, 2 : 3);
            thirdCutEllMat = ellMat(1 : 2, 2 : 3);
            self.runAndCheckError(...
                'copiedEllMat.isEqual(firstCutEllMat)', ...
                'wrongSizes');
            isEqualMat = firstCutEllMat.isEqual(secondCutEllMat);
            isOkMat = isEqualMat == [1 0; 1 0];
            isOk = all(isOkMat(:));
            mlunitext.assert_equals(true, isOk);
            isEqualMat = firstCutEllMat.isEqual(thirdCutEllMat);
            isOkMat = isEqualMat == [0 0; 0 1];
            isOk = all(isOkMat(:));
            mlunitext.assert_equals(true, isOk);
        end
        %
        function self = testSqrtmposToleranceFailure(self)
            sh1Mat = diag(repmat(0.0000001, 1, 4)) + diag([1 1 0 0]);
            sh2Mat = diag(ones(1, 4));
            minksum_ia([ellipsoid(zeros(4, 1), sh1Mat),...
                ellipsoid(zeros(4, 1), sh2Mat)], [0 0 1 0]');
        end
        %
        function self = testToStruct(self)
            centerCVec{1} = [1 2 3];
            shapeMatCVec{1} = eye(3);
            centerCVec{2} = [2 3 4];
            shapeMatCVec{2} = ones(3);
            centerCVec{3} = [1 0];
            shapeMatCVec{3} = [3 1; 1 2];
            centerCVec{4} = [1 0 0 0];
            shapeMatCVec{4} = diag([3 2 1 0]);
            for iElem = 1 : 4
                ellVec(iElem) = ellipsoid(centerCVec{iElem}', shapeMatCVec{iElem});
                transposedCenterCVec{iElem} = centerCVec{iElem}';
            end
            SEllVec = struct('centerVec', transposedCenterCVec, 'shapeMat', shapeMatCVec);
            ObtainedEllStruct = ellVec(1).toStruct();
            isOk = isequal(ObtainedEllStruct, SEllVec(1));
            ObtainedEllStructVec = ellVec.toStruct();
            isOk = isOk && isequal(ObtainedEllStructVec, SEllVec);
            mlunitext.assert_equals(true, isOk);
        end
    end
end
%
function fCheckForTestEllipsoidAndDouble(qCenterVec, qShapeMat)
if nargin < 2
    qShapeMat = qCenterVec;
    qCenterVec = zeros(size(qShapeMat,1),1);
    testEllipsoid=ellipsoid(qShapeMat);
else
    testEllipsoid=ellipsoid(qCenterVec,qShapeMat);
end
[testCenterVec, testShapeMat]=double(testEllipsoid);
try
    isTestCVec  = testCenterVec == qCenterVec;
    isTestEyeMat = testShapeMat == qShapeMat;
catch
    isTestRes = false;
end
isTestRes = all(isTestCVec(:)) && all(isTestEyeMat(:));
mlunitext.assert_equals(true, isTestRes);
end
%
function fCheckForTestParameters(qCenterVec, qShapeMat)
if nargin < 2
    qShapeMat = qCenterVec;
    qCenterVec = zeros(size(qShapeMat,1),1);
    testEllipsoid=ellipsoid(qShapeMat);
else
    testEllipsoid=ellipsoid(qCenterVec,qShapeMat);
end
[testCenterVec, testShapeMat]=parameters(testEllipsoid);
try
    isTestCVec  = testCenterVec == qCenterVec;
    isTestEyeMat = testShapeMat == qShapeMat;
catch
    isTestRes = false;
end
isTestRes = all(isTestCVec(:)) && all(isTestEyeMat(:));
mlunitext.assert_equals(true, isTestRes);
end
%
function fCheckBallsForTestMinkMP(nDim,minEll,subEll,sumEllMat,centerVec,rad,tol)
[testCenterVec testPointsMat]=minkmp(minEll,subEll,sumEllMat);
switch nDim
    case 1
        isTestRes = (testCenterVec==centerVec) && all( (abs(testPointsMat-centerVec)-rad) <= tol);
    case 2
        testDistSqr = (testPointsMat(1,:)-centerVec(1)).*(testPointsMat(1,:)-centerVec(1))...
            +(testPointsMat(2,:)-centerVec(2)).*(testPointsMat(2,:)-centerVec(2));
        isTestRes = all( testCenterVec==centerVec ) && all( abs(testDistSqr - rad*rad) <= tol );
    case 3
        testDistSqr = (testPointsMat(1,:)-centerVec(1)).*(testPointsMat(1,:)-centerVec(1)) +...
            (testPointsMat(2,:)-centerVec(2)).*(testPointsMat(2,:)-centerVec(2))+...
            (testPointsMat(3,:)-centerVec(3)).*(testPointsMat(3,:)-centerVec(3));
        isTestRes = all( testCenterVec==centerVec ) && all( abs(testDistSqr - rad*rad) <= tol );
end
mlunitext.assert(isTestRes);
end
%
function distEll=ellVecDistanceCVX(ellObj,vectorVec,isFlagOn)
[ellCenVec ellshapeMatMat]=double(ellObj);
ellshapeMatMat=ellshapeMatMat\eye(size(ellshapeMatMat));
ellshapeMatMat=0.5*(ellshapeMatMat+ellshapeMatMat.');
ellDims = dimension(ellObj);
maxDim   = max(max(ellDims));
cvx_begin sdp
variable x(maxDim, 1)
if isFlagOn
    fDist = (x - vectorVec)'*ellshapeMatMat*(x - vectorVec);
else
    fDist = (x - vectorVec)'*(x - vectorVec);
end
minimize(fDist)
subject to
x'*ellshapeMatMat*x + 2*(-ellshapeMatMat*ellCenVec)'*x + (ellCenVec'*ellshapeMatMat*ellCenVec - 1) <= 0
cvx_end
distEll = sqrt(fDist);
end
%
function distEllEll=ellEllDistanceCVX(ellObj1,ellObj2,flag)
dims1Mat = dimension(ellObj1);
%dims2Mat = dimension(ellObj2);
maxDim   = max(max(dims1Mat));
%maxDim2   = max(max(dims2Mat));
[cen1Vec, q1Mat] = double(ellObj1);
[cen2Vec, q2Mat] = double(ellObj2);
qi1Mat     = ell_inv(q1Mat);
qi1Mat     = 0.5*(qi1Mat + qi1Mat');
qi2Mat     = ell_inv(q2Mat);
qi2Mat     = 0.5*(qi2Mat + qi2Mat');
cvx_begin sdp
variable x(maxDim, 1)
variable y(maxDim, 1)
if flag
    fDist = (x - y)'*qi1Mat*(x - y);
else
    fDist = (x - y)'*(x - y);
end
minimize(fDist)
subject to
x'*qi1Mat*x + 2*(-qi1Mat*cen1Vec)'*x + (cen1Vec'*qi1Mat*cen1Vec - 1) <= 0
y'*qi2Mat*y + 2*(-qi2Mat*cen2Vec)'*y + (cen2Vec'*qi2Mat*cen2Vec - 1) <= 0
cvx_end
distEllEll = sqrt(fDist);
end
%
function [varargout] = createTypicalEll(flag)
switch flag
    case 1
        varargout{1} = ellipsoid([0; 0], [1 0; 0 1]);
        varargout{2} = ellipsoid([1; 0], [1 0; 0 1]);
        varargout{3} = ellipsoid([1; 0], [2 0; 0 1]);
        varargout{4} = ellipsoid([0; 0], [0 0; 0 0]);
        varargout{5} = ellipsoid([0; 0; 0], [0 0 0 ;0 0 0; 0 0 0]);
        varargout{6} = ellipsoid;
        varargout{7} = ellipsoid([2; 1], [3 1; 1 1]);
        varargout{8} = ellipsoid([1; 1], [1 0; 0 1]);
    case 2
        varargout{1} = ellipsoid([0; 0], [1 0; 0 1]);
        varargout{2} = ellipsoid([0; 0], [2 0; 0 2]);
        varargout{3} = ellipsoid([0; 0], [4 2; 2 4]);
        varargout{4} = ellipsoid;
    otherwise
end
end
%
function checkEllEqual(testEll1Vec, testEll2Vec, isEqRight, ansStr)
[isEq, reportStr] = isEqual(testEll1Vec, testEll2Vec);
mlunitext.assert_equals(isEq, isEqRight);
isRepEq = isequal(reportStr, ansStr);
if ~isRepEq
    isRepEq = ~isempty(regexp(reportStr, ansStr, 'once'));
end
mlunitext.assert_equals(isRepEq, true);
end
%
function [varargout] = createTypicalHighDimEll(flag)
switch flag
    case 1
        varargout{1} = ellipsoid(diag(1:0.5:6.5));
        varargout{2} = ellipsoid(diag(11:0.5:16.5));
    case 2
        varargout{1} = ellipsoid(diag(1:0.5:10.5));
        varargout{2} = ellipsoid(diag(11:0.5:20.5));
    case 3
        varargout{1} = ellipsoid(diag(1:0.1:10.9));
        varargout{2} = ellipsoid(diag(11:0.1:20.9));
    case 4
        varargout{1} = diag(1:0.5:6.5);
        varargout{2} = diag(11:0.5:16.5);
    case 5
        varargout{1} = diag(1:0.5:10.5);
        varargout{2} = diag(11:0.5:20.5);
    case 6
        varargout{1} = diag(1:0.1:10.9);
        varargout{2} = diag(11:0.1:20.9);
    otherwise
end
end