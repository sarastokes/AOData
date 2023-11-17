classdef RecordTypes
% RECORDTYPES
%
% Description:
%   Enumeration for the types of records in an AOData schema
%

% By Sara Patterson, 2023 (AOData)
% ----------------------------------------------------------------------

    enumeration
        ATTRIBUTE
        DATASET
        FILE
    end

    methods
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