function ellObj = tell_unitball(ellFactoryObj,varargin)
ellObj = ell_unitball(varargin{:});
ellObj = ellFactoryObj.createInstance(...
    'ellipsoid', ellObj.getCenterVec(), ellObj.getShapeMat());