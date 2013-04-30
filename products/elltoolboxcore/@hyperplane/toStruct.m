function ShypArr = toStruct(hypArr)
    ShypArr = arrayfun(@formCompStruct, hypArr);
end

function SComp = formCompStruct(hypObj)

[hypNormVec, hypScal] = parameters(hypObj);

normMult = 1/norm(hypNormVec);
hypNormVec  = hypNormVec*normMult;
hypScal  = hypScal*normMult;
if hypScal < 0
    hypScal = -hypScal;
    hypNormVec = -hypNormVec;
end

SComp = struct('normal', hypNormVec, 'shift', hypScal);

end