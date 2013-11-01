classdef TestSuite < mlunitext.test_case
    properties 
    end
    
    methods
        function self = TestSuite(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)

        end
        function testCellStr2Expression(~)
            inpCMat={'cos(t)','sin(t)';'-sin(t)','cos(t)'};
            timeVec=0:0.1:2*pi;
            etArray=evalStrMat(inpCMat,timeVec);
            resArray=evalOptMat(inpCMat,timeVec);
            fcnArray=evalFcnMat(inpCMat,timeVec);
            mlunitext.assert_equals(true,isequal(etArray,resArray));
            mlunitext.assert_equals(true,isequal(fcnArray,resArray));
            %
            function resArray=evalFcnMat(X,t)
                fHandle=modgen.cell.cellstr2func(X,'t');
                t=shiftdim(t,-1);
                resArray=fHandle(t);
            end
            function resArray=evalOptMat(X,t)
                expStr=modgen.cell.cellstr2expression(X);
                t=shiftdim(t,-1);
                resArray=eval(expStr);
            end
            %
            function Y=evalStrMat(X,t)
                msize=size(X);
                tsize=size(t);
                Y=zeros([msize tsize(2)]);
                for i=1:1:msize(1)
                    for j=1:1:msize(2)
                        Y(i,j,:)=eval(vectorize(X{i,j}));
                    end
                end
            end
        end
        function self=test_parseparams_negative(self)
            inpVar={};
            resStr=evalc('showcell(inpVar);');
            mlunitext.assert_equals(true,...
                ~isempty(findstr(resStr,'inpVar')));
            commandStr='showcell(inpVar,''printVarName'',false)';
            %
            resStr=evalc(commandStr);
            mlunitext.assert_equals(false,...
                ~isempty(findstr(resStr,'inpVar')));
        end
        function testShowCellOnEnum(self)
            if ~verLessThan('matlab','7.12')
                inpCell=cell(2,3);
                inpCell{1,2}=1;
                inpCell{2,2}=2;
                inpCell{1,3}=modgen.cell.test.ShowCellTestEnum.Internal;
                inpCell{2,3}=[modgen.cell.test.ShowCellTestEnum.Internal,...
                    ;modgen.cell.test.ShowCellTestEnum.External];
                inpCell{1,1}=repmat(...
                    modgen.cell.test.ShowCellTestEnum.Internal,[1,1,2,2]);
                resStr=evalc('showcell(inpCell,''printVarName'',false);');
                resStrList=strsplit(resStr,sprintf('\n'));
                resStrExpList={...
                    '[4-D modgen.cell.test.ShowCellTestEnum]    [1]    [Internal]',...
                    '[]                                         [2]    [2x1 modgen.cell.test.ShowCellTestEnum]'};
                mlunitext.assert_equals(true,isequal(resStrList,resStrExpList));
            end
        end
        function testShowCellOfCharCols(self)
            inpCell={'a',1;'bb'.' 2};
            resStr=evalc('display(inpCell)');
            mlunitext.assert_equals(true,~isempty(findstr(resStr,'inpCell =')));
            resStr=evalc('disp(inpCell)');
            mlunitext.assert_equals(true,isempty(findstr(resStr,'inpCell =')));
            %
            inpCell={repmat('z',10,1)};
            evalc('showcell(inpCell)');
            res={repmat('z',10,1)};
            evalc('res');
        end
        function testShowCellOfStruct(~)
            showcell({struct(),struct(),struct()});
        end
        function testShowCellOfSomeClass(~)
            inpCell={modgen.cell.test.SomeClass()};
            evalc('showcell(inpCell)');
        end
    end
end