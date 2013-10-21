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

    hfigHandleVec = findobj('Type','figure');
    figPositionsVec = 4:-1:1;
    cameraPositionsMat = [1.0e+03 *[ -1.1392    0.0027    0.6616];...
                          1.0e+03 *[-1.1572    0.3797    0.6193];...
                          1.0e+03 *[-1.4268    0.1381    0.4006];...
                          [175 200 17.3205]];
    hcombinedFig = elltool.doc.picgen.PicGenController.createCombinedFigure(hfigHandleVec, figPositionsVec, cameraPositionsMat);
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(hcombinedFig, 0.6, 0.6);

end