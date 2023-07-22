classdef DescriptionFilter < aod.api.DatasetFilter 
% Filter entities by the content of their description
%
% Superclasses:
%   aod.api.DatasetFilter
%
% Syntax:
%   obj = aod.api.DescriptionFilter(value)
%
% Notes:
%   - This is equivalent to a DatasetFilter with "Description" as the name 
%     and the provided value as the 2nd input.
%
% See also:
%   aod.api.DatasetFilter

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = DescriptionFilter(parent, value)
            value = convertCharsToStrings(value);

            if nargin == 0
                value = [];
            elseif ~isa(value, 'function_handle') && (~istext(value) && isscalar(value))
                error('DescriptionFilter:InvalidInput',...
                    'Value must be a function handle or string scalar');
            end

            obj = obj@aod.api.DatasetFilter(parent, 'description', value);
        end
    end

    % FilterQuery methods
    methods
        function tag = describe(obj)
            tag = describe@aod.api.DatasetFilter(obj);
            tag = strrep(tag, 'DatasetFilter', 'DescriptionFilter');
        end

        function out = apply(obj)
            out = apply@aod.api.DatasetFilter(obj);
        end

        function txt = code(obj, varargin)
            txt = code@aod.api.DatasetFilter(obj);
            txt = strrep(txt, 'DatasetFilter', 'DescriptionFilter');
        end

    end
end