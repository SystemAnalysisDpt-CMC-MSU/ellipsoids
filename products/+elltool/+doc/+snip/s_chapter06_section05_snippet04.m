% Question 1
%can there be a collision e_i \leq 0 
grdHypObj1 = hyperplane([1 0 0]', e_1);
grdHypObj2 = hyperplane([0 1 0]', e_2);
grdHypObj3 = hyperplane([0 0 1]', e_3);

basisMat0 = [1 0 0 0 0 0 0 0 0
             0 0 0 1 0 0 0 0 0
             0 0 0 0 0 0 1 0 0]';
         
[externalEllMat, TimeVec] = thRsObj.get_ea();
[externalEllMat_n,externalEllMat_m] = size(externalEllMat);

i = 0;
resEllObjnom = -1;
GlobalMax = -inf;
PlatoonDist = -inf;
%check the intersection with hyperplanes

while  (i < externalEllMat_m)
     i = i + 1;
     ellVec = externalEllMat(:,i);
     resEllObj = ellintersection_ia(ellVec);
     resEllObj = resEllObj.projection(basisMat0);
     [bpMat,fMat,supVec,lGridMat] = resEllObj.getRhoBoundary();
    % disp(bpMat);
    %find max(sum(e_i))
     if max(sum(bpMat,2)) > PlatoonDist
         PlatoonDist = max(sum(bpMat,2));
         PlatoonDistNumber = i;
     end
     %find max(e_i)
     if max(bpMat(:))> GlobalMax
         GlobalMax = max(bpMat(:));
         GlobalMaxNum = i;
     end
     if (resEllObjnom == -1)
         intersectEllVec1 = resEllObj.hpintersection(grdHypObj1);
         intersectEllVec2 = resEllObj.hpintersection(grdHypObj2);
         intersectEllVec3 = resEllObj.hpintersection(grdHypObj3);
     end
     if (~isEmpty(intersectEllVec1) || ~isEmpty(intersectEllVec2) || ~isEmpty(intersectEllVec3))...
            && (resEllObjnom == -1)
        resEllObjnom = i;
        resEllObjansfirst = resEllObj;
     end
     if (~isEmpty(intersectEllVec1) || ~isEmpty(intersectEllVec2) || ~isEmpty(intersectEllVec3))
        resEllObjnom = i;
        resEllObjanslast = resEllObj;
     end
    
end

%If there are no intersections with hyperplanes
 %disp(resEllObjans);
 if resEllObjnom == -1
     disp('There are no intersections, we derive the result for a finite time');
     resEllObjans = resEllObj;
 else    
   %choose and change to build
   
   %resEllObjans =  resEllObjanslast;
    resEllObjans =  resEllObjansfirst;
 end

 
 plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
  @(x)sprintf('_before_the_guard1%d',x));
 resEllObjans.plot('color', [0 0 1], 'newFigure', true, 'relDataPlotter', plObj);

 hold on
 [hypVec, hypScal] = grdHypObj1.double;
 hyp = hyperplane([hypVec(1); hypVec(2);hypVec(3);], hypScal);
 [centVec, ~] = double(resEllObjans);
 hyp.plot('center', [e_1 centVec(2) centVec(3)], 'color', [1 0 0]);

 hold on
 [hypVec, hypScal] = grdHypObj2.double;
 hyp2 = hyperplane([hypVec(1); hypVec(2);hypVec(3);], hypScal);
 [centVec, ~] = double(resEllObjans);
 hyp2.plot('center', [ centVec(1) e_2 centVec(3)], 'color', [1 0 0]);
 
 hold on
 [hypVec, hypScal] = grdHypObj3.double;
 hyp3 = hyperplane([hypVec(1); hypVec(2);hypVec(3);], hypScal);
 [centVec, ~] = double(resEllObjans);
 hyp3.plot('center', [centVec(1) centVec(2) e_3], 'color', [1 0 0]);