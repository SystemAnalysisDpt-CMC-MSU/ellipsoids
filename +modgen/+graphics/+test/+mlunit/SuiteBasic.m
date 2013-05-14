classdef SuiteBasic < mlunitext.test_case
    properties
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = set_up_param(self,varargin)
            %
        end
        %
        function testLightAxis(~)
            MAX_TOL=1e-15;
            hFigure=figure();
            hAxes=axes('Parent',hFigure);
            xVec=1:10;
            yVec=xVec+3;
            z1Mat=ones(length(xVec),length(yVec));
            h1Surf=surf(xVec,yVec,z1Mat,'Parent',hAxes);
            %touch test
            hLight=modgen.graphics.lightaxis(hAxes,{[0 0 1]},1,'local');
            delete(hLight);
            %
            hold on;
            z2Mat=z1Mat+10;
            hold on;
            h2Surf=surf(xVec,yVec,z2Mat,'Parent',hAxes);
            
            v1Mat = [2 4 1; ...
                2 8 1.1; ...
                8 4 1.2; ...
                8 0 1.3; ...
                0 4 1.4; ...
                2 6 1.5; ...
                2 2 1.6; ...
                4 2 1.7; ...
                4 0 1.8; ...
                5 2 1.9; ...
                5 0 2];
            
            % There are five faces, defined by connecting the
            % vertices in the order indicated.
            fMat = [ ...
                1  2  3; ...
                1  3  4; ...
                5  6  1; ...
                7  8  9; ...
                11 10 4 ];
            h1Patch=patch('Faces',fMat,'Vertices',v1Mat,...
                'FaceColor','b','Parent',hAxes);
            v2Mat=v1Mat+4;
            h2Patch=patch('Faces',fMat,'Vertices',v2Mat,...
                'FaceColor','b','Parent',hAxes);
            lightCoordList={[1.1 0 0],[-0.9 0 0],[0 0.8 0],...
                [0 -1.2 0],[0 0 1.3],[0 0 -0.7],[1.1 0.5 1.4],[-1.4 -1.4 2]};
            powerVec=[2 1 3 3 1 5 2 4];
            %xVec,yVec,z1Mat,z2Mat,v1Mat,v2Mat
            leftLimVec=getLim(@min);
            rightLimVec=getLim(@max);
            midVec=0.5*(leftLimVec+rightLimVec);
            halfRangeVec=0.5*(rightLimVec-leftLimVec);
            %
            nLights=length(powerVec);
            nLightsFirst=fix(nLights*0.5);
            lightStyleList=[repmat({'local'},1,nLightsFirst),...
                repmat({'infinite'},1,nLights-nLightsFirst)];
            
            h1LightVec=modgen.graphics.lightaxis(hAxes,lightCoordList,powerVec,...
                'local');
            hLightVec=modgen.graphics.lightaxis(hAxes,lightCoordList,powerVec,...
                lightStyleList);
            mlunitext.assert_equals(length(h1LightVec),length(hLightVec));
            mlunitext.assert_equals(sum(powerVec),length(hLightVec));
            nLightObjs=sum(powerVec);
            indRefVec=zeros(1,nLightObjs);
            powerCumVec=cumsum(powerVec(1:end-1))+1;
            indRefVec(powerCumVec)=1;
            indRefVec=cumsum(indRefVec)+1;
            for iLightObj=1:nLightObjs
                lightStyle=get(hLightVec(iLightObj),'Style');
                lightCoordVec=get(hLightVec(iLightObj),'Position');
                if strcmpi(lightStyle,'local')
                    lightCoordVec=lightCoordVec-midVec;
                end
                lightCoordVec=lightCoordVec./halfRangeVec;
                expLightCoordVec=lightCoordList{indRefVec(iLightObj)};
                %
                isEqual=all(max(abs(lightCoordVec-expLightCoordVec))<MAX_TOL);
                mlunitext.assert_equals(true,isEqual);
            end
            close(hFigure);
            function limVec=getLim(hFunc)
                limVec=[hFunc(hFunc(xVec),hFunc(hFunc(v1Mat(:,1)),hFunc(v2Mat(:,1)))),...
                    hFunc(hFunc(yVec),hFunc(hFunc(v1Mat(:,2)),hFunc(v2Mat(:,2)))),...
                    hFunc(hFunc(hFunc(z1Mat(:)),hFunc(z2Mat(:))),...
                    hFunc(hFunc(v1Mat(:,3)),hFunc(v2Mat(:,3))))];
            end
        end
        function testPlot3Adv(~)
            hFig=figure();
            hAxes=axes('Parent',hFig);
            t = transpose(0:pi/50:10*pi);
            vMat=[sin(t),cos(t),t];
            cMat=abs(vMat)./repmat(max(abs(vMat),[],2),1,3);
            xlabel('sin(t)');
            ylabel('cos(t)');
            zlabel('t');
            %
            h=modgen.graphics.plot3adv(vMat(:,1),vMat(:,2),vMat(:,3),...
                cMat,'Parent',hAxes);
            view(3);
            hParent=get(h,'Parent');
            mlunitext.assert_equals(hAxes,hParent);
            delete(hFig);
        end
    end
end