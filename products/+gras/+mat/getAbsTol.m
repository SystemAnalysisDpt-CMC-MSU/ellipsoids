function [absTolArr, absTolVal] = getAbsTol(Arr, varargin)
[absTolArr, absTolVal] = Arr.getProperty('absTol',varargin{:});
end