classdef ParCalculator
% ParCalculator - has static method eval, that launches auxdfeval
%         function to calculate  in a
%         parallel manner with clusterSize, equal to 
%         parameter that was readen from configuration.
%        
%   
% $Authors: Ekaterina Zilonova <zilonova.e.m@gmail.com>
%               $Date: October-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $
%    
    methods (Static)
      function [varargout]=eval(f, varargin)
            %  EVAL -  reads clusterSize from the current
            %      configuration and launches modgen.pcalc.auxdfeval
            %      with this clusterSize for  parent processes and with
            %      clusterSize=1 for child processes.
            % Input:
            %   regular:
            %     f: function_handle[1,1]- function that is going to be
            %        calculated in a parallel manner.
            %   optional:
            %     varargin: arguments for f. 
            %     In case f takes no arguments, nothing is needed to be
            %     passed.
            % Output:
            %      varargout: whatever function f returns.
            %
            % $Author: Zilonova Ekaterina
            % <zilonova.e.m@gmail.com> $
            % $Date: 4-december-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012 $
          nMaxParProcess=elltool.conf.Properties.getConfRepoMgr.getParam('parallelCompProps.nMaxParProcess');
          varargout=cell(1,nargout); 
          [taskName,SProp]=modgen.pcalc.gettaskname();
          if (SProp.isMain==false)
              [varargout{:}]=modgen.pcalc.auxdfeval(f, varargin{:},'ClusterSize',1);
              
          else
            [varargout{:}]=modgen.pcalc.auxdfeval(f, varargin{:},'ClusterSize',nMaxParProcess);
            
         end
       end 
   end
end