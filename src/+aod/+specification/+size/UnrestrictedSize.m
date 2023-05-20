classdef UnrestrictedSize < aod.specification.Specification
% Absence of a specification, any size is allowed for any dimension
%
% Superclass:
%   aod.specification.Size
%
% Constructor:
%   obj = aod.specification.size.UnrestrictedSize
%
% Notes:
%   - Default size specification for any new object
%
% See also:
%   aod.specification.size.UnrestrictedDimension

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = UnrestrictedSize()
        end
    end

    methods
        function setValue(~, ~)
        end

        function tf = validate(~, ~)
            tf = true;
        end

        function output = text(obj)
            output = "[]";
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isequal(obj, other)
            tf = isa(other, class(obj));
        end
    end
end 