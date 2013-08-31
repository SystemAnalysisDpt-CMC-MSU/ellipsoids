classdef SmartGraphObjGenerator<handle
    properties(Access=private)
        fGetExistingObj
        fGenNewObj
        hUsedObjVec=[]
    end
    methods
        function self=SmartGraphObjGenerator(fGetExistingObj,fGenNewObj)
            self.fGetExistingObj=fGetExistingObj;
            self.fGenNewObj=fGenNewObj;
        end
        function hObj=create(self,varargin)
            import modgen.common.throwerror;
            hObj=self.fGetExistingObj(varargin{:});
            if any(self.hUsedObjVec==hObj)
                hObj=self.fGenNewObj(varargin{:});
                if any(self.hUsedObjVec==hObj)
                    throwerror('wrongInput',...
                        ['fGenNewObj is supposed to always generate ',...
                        'a new object, instead it returned a handle ',...
                        'of already used object']);
                end
            end
            self.hUsedObjVec=[self.hUsedObjVec,hObj];
        end
    end
end
