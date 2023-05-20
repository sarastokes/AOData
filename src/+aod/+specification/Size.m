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
            if nargin > 0
                obj.setValue(input);
            end
        end
    end

    % aod.specification.Specification methods
    methods
        function setValue(obj, input)
            if isempty(input) || strcmp(input, '[]')
                obj.Value = [];
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

        function tf = validate(obj, input)
            % Validate whether input size is consistent with specs
            % -----------------------------------------------------------

            % Check whether size is specified
            if isempty(obj)
                tf = true;
                return
            end

            % Check the dimensionality
            if numel(obj.Value) ~= ndims(input)
                tf = false;
                return
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
            if isempty(obj.Value) 
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
                error('Size:InvalidDimensions',...
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
                error('Size:InvalidDimensions', ...
                'Dimensionality specification cannot be scalar');
            end
            
            value = [];
            for i = 1:numel(input)
                value = [value, aod.specification.size.FixedDimension(input(i))];
            end
        end

        function value = parseMetaProperty(input)
            if isempty(input.Validation.Size)
                value = [];
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

    % MATLAB built-in methods
    methods 
        function tf = isempty(obj)
            tf = isempty(obj.Value);
        end

        function tf = isequal(obj, other)
            if ~isa(other, 'aod.specification.Size')
                tf = false;
                return 
            end

            if numel(obj.Value) ~= numel(other.Value)
                tf = false;
                return
            end

            for i = 1:numel(obj.Value)
                if ~isequal(class(obj.Value(i)), class(other.Value(i))) || ...
                        ~isequal(obj.Value(i), other.Value(i))
                    tf = false;
                    return
                end
            end
            tf = true;
        end
    end
end