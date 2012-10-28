classdef CubeStructConfigurator
    methods (Static)
        function isPositive=isOfStaticType(obj)
            isPositive=isa(obj,...
                'smartdb.relations.ATypifiedStaticRelation');
        end
        function isPositive=isOfAutoType(obj)
            isPositive=isa(obj,'smartdb.cubes.TypifiedStruct')||...
                isa(obj,'smartdb.relations.DynTypifiedRelation');
        end
    end
end
