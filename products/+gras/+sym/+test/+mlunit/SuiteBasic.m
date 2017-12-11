classdef SuiteBasic < mlunitext.test_case
    properties
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)
            
        end
        function testVarreplace(~)
            mCMat={ 't+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    'att+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't-t^t'};
                
            fromVarName = 'tt';
            tSum = '10.8';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(15-t)+(15-t)^2+(15-t)^3+sin((15-t))'...
                     '(15-t)^(1/2)+(15-t)*(15-t)*17';...
                     'att+t2' '(15-t)+temp^(15-t)';...
                     '1/((15-t)+3)*2^(15-t)^(15-t)'...
                     '(15-t)-(15-t)^(15-t)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
    end
end