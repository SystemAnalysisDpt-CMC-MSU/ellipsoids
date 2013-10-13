function chapter06_section04_hwreach_gen
%     HWREACH_GEN - creates picture "chapter06_section03_rlcreach.eps" in
%     doc/pic   
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <9 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter06_section04_snippet01;
    elltool.doc.snip.s_chapter06_section04_snippet02;
    elltool.doc.snip.s_chapter06_section04_snippet03;
    elltool.doc.snip.s_chapter06_section04_snippet04;
           
    combinedFig = figure;
    basisMat = [1 0 0 0; 0 1 0 0; 0 0 1 0]';
    
    ellObj = externalEllMat(10).projection(basisMat);
    leftupAxes = subplot (2, 2, 1);
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('(a)');
    plot(ellObj, 'color', [0 0 1]);
    hold on
    [hypVec, hypScal] = grdHypObj.double;
    hyp = hyperplane([hypVec(1); hypVec(2); hypVec(3)], hypScal);
    [centVec, ~] = double(ellObj);
    plot(hyp, 'center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);
    set(leftupAxes, 'Position',  [ 0.1300    0.5838    0.3005    0.3412],...
         'CameraPosition',  1.0e+03 *[ -1.1392    0.0027    0.6616]);
   
    ellObj = externalEllMat(50).projection(basisMat);
    rightupAxes = subplot (2, 2, 2);
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('(b)');
    plot(ellObj, 'color', [0 0 1]);
    hold on
    plot(hyp, 'center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);
    set(rightupAxes, 'Position',  [ 0.5703    0.5838    0.3005    0.3412],...
        'CameraPosition',  1.0e+03 *[-1.1572    0.3797    0.6193]);
    
    ellObj = externalEllMat(80).projection(basisMat);
    leftdownAxes  = subplot (2, 2, 3);
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('(c)');
    plot(ellObj, 'color', [0 0 1]);
    hold on
    plot(hyp, 'center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);
    set(leftdownAxes, 'Position',  [0.1300    0.1100    0.3005    0.3412],...
         'CameraPosition', 1.0e+03 *[-1.4268    0.1381    0.4006]);
    
    elltool.doc.snip.s_chapter06_section04_snippet01;
    elltool.doc.snip.s_chapter06_section04_snippet02;
    elltool.doc.snip.s_chapter06_section04_snippet03;
    elltool.doc.snip.s_chapter06_section04_snippet04;
         
   
    rightdownAxes = axes;
    basisMat = [1 0 0 0; 0 1 0 0]';
    ellObjVec = externalEllMat(1:101).projection(basisMat);
    plot(ellObjVec, 'color', [0 0 1], 'fill', 1);
    hold on     
    plot(x0EllObj.projection(basisMat), 'color', [1 0 1]);
    hold on
    hyp = hyperplane([hypVec(1); hypVec(2)], hypScal);
    plot(hyp, 'center', [170 200], 'color', [1 0 0]);       
    crsexternalEllMat = crsObjVec.get_ea();
    ellObjVec = crsexternalEllMat(1:83).projection(basisMat);
    plot(ellObjVec, 'color', [0 1 0], 'fill', 1);
    set(rightdownAxes,  'Position', [0.5703    0.1100    0.3347    0.3412]);
    xlabel('x1');
    ylabel('x2');
    title('(d)');

    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(combinedFig, 0.6, 0.6);

end