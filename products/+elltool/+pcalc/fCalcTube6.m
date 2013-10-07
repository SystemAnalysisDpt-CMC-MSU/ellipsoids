function  [QArrayListL]=fCalcTube6(self,selfGetEllApxMatrixDerivFunc1,...
    logger,selfGetEllApxMatrixInitValue1, solverObj,...
    lsGoodDirMat1, sTime, isFirstPointToRemove,solveTimeVec)
    

tStart=tic;
                logStr=sprintf(...  
                    'solving ode for direction \n %s  defined at time %f',...
                    mat2str(lsGoodDirMat1),sTime);
                logger.debug([logStr,'...']);
                fHandle=selfGetEllApxMatrixDerivFunc1;
                initValueMat=selfGetEllApxMatrixInitValue1;
                %
                [~,data_Q_star]=solverObj.solve(selfGetEllApxMatrixDerivFunc1,...
                    solveTimeVec,selfGetEllApxMatrixInitValue1);
                if isFirstPointToRemove
                    data_Q_star(:,:,1)=[];
                end
                %
                QArrayListL=self.adjustEllApxMatrixVec(data_Q_star);
                logger.debug(sprintf([logStr,':done, %.3f sec. elapsed'],...
                    toc(tStart)));
 end