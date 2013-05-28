ellArray(nPoints) = ellipsoid();
approxType=gras.ellapx.enums.EApproxType.Internal;
sTime= 2;
for iElem = 1:nPoints
   ellArray(iElem) = ellipsoid(...
   aMat(:,iElem), qArrayList{1}(:,:,iElem)); 
end
fromEllArrayEllTube = gras.ellapx.smartdb.rels.EllTube.fromEllArray(...
                ellArray, timeVec,ltGoodDirArray, sTime, approxType,...
                approxSchemaName,approxSchemaDescr, calcPrecision);
