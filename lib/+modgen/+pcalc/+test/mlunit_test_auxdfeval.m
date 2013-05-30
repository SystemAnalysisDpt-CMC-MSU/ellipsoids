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
            [taskName,SProp]=modgen.pcalc.gettaskname();
            taskName2=modgen.pcalc.gettaskname();
            mlunitext.assert_equals(taskName,taskName2);
            mlunitext.assert_equals(true,SProp.isMain);
            [a,b]=modgen.pcalc.auxdfeval(...
                @(x)modgen.pcalc.gettaskname(),cell(1,2));
            isOk=all(cellfun(@(x)~strcmp(x,taskName),a));
            mlunitext.assert_equals(true,isOk);
            isOk=all(cellfun(@(x)isequal(x.isMain,false),b));
            mlunitext.assert_equals(true,isOk);
        end
        %
        function self=test_always_fork(self)
            % alwaysFork=false by default, which means that the following
            % will execute within the same process. The presistent variable
            % will be set to [1]
            modgen.pcalc.auxdfeval(@self.setPersistent,{1});
            % Check that the persistent variable is not empty and reset it
            % to []
            mlunitext.assert_equals(false, self.setPersistent([]));
            % With the flag set to true, execute setPersistent(1) in a new
            % process, which should have no effect on the presistent
            % variable within this process
            modgen.pcalc.auxdfeval(@self.setPersistent,{1},'alwaysFork',true,...
                self.configurationProp{:});
            mlunitext.assert_equals(true, self.setPersistent([]));
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
            % Make sure that auxdfeval can be called for functions that
            % take no arguments
            hFunc = @()1;
            % 1 worker
            mlunitext.assert_equals(true, ...
                isequal({1}, modgen.pcalc.auxdfeval(hFunc, cell(0,1))));
            % 2 workers
            mlunitext.assert_equals(true, ...
                isequal({1;1}, modgen.pcalc.auxdfeval(hFunc, cell(0,2),...
                self.configurationProp{:})));
        end
        function self=test_clusterSizeProp(self)
            res=modgen.pcalc.auxdfeval(@deal,num2cell(1:3),'clusterSize',1);
            mlunitext.assert_equals(true,isequal(res.',num2cell(1:3)));
        end
        function self=test_clusterSize1(self)
            res=modgen.pcalc.auxdfeval(@getTaskName,cell(1,3),'clusterSize',1);
            mlunitext.assert_equals(true,all(cellfun(@(x)isequal(x,true),res)));
            
            function isMain=getTaskName(varargin)
                [~,SProp]=modgen.pcalc.gettaskname();
                isMain=SProp.isMain;
            end
        end
    end
end