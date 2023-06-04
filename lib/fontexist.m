function bool = fontexist(font)
%FONTEXIST Check existence of font.
%   FONTEXIST(FONT) returns TRUE if FONT is an available system font.
% Created 2016-01-05 by Jorg C. Woehl
% 2016-12-16 (JCW): Converted to standalone function, comments added.
% input: empty character array, or character vector
assert(ischar(font) && (isrow(font) || isempty(font)),...
    'fontexist:IncorrectInputType', 'Input must be an empty character array or a character vector.');
if isempty(font)
    % reduce to simplest empty type
    font = '';
end
idx = find(strcmpi(listfonts, font), 1);
bool = ~isempty(idx);
end