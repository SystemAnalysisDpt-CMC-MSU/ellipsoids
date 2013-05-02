classdef MatrixODESolver
    properties
        sizeVec
        odePropList
        fSolveFunc
    end
    methods
        function self=MatrixODESolver(sizeVec,fSolveFunc,varargin)
            self.sizeVec=sizeVec;
            self.odePropList=varargin;
            self.fSolveFunc=fSolveFunc;
        end
        function [timeVec,xResArray]=solve(self,fDerivFunc,timeVec,initVal)
            import modgen.common.throwerror;
            sizeVec = self.sizeVec;
            reshapeSizeVec = [sizeVec, ones(1, max(0, ...
                2 - length(sizeVec)))];
            if ~isequal(reshapeSizeVec, size(initVal))
                throwerror('wrongInput', ['initial value should be ', ...
                    'consistent with sizeVec specified in ', ...
                    'the constructor']);
            end
            timeSizeVec = size(timeVec);
            minTimeVecSize = min(timeSizeVec);
            [~, maxTimeVecInd] = max(timeSizeVec);
            if (minTimeVecSize ~= 1) || (maxTimeVecInd > 2)
                throwerror('wrongInput', 'time span is not a vector');
            end
            if timeVec(1) ~= timeVec(end)
                fMatrixDerivFunc=@(t, y)(reshape(fDerivFunc(t, ...
                    reshape(y, reshapeSizeVec)), [], 1));
                [timeVec, xResMat] = ...
                    self.fSolveFunc(fMatrixDerivFunc, timeVec, ...
                    initVal(:), odeset(self.odePropList{:}));
                timeVec = timeVec.';
                nTimePoints = length(timeVec);
                xResArray = reshape(xResMat.',[sizeVec nTimePoints]);
            else
                timeVec = timeVec(1);
                xResArray = reshape(initVal, reshapeSizeVec);
            end
        end
    end
end