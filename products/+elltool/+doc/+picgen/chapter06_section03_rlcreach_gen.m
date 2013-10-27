function chapter06_section03_rlcreach_gen
%     RLCREACH_GEN - creates picture "chapter06_section03_rlcreach.eps"
%      
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <9 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter06_section03_snippet01;
    elltool.doc.snip.s_chapter06_section03_snippet02;

    hFigHandleVec = findobj('Type','figure');
    viewAngleList = {3, 3, 3, 3};
    figRegExpList = {'[a-zA-Z_0-9:;,-\]\[\s]*_forward_reach_set_proj\w*', '[a-zA-Z_0-9:;,-\]\[\s]*_forward_reach_set_3D\w*',...
                     '[a-zA-Z_0-9:;,-\]\[\s]*_backward_reach_set_proj\w*', '[a-zA-Z_0-9-:;,\]\[\s]*_backward_reach_set_3D\w*'};
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(hFigHandleVec, 0.6, 0.6, 2, 2,...
    'figRegExpList', figRegExpList, 'cameraPositionsList', {},...
    'viewAngleList', viewAngleList);

end