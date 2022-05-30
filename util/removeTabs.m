function out = removeTabs(txt)
    % REMOVETABS
    %
    % Description:
    %   Remove tabs from text
    %
    % Syntax:
    %   out = removeTabs(txt)
    %
    % History:
    %   30May2022 - SSP
    % ---------------------------------------------------------------------

    if isempty(txt)
        out = [];
        return
    end
    out = regexprep(txt, '\t', '');