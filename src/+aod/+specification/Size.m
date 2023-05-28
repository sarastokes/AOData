classdef Size < aod.specification.Validator
% Container for the expected size of a dataset or attribute
%
% Superclasses:
%   aod.specification.Specification
%
% Static method constructor:
%   obj = aod.specification.Size(input)
%
% Methods:
%   tf = isempty(obj)
%   tf = isequal(obj, other)
%   tf = isscalar(obj)
%   tf = isvector(obj)
%   x = ndims(obj)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

%#ok<*ISMAT>

    properties (SetAccess = private)
        Value           = []
        SizeType        aod.specification.SizeTypes = aod.specification.SizeTypes.UNDEFINED   
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
            % Set the Size value
            %
            % Syntax:
            %   setValue(obj, input)
            % -----------------------------------------------------------
            
            import aod.specification.SizeTypes

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

        function tf = validate(obj, input)
            % Validate whether input size is consistent with specs
            %
            % Syntax:
            %   tf = validate(obj, input)
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

            % If it passes all the tests, the input is valid
            tf = true;
        end

        function out = text(obj)
            % Converts to a text representation
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
    end

    methods (Access = private)
        function setSizeType(obj)
            % Set aod.specification.SizeTypes
            % -------------------------------------------------------------
            import aod.specification.SizeTypes

            if isempty(obj.Value)
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
            idx = arrayfun(@(x) isa(x, 'aod.specification.size.FixedDimension'), obj.Value);
            if nargin > 1
                idx = idx(whichDim);
            end
        end
    end

    methods (Static, Access = private)

        function value = parseText(input)
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
            if isempty(input.Validation) || isempty(input.Validation.Size)
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
            % Determine whether object is empty (aka UNDEFINED)
            %
            % Syntax:
            %   tf = isempty(obj)
            % -------------------------------------------------------------
            tf = isempty(obj.Value);
        end

        function tf = isequal(obj, other)
            % Determine whether two objects are equal
            %
            % Syntax:
            %   tf = isequal(obj, other)
            % -------------------------------------------------------------
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

        function out = jsonencode(obj)
            if isempty(obj)
                out = jsonencode([]);
            else
                out = jsonencode(obj.text());
            end
        end

        function value = ndims(obj)
            % Determine the number of dimensions specified
            %
            % Syntax:
            %   value = ndims(obj)
            %
            % Notes:
            %   - If Size is empty (aka undefined), value will be empty
            % -------------------------------------------------------------
            if isempty(obj.Value)
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
            %   tf = isrow(obj)
            % -------------------------------------------------------------
            if isempty(obj)
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