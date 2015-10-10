classdef SuiteBasic < mlunitext.test_case %#ok<*NASGU>
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function testPathFilterStruct(~)
            SInp.a.b=2;
            SInp.a.c=3;
            SInp.cd.u=2;
            SInp.m=2;
            SInp.alpha.beta.gamma=3;
            %
            SRes=modgen.struct.pathfilterstruct(SInp,{'a.b','cd.u','.m'});
            SExp.a.b=2;
            SExp.cd.u=2;
            SExp.m=2;
            [isOk,reportStr]=modgen.struct.structcompare(SExp,SRes);
            mlunitext.assert(isOk,reportStr);
            %
            SRes=modgen.struct.pathfilterstruct(SInp,{'a','a.b','cd.u','.m'});
            SExp.a.c=3;
            [isOk,reportStr]=modgen.struct.structcompare(SExp,SRes);
            mlunitext.assert(isOk,reportStr);
        end
        %
        function testBinaryUnionStruct(~)
            SLeft.alpha=[1,2];
            SRight.alpha=[3,4];
            SLeft.beta=3;
            SRight.gamma=4;
            SRes=modgen.struct.binaryunionstruct(SLeft,SRight,@horzcat);
            SExp.alpha=[1,2,3,4];
            SExp.beta=3;
            SExp.gamma=4;
            [isOk,reportStr]=modgen.struct.structcompare(SExp,SRes);
            mlunitext.assert(isOk,reportStr);
            SRes=modgen.struct.binaryunionstruct(SLeft,SRight,@horzcat,...
                @(x)x*100,@(x)x*10);
            SExp.alpha=[1,2,3,4];
            SExp.beta=300;
            SExp.gamma=40;            
            [isOk,reportStr]=modgen.struct.structcompare(SExp,SRes);
            mlunitext.assert(isOk,reportStr);            
        end
    end
end