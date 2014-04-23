classdef PropsForVisibleMap<modgen.graphics.bld.AElementWithPropsMap
    % This class is an analogue of containers.Map class save, first,
    % that keys are objects of classes inherited from AElemenentWithProps,
    % second, that values are list of properties (possibly, empty)
    % redefined for those corresponding graphical objects that are visble
    % and, third, that all the map is filled in constructor, so that no
    % modification of this map is permitted
    
    methods (Access=protected,Static)
        function [isValueVec,propListCVec]=getValueVec(sizeVec,varargin)
            isValueVec=true;
            if nargin~=2,
                modgen.common.throwerror('wrongInput',...
                    'Improper number of input arguments');
            end
            propListCVec=varargin{1};
            modgen.common.checkvar(propListCVec,[...
                'iscell(x)&&isequal(size(x),'...
                mat2str(sizeVec) ')']);
            modgen.common.checkvar(propListCVec,[...
                'all(mod(cellfun(''prodofsize'',x(:)),2)==0&('...
                'cellfun(''isempty'',x(:))|'...
                'cellfun(@(y)modgen.common.type.simple.lib.iscellofstring('...
                'y(1:2:end-1)),x(:))))']);
            propListCVec=cellfun(@(x)reshape(x,1,[]),...
                propListCVec(:),'UniformOutput',false);
        end
    end
    
    methods
        function self=PropsForVisibleMap(keyCVec,propListCVec)
            self=self@modgen.graphics.bld.AElementWithPropsMap(keyCVec,propListCVec);
        end
    end
end