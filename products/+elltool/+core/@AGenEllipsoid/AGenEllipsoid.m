classdef AGenEllipsoid < handle
    methods (Access = protected, Abstract, Static)
        formCompStruct(SEll, SFieldNiceNames, absTol, isPropIncluded)
    end
    %
    methods (Access = protected)
        function [isEqualArr, reportStr] = isEqualInternal(ellFirstArr,...
                ellSecArr, isPropIncluded)
            import modgen.struct.structcomparevec;
            import gras.la.sqrtmpos;
            import elltool.conf.Properties;
            import modgen.common.throwerror;
            %
            nFirstElems = numel(ellFirstArr);
            nSecElems = numel(ellSecArr);
            if (nFirstElems == 0 && nSecElems == 0)
                isEqualArr = true;
                reportStr = '';
                return;
            elseif (nFirstElems == 0 || nSecElems == 0)
                throwerror('wrongInput:emptyArray',...
                    'input ellipsoidal arrays should be empty at the same time');
            end
            
            [~, absTol] = ellFirstArr.getAbsTol;
            firstSizeVec = size(ellFirstArr);
            secSizeVec = size(ellSecArr);
            isnFirstScalar=nFirstElems > 1;
            isnSecScalar=nSecElems > 1;
            
            [~, tolerance] = ellFirstArr.getRelTol;
            
            [SEll1Array, SFieldNiceNames, ~] = ...
                ellFirstArr.toStruct(isPropIncluded);
            SEll2Array = ellSecArr.toStruct(isPropIncluded);
            %
            SEll1Array = arrayfun(@(SEll)ellFirstArr.formCompStruct(SEll,...
                SFieldNiceNames, absTol, isPropIncluded), SEll1Array);
            SEll2Array = arrayfun(@(SEll)ellSecArr.formCompStruct(SEll,...
                SFieldNiceNames, absTol, isPropIncluded), SEll2Array);
            
            if isnFirstScalar&&isnSecScalar
                if ~isequal(firstSizeVec, secSizeVec)
                    throwerror('wrongSizes',...
                        'sizes of ellipsoidal arrays do not... match');
                end;
                compare();
                isEqualArr = reshape(isEqualArr, firstSizeVec);
            elseif isnFirstScalar
                SEll2Array=repmat(SEll2Array, firstSizeVec);
                compare();
                
                isEqualArr = reshape(isEqualArr, firstSizeVec);
            else
                SEll1Array=repmat(SEll1Array, secSizeVec);
                compare();
                isEqualArr = reshape(isEqualArr, secSizeVec);
            end
            function compare()
                [isEqualArr, reportStr] =...
                    modgen.struct.structcomparevec(SEll1Array,...
                    SEll2Array, tolerance);
            end
        end

        function polar = getScalarPolar(self, isRobustMethod)
            import modgen.common.throwerror
            modgen.common.checkvar(self, 'isscalar(self)', 'myVar',...
               'errorTag','wrongInput:badType','errorMessage','Type is wrong')
            if (isRobustMethod)
                singEll = self;
                qVec = singEll.centerVec;
                shMat = singEll.shapeMat;
                isZeroInEll = qVec' * ell_inv(shMat) * qVec;

                if isZeroInEll < 1
                    auxMat  = ell_inv(shMat - qVec*qVec');
                    auxMat  = 0.5*(auxMat + auxMat');
                    polarCVec  = -auxMat * qVec;
                    polarShMat  = (1 + qVec'*auxMat*qVec)*auxMat;
                    self.centerVec = polCenVec;
                    self.shapeMat = polShapeMat;
                    polar = ellipsoid(polarCVec,polarShMat);
                else
                    throwerror('degenerateEllipsoid',...
                        'The resulting ellipsoid is not bounded');
                end
            else
                [cVec, shMat] = double(self);
                invShMat = inv(shMat);
                normConst = cVec'*(shMat\cVec);
                polarCVec = -(shMat\cVec)/(1-normConst);
                polarShMat = invShMat/(1-normConst) + polarCVec*polarCVec';
                polar = ellipsoid(polarCVec,polarShMat);
            end

        end
    end
end