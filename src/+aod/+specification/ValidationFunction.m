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

        function [tf, ME, isValid] = validate(obj, input)
            % Validate an input according to function(s)
            %
            % Syntax:
            %   [tf, ME, isValid] = validate(obj, input)
            % -------------------------------------------------------------
            ME = [];

            if isempty(obj.Value)
                tf = true;
                isValid = [];
                return 
            end

            isValid = false(1, numel(obj.Value));

            for i = 1:numel(obj.Value)
                [tf, iME] = err2tf(obj.Value{i}, input);
                if numel(tf) > 1
                    warning("validate:TooManyOutputs",...
                        "%s returned %u outputs not 1, assuming value is invalid",...
                        func2str(obj.Value{i}), numel(tf));
                    tf = false;
                end
                isValid(i) = tf;

                if ~tf && ~isempty(iME)
                    ME = cat(2, ME, iME);    
                    % obj.notifyListeners(sprintf(...
                    %     "%s failed.", func2str(obj.Value{i})));
                end
            end
            tf = all(isValid);
        end

        function out = text(obj)
            if isempty(obj)
                out = "[]";
                return
            end

            out = func2str(aod.specification.util.combineFunctionHandles(...
                obj.Value));
            out = convertCharsToStrings(out);
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

            if istext(input)
                eval(sprintf("input = %s;", input));
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
            if ~isscalar(obj)
                tf = arrayfun(@isempty, obj);
                return
            end

            tf = isempty(obj.Value);
        end

        function tf = isequal(obj, other)
            if ~isa(other, 'aod.specification.ValidationFunction')
                tf = false;
                return
            end

            if nnz(isempty([obj, other])) == 1
                tf = false;
                return
            end

            tf = strcmp(text(obj), text(other));
        end
        
        function out = jsonencode(obj)
            if isempty(obj)
                out = jsonencode([]);
            else
                out = jsonencode(obj.text());
            end
        end
    end
end 