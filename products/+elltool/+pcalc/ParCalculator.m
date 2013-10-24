classdef ParCalculator
    methods (Static)
      function [varargout]=eval(f, varargin)
            % EVAL - reads the parametr how many parallel processes could 
            %        be executed and launches function to make it possible 
            %   
            % $Authors: Ekaterina Zilonova <zilonova.e.m@gmail.com>
            %               $Date: October-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013 $
            %
         varargout=cell(1,nargout); 
         [varargout{:}]=modgen.pcalc.auxdfeval(f, varargin{:},'ClusterSize',1);
         %[varargout{:}]=modgen.pcalc.auxdfeval(f, varargin{:});
        end 
    end
end