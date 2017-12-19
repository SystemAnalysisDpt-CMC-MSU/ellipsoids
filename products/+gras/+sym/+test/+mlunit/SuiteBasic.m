classdef SuiteBasic < mlunitext.test_case
    
    properties (GetAccess=private,Constant)
        N_COMPARE_DECIMAL_DIGITS = 15
    end
    
    methods (Access=private,Static)
        function isOk = compareCMatWithNumerics(self,mCMat,resCMat,corCMat)
            isNumMat = cellfun('isclass',mCMat,'double');
            isEqMat = false(size(isNumMat));
            isEqMat(~isNumMat) = ...
                cellfun(@isequal,corCMat(~isNumMat),resCMat(~isNumMat));
            isEqMat(isNumMat) = ...
                cellfun(@(x,y)cmpuptodigits(x,y,...
                self.N_COMPARE_DECIMAL_DIGITS),corCMat(isNumMat),...
                resCMat(isNumMat));
            isOk = all(isEqMat(:));
            
            function isEq = cmpuptodigits(firstNumStr,secondNumStr,nCmpDigits)
                [firstNumStr,firstFracStr] = strtok(firstNumStr, '.');
                [secondNumStr,secondFracStr] = strtok(secondNumStr, '.');
                isEq = strcmp(firstNumStr,secondNumStr) &&...
                    (isempty(firstFracStr) == isempty(secondFracStr));
                if isEq && ~isempty(firstFracStr)
                    isEq = strncmp(firstFracStr, secondFracStr, nCmpDigits + 1);
                end
            end
        end
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
                
        function testVarreplaceInt(~)
            mCMat={'t+t^2+t^3+sin(t)', 't^(1/2)+t*t*17';...
                'att+t2', 't+temp^t';...
                '1/(t+3)*2^t^t', 't-t^t'};
            
            fromVarName = 't';
            tSum = '15';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(15-t)+(15-t)^2+(15-t)^3+sin((15-t))', '(15-t)^(1/2)+(15-t)*(15-t)*17';...
                'att+t2',                               '(15-t)+temp^(15-t)';...
                '1/((15-t)+3)*2^(15-t)^(15-t)',         '(15-t)-(15-t)^(15-t)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceReal(~)
            mCMat={'t+t^2+t^3+sin(t)', 't^(1/2)+t*t*17';...
                'att+t2',           't+temp^t';...
                '1/(t+3)*2^t^t',    't-t^t'};
            
            fromVarName = 'att';
            tSum = '10.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'t+t^2+t^3+sin(t)', 't^(1/2)+t*t*17';...
                '(10.8-att)+t2',    't+temp^t';...
                '1/(t+3)*2^t^t',    't-t^t'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceSpaces(~)
            mCMat={'t +      t^2+t^3+sin(t)', 't ^( 1/2)+t*t *17';...
                   'att +t2',                 't+temp^t';...
                   '1/(t+3)*2^t^t',           't -t^ t'};
            
            fromVarName = 't';
            tSum = '15';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(15-t)+(15-t)^2+(15-t)^3+sin((15-t))', '(15-t)^(1/2)+(15-t)*(15-t)*17';...
                'att+t2',                                    '(15-t)+temp^(15-t)';...
                '1/((15-t)+3)*2^(15-t)^(15-t)',              '(15-t)-(15-t)^(15-t)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceCombOfVars(~)
            mCMat={'t+tt+   ttt',     't^(t/2)+t*tt-t';...
                'atttt+ttt2',      't+temp^t+0.1';...
                '1/(t+3)*2^tt^ts', 'st-t^t'};
            
            fromVarName = 't';
            tSum = '0.01';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(0.01-t)+tt+ttt',        '(0.01-t)^((0.01-t)/2)+(0.01-t)*tt-(0.01-t)';...
                'atttt+ttt2',             '(0.01-t)+temp^(0.01-t)+0.1';...
                '1/((0.01-t)+3)*2^tt^ts', 'st-(0.01-t)^(0.01-t)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceVec(~)
            mCMat={'tt + t^3+sin(cos(tt))', 't^(1/2)+t*t*17', 'tt'};
            
            fromVarName = 'tt';
            tSum = '0.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(0.8-tt)+t^3+sin(cos((0.8-tt)))', 't^(1/2)+t*t*17', '(0.8-tt)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceOneElem(~)
            mCMat={'tt'};
            
            fromVarName = 'tt';
            tSum = '0.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'(0.8-tt)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceNoToRepVar(~)
            mCMat={'t'};
            
            fromVarName = 'tt';
            tSum = '0.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'t'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceNoToRepFun(~)
            mCMat={'sqrt(tt)'};
            
            fromVarName = 't';
            tSum = '0.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'sqrt(tt)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceNoToRepMat(~)
            mCMat={'exp(t)',      'sin(ttt)', '-t';...
                'tttt',        't_ttt',     '-0.6*t';...
                'tan(exp(t))', 'exp(10)', 'cos(t - ttt)'};
            
            fromVarName = 'tt';
            tSum = '0.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'exp(t)',      'sin(ttt)', '-t';...
                'tttt',        't_ttt',     '-0.6*t';...
                'tan(exp(t))', 'exp(10)', 'cos(t-ttt)'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceOneIntElem(~)
            mCMat={150};
            
            fromVarName = 'att';
            tSum = '10.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'150'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceMatInt(~)
            mCMat={150, 1,  2;
                -10, 30, 100;
                1,   0,  -190};
            
            fromVarName = 'att';
            tSum = '10.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'150', '1',  '2';
                '-10', '30', '100';
                '1',   '0',  '-190'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceOneRealElem(self)
            mCMat={0.01};
            
            fromVarName = 'att';
            tSum = '10.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'0.01'};
            isOk = self.compareCMatWithNumerics(self,mCMat,resCMat,corCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        
        function testVarreplaceMatreal(self)
            mCMat={150.1, 1.08,  2.09;
                -10.008, 30.1, 100.01;
                1.1,   0.556,  -190.901};
            
            fromVarName = 'att';
            tSum = '10.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'150.1',   '1.08',  '2.09';
                     '-10.008', '30.1',  '100.01';
                     '1.1',     '0.556', '-190.901'};
            isOk = self.compareCMatWithNumerics(self,mCMat,resCMat,corCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceIntElem(~)
            mCMat={'t+t^2+t^3+sin(t)', 't^(1/2)+t*t*17';...
                'att+t2',           't+temp^t';...
                '1/(t+3)*2^t^t',     1};
            
            fromVarName = 'att';
            tSum = '10.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'t+t^2+t^3+sin(t)', 't^(1/2)+t*t*17';...
                '(10.8-att)+t2',    't+temp^t';...
                '1/(t+3)*2^t^t',    '1'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceRealElem(self)
            mCMat={'3.2',           't';...
                'att+t2',        't+temp^t';...
                '1/(t+3)*2^t^t', 1.9};
            
            fromVarName = 'att';
            tSum = '10.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'3.2',           't';...
                '(10.8-att)+t2', 't+temp^t';...
                '1/(t+3)*2^t^t', '1.9'};
            isOk = self.compareCMatWithNumerics(self,mCMat,resCMat,corCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceMixedElems(self)
            mCMat={'3.2',    't + 3.2';...
                9.8,      -34;...
                'sin(t)', 1.9};
            
            fromVarName = 't';
            tSum = '0.81';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'3.2',           '(0.81-t)+3.2';...
                     '9.8',           '-34';...
                     'sin((0.81-t))', '1.9'};
            isOk = self.compareCMatWithNumerics(self,mCMat,resCMat,corCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testSymbolic(~)
            if isempty(ver('Symbolic'))
                return;
            end
            syms t;
            mCMat={sin(t), 10;
                'cos(2*t)', sin(3*t)};
            
            fromVarName = 't';
            tSum = '1';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'sin((1-t))', '10';
                'cos(2*(1-t))', 'sin(3*(1-t))'};
            isOk=isequal(corCMat, resCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceAll(self)
            if isempty(ver('Symbolic'))
                return;
            end
            syms t tt;
            mCMat={sin(t), 10, exp(tt);
                'cos(2*t)', sin(3*t), -1.09;
                '     3*t*tt', t + tt, 1};
            
            fromVarName = 't';
            tSum = '1';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName);
            resCMat=gras.sym.varreplace(mCMat, fromVarName, toVarName);
            
            corCMat={'sin((1-t))', '10', 'exp(tt)';
                'cos(2*(1-t))', 'sin(3*(1-t))', '-1.09';
                '3*(1-t)*tt', '(1-t)+tt', '1'};
            isOk = self.compareCMatWithNumerics(self,mCMat,resCMat,corCMat);
            mlunitext.assert_equals(true,isOk);
        end
        
        function testVarreplaceWrongInArgs(self)
            mCMat={'t+t^2+t^3+sin(t)', 't^(1/2)+t*t*17';...
                'att+t2',           't+temp^t';...
                '1/(t+3)*2^t^t',    't-t^t'}; %#ok<NASGU>
            
            fromVarName = 'att';
            tSum = '10.8';
            
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName); %#ok<NASGU>
            
            self.runAndCheckError(...
                'gras.sym.varreplace(mCMat, fromVarName)',...
                ':wrongInput');
        end
        
        
        function testVarreplaceEmptMat(self)
            mCMat={}; %#ok<NASGU>
            
            fromVarName = 't';
            tSum = '0.01';
            toVarName = strcat(tSum,'-');
            toVarName = strcat(toVarName, fromVarName); %#ok<NASGU>
            self.runAndCheckError(...
                'gras.sym.varreplace(mCMat, fromVarName, toVarName)',...
                ':wrongInput');
        end
    end
end
