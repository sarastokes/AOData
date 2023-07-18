function tf = isdouble01(val)
% ISDOUBLE01
%
% Description:
%   Convenience function to determine if input is a double between 0 and 1
%
% Syntax:
%   tf = isdouble01(val)
%
% History:
%   10May2022 - SSP
% ---------------------------------------------------------------------

    if ~isa(val, 'double')
        tf = false;
        return
    end

    if any(val > 1) || any(val < 0)
        tf = false;
        return
    end

    tf = true;
