function [reg,isSpecified]=reconstructFieldValues(self,reg,isSpecified,isNullInferred)
%
if numel(self)~=1
    error([upper(mfilename),':wrongInput'],...
        'methods only works with the scalar objects');
end
%
if numel(isNullInferred)==1
    isNullInferred=[isNullInferred,isNullInferred];
end
if ~isSpecified(2)&&isSpecified(1)&&isNullInferred(1)
    isSpecified(2)=true;
    reg{2}=self.getIsNullDefault(reg{1});
end
if ~isSpecified(3)&&isSpecified(2)&&isNullInferred(2)
    isSpecified(3)=true;
    reg{3}=smartdb.cubes.ACubeStructFieldType.isnull2isvaluenull(reg{2},...
        self.cubeStructRef.getMinDimensionality());
end
