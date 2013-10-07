 function  [QIntArrayListIDir, MIntArrayListIDir, QExtArrayListIDir,  MExtArrayListIDir]=fCalcTube4(self, sTime, lsGoodDirMat,...
            selfGetEllApxMatrixDerivFunc, selfGetEllApxMatrixInitValue, ...
            solverObjSolve, isFirstPointToRemove,  logger)
        function QArray=adjustEllApxMatrixVec(~,QArray)
        end
        logStr=sprintf(...
                    'solving ode for direction \n %s  defined at time %f',...  
                    mat2str(lsGoodDirMat),sTime);
                tStart=tic;
                logger.info([logStr,'...']);
                fHandle=selfGetEllApxMatrixDerivFunc;
                initValueMat=selfGetEllApxMatrixInitValue;
                %
                [~,QStarIntArray,QStarExtArray,MIntArray,MExtArray]=solverObjSolve;
                if isFirstPointToRemove
                    QStarIntArray(:,:,1)=[];
                    QStarExtArray(:,:,1)=[];
                end
                %
                QIntArrayListIDir=self.adjustEllApxMatrixVec(QStarIntArray);
                MIntArrayListIDir=MIntArray;
                QExtArrayListIDir=self.adjustEllApxMatrixVec(QStarExtArray);
                MExtArrayListIDir=MExtArray;
                logger.info(sprintf([logStr,':done, %.3f sec. elapsed'],...
                    toc(tStart)));
 end