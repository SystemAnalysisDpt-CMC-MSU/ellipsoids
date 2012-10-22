classdef DiskBasedHashMapFactory
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=getInstance(varargin)
            obj=modgen.containers.DiskBasedHashMap(varargin{:});
        end
    end
    
end
