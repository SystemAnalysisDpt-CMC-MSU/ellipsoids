classdef ParCalculator
    methods (Static)
      function [varargout]=eval11(f, varargin)
       %function [varargout]=eval11(f, arrayTubes)
            % EVAL - reads the parametr how many parallel processes could 
            %        be executed and launches function to make it possible 
            %   
            % Input: 
            %  regular:
            %    processorFunc: functionHandle/str - function to calculate 
            %    across multiple workes
            %    Workers: cell[1, nWorkes] - list of arguments          
            % Output:
            %   varargout: whatever processorFunc function return
         
         % modgen.pcalc.auxdfeval.ClusterSize=elltool.conf.Properties.getConfRepoMgr.getParam('parallelCompProps.nMaxParProcess');
          
         %modgen.pcalc.auxdfeval.ClusterSize=1;
            
         
        
         
         
         [varargout]=modgen.pcalc.auxdfeval(f, varargin);
        % [varargout]=modgen.pcalc.auxdfeval(f,args);
      
      
      end 
  
   end
end