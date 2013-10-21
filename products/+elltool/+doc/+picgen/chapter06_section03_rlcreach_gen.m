function chapter06_section03_rlcreach_gen
%     RLCREACH_GEN - creates picture "chapter06_section03_rlcreach.eps" in
%     doc/pic   
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <9 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter06_section03_snippet01;
    elltool.doc.snip.s_chapter06_section03_snippet02;

    hfigHandleVec = findobj('Type','figure');
    figPositionsVec(1:2) = 4;
    figPositionsVec(3:6) = 3;
    figPositionsVec(7:8) = 2;
    figPositionsVec(9:12) = 1;
    hcombinedFig = elltool.doc.picgen.PicGenController.createCombinedFigure(hfigHandleVec, figPositionsVec, []); 
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(hcombinedFig, 0.6, 0.6);

end