function varargout=getData(self,varargin)
% GETDATA - same as GETDATAINDEXED
if nargout>0
    varargout=cell(1,nargout);
    [varargout{:}]=self.getDataInternal(varargin{:});
else
    self.getDataInternal(varargin{:});
end