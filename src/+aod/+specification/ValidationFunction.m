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

        function [tf, isValid, exceptions] = validate(obj, input)
            % Validate an input according to function(s)
            %
            % Syntax:
            %   [tf, isValid, exceptions] = validate(obj, input)
            % -------------------------------------------------------------
            exceptions = [];

            if isempty(obj.Value)
                tf = true;
                isValid = [];
                return 
            end

            isValid = false(1, numel(obj.Value));

            for i = 1:numel(obj.Value)
                [tf, ME] = err2tf(obj.Value{i}, input);
                if numel(tf) > 1
                    warning("validate:TooManyOutputs",...
                        "%s returned %u outputs not 1, assuming value is invalid",...
                        func2str(obj.Value{i}), numel(tf));
                    tf = false;
                end
                isValid(i) = tf;
                if ~tf && ~isempty(ME)
                    exceptions = cat(1, exceptions, ME);    
                    obj.notifyListeners(sprintf(...
                        "%s failed.", func2str(obj.Value{i})));
                end
            end
            tf = all(isValid);
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
                    out = out + formatFcn(indiv(i));
                    if i < numel(indiv)
                        out = out + ", ";
                    end
                end
                out = out + "}";
            else
                out = "{" + formatFcn(indiv) + "}";
            end

            function y = formatFcn(x)
                if ~startsWith(x, "@")
                    y = "@" + x;
                else
                    y = x;
                end
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
        
        function out = jsonencode(obj)
            if isempty(obj)
                out = jsonencode([]);
            else
                out = jsonencode(obj.text());
            end
        end
    end
end 