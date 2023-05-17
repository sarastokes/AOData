classdef ValidationFunction < aod.specification.Specification
%
% Constructor:
%   obj = aod.specification.ValdiationFunction(input)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Functions (1,:)      cell    = {}
    end

    methods
        function obj = ValidationFunction(input)
            if nargin > 0 || isempty(input)
                obj.Functions = obj.validateFunctionHandles(input);
            end
        end

        function tf = validate(obj, input)
            if isempty(obj.Functions)
                tf = true;
                return 
            end
            
            % Validation functions like mustBeNumeric have no output but 
            % will have errored if invalid. Other functions should return 
            % true, so isValid should be a cell with empty or 1 (not 0)
            isValid = false(1, numel(obj.Functions));
            for i = 1:numel(obj.Functions)
                iValid = [];
                try
                    % Validation function that returns true/false
                    iValid = obj.Functions{i}(input);
                    % Make sure the validation function is appropriate
                    if ~islogical(iValid)
                        error('validate:InvalidValidationFunctions',...
                            'Function %u returned type %s, but should return true/false',...
                            i, class(iValid));
                    end
                catch ME 
                    % Skip errors by "mustBe" validation functions
                    if ~strcmp(ME.identifier, "MATLAB:TooManyOutputs")
                        rethrow(ME);
                    end
                end
                if isempty(iValid)
                    obj.Functions{i}(input);
                    iValid = true; % Would have errored if invalid
                end
                isValid(i) = iValid;
            end
            tf = isValid;
        end

        function out = text(obj)
            out = cellfun(@(x) string(func2str(x)), obj.Functions);
        end
    end

    methods (Static)
        function output = validateFunctionHandles(input)
            [tf, output] = isfunctionhandle(input);
            if ~tf 
                error('valdiateFunctionHandles:InvalidInput',...
                    'Input must be function handle, cell of function handles or text convertable to a function handle');
            end
        end

        function out = get(input)
            [tf, output] = isfunctionhandle(input);
            if ~iscolumn(output)
                output = output';
            end
        end
    end
end 