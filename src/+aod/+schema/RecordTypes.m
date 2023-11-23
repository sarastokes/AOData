classdef RecordTypes
% RECORDTYPES
%
% Description:
%   Enumeration for the types of records in an AOData schema. Should
%   inherit from "string" but this is not supported as of 2023b

% By Sara Patterson, 2023 (AOData)
% ----------------------------------------------------------------------

    enumeration
        ATTRIBUTE
        DATASET
        FILE
        UNDEFINED
    end

    methods
        function value = plural(obj)
            value = string(obj) + "s";
        end
    end

    % Builtin MATLAB methods
    methods
        function out = char(obj)
            % Returns char of entity type with correct capitalization
            %
            % Note:
            %   Necessary to avoid calling "string" bc infinite recursion
            % ----------------------------------------------------------
            import aod.schema.RecordTypes

            if ~isscalar(obj)
                out = aod.util.arrayfun(@(x) char(x), obj);
                return
            end

            switch obj
                case RecordTypes.ATTRIBUTE
                    out = 'Attribute';
                case RecordTypes.DATASET
                    out = 'Dataset';
                case RecordTypes.FILE
                    out = 'File';
                case RecordTypes.UNDEFINED
                    out = 'Undefined';
            end
        end

        function out = string(obj)
            % Returns string of entity type with correct capitalization
            %
            % Note:
            %   Necessary to avoid calling "string" bc infinite recursion
            % -------------------------------------------------------------

            if ~isscalar(obj)
                out = aod.util.arrayfun(@(x) string(x), obj);
                return
            end

            out = sprintf("%s", char(obj));
        end
    end

    methods (Static)
        function obj = get(input)
            import aod.schema.RecordTypes

            input = convertCharsToStrings(input);

            if ~isscalar(input)
                obj = arrayfun(@(x) RecordTypes.get(x), input);
                return
            end

            if isa(input, 'aod.schema.RecordTypes')
                obj = input;
                return
            end

            if ~isstring(input)
                error('get:InvalidInputType',...
                    'Input must be string or char');
            end

            switch lower(input)
                case {'dataset', 'datasets', 'dset'}
                    obj = RecordTypes.DATASET;
                case {'file', 'files'}
                    obj = RecordTypes.FILE;
                case {'attribute', 'attributes', 'attr'}
                    obj = RecordTypes.ATTRIBUTE;
                otherwise
                    error('get:UnknownRecordType',...
                        'Record type %s not recognized', input);
            end
        end
    end
end