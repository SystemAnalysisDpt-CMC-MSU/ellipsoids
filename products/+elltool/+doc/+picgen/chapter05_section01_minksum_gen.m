function chapter05_section01_minksum_gen
%     MINKSUM_GEN - creates picture "chapter05_section01_minksum.eps"
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $
% $Date: <27 September 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $

close all
elltool.doc.snip.s_chapter05_section01_snippet02;
elltool.doc.snip.s_chapter05_section01_snippet15;
hfigHandle = findobj('Type','figure');
elltool.doc.picgen.PicGenController.savePicFileNameByCaller(...
    hfigHandle, 0.4, 0.5, 1, 1);
end