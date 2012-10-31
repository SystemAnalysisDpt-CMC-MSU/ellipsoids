classdef EllipsoidTestCase < mlunitext.test_case
    methods
        function self=EllipsoidTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
        end
        function self = testDistance(self)
            
            global  ellOptions;
            %testing vector-ellipsoid distance
            
            %distance between ellipsoid and two vectors
            testEllipsoid = ellipsoid([1,0,0;0,5,0;0,0,10]);
            testPointMat = [3,0,0; 5,0,0].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunit.assert_equals(1, (abs(testResVec(1)-2)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-4)<ellOptions.abs_tol));
            
            %distance between ellipsoid and point in the ellipsoid
            %and point on the boader of the ellipsoid
            testEllipsoid = ellipsoid([1,2,3].',4*eye(3,3));
            testPointMat = [2,3,2; 1,2,5].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunit.assert_equals(1, testResVec(1)==-1 && testResVec(2)==0);
            
            
            %distance between two ellipsoids and two vectors
            testEllipsoidVec = [ellipsoid([5,2,0;2,5,0;0,0,1]),...
                ellipsoid([0,0,5].',[4, 0, 0; 0, 9 , 0; 0,0, 25])];
            testPointMat = [0,0,5; 0,5,5].';
            testResVec = distance(testEllipsoidVec, testPointMat);
            mlunit.assert_equals(1, (abs(testResVec(1)-4)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-2)<ellOptions.abs_tol));
           
            
            %distance between two ellipsoids and a vector
            testEllipsoidVec = [ellipsoid([5,5,0].',[1,0,0;0,5,0;0,0,10]),...
                ellipsoid([0,10,0].',[10, 0, 0; 0, 16 , 0; 0,0, 5])];
            testPointVec = [0,5,0].';
            testResVec = distance(testEllipsoidVec, testPointVec);
            mlunit.assert_equals(1, (abs(testResVec(1)-4)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-1)<ellOptions.abs_tol));
            
            %negative test: matrix Q of ellipsoid has very large
            %eigenvalues.
            testEllipsoid = ellipsoid([1e+15,0;0,1e+15]);
            testPointVec = [3e+15,0].';
            self.runAndCheckError('distance(testEllipsoid, testPointVec)',...
                'notSecant');
            %
            %Testing ellipsoid-ellipsoid distance
            %distance between two ellipsoids
            testEllipsoid1 = ellipsoid([25,0;0,9]);
            testEllipsoid2 = ellipsoid([10,0].',[4,0;0,9]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-3)<ellOptions.abs_tol));
            %    
            testEllipsoid1 = ellipsoid([0 -15 0].',[25,0,0;0,100,0;0,0,9]);
            testEllipsoid2 = ellipsoid([0,7,0].',[9,0,0;0,25,0;0,0,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-7)<ellOptions.abs_tol));
            %
            % case of ellipses with common center
            testEllipsoid1 = ellipsoid([1 2 3].',[1,2,5;2,5,3;5,3,100]);
            testEllipsoid2 = ellipsoid([1,2,3].',[1,2,7;2,10,5;7,5,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes)<ellOptions.abs_tol));
            
            % distance between two pairs of ellipsoids 
            testEllipsoidVec1=[ellipsoid([0, -6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,-4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testEllipsoidVec2=[ellipsoid([0, 6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testResVec=distance(testEllipsoidVec1,testEllipsoidVec2);
            mlunit.assert_equals(1, (abs(testResVec(1)-8)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-5)<ellOptions.abs_tol));
            %            
            % distance between a of ellipsoids and an ellipsoid 
            testEllipsoidVec=[ellipsoid([0, 0, 0].',[9,0,0; 0,25,0; 0,0, 1]),...
                ellipsoid([-5,0,0].',[9,0,0; 0, 25,0; 0,0,1])];
            testEllipsoid=ellipsoid([5, 0, 0].',[25,0,0; 0,100,0; 0,0, 1]);
            testResVec=distance(testEllipsoidVec,testEllipsoid);
            mlunit.assert_equals(1, (abs(testResVec(1))<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-2)<ellOptions.abs_tol));

            
         end
    end
end