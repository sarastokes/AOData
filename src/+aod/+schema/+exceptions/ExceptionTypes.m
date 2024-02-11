classdef ExceptionTypes

    enumeration
        VALIDATION_FAILURE
        SCHEMA_INTEGRITY
        UNDEFINED_PRIMITIVE
        UNMET_REQUIREMENT
    end

    methods (Static)
        function obj = get(input)
            if isa(input, 'aod.schema.exceptions.ExceptionType')
                obj = input;
                return
            end

            switch lower(input)
                case {'validation', 'validationfailure'}
                    obj = ExceptionTypes.VALIDATION_FAILURE;
                case {'integrity', 'schemaintegrity'}
                    obj = ExceptionTypes.SCHEMA_INTEGRITY;
                case {'undefined', 'undefinedprimitive'}
                    obj = ExceptionTypes.UNDEFINED_PRIMITIVE;
                case {'unmet', 'requirement', 'unmetrequirement'}
                    obj = ExceptionTypes.UNMET_REQUIREMENT;
                otherwise
                    error("ExceptionTypes:get:InvalidInput",...
                        "Input %s does not match a known exception type", input);
            end
        end
    end
end