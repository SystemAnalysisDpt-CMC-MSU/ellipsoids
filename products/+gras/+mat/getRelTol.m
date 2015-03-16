function [relTolArr, relTolVal] = getRelTol(arr, varargin)
[relTolArr, relTolVal] = arr.getProperty('relTol',varargin{:});
end