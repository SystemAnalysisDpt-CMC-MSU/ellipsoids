function chapter05_section01_minksum_gen
%     MINKSUM_GEN - creates picture "chapter05_section01_minksum.eps" in doc/pic     
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <27 September 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $

    close all
    elltool.doc.snip.s_chapter05_section01_snippet02;
    elltool.doc.snip.s_chapter05_section01_snippet15;
    figHandle = findobj('Type','figure');
    h = get(findobj(figHandle, 'Type','axes'), 'Children');
    centrXVec = get(h(1), 'XData');
    centrYVec = get(h(1), 'YData');
    ellXVec = get(h(2), 'XData');
    ellYVec = get(h(2), 'YData');
    fill (ellXVec, ellYVec, [0, 1, 0.5]);
    hold on
    plot (centrXVec, centrYVec, 'Marker', '*', 'MarkerSize', 8, 'Color', 'b');
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(figHandle);
end