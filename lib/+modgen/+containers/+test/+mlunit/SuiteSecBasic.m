classdef SuiteSecBasic < mlunitext.test_case
    %
    methods
        function self = SuiteSecBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testMapAutoKey(~)
            c=modgen.containers.MapAutoKey(...
                'directPrefix','EE','autoPrefix','ZZZ');
            %
            c.putDirect('a',2);
            c.putDirect('b',3);
            c.putDirect('cc',4);
            c.putAuto(333);
            c.putAuto(33);
            keyList=c.keys;
            valueList=c.values;
            mlunitext.assert(isequal(keyList,...
                {'EEa','EEb','EEcc','ZZZ1','ZZZ2'}));
            mlunitext.assert(isequal(valueList,{2,3,4,333,33}));
            mlunitext.assert(isequal(333,c.get('ZZZ1')));
            mlunitext.assert(isequal(3,c.get('EEb')));
            c.remove({'EEb','ZZZ1'});
            keyList=c.keys;
            valueList=c.values;
            %
            mlunitext.assert(isequal(keyList,...
                {'EEa','EEcc','ZZZ2'}));
            mlunitext.assert(isequal(valueList,{2,4,33}));
        end
    end
end