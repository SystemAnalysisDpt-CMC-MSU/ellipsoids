classdef HandleMap<modgen.graphics.bld.AElementWithPropsMap
    % This class is an analogue of containers.Map class save, first,
    % that keys are objects of classes inherited from AElemenentWithProps
    % and values are handles of the corresponding graphical objects and,
    % second, that all the map is filled in constructor, so that no
    % modification of this map is permitted
    
    methods (Access=protected,Static)
        function [isValueVec,handleVec]=getValueVec(sizeVec,varargin)
            isValueVec=true;
            if nargin~=2,
                modgen.common.throwerror('wrongInput',...
                    'Improper number of input arguments');
            end
            handleVec=varargin{1};
            modgen.common.checkvar(handleVec,[...
                'all(ishandle(x))&&isequal(size(x),'...
                mat2str(sizeVec) ')']);
            handleVec=double(handleVec);
            modgen.common.checkvar(handleVec,'all(ishandle(x))');
        end
    end
    
    methods
        function self=HandleMap(keyCVec,handleVec)
            self=self@modgen.graphics.bld.AElementWithPropsMap(keyCVec,handleVec);
        end
    end
end