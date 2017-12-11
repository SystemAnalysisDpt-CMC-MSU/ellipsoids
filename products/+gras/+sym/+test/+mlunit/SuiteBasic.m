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
        
        function testVarreplaceInteger(self)
            mCMat={ 't+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    'att+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't-t^t'};
                
            fromVarName = 't';
            tSum = '15';
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
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceReal(self)
            mCMat={ 't+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    'att+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't-t^t'};
                
            fromVarName = 'att';
            tSum = '10.8';
  
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'t+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    '(10.8-att)+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't-t^t'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceSpaces(self)
            mCMat={ 't +      t^2+t^3+sin(t)' 't ^( 1/2)+t*t *17';...
                    'att +t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't -t^ t'};
                
            fromVarName = 't';
            tSum = '15';
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
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceCombinationsOfVariables(self)
            mCMat={ 't+tt+   ttt' 't^(t/2)+t*tt-t';...
                    'atttt+ttt2' 't+temp^t+0.1';...
                    '1/(t+3)*2^tt^ts' 'st-t^t'};
                
            fromVarName = 't';
            tSum = '0.01';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(0.01-t)+tt+ttt' '(0.01-t)^((0.01-t)/2)+(0.01-t)*tt-(0.01-t)';...
                    'atttt+ttt2' '(0.01-t)+temp^(0.01-t)+0.1';...
                    '1/((0.01-t)+3)*2^tt^ts' 'st-(0.01-t)^(0.01-t)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceVector(self)
            mCMat={'tt + t^3+sin(cos(tt))' 't^(1/2)+t*t*17' 'tt'};
                
            fromVarName = 'tt';
            tSum = '0.8';
  
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(0.8-tt)+t^3+sin(cos((0.8-tt)))' 't^(1/2)+t*t*17' '(0.8-tt)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceOneElement(self)
            mCMat={'tt'};
                
            fromVarName = 'tt';
            tSum = '0.8';
  
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(0.8-tt)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceNothingToReplace(self)
            mCMat={'t'};
                
            fromVarName = 'tt';
            tSum = '0.8';
  
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'t'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceNothingToReplace1(self)
            mCMat={'sqrt(tt)'};
                
            fromVarName = 't';
            tSum = '0.8';
  
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'sqrt(tt)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        %error tests
        function testVarreplaceNotEnoughInputArguments(self)
            mCMat={ 't+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    'att+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't-t^t'};
                
            fromVarName = 'att';
            tSum = '10.8';
  
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName);
            
            corCMat={'t+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    '(10.8-att)+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't-t^t'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceIsCellStr(self)
            mCMat={ 't+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    'att+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 1};
                
            fromVarName = 'att';
            tSum = '10.8';
  
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'t+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    '(10.8-att)+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' '1'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceWrongClassVariable(self)
            mCMat={ 't+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    'att+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't-t^t'};
                
            fromVarName = {'att'};
            tSum = '10.8';
  
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'t+t^2+t^3+sin(t)' 't^(1/2)+t*t*17';...
                    '(10.8-att)+t2' 't+temp^t';...
                    '1/(t+3)*2^t^t' 't-t^t'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
        
        function testVarreplaceEmptyMatrix(self)
            mCMat={};
                
            fromVarName = 't';
            tSum = '0.01';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);  
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(0.01-t)+tt+ttt' '(0.01-t)^((0.01-t)/2)+(0.01-t)*tt-(0.01-t)';...
                    'atttt+ttt2' '(0.01-t)+temp^(0.01-t)+0.1';...
                    '1/((0.01-t)+3)*2^tt^ts' 'st-(0.01-t)^(0.01-t)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
            self.runAndCheckError('gras.sym.varreplace([])',':wrongInput');
        end
    end
end