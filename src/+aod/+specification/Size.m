classdef Size < aod.specification.Validator
% Container for the expected size of a dataset or parameter
%
% Superclasses:
%   aod.specification.Specification
%
% Static method constructor:
%   obj = aod.specification.Size(input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value
    end

    methods
        function obj = Size(input)
            if nargin < 1 || isempty(input) || strcmp(input, '[]')
                obj.Value = aod.specification.size.UnrestrictedSize;
                return
            end

            if istext(input)
                obj.Value = obj.parseText(input);
            elseif isa(input, 'meta.property')
                obj.Value = obj.parseMetaProperty(input);
            elseif isnumeric(input)
                obj.Value = obj.parseNumeric(input);
            end 
        end
    end

    % aod.specification.Specification methods
    methods
        function tf = validate(obj, input)
            % Validate whether input size is consistent with specs
            % -----------------------------------------------------------

            % Check whether size is specified
            if isempty(obj) || isa(obj, 'aod.specification.size.UnrestrictedSize')
                tf = true;
                return
            end

            % Check the dimensionality
            if numel(obj) ~= ndims(input)
                error('validate:DimensionsDoNotMatch',...
                    "Input was expected to have %u dimensions, but had %u",...
                    numel(obj), ndims(input));
            end
            % Check the individual dimensions
            for i = 1:numel(obj.Value)
                if ~validate(obj.Value(i), size(input, i))
                    tf = false;
                    return
                end
            end
            tf = true;
        end

        function out = text(obj)
            % Converts to a text representation
            if isempty(obj.Value) || isa(obj.Value, 'aod.specification.size.UnrestrictedSize')
                out = "[]";
                return
            end

            out = '(';
            for i = 1:numel(obj.Value)
                out = [out, char(obj.Value(i).text())]; %#ok<*AGROW>
                if i == numel(obj.Value)
                    out = [out, ')'];
                else
                    out = [out, ','];
                end
            end

            out = string(out);
        end
    end

    methods (Static, Access = private)
        function value = parseText(input)
            input = convertStringsToChars(input);

            [startIdx, endIdx] = regexp(input, "[\d:]{1,10}");
            if numel(startIdx) == 1
                error('init:InvalidDimensions',...
                    'Dimensionality specification cannot be scalar');
            end

            value = [];
            for i = 1:numel(startIdx)
                iSize = input(startIdx(i):endIdx(i));
                if strcmp(iSize, ':')
                   value = cat(2, value, aod.specification.size.UnrestrictedDimension());
                else
                    value = cat(2, value, aod.specification.size.FixedDimension(iSize));
                end
            end
        end

        function value = parseNumeric(input)
            if numel(input) == 1
                error('init:InvalidDimensions', ...
                'Dimensionality specification cannot be scalar');
            end
            
            value = [];
            for i = 1:numel(input)
                value = [value, aod.specification.size.FixedDimension(input(i))];
            end
        end

        function value = parseMetaProperty(input)
            if isempty(input.Validation.Size)
                value = aod.specification.size.None;
            else 
                mcSize = input.Validation.Size;
                value = [];
                for i = 1:numel(mcSize)
                    if isa(mcSize(i), 'meta.FixedDimension')
                        value = [value, aod.specification.size.FixedDimension(...
                            double(mcSize(i).Length))];
                    else
                        value = [value, aod.specification.size.UnrestrictedDimension];
                    end
                end
            end
        end
    end
end