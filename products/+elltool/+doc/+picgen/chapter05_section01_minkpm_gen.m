function chapter05_section01_minkpm_gen
%     MINKPM_GEN - creates picture "chapter05_section01_minkpm.eps"     
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <2 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter05_section01_snippet02;
    elltool.doc.snip.s_chapter05_section01_snippet16;
    elltool.doc.snip.s_chapter05_section01_snippet20;
    hfigHandle = findobj('Type','figure');
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(hfigHandle, 0.4, 0.5, 1, 1);
end