function chapter05_section03_reachTubeDynProj_gen
%     REACHTUBEDYNPROJ_GEN - creates picture "chapter05_section03_reachTubeDynProj.eps" in
%     doc/pic   
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <2 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter05_section03_snippet04;
    figHandle = findobj('Type','figure');
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(figHandle(1), 0.5, 0.6);

end