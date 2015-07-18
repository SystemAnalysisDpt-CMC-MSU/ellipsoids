classdef BasicTC<mlunitext.test_case
    properties (Access=private)
        isReCache
        testDataRootDir
    end
    %
    methods
        function tear_down(~)
            close all;
        end
        function self=BasicTC(varargin)
            self=self@mlunitext.test_case(varargin{:});
        end
        function set_up_param(self,varargin)
            [~,~,self.isReCache]=modgen.common.parseparext(varargin,...
                {'reCache';false;'islogical(x)'});
            %
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',filesep,shortClassName];
        end
        function testCompareWithPlotts(self)
            import modgen.graphics.bld.*;
            x=(1:10).';
            y=2*(x-5);
            width=0.1*ones(size(x));
            z=(-10:-1);
            %%
            [hAxesVec,hGraphVec]=plotts('xCell',{x,x,x},'yCell',{sin(x),cos(x),tan(x)},'groupMembership',[1,2,1],...
                'groupAreaDistr',[0.3 0.7],'graphLegends',{'sin(x)','cos(x)','tan(x)'},...
                'groupYLabels',{'aaaa','bbbb'},'figureName','myfigure','graphPlotSpecs',{'c','b','g'},...
                'graphTypes',{'plot','bar','plot'},'fontSize',8);
            %
            sinGraphObj=Graph(x,sin(x),...
                'legend','sin(x)','plotSpecs','c',...
                'type','plot');
            cosGraphObj=Graph(x,cos(x),...
                'legend','cos(x)','plotSpecs','b',...
                'type','bar');
            tanGraphObj=Graph(x,tan(x),...
                'legend','tan(x)','plotSpecs','g',...
                'type','plot');
            sintanGroupObj=GraphGroup({sinGraphObj,tanGraphObj},...
                'groupYLabel','aaaa');
            sintanPlaceObj=GroupPlace({sintanGroupObj},...
                'areaDistr',0.3);
            cosGroupObj=GraphGroup({cosGraphObj},...
                'groupYLabel','bbbb');
            cosPlaceObj=GroupPlace({cosGroupObj},...
                'areaDistr',0.7);
            figureObj=Figure({sintanPlaceObj,cosPlaceObj},...
                'figureName','myfigure','fontSize',8);
            %
            check(figureObj,hAxesVec,hGraphVec,'1');
            %%
            [hAxesVec,hGraphVec]=plotts('xCell',{x,x},'yCell',{y,zeros(1,numel(x))},'widthCell',{width,[]},...
                'groupMembership',[1 1],'graphLegends',{'data','qwert'},...
                'groupYLabels',{'aaaa'},'figureName','myfigure',...
                'graphPlotSpecs',{'g','r*'},'graphTypes',{'widthbar','plot'},'fontSize',12);
            %
            yGraphObj=Graph(x,y,'barWidthVec',width,...
                'legend','data',...
                'plotSpecs','g','type','widthbar');
            zeroGraphObj=Graph(x,zeros(size(x)),...
                'legend','qwert','plotSpecs','r*','type','plot');
            yzeroGroupObj=GraphGroup({yGraphObj,zeroGraphObj},...
                'groupYLabel','aaaa');
            yzeroPlaceObj=GroupPlace({yzeroGroupObj});
            figureObj=Figure({yzeroPlaceObj},'figureName','myfigure',...
                'fontSize',12);
            %
            check(figureObj,hAxesVec,hGraphVec,'2');
            %%
            [hAxesVec,hGraphVec]=plotts('xCell',{x,z},'yCell',{y,zeros(1,numel(z))},...
                'groupMembership',[1 2],'placeMembership',[1 1],'graphLegends',{'data','xData'},...
                'groupYLabels',{'aaaa','2222'},'figureName','myfigure',...
                'groupYAxisLocations',[cell(1,1),{'right'}],...
                'groupXAxisLocations',[cell(1,1),{'top'}],...
                'graphPlotSpecs',{'g','r'},'markerName',{'none','*'},...
                'markerSize',[1 5],'graphTypes',{'area','plot'},'fontSize',12,...
                'xTypes',{'numbers','numbers'},...
                'groupPropSetFuncList',[cell(1,1),{...
                @(hAxes)set(hAxes,'XGrid','off','YGrid','off')}]);
            %
            yGraphObj=Graph(x,y,'legend','data','plotSpecs','g',...
                'markerSize',1,'markerName','none','type','area');
            zeroGraphObj=Graph(z,zeros(size(z)),...
                'legend','xData','plotSpecs','r','markerName','*',...
                'markerSize',5,'type','plot');
            yGroupObj=GraphGroup({yGraphObj},...
                'groupYLabel','aaaa',...
                'xType','numbers');
            zeroGroupObj=GraphGroup({zeroGraphObj},...
                'groupYLabel','2222',...
                'xAxisLocation','top',...
                'yAxisLocation','right',...
                'xType','numbers');
            yzeroPlaceObj=GroupPlace({yGroupObj,zeroGroupObj});
            figureObj=Figure({yzeroPlaceObj},'figureName','myfigure',...
                'fontSize',12,'synchroDates',false);
            %
            check(figureObj,hAxesVec,hGraphVec,'3');
            
            function check(figureObj,hAxesVec,hGraphVec,markerStr)
                import modgen.graphics.bld.*;
                hParentVec=getParentVec(hAxesVec);
                mlunitext.assert_equals(1,numel(unique(hParentVec)));
                hFig1=hParentVec(1);
                %
                hParentVec=getParentVec(hGraphVec);
                [~,indMemb1Vec]=ismember(hParentVec,hAxesVec);
                %
                handleMap=FigureBuilder.createFigure(figureObj);
                hFig2=handleMap.getValue(figureObj);
                mlunitext.assert_not_equals(true,isnan(hFig2));
                groupCVec=handleMap.getKeysForType(...
                        'modgen.graphics.bld.GraphGroup');
                hAxes2Vec=cellfun(@(x)handleMap.getValue(x),groupCVec);
                mlunitext.assert_not_equals(true,any(isnan(hAxes2Vec)));
                hParentVec=getParentVec(hAxes2Vec);
                mlunitext.assert_equals(true,all(hParentVec==hFig2));
                graphCVec=cellfun(@(x)x.graphCVec,groupCVec,...
                    'UniformOutput',false);
                graphCVec=horzcat(graphCVec{:});
                hGraph2Vec=cellfun(@(x)handleMap.getValue(x),graphCVec);
                mlunitext.assert_not_equals(true,any(isnan(hGraph2Vec)));
                hParentVec=getParentVec(hGraph2Vec);
                [~,indMemb2Vec]=ismember(hParentVec,hAxes2Vec);
                mlunitext.assert(isequal(sort(indMemb1Vec),indMemb2Vec));
                %
                hFigVec=[hFig1 hFig2];
                self.checkPlotting(hFigVec,markerStr);
                close(hFigVec);
                
                function hVec=getParentVec(hVec)
                    hVec=get(hVec,'Parent');
                    if iscell(hVec),
                        hVec=horzcat(hVec{:});
                    end
                end
            end
        end
        function testSeveralAxesOnPlace(self)
            import modgen.graphics.bld.*;
            x=(1:10).';
            group0Obj=GraphGroup({},...
                'yAxisLocation','left',...
                'propSetFunc',@(hAxes)set(hAxes,...
                'YTickLabelMode','manual','YTickLabel',[],'YTick',[]));
            graph1Obj=Graph(x,sin(x),...
                'type','plot','legend','sin(x)','plotSpecs','r');
            group1Obj=GraphGroup({graph1Obj},...
                'yAxisLocation','left');
            graph2Obj=Graph(x,cos(x),...
                'type','area','legend','cos(x)','plotSpecs','g');
            group2Obj=GraphGroup({graph2Obj},...
                'yAxisLocation','right');
            graph3Obj=Graph(x,tan(x),...
                'type','bar','legend','tan(x)','plotSpecs','b');
            group3Obj=GraphGroup({graph3Obj},...
                'yAxisLocation','right');
            placeObj=GroupPlace({group0Obj,group1Obj,...
                group2Obj,group3Obj});
            figureObj=Figure({placeObj});
            handleMap=FigureBuilder.createFigure(figureObj);
            hFigure=handleMap.getValue(figureObj);
            mlunitext.assert(~isnan(hFigure));
            self.checkPlotting(hFigure,'1');
            close(hFigure);
        end
    end
    methods (Access=protected)
        function checkPlotting(self,hFigVec,markerStr)
            testName=modgen.common.getcallernameext(2);
            resMap=modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[testName,'_out'],...
                'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            %
            nFigs=numel(hFigVec);
            mlunitext.assert_equals(true,nFigs>=1);
            SFigInfo=[];
            for iFig=1:nFigs,
                hFig=hFigVec(iFig);
                SNextFigInfo=self.getFigInfo(hFig);
                if iFig==1,
                    SFigInfo=SNextFigInfo;
                else
                    [isOk,reportStr]=modgen.struct.structcompare(...
                        SFigInfo,SNextFigInfo);
                    mlunitext.assert(isOk,...
                        ['Fig #%d does not coincide with Fig #%d: '...
                        reportStr]);
                end
            end
            %
            figName=get(hFig,'Name');
            %
            keyName=[figName '_' markerStr];
            if self.isReCache||~resMap.isKey(keyName);
                SExpFigInfo=SFigInfo;
                resMap.put(keyName,SExpFigInfo);
            end
            SExpFigInfo=resMap.get(keyName);
            [isOk,reportStr]=modgen.struct.structcompare(SExpFigInfo,SFigInfo);
            mlunitext.assert(isOk,reportStr);
        end
    end
    methods (Static,Access=protected)
        function SFigInfo=getFigInfo(hFig)
            removeFieldPatterns={...
                'Current','Fcn','WindowStyle','Paper','Renderer',...
                'Camera','Position','Extent','TightInset','Lim','Tick','TickLabel',...
                'AspectRatio','BaseLine','Parent','DockControls',...
                'WVisual','WVisualMode','XDisplay','XVisual','XVisualMode'};
            nRemoveFieldPatterns=numel(removeFieldPatterns);
            nonHandleFieldPatterns={...
                'Alpha','Color','Width','View','Data','Margin',...
                'Rotation','Size','Value'};
            SFigInfo=get(hFig);
            fieldNameList=fieldnames(SFigInfo);
            isFieldVec=true(1,numel(fieldNameList));
            for iRemoveFieldPattern=1:nRemoveFieldPatterns,
                removeFieldPattern=removeFieldPatterns{iRemoveFieldPattern};
                isFieldVec(isFieldVec)=cellfun(...
                    @(x)isempty(strfind(x,removeFieldPattern)),...
                    fieldNameList(isFieldVec));
                if ~any(isFieldVec),
                    break;
                end
            end
            SFigInfo=rmfield(SFigInfo,fieldNameList(~isFieldVec));
            fieldNameList=fieldNameList(isFieldVec);
            nFields=numel(fieldNameList);
            for iField=1:nFields,
                fieldName=fieldNameList{iField};
                val=SFigInfo.(fieldName);
                if isobject(val)||isjava(val)||strncmp(class(val),'hg.',3),
                    SFigInfo=rmfield(SFigInfo,fieldName);
                end
                if any(cellfun(@(x)~isempty(strfind(fieldName,x)),...
                        nonHandleFieldPatterns)),
                    continue;
                end
                if isempty(val),
                    continue;
                end
                if ~(isnumeric(val)&&isreal(val)&&numel(val)==length(val)),
                    continue;
                end
                if any(val==0)||~all(ishandle(val)),
                    continue;
                end
                hParentVec=get(val,'Parent');
                if iscell(hParentVec),
                    hParentVec=vertcat(hParentVec{:});
                end
                if numel(hParentVec)==numel(val)&&all(hParentVec==hFig),
                    nVals=numel(val);
                    curCell=cell(1,nVals);
                    for iVal=1:nVals,
                        curCell{iVal}=feval(...
                            [mfilename('class') '.getFigInfo'],val(iVal));
                    end
                    SFigInfo.(fieldName)=curCell;
                end
            end
        end
    end
end