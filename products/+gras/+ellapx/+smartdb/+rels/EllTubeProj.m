classdef EllTubeProj<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel&...
        gras.ellapx.smartdb.rels.EllTubeProjBasic
    % EllTubeProj - class which keeps ellipsoidal tube's projection
    % 
    % Fields:
    %   QArray:cell[1, nElem] - Array of ellipsoid matrices                              
    %   aMat:cell[1, nElem] - Array of ellipsoid centers                               
    %   scaleFactor:double[1, 1] - Tube scale factor                                        
    %   MArray:cell[1, nElem] - Array of regularization ellipsoid matrices                
    %   dim :double[1, 1] - Dimensionality                                          
    %   sTime:double[1, 1] - Time s                                                   
    %   approxSchemaName:cell[1,] - Name                                                      
    %   approxSchemaDescr:cell[1,] - Description                                               
    %   approxType:gras.ellapx.enums.EApproxType - Type of approximation 
    %                 (external, internal, not defined) 
    %   timeVec:cell[1, m] - Time vector                                             
    %   calcPrecision:double[1, 1] - Calculation precision                                    
    %   indSTime:double[1, 1]  - index of sTime within timeVec                             
    %   ltGoodDirMat:cell[1, nElem] - Good direction curve                                     
    %   lsGoodDirVec:cell[1, nElem] - Good direction at time s                                  
    %   ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve                              
    %   lsGoodDirNorm:double[1, 1] - Norm of good direction at time s                         
    %   xTouchCurveMat:cell[1, nElem] - Touch point curve for good 
    %                                   direction                     
    %   xTouchOpCurveMat:cell[1, nElem] - Touch point curve for direction 
    %                                     opposite to good direction
    %   xsTouchVec:cell[1, nElem]  - Touch point at time s                                    
    %   xsTouchOpVec:cell[1, nElem] - Touch point at time s  
    %   projSTimeMat: cell[1, 1] - Projection matrix at time s                                  
    %   projType:gras.ellapx.enums.EProjType - Projection type                                             
    %   ltGoodDirNormOrigVec:cell[1, 1] - Norm of the original (not 
    %                                     projected) good direction curve   
    %   lsGoodDirNormOrig:double[1, 1] - Norm of the original (not 
    %                                    projected)good direction at time s
    %   lsGoodDirOrigVec:cell[1, 1] - Original (not projected) good 
    %                                 direction at time s            
    %
    % TODO: correct description of the fields in 
    %     gras.ellapx.smartdb.rels.EllTubeProj
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    methods
        function self=EllTubeProj(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:}); 
        end
        function plObj = plotExt(self,varargin)
            import elltool.plot.plotgeombodyarr;
            ABS_TOL = elltool.conf.Properties.getAbsTol();
            tempEllMat = self.QArray{1};
            tempEll = ellipsoid(tempEllMat(:,:,1));
            plObj= plotgeombodyarr('ellipsoid',...
                @fCalcBodyArr,@patch,tempEll,varargin{:},'isTitle',true);
            function [xCMat,fCMat,titl] = fCalcBodyArr(~,varargin)
                dim = self.dim(1);
                allEllMat =zeros(size(self.QArray,1),dim,dim,...
                    size(self.timeVec{1},2));
                arrayfun(@(x) getEllMat(x),...
                    1:size(self.QArray,1),'UniformOutput', false);
                
                if dim == 3
                    allEll2Mat = allEllMat(:,:,:,end);
                    lastCenterVec = self.aMat{1}(:, end);
                    lGridMat =getBoundary(ellipsoid(eye(3)),...
                        getNPlot3dPoints(ellipsoid(eye(3))));
                    lGridMat = lGridMat';
                    nDim = size(lGridMat, 2);
                    xMat = zeros(3,nDim);
                    allEll3Mat = [];
                    ind2 = 1;
                    arrayfun(@(x) getEll3Mat(x),...
                        1:size(allEll2Mat,1),'UniformOutput', false);
                    
%                     arrayfun(@(x) calcXMat(x),allEll3Mat,...
%                         'UniformOutput', false);
                    
                    
                    for i = 1:nDim                        
                        lVec    = lGridMat(:, i);                                               
                        valMat =...
                            gras.gen.SquareMatVector.lrDivideVec...
                            (allEll3Mat,lVec);
                        mval = max(max(valMat,[],2),ABS_TOL);
                        xVec = (lVec/sqrt(mval)) + lastCenterVec;
                        xMat(:,i) =  xVec;
                    end                    
                    fMat = convhulln(xMat');
                    xCMat = {xMat};
                    fCMat = {fMat};
                    titl = 'yes';                                                            
                else
                    if size(self.timeVec{1}, 2) == 1
                        mDim   = size(allEllMat, 2);
                        allEllMat
                        lGridMat = getBoundary(ellipsoid(eye(2)),...
                            getNPlot2dPoints(ellipsoid(eye(2))));
                        nDim   = getNPlot2dPoints(ellipsoid(eye(2)));
                        X   = [];
%                         for ind = 1:nDim
%                             lVec      = lGridMat(:, ind);
%                             [v, x] = rhomat(E, l);
%                             idx    = find(isinternal((1+ellOptions.abs_tol)*E, x, 'i') > 0);
%                             if ~isempty(idx)
%                                 x = x(:, idx(1, 1)) + rs.center_values;
%                                 X = [X x];
%                             end
%                         end
%                         if ~isempty(X)
%                             X = [X X(:, 1)];
%                             if Options.fill ~= 0
%                                 fill(X(1, :), X(2, :), Options.color);
%                                 hold on;
%                             end
%                             h = ell_plot(X);
%                             hold on;
%                             set(h, 'Color', Options.color, 'LineWidth', Options.width);
%                             h = ell_plot(rs.center_values, '.');
%                             set(h, 'Color', Options.color);
%                             if isdiscrete(rs.system)
%                                 title(sprintf('%s at time step K = %d', back, rs.time_values));
%                             else
%                                 title(sprintf('%s at time T = %d', back, rs.time_values));
%                             end
%                             xlabel('x_1'); ylabel('x_2');
%                             if ih == 0
%                                 hold off;
%                             end
%                         else
%                             warning('2D grid too sparse! Please, increase ''ellOptions.plot2d_grid'' parameter...');
%                         end
%                         return;
                    end
                end
                
                function  getEllMat(ind)
                    allEllMat(ind,:,:,:) = self.QArray{ind};
                end
                function getEll3Mat(ind)
                    aMat = reshape(allEll2Mat(ind,:,:),dim,dim);
                    if trace(aMat) > ...
                            ABS_TOL
                        allEll3Mat(:,:,ind2) = aMat;
                        ind2 = ind2+1;
                    end
                end
            end
        end
    end
end