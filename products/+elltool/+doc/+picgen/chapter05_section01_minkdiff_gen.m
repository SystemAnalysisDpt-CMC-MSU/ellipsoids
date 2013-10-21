function chapter05_section01_minkdiff_gen
%     MINKDIFF_GEN - creates picture "chapter05_section01_minkdiff.eps" in
%     doc/pic   
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <2 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter05_section01_snippet02;
    elltool.doc.snip.s_chapter05_section01_snippet17;
    hfigHandle = findobj('Type','figure');
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(hfigHandle, 0.4, 0.5);

end