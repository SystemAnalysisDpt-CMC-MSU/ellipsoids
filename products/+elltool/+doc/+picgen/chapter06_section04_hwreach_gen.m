function chapter06_section04_hwreach_gen
%     HWREACH_GEN - creates picture "chapter06_section03_hwreach.eps"
%
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $
% $Date: <9 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
close all
elltool.doc.snip.s_chapter06_section04_snippet01;
elltool.doc.snip.s_chapter06_section04_snippet02;
elltool.doc.snip.s_chapter06_section04_snippet03;
elltool.doc.snip.s_chapter06_section04_snippet04;

hFigHandleVec = findobj('Type','figure');
cameraPositionsList = {1.0e+03 *[ -1.1392    0.0027    0.6616];...
    1.0e+03 *[-1.1572    0.3797    0.6193];...
    1.0e+03 *[-1.4268    0.1381    0.4006];...
    [175 200 17.3205]};
viewAngleList = {3, 3, 3, []};
figRegExpList = {'[a-zA-Z_0-9:;,\]\[\s]*_before_the_guard\w*',...
    '[a-zA-Z_0-9;,:\]\[\s]*_crossing_the_guard\w*',...
    '[a-zA-Z_0-9;,\]\[\s:]*_after_the_guard\w*',...
    '[a-zA-Z_0-9;,\]\[\s:]*_all2D\w*'};

elltool.doc.picgen.PicGenController.savePicFileNameByCaller(...
    hFigHandleVec, 0.6, 0.6, 2, 2, 'figRegExpList', figRegExpList,...
    'cameraPositionsList', cameraPositionsList,...
    'viewAngleList', viewAngleList);

end