function out = dehyphenate(str)
% DEHYPHENATE
%
% Description:
%   Remove hyphens from text
%
% Syntax:
%   out = dehyphenate(str)
%
% History:
%   29Aug2022 - SSP
% -------------------------------------------------------------------------

    out = erase(str, '-');
    