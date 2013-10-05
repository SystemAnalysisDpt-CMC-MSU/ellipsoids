function chapter05_section01_minkmp_gen (FileName)
%     MINKMP_GEN - creates picture "FileName.eps" 
% Input:
%     regular:
%         FileName: char [1, ] - target file name for a picture.    
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <2 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
if ~(ischar(FileName))
    modgen.common.throwerror('wrongInput',...
        'Input must be char');
elseif ~(size(FileName, 1))
    modgen.common.throwerror('wrongInput',...
        'Input must be char[1, ]');
else
    elltool.doc.snip.s_chapter05_section01_snippet02;
    elltool.doc.snip.s_chapter05_section01_snippet16;
    elltool.doc.snip.s_chapter05_section01_snippet19;
    h = get(gca,'Children');
    centrX = get(h(1), 'XData');
    centrY = get(h(1), 'YData');
    ellX = get(h(2), 'XData');
    ellY = get(h(2), 'YData');
    fill (ellX, ellY, [0.53, 0.81, 1]);
    hold on
    plot (centrX, centrY, 'Marker', '*', 'MarkerSize', 8, 'Color', [0, 0.55, 0]);
    [pathstr, ~, ~] = fileparts(which(modgen.common.getcallernameext(1)));
    Part1ofPath = modgen.path.rmlastnpathparts(pathstr, 4);
    Part2ofPath = strcat (FileName, '.eps');
    saveas (gcf,  [Part1ofPath filesep 'doc' filesep 'pic' filesep Part2ofPath]);
end
end