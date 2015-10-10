classdef BasicTC < mlunitext.test_case
    methods
        function self = BasicTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function testMergeStability(~)
            %we expect than indices returned as the second output argument
            %are ordered within groups of matching values. i.e if values
            %are the same - indices should be in an ascending order
            inpArgList={[1,1,1],[1,1,1],[1,2,3]};
            check();
            inpArgList={[2,1,1],[1,1,2],[2,3,1]};
            check();            
            inpArgList={[2,3,1,1,2],[1,1,2,2,3],[3 4 1 5 2]};
            check();
            %
            function check()
                inpVec=inpArgList{1};
                outExpVec=inpArgList{2};
                indExpVec=inpArgList{3};
                [outVec,indVec]=modgen.algo.sort.mergesort(inpVec);
                mlunitext.assert_equals(outVec,outExpVec);
                mlunitext.assert_equals(indVec,indExpVec);
            end
        end
        function testQuickMergeBasic(~)
            import modgen.common.test.aux.EntityFactory;
            %
            N_ITERS=10;
            N_VEC_ELEMS=10;
            inpVec=[2,3,1,1,2];
            check();
            inpVec=[12,3,1,1,2,3,6,6.3,3];
            check();
            inpVec=inpVec.';
            check();
            %
            for iIter=1:N_ITERS
                inpVec=rand(1,N_VEC_ELEMS);
                check();
                inpVec=inpVec.';
                check();
            end
            %
            inpVec=EntityFactory.create([2,3,1,1,2]);
            check();
            inpVec=EntityFactory.create([2,3,1]);
            check();
            %
            function check()
            [sortVec,indForwardVec]=modgen.algo.sort.mergesort(inpVec);
            isOk=isequal(sortVec,inpVec(indForwardVec));
            mlunitext.assert(isOk);
            mlunitext.assert_equals(size(sortVec),size(indForwardVec));
            end
        end
    end
end