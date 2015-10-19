classdef mlunit_test_auxdfeval < mlunitext.test_case
    properties
        configurationProp
    end
    methods
        function self = mlunit_test_auxdfeval(varargin)
            [reg,prop] = modgen.common.parseparams(varargin,...
                {'parallelConfiguration'});
            nReg = length(reg);
            self = self@mlunitext.test_case(reg{1:min(nReg,2)});
            if ~isempty(prop)
                self.configurationProp = {'configuration', prop{2}};
            else
                self.configurationProp = {};
            end
        end
        %
        function self=test_gettaskname(self)
            %
            checkMaster(@check);
            %
            function check(fAuxFeval,fGetTask)
                [taskName,SProp]=fGetTask();
                taskName2=fGetTask();
                mlunitext.assert_equals(taskName,taskName2);
                mlunitext.assert_equals(true,SProp.isMain);
                %
                [a,b]=fAuxFeval(...
                    @(x)fGetTask(),cell(1,2));
                isOk=all(cellfun(@(x)~strcmp(x,taskName),a));
                mlunitext.assert_equals(true,isOk);
                isOk=all(cellfun(@(x)isequal(x.isMain,false),b));
                mlunitext.assert_equals(true,isOk);
            end
        end
        %
        function self=test_always_fork(self)
            checkMaster(@check);
            function check(fAuxFeval,~)
                % alwaysFork=false by default, which means that the following
                % will execute within the same process. The presistent variable
                % will be set to [1]
                fAuxFeval(@self.setPersistent,{1});
                % Check that the persistent variable is not empty and reset it
                % to []
                mlunitext.assert_equals(false, self.setPersistent([]));
                % With the flag set to true, execute setPersistent(1) in a new
                % process, which should have no effect on the presistent
                % variable within this process
                fAuxFeval(@self.setPersistent,{1},...
                    'alwaysFork',true,self.configurationProp{:});
                mlunitext.assert_equals(true, self.setPersistent([]));
            end
        end
        %
        function isEmpty = setPersistent(~,val)
            % setPersistent sets a persistent variable to val and returns
            % true if the presistent variable was empty, false otherwise
            
            persistent persistVal
            if isempty(persistVal)
                isEmpty = true;
            else
                isEmpty = false;
            end
            persistVal = val;
        end
        %
        function self=test_no_args(self)
            isParTbxInstalled=modgen.pcalc.isparttbxinst();
            %
            if isParTbxInstalled
                fAuxFeval=@modgen.pcalc.auxdfevalpcomp;
                check();
                fAuxFeval=@(varargin)modgen.pcalc.auxdfeval(varargin{:},...
                    'engSelectMode','pcalc');
                check();
            end
            function check()
                % Make sure that auxdfeval can be called for functions that
                % take no arguments
                hFunc = @()1;
                % 1 worker
                mlunitext.assert_equals(true, ...
                    isequal({1}, fAuxFeval(hFunc, cell(0,1))));
                % 2 workers
                mlunitext.assert_equals(true, ...
                    isequal({1;1}, fAuxFeval(hFunc, cell(0,2),...
                    self.configurationProp{:})));
            end
        end
        function testInOutCorrespond(~)
            checkMaster(@check);
            function check(fAuxFeval,~)
                [firstOutList,secOutList,thirdOutList]=...
                    fAuxFeval(@deal,{1,2;3,4;5 6});
                isOk=isequal(firstOutList,{1;2});
                mlunitext.assert(isOk);
                isOk=isequal(secOutList,{3;4});
                mlunitext.assert(isOk);
                isOk=isequal(thirdOutList,{5;6});
                mlunitext.assert(isOk);
                %
                [firstExpOutList,secExpOutList,...
                    thirdExpOutList]=fAuxFeval(@deal,{1,2},{3,4},...
                    {5 6});
                %
                isOk=isequal(firstOutList,firstExpOutList);
                mlunitext.assert(isOk);
                isOk=isequal(secOutList,secExpOutList);
                mlunitext.assert(isOk);
                isOk=isequal(thirdOutList,thirdExpOutList);
                mlunitext.assert(isOk);
            end
        end
        function self=test_clusterSizeProp(self)
            checkMaster(@check);
            function check(fAuxFeval,~)
                res=fAuxFeval(@deal,num2cell(1:3),...
                    'clusterSize',1);
                mlunitext.assert_equals(true,isequal(res.',num2cell(1:3)));
            end
        end
        function self=test_clusterSize1(self)
            checkMaster(@check);
            function check(fAuxFeval,fGetTask)
                res=fAuxFeval(@getTaskName,cell(1,3),'clusterSize',1);
                mlunitext.assert_equals(true,all(cellfun(@(x)isequal(x,true),res)));
                
                function isMain=getTaskName(varargin)
                    [~,SProp]=fGetTask();
                    isMain=SProp.isMain;
                end
            end
        end
    end
end
function checkMaster(fCheck)
[isParTbxInstalled,isAltPartTbxInstalled]=...
    modgen.pcalc.isparttbxinst();
%
if isParTbxInstalled||isAltPartTbxInstalled
    fAuxFeval=@modgen.pcalc.auxdfeval;
    fGetTask=@modgen.pcalc.gettaskname;
    fCheck(fAuxFeval,fGetTask);
    if isParTbxInstalled
        fAuxFeval=@modgen.pcalc.auxdfevalpcomp;
        fGetTask=@modgen.pcalc.gettasknamepcomp;
        fCheck(fAuxFeval,fGetTask);
        fAuxFeval=@(varargin)modgen.pcalc.auxdfeval(...
            varargin{:},'engSelectMode','pcalc');
        fCheck(fAuxFeval,fGetTask);
    end
    if isAltPartTbxInstalled
        fAuxFeval=@modgen.pcalcalt.auxdfeval;
        fGetTask=@modgen.pcalcalt.gettaskname;
        fCheck(fAuxFeval,fGetTask);
        fAuxFeval=@(varargin)modgen.pcalc.auxdfeval(...
            varargin{:},'engSelectMode','pcalcalt');
        fCheck(fAuxFeval,fGetTask);
    end
end
end