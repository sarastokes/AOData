classdef (Abstract) Size < matlab.mixin.Heterogeneous
%
% Parent:
%   matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.specification.Size()

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods (Abstract)
        tf = isValid(obj, input)
    end

    methods
        function obj = Size()
        end
    end

    methods (Sealed)
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
                    numel(obj), numel(input));
            end
            % Check the individual dimensions
            for i = 1:numel(obj)
                if ~isValid(obj(i), size(input, i))
                    tf = false;
                    return
                end
            end
            tf = true;
        end
    end

    methods (Static)
        function obj = init(input)
            % Creates Dimensionality from text
            %
            % Syntax:
            %   obj = aod.specification.Size.init(input)
            %
            % Examples:
            %   obj = aod.size.Dimensionality.init("(1,:)")
            %   obj = aod.size.Dimensionality.init("[]")
            % -----------------------------------------------------------
            
            arguments
                input       char 
            end
            
            if strcmp(input, '[]')
                obj = aod.specification.size.None;
                return 
            end

            [startIdx, endIdx] = regexp(input, "[\d:]{1,10}");
            if numel(startIdx) == 1
                error('init:InvalidDimensions',...
                    'Dimensionality specification cannot be scalar');
            end

            obj = [];
            for i = 1:numel(startIdx)
                iSize = input(startIdx(i):endIdx(i));
                if strcmp(iSize, ':')
                   obj = cat(2, obj, aod.specification.size.UnrestrictedDimension());
                else
                    obj = cat(2, obj, aod.specification.size.FixedDimension(iSize));
                end
            end
        end

        function out = getText(obj)
            % Converts to a text representation
            if isempty(obj) || isa(obj, 'aod.specification.size.UnrestrictedSize')
                out = [];
                return
            end

            out = '(';
            for i = 1:numel(obj)
                out = [out, char(obj(i))]; %#ok<*AGROW>
                if i == numel(obj)
                    out = [out, ')'];
                else
                    out = [out, ','];
                end
            end

            out = string(out);
        end
    end

    % matlab.mixin.Heterogeneous methods
    methods (Static, Sealed, Access = protected)
        function defaultObj = getDefaultScalarElement()
            defaultObj = aod.specification.size.UnrestrictedSize;
        end
    end
end