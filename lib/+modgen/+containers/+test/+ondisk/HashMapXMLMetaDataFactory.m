classdef HashMapXMLMetaDataFactory
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=getInstance(varargin)
            obj=modgen.containers.ondisk.HashMapXMLMetaData(varargin{:});
        end
    end
    
end
