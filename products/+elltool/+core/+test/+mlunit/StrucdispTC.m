classdef StrucdispTC < mlunitext.test_case
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods (Access = public)
        function self = StrucdispTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = testArrays(self)
            S = struct('a', 1);
            str = evalc('strucdisp(S)');
            isOk = ~isempty(strfind(str, '1'));
            
            S = struct('a', [1 2 3]);
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[1 2 3]'));
            
            S = struct('a', ones(5, 3, 2));
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[5x3x2 Array]'));
            
            mlunitext.assert_equals(isOk, true);
        end
        
        function self = testLogicalFields(self)
            S = struct('a', false(1, 2));
            str = evalc('strucdisp(S)');
            isOk = ~isempty(strfind(str, '[false false]'));
            
            S = struct('a', false);
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, 'false'));
            
            S = struct('a', false(5));
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[5x5 Logic array]'));
            
            mlunitext.assert_equals(isOk, true);
        end
    end
end