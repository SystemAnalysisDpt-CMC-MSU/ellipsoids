function outObj=loadobj(inpObj)
import modgen.common.throwwarn;
if isstruct(inpObj)
    throwwarn('wrongInput',...
        ['Loaded relation has a legacy format making it impossible to ',...
        'recover an exact relation type, ',...
        'loading as smartdb.relations.DynamicRelation']);
    outObj=smartdb.relations.DynamicRelation();
    outObj.copyFrom(inpObj);
else
    outObj=loadobj@smartdb.relations.ARelation(inpObj);
end
