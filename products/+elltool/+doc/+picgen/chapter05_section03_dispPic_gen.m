function chapter05_section03_dispPic_gen
%     DISPPIC_GEN - creates picture "chapter05_section03_dispPic.eps" 
%        
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <2 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter05_section03_snippet07;
    hfigHandle = findobj('Type','figure');
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(hfigHandle, 0.38, 0.35, 1, 1);

end