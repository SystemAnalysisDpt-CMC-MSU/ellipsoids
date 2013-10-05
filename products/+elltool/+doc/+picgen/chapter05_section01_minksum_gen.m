function chapter05_section01_minksum_gen (FileName)
%     MINKSUM_GEN - creates picture "FileName.eps" 
% Input:
%     regular:
%         FileName: char [1, ] - target file name for a picture.    
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <27 September 2013> $
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
    elltool.doc.snip.s_chapter05_section01_snippet15;
    h = get(gca,'Children');
    centrX = get(h(1), 'XData');
    centrY = get(h(1), 'YData');
    ellX = get(h(2), 'XData');
    ellY = get(h(2), 'YData');
    fill (ellX, ellY, [0, 1, 0.5]);
    hold on
    plot (centrX, centrY, 'Marker', '*', 'MarkerSize', 8, 'Color', 'b');
    [pathstr, ~, ~] = fileparts(which(modgen.common.getcallernameext(1)));
    Part1ofPath = modgen.path.rmlastnpathparts(pathstr, 4);
    Part2ofPath = strcat (FileName, '.eps');
    saveas (gcf,  [Part1ofPath filesep 'doc' filesep 'pic' filesep Part2ofPath]);
end
end