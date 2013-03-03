function res = my_color_table(ch)
%
% MY_COLOR_TABLE - returns the code of the color defined by single letter.
%

  if ~(ischar(ch))
    res = [0 0 0];
    return;
  end

  switch ch
    case 'r',
      res = [1 0 0];

    case 'g',
      res = [0 1 0];

    case 'b',
      res = [0 0 1];

    case 'y',
      res = [1 1 0];

    case 'c',
      res = [0 1 1];

    case 'm',
      res = [1 0 1];

    case 'w',
      res = [1 1 1];

    otherwise,
      res = [0 0 0];
  end

  return;
