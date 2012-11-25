classdef SuiteBasic < mlunitext.test_case
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)

        end
        function testMatrixSymbolicInterp(~)
            %% Check symbolic interp
            timeVec=0:0.1:2*pi;
            checkMaster();
            timeVec=0;
            checkMaster();
            %
            function checkMaster()
                symCMat={'cos(t)','sin(t)';'-sin(t)','cos(t)'};            
                dataArray=gras.gen.MatVector.fromFormulaMat(symCMat,timeVec);  
                mInterp=gras.mat.symb.MatrixSymbFormulaBased(symCMat);
                check(mInterp);
                function check(mInterp)
                    resDataArray=mInterp.evaluate(timeVec);
                    mlunit.assert_equals(true,isequal(dataArray,resDataArray));
                end
            end
        end
        function testMatrixCubicSplineBasic(self)
            MAX_TOL=1e-13;
            N_TIME_POINTS=100;
            dataArray=rand(8,7,N_TIME_POINTS);
            timeVec=1:100;
            checkBulk();
            dataArray=rand(7,8,N_TIME_POINTS);
            checkBulk();
            %
            %
            dataArray=rand(8,8,N_TIME_POINTS);
            for iTime=1:N_TIME_POINTS
                dataArray(:,:,iTime)=triu(dataArray(:,:,iTime)+...
                    transpose(dataArray(:,:,iTime)));
            end
            check('column_triu');
            for iTime=1:N_TIME_POINTS
                dataArray(:,:,iTime)=dataArray(:,:,iTime)*transpose(dataArray(:,:,iTime));
            end            
            check('posdef_chol');
            tmpMat=rand(8,8);
            dataArray(:,:,10)=tmpMat+transpose(tmpMat);
            checkN('posdef_chol');
            check('symm_column_triu');
            dataArray(:,:,10)=rand(8,8);
            checkN('symm_column_triu');
            checkN('posdef_chol');
            dataArray=gras.gen.MatVector.triu(dataArray);
            check('column_triu');            
            dataArray=rand(8,N_TIME_POINTS);
            check('column');
            check('row');
            %%
            posArray=rand(8,8,N_TIME_POINTS);
            for iTime=1:N_TIME_POINTS
                posArray(:,:,iTime)=posArray(:,:,iTime)*transpose(posArray(:,:,iTime));
            end              
            multArray=rand(8,8,N_TIME_POINTS);
            dataArray=gras.gen.SquareMatVector.lrMultiply(posArray,...
                multArray,'L');
            check('nndef_chol',{multArray,posArray,timeVec});
            checkN('nndef_chol',{multArray(:,:,1:end-1),posArray,timeVec});
            checkN('nndef_chol',{multArray(:,1:end-1,:),posArray,timeVec});
            checkN('nndef_chol',{multArray,-posArray,timeVec});
            %
            function checkBulk()
                check('column');
                check('row');
                checkN('column_triu');
                checkN('symm_column_triu');
                checkN('posdef_chol');                
            end
            function checkN(shape,inpArgList)
                if nargin<2
                    inpArgList={};
                else
                    inpArgList={inpArgList};
                end
                self.runAndCheckError(@(x)check(shape,inpArgList{:}),...
                    ':wrongInput');                
            end
            function check(shape,inpArgList)
                if nargin<2
                    inpArgList={dataArray,timeVec};
                end
                %% Check for a possibility to use a default constuctor
                obj=gras.interp.MatrixInterpolantFactory.createInstance(shape);
                mlunit.assert_equals(true,isempty(obj.evaluate([])));
                mlunit.assert_equals(2,obj.getDimensionality());
                %
                %%
                obj=gras.interp.MatrixInterpolantFactory.createInstance(...
                    shape,inpArgList{:});
                %%
                resDataArray=obj.evaluate(timeVec);
                nTimePoints=length(timeVec);
                nDims=obj.getDimensionality();
                checkInternal();
                %
                resDataArray=obj.getKnotDataArray();
                checkInternal();
                %
                indMid=fix(nTimePoints*0.5);
                timeLeftVec=timeVec(1:indMid);
                timeRightVec=timeVec((indMid+1):end);
                resDataArray=cat(nDims+1,obj.evaluate(timeLeftVec),...
                    obj.evaluate(timeRightVec));
                checkInternal();
                %%
                %%
                if strcmp(shape,'column')
                    objList=obj.getColSplines();
                    dataList=cellfun(@(x)x.evaluate(timeVec),objList,...
                        'UniformOutput',false);
                    if nDims==2
                        nRows=obj.getNRows();
                        nTimePoints=length(obj.getKnotVec);
                        mlunit.assert_equals(nTimePoints,obj.getNKnots());
                        %
                        dataList=cellfun(@(x)reshape(x,...
                            [nRows,1,nTimePoints]),dataList,...
                            'UniformOutput',false);
                        catDataArray=cat(2,dataList{:});
                    else
                        catDataArray=dataList{1};
                    end
                    mlunit.assert_equals(true,isequal(resDataArray,catDataArray));
                end                
                function checkInternal()
                    maxTol=max(abs(dataArray(:)-resDataArray(:)));
                    isOk=maxTol<=MAX_TOL;
                    mlunit.assert_equals(true,isOk,...
                        sprintf('max tol %g',maxTol));
                end
                %
            end
        end
    end
end