classdef AMatrixFunctionComparable < gras.mat.IMatrixFunction
    properties (Access=private) 
        absTol
        relTol;
    end
    
    methods     
        function isOk = isequal(self,SecMatObj)
            isOk = self.isEqual(SecMatObj);
        end
        function SData = toStruct(self,isPropIncluded)
            SData = self.toStructInternal(isPropIncluded);
        end
    end
    
    methods
        function [isOk, reportStr] = isEqual(firstObj,secObj)
            import modgen.common.throwerror;
            import modgen.struct.structcomparevec;
            import gras.la.sqrtmpos;

            nFirstElems = numel(firstObj);
            nSecElems = numel(secObj);

            firstSizeVec = size(firstObj);
            secSizeVec = size(secObj);
            isnFirstScalar = nFirstElems > 1;
            isnSecScalar = nSecElems > 1;
            
            SEll1Array = firstObj.toStructInternal(); % add param 'true' for absTol and relTol
            SEll2Array = secObj.toStructInternal(); % add param 'true' for absTol and relTol
            
            if isnFirstScalar&&isnSecScalar
                
                if ~isequal(firstSizeVec, secSizeVec)
                    throwerror('errorinSizes',...
                        'sizes do not match');
                end;
                compare();
            elseif isnFirstScalar
                
                SEll2Array = repmat(SEll2Array, firstSizeVec);
                compare();
            else
                
                SEll1Array = repmat(SEll1Array, secSizeVec);
                compare();
            end
            
            function compare()
                [isOk,reportStr] = modgen.struct.structcomparevec(SEll1Array,...
                    SEll2Array);
            end
            
        end
    end
    
    methods(Abstract, Access=protected)
        function [SData,SFieldNiceNames,SFieldDescr] = toStructInternal(self,isPropIncluded)            
            if (nargin < 2)
                isPropIncluded = false;
            end
            SEll = struct;
            SFieldNiceNames = struct;
            SFieldDescr = struct;
            if (isPropIncluded)
                SEll.absTol = self.getAbsTol();
                SEll.relTol = self.getRelTol();
            end
            SData = SEll;
            if (isPropIncluded)
                SFieldNiceNames.absTol = 'absTol';
                SFieldNiceNames.relTol = 'relTol';
                
                SFieldDescr.absTol = 'Absolute tolerance.';
                SFieldDescr.relTol = 'Relative tolerance.';
            end
        end
    end
    
    methods
        function abstolval = getAbsTol(varargin)
            abstolval = 'absTol';
        end;
        function reltolval = getRelTol(varargin)
            reltolval = 'relTol';
        end;
    end
end