classdef Size < aod.schema.Validator & matlab.mixin.CustomDisplay
% Container for the expected size of a dataset or attribute
%
% Superclasses:
%   aod.schema.Specification
%
% Constructor:
%   obj = aod.schema.Size(input)
%
% Methods:
%   idx = isfixed(obj)
%   tf = isSpecified(obj)
%
%   tf = isequal(obj, other)
%   tf = isscalar(obj)
%   tf = isvector(obj)
%   out = jsonencode(obj, varargin)
%   x = ndims(obj)
%
% TODO: custom display so human-readable size is shown in disp()

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

%#ok<*ISMAT>

    properties (SetAccess = private)
        Value           = []
        SizeType        aod.schema.validators.size.SizeTypes = aod.schema.validators.size.SizeTypes.UNDEFINED
    end

    methods
        function obj = Size(input, parent)
            if nargin < 2
                parent = [];
            end
            obj = obj@aod.schema.Validator(parent);

            if nargin > 0
                obj.setValue(input);
            end
        end
    end

    % aod.schema.Specification methods
    methods
        function setValue(obj, input)
            % Set the Size value
            %
            % Syntax:
            %   setValue(obj, input)
            % -----------------------------------------------------------

            import aod.schema.validators.size.SizeTypes

            if aod.util.isempty(input) || (istext(input) && input == "[]")
                obj.Value = [];
                obj.SizeType = SizeTypes.UNDEFINED;
                return
            end

            try
                obj.SizeType = SizeTypes.get(input);
                input = obj.SizeType.getSizing();
            catch

            end

            if istext(input)
                obj.Value = obj.parseText(input);
                obj.setSizeType();
            elseif isa(input, 'meta.property')
                obj.Value = obj.parseMetaProperty(input);
                obj.setSizeType();
            elseif isnumeric(input)
                obj.Value = obj.parseNumeric(input);
                obj.setSizeType();
            end
        end

        function [tf, ME] = validate(obj, input)
            % Validate whether input size is consistent with specs
            %
            % Syntax:
            %   tf = validate(obj, input)
            % -----------------------------------------------------------

            ME = [];

            % Check whether size is specified
            if ~obj.isSpecified()
                tf = true;
                return
            end

            % Check the dimensionality
            if numel(obj.Value) ~= ndims(input)
                tf = false;
                ME = MException("Size:InvalidDimensionality",...
                    "Expected: %s. Actual: %s.",...
                    obj.text(), jsonencode(size(input)));
                return
            end

            % Check the individual dimensions
            for i = 1:numel(obj.Value)
                if ~validate(obj.Value(i), size(input, i))
                    tf = false;
                    ME = MException("Size:InvalidSize",...
                        "Expected: %s. Actual: %s.",...
                        obj.text(), jsonencode(size(input)));
                    return
                end
            end

            % If it passes all the tests, the input is valid
            tf = true;
        end

        function out = text(obj)
            % Converts to a text representation
            %
            % Syntax:
            %   out = text(obj)
            % -------------------------------------------------------------
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

        function tf = isSpecified(obj)
            % Determine whether object is empty (aka UNDEFINED)
            %
            % Syntax:
            %   tf = isSpecified(obj)
            % -------------------------------------------------------------
            tf = obj.SizeType ~= aod.schema.validators.size.SizeTypes.UNDEFINED;
        end
    end

    methods (Access = private)
        function setSizeType(obj)
            % Set the SizeType
            %
            % Syntax:
            %   setSizeType(obj)
            % -------------------------------------------------------------
            import aod.schema.validators.size.SizeTypes

            if numel(obj.Value) == 0
                obj.SizeType = SizeTypes.UNDEFINED;
            elseif ndims(obj) > 2
                obj.SizeType = SizeTypes.NDARRAY;
            elseif isscalar(obj)
                obj.SizeType = SizeTypes.SCALAR;
            elseif isvector(obj)
                if obj.isfixed(1) && obj.Value(1).Length == 1
                    obj.SizeType = SizeTypes.ROW;
                else
                    obj.SizeType = SizeTypes.COLUMN;
                end
            else
                obj.SizeType = SizeTypes.MATRIX;
            end
        end

        function idx = isfixed(obj, whichDim)
            % Return an index of which dimensions are fixed
            %
            % Syntax:
            %   idx = isfixed(obj, whichDim)
            %
            % Optional Inputs:
            %   whichDim        double, integer
            %       A specific dimension to return (default all dims)
            % -------------------------------------------------------------

            idx = arrayfun(@(x) isa(x, 'aod.schema.validators.size.FixedDimension'), obj.Value);
            if nargin > 1
                idx = idx(whichDim);
            end
        end
    end

    methods (Access = private)
        function value = parseText(obj, input)
            input = convertStringsToChars(input);

            [startIdx, endIdx] = regexp(input, "[\d:]{1,10}");
            if isempty(startIdx)
                error('Size:InvalidTextInput',...
                    'Text input must be numeric specification, "row", "column", "scalar", "matrix", or "undefined"')
            elseif numel(startIdx) == 1
                error('Size:InvalidDimensions',...
                    'Dimensionality specification cannot be scalar');
            end

            value = [];
            for i = 1:numel(startIdx)
                iSize = input(startIdx(i):endIdx(i));
                if strcmp(iSize, ':')
                   value = cat(2, value, aod.schema.validators.size.UnrestrictedDimension(obj));
                else
                    value = cat(2, value, aod.schema.validators.size.FixedDimension(obj, iSize));
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
                value = [value, aod.schema.validators.size.FixedDimension(obj, input(i))];
            end
        end

        function value = parseMetaProperty(input)
            if isempty(input.Validation) || isempty(input.Validation.Size)
                value = [];
            else
                mcSize = input.Validation.Size;
                value = [];
                for i = 1:numel(mcSize)
                    if isa(mcSize(i), 'meta.FixedDimension')
                        value = [value, aod.schema.validators.size.FixedDimension(...
                            obj, double(mcSize(i).Length))];
                    else
                        value = [value, aod.schema.validators.size.UnrestrictedDimension(obj)];
                    end
                end
            end
        end
    end

    % CustomDisplay methods
    methods (Access = protected)
        function header = getHeader(obj)
            if ~isscalar(obj)
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            else
                className = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                newHeader = [className, obj.text(), ' with properties:'];
                header = sprintf('%s\n',newHeader);
            end
        end
    end

    % MATLAB built-in methods
    methods
        function tf = isequal(obj, other)
            % Determine whether two objects are equal
            %
            % Syntax:
            %   tf = isequal(obj, other)
            % -------------------------------------------------------------
            if ~isa(other, 'aod.schema.validators.Size')
                tf = false;
                return
            end

            if numel(obj.Value) ~= numel(other.Value)
                tf = false;
                return
            end

            tf = strcmp(obj.text(), other.text());
        end

        function out = jsonencode(obj, varargin)
            % Convert to JSON-formatted text
            %
            % Syntax:
            %   out = jsonencode(obj, varargin)
            % -------------------------------------------------------------
            if ~obj.isSpecified()
                out = jsonencode([], varargin{:});
            else
                out = jsonencode(obj.text(), varargin{:});
            end
        end

        function value = ndims(obj)
            % Determine the number of dimensions specified
            %
            % Syntax:
            %   value = ndims(obj)
            %
            % Notes:
            %   - If Size is empty (a.k.a. undefined), value will be empty
            % -------------------------------------------------------------
            if numel(obj.Value) == 0
                value = [];
            else
                value = numel(obj.Value);
            end
        end

        function tf = isscalar(obj)
            % Determine whether specification is a scalar
            %
            % Syntax:
            %   tf = isscalar(obj)
            % -------------------------------------------------------------
            tf = false;
            if ~obj.isSpecified()
                return
            end

            if ndims(obj) == 2 && all(obj.isfixed())
                if all(arrayfun(@(x) x.Length == 1, obj.Value))
                    tf = true;
                end
            end
        end

        function tf = isvector(obj)
            % Determine whether specification is a vector
            %
            % Syntax:
            %   tf = isvector(obj)
            % -------------------------------------------------------------
            if ~obj.isSpecified()
                tf = false;
                return
            end

            fixedDims = obj.isfixed();
            if ndims(obj) ~= 2 || nnz(fixedDims) == 0
                tf = false;
                return
            end

            idx = false(1, obj.ndims());
            for i = 1:numel(obj.Value)
                if fixedDims(i) && obj.Value(i).Length == 1
                    idx(i) = true;
                end
            end

            tf = (nnz(idx) == 1);
        end
    end
end