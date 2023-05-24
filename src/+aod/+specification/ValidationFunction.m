classdef ValidationFunction < aod.specification.Validator
% Validation functions for dataset
%
% Superclass:
%   aod.specification.Validator
%
% Constructor:
%   obj = aod.specification.ValdiationFunction(input)
%
% Examples:
%   % Intiialize from a single function handle
%   obj = aod.specification.ValidationFunction(@mustBeNumeric);
%
%   % Initialize from a cell of function handles
%   obj = aod.specification.ValidationFunction({@isnumeric, @(x) x > 1})
%
%   % Initialize from meta.property
%   mc = meta.class.fromName('aod.core.Experiment')
%   obj = aod.specification.ValidationFunction(mc.PropertyList(1));
%
% Notes:
%   - Both validation functions without an output (e.g. mustBeNumeric) and
%       validation functions with a logical output (e.g. isdouble) are ok
%   - Mirrors meta.Validation which isn't accessible

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value   (1,:)      cell    = cell.empty()
    end

    methods
        function obj = ValidationFunction(input)
            if nargin > 0 
                if ~isempty(input)
                    obj.setValue(input);
                end
            end
        end
    end

    % aod.specification.Specification methods
    methods 
        function setValue(obj, input)
            if aod.util.isempty(input)
                obj.Value = {};
            else
                obj.Value = obj.validateInput(input);
            end
        end

        function tf = validate(obj, input)
            if isempty(obj.Value)
                tf = true;
                return 
            end

            % Validation functions like mustBeNumeric have no output but 
            % will have errored if invalid. Other functions should return 
            % true, so isValid should be a cell with empty or 1 (not 0)
            isValid = false(1, numel(obj.Value));

            for i = 1:numel(obj.Value)
                iValid = [];
                try
                    % Validation function that returns true/false
                    iValid = obj.Value{i}(input);
                    % Make sure the validation function is appropriate
                    if ~islogical(iValid)
                        error('validate:InvalidValidationFunctions',...
                            'Function %u returned type %s, but should return logical',...
                            i, class(iValid));
                    end
                catch ME 
                    % Skip errors by "mustBe" validation functions
                    if ~strcmp(ME.identifier, "MATLAB:TooManyOutputs")
                        iValid = false;
                    end
                end
                if isempty(iValid)
                    try
                        obj.Value{i}(input);
                        iValid = true;      % Would have errored if failed
                    catch ME
                        iValid = false;
                        warning(ME.identifier, '%s', ME.message);
                    end
                end
                isValid(i) = iValid;
            end
            tf = all(iValid);
        end

        function out = text(obj)
            if isempty(obj)
                out = "[]";
                return
            end
            
            indiv = cellfun(@(x) string(func2str(x)), obj.Value);
            if numel(indiv) > 1
                out = "{";
                for i = 1:numel(indiv)
                    out = out + indiv(i);
                    if i < numel(indiv)
                        out = out + ", ";
                    end
                end
                out = out + "}";
            else
                out = "{" + indiv + "}";
            end
        end
    end

    methods (Static, Access = private)
        function output = validateInput(input)
            if isa(input, 'meta.property')
                if isempty(input.Validation) || isempty(input.Validation.ValidatorFunctions)
                    output = [];
                else
                    output = input.Validation.ValidatorFunctions;
                end
                return
            end

            [tf, output] = isfunctionhandle(input);
            if ~tf 
                error('validateFunctionHandles:InvalidInput',...
                    'Input must be function handle, cell of function handles or text convertable to a function handle');
            end
        end
    end

    % MATLAB built-in methods
    methods 
        function tf = isempty(obj)
            tf = isempty(obj.Value);
        end
    end
end 