classdef Format < aod.schema.Validator
% FORMAT
%
% Description:
%   Used to validate data with a 'Format' property (datetime, duration)
%
% Superclasses:
%   aod.schema.Validator
%
% Constructor:
%   obj = aod.schema.validators.Format(parent, value)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value
    end

    methods
        function obj = Format(parent, value)
            obj = obj@aod.schema.Validator(parent);

            if ~aod.util.isempty(value)
                obj.setValue(value);
            end
        end
    end

    methods
        function setValue(obj, value)
            arguments
                obj
                value
            end

            if aod.util.isempty(value)
                obj.Value = [];
            else
                obj.Value = value;
            end
        end
    end

    methods
        function [tf, ME] = validate(obj, input)
            ME = [];
            if isdatetime(input) || isduration(input)
                tf = strcmp(input.Format, obj.Value);
                if ~tf
                    ME = MException(...
                        'validate:FailedValidation',...
                        'Input has format %s, not %s', input.Format, obj.Value);
                end
            else
                % TODO: Idk how  to confirm here w/out the primitive type
                % Is it better to keep validation in one place or perform
                % it in the parent primitive's validation call?
                tf = true;
            end
        end

        function out = text(obj)
            out = value2string(obj.Value);
            out = convertCharsToStrings(out);
        end
    end
end