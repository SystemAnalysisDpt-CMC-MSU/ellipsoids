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
          nMaxParProcess=elltool.conf.Properties.getConfRepoMgr.getParam('parallelCompProps.nMaxParProcess');
          varargout=cell(1,nargout); 
          [taskName,SProp]=modgen.pcalc.gettaskname();
          if (SProp.isMain==false)
              [varargout{:}]=modgen.pcalc.auxdfeval(f, varargin{:},'ClusterSize',1);
              
          else
             %[varargout{:}]=modgen.pcalc.auxdfeval(f, varargin{:},'ClusterSize',nMaxParProcess);
            [varargout{:}]=modgen.pcalc.auxdfeval(f, varargin{:},'ClusterSize',1);
          
         end
       end 
   end
end