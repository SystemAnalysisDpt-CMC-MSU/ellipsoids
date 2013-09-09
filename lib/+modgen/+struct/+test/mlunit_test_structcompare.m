classdef mlunit_test_structcompare < mlunitext.test_case
    properties
        SXComp
        SYComp
    end
    methods
        function self = set_up_param(self,varargin)
            s.a=1;
            s.b=2;
            S(1)=s;
            S(2)=s;
            S2=S;
            S(2).b=3;
            X=S;
            Y=S;
            X([1 2])=S;
            Y([1 2])=S2;
            [X.c]=deal(S);
            [Y.c]=deal(S2);
            X=[X;X];
            Y=[Y;Y];
            self.SXComp=X;
            self.SYComp=Y;
        end
        function self = mlunit_test_structcompare(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = test_simplestruct_positive(self)
            S1=struct('a',1,'b',2);
            S2=struct('a',2,'b',2);
            isEqual=modgen.struct.structcompare(S1,S2,0);
            mlunitext.assert_equals(isEqual,false);
        end
        %
        function testVectorialStruct(~)
            S1=struct();
            S1(2,2).alpha=4;
            S2=struct();
            S2(4).alpha=4;
            check();
            %
            S1=struct();
            S1.alpha(2,3).a=6;
            %
            S2=struct();
            S2.alpha(6).a=6;
            check();
            function check()
                isEqual=modgen.struct.structcompare(S1,S2);
                mlunitext.assert_equals(false,isEqual);
            end
        end
        %
        function self = test_simplestruct_int64(self)
            check(int64(1),int64(1),0,true);
            check(uint64(1),uint64(2),3,true);
            check(uint64(1),uint64(2),0,false);
            %
            function check(value1,value2,tol,expRes)
            S1=struct('a',1,'b',value1);
            S2=struct('a',1,'b',value2);
            isEqual=modgen.struct.structcompare(S1,S2,tol);
            mlunitext.assert_equals(isEqual,expRes);
            end
        end
        %
        function testInf(~)
            S1=struct('a',1,'b',[nan inf -inf 1]);
            isEqual=modgen.struct.structcompare(S1,S1,0);
            mlunitext.assert_equals(isEqual,true);
        end
        %
        function self = test_simplestruct_negative(self)
            S1=struct('a',1,'b',nan);
            S2=struct('a',1,'b',2);
            isEqual=modgen.struct.structcompare(S1,S2,0);
            mlunitext.assert_equals(isEqual,false);
        end
        function self = test_simplestruct_negative2(self)
            S1=struct('a',1,'b',2);
            S2=struct('a',1,'b',2);
            isEqual=modgen.struct.structcompare(S1,S2,0);
            mlunitext.assert_equals(isEqual,true);
        end
        function self = test_simplestruct2_negative(self)
            S1=struct('a',struct('a',1+1e-10,'b',1),'b',2);
            S2=struct('a',struct('a',1,'b',1),'b',2);
            isEqual=modgen.struct.structcompare(S1,S2,1e-11);
            mlunitext.assert_equals(isEqual,false);
        end        
        function self = test_simplestruct2_positive(self)
            S1=struct('a',struct('a',1+1e-10,'b',1),'b',2);
            S2=struct('a',struct('a',1,'b',1),'b',2);
            [isEqual,reportStr]=modgen.struct.structcompare(S1,S2,1e-9);
            mlunitext.assert_equals(isEqual,true,reportStr);
        end   
        function self = test_simplestruct3_negative(self)
            S1=struct('a',struct('a',nan,'b',1),'b',2);
            S2=struct('a',struct('a',1,'b',1),'b',2);
            isEqual=modgen.struct.structcompare(S1,S2,0);
            mlunitext.assert_equals(isEqual,false);
        end        
        
        function self = test_simplestructarray1_negative(self)
            S1(1)=struct('a',struct('a',1+1e-10,'b',1),'b',2);
            S1(2)=struct('a',struct('a',nan,'b',1),'b',2);
            S2(1)=struct('a',struct('a',1,'b',1),'b',2);
            S2(2)=struct('a',struct('a',1,'b',1),'b',2);
            isEqual=modgen.struct.structcompare(S1,S2,0);
            mlunitext.assert_equals(isEqual,false);
        end        
        function self = test_simplestructarray1_positive(self)
            S2(1)=struct('a',struct('a',1,'b',1),'b',2);
            S2(2)=struct('a',struct('a',1,'b',1),'b',2);
            S1=S2;
            [isEqual,reportStr]=modgen.struct.structcompare(S1,S2,0);
            mlunitext.assert_equals(isEqual,true,reportStr);
        end        
        function self = test_complex1_positive(self)
            [isEqual,reportStr]=modgen.struct.structcompare(self.SXComp,self.SXComp,0);
            mlunitext.assert_equals(isEqual,true,reportStr);
        end        
        function self = test_complex1_negative(self)
            [isEqual,reportStr]=modgen.struct.structcompare(self.SXComp,self.SYComp,0);
            mlunitext.assert_equals(isEqual,false);
            mlunitext.assert_equals(numel(strfind(reportStr,sprintf('\n'))),5);
        end
        function self = test_optional_tolerance_arg(self)
            [isEqual,reportStr]=modgen.struct.structcompare(self.SXComp,self.SYComp,0);
            [isEqual2,reportStr2]=modgen.struct.structcompare(self.SXComp,self.SYComp);
            mlunitext.assert_equals(isEqual,isEqual2);
            mlunitext.assert_equals(reportStr,reportStr2);
        end          
        function self = test_complex2_negative(self)
            S1=struct('a',1,'b',repmat([2 nan 3],2,1));
            S2=struct('a',2,'b',repmat([1 nan 2],2,1));
            [isEqual,reportStr]=modgen.struct.structcompare(S1,S2,0.1);
            mlunitext.assert_equals(isEqual,false);
            mlunitext.assert_equals(2,numel(strfind(reportStr,'Max.')));
        end
        function self = test_differentsize_negative(self)
            S1=struct('a',1,'b',repmat([2 nan 3 3],2,1));
            S2=struct('a',2,'b',repmat([1 nan 2],2,1));
            [isEqual,reportStr]=modgen.struct.structcompare(S1,S2,0.1);
            mlunitext.assert_equals(isEqual,false);
            mlunitext.assert_equals(1,numel(strfind(reportStr,'Max.')));
            mlunitext.assert_equals(1,numel(strfind(reportStr,'Different sizes')));
        end
        function self = test_cell_positive(self)
            S1=struct('a',1,'b',{{NaN;struct('c',{'aaa'})}});
            isEqual=modgen.struct.structcompare(S1,S1,0);
            mlunitext.assert_equals(isEqual,true);
        end
        function self = test_cell_negative(self)
            S1=struct('a',1,'b',{{NaN;struct('c',{'aaa'})}});
            S2=struct('a',1,'b',{{NaN;struct('c',{'bbb'})}});
            [isEqual,reportStr]=modgen.struct.structcompare(S1,S2,0);
            mlunitext.assert_equals(isEqual,false);
            mlunitext.assert_equals(1,numel(strfind(reportStr,'values are different')));
        end
        function self = test_simplestruct_order_positive(self)
            S1=struct('a',1,'b',2);
            S2=struct('b',2,'a',1);
            isEqual=modgen.struct.structcompare(S1,S2,0);
            mlunitext.assert_equals(isEqual,true);
        end
        function self = test_relative_negative(self)
            S1=struct('a',1e+10,'b',2e+12);
            %
            S2=struct('b',2e+12, 'a',1e+10 + 1e+6);
            [isEqual,reportStr]=modgen.struct.structcompare(S1, S2, ...
                1e-10, 1e-5);
            check_neg(1);
            %
            S2=struct('b',2e+12 - 1e+2, 'a',1e+10 + 1e+6);
            [isEqual,reportStr]=modgen.struct.structcompare(S1, S2, ...
                1e+3, 1e-5);
            check_neg(1);
            %
            S2=struct('b',2e+12 - 1e+9, 'a',1e+10 + 1e+6);
            [isEqual,reportStr]=modgen.struct.structcompare(S1, S2, ...
                1e+3, 1e-5);
            check_neg(2);
            %
            S1=struct('a',1e+6 - 2,'b',2e+6, 'c', 'aab');
            S2=struct('a',1e+6,'b',2e+6 + 4, 'c', 'aab');
            [isEqual,reportStr]=modgen.struct.structcompare(S1, S2, ...
                1, 1e-7);
            check_neg(2);
            function check_neg(repMsgCount)
                mlunitext.assert_equals(isEqual,false);
                mlunitext.assert_equals(repMsgCount, ...
                    numel(strfind(reportStr, 'Max. relative difference')));
            end
        end
        function self = test_relative_positive(self)
            S1=struct('a',1e+6 - 0.5,'b',2e+6, 'c', 'aab');
            S2=struct('a',1e+6,'b',2e+6 +1, 'c', 'aab');
            isEqual=modgen.struct.structcompare(S1, S2, 1e-10, 1e-6);
            mlunitext.assert_equals(isEqual,true);
            %
            S1=struct('a',1e+10,'b',2e+12);
            S2=struct('b',2e+12, 'a',1e+10 + 1e+2);
            isEqual=modgen.struct.structcompare(S1, S2, 1e-10, 1e-5);
            mlunitext.assert_equals(isEqual,true);
            %
            S2=struct('b',2e+12 - 1e+4, 'a',1e+10 + 1e+2);
            isEqual=modgen.struct.structcompare(S1, S2, 1e+3, 1e-5);
            mlunitext.assert_equals(isEqual,true);
        end
    end
end
