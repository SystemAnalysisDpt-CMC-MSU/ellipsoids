function chapter06_section02_reachmech_gen
%     REACHMECH_GEN - creates picture "chapter05_section03_reachmech.eps"
%
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $
% $Date: <9 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
close all
elltool.doc.snip.s_chapter06_section02_snippet01;
elltool.doc.snip.s_chapter06_section02_snippet02;
hFigHandleVec = findobj('Type','figure');
viewAngleList = {3, [90 0], 3, [90 0]};
figRegExpList = {'[a-zA-Z_0-9:;,\]\[\s]*_tube_without_disturbance\w*',...
    '[a-zA-Z_0-9:;,\]\[\s]*_set_without_disturbance\w*',...
    '[a-zA-Z_0-9:;,\]\[\s]*_tube_with_disturbance\w*',...
    '[a-zA-Z_0-9:;,\]\[\s]*_set_with_disturbance\w*'};
elltool.doc.picgen.PicGenController.savePicFileNameByCaller(...
    hFigHandleVec, 0.6, 0.6, 2, 2, 'figRegExpList', figRegExpList,...
    'viewAngleList', viewAngleList);

end