function ellObj = tell_enclose(ellFactoryObj,varargin)
ellObj = ell_enclose(varargin{:});
ellObj = ellFactoryObj.createInstance(...
    'ellipsoid', ellObj.getCenterVec(), ellObj.getShapeMat());

