classdef Specification < handle & matlab.mixin.Heterogeneous & matlab.mixin.SetGet
% Parent class for all property, link and attribute specifications
%
% Parent:
%   handle, matlab.mixin.Heterogeneous, matlab.mixin.SetGet

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        % Validation functions
        Validation (1,:)    cell            = cell(1,0)
        % Information about the property such as units
        Description         string          = string.empty()
        % Automate a set method
        makeSetFcn          logical         = false  
        % Whether property is a required input to constructor
        isRequired          logical         = false 
        % Whether property is an optional key/value input to constructor
        isOptional          logical         = false 
    end

    methods
        function obj = Specification()
        end
    end

    methods 
        function set.isRequired(obj, value)
            arguments
                obj
                value       logical 
            end

            obj.isRequired = value;
            if value && obj.isOptional %#ok<*MCSUP> 
                obj.isOptional = false;
            end
        end

        function set.isOptional(obj, value)
            arguments
                obj
                value       logical 
            end
            
            obj.isOptional = value;
            if value && obj.isRequired
                obj.isRequired = false;
            end
        end 

        function set.Validation(obj, value)
            arguments
                obj
                value
            end

            if isempty(value)
                obj.Validation = cell(1,0);
                return
            end
            
            if iscell(value)
                if ~isvector(value)
                    error("setValidation:MustBeVector",...
                        "Validation function handles must be scalar or a vector");
                end
                for i = 1:numel(value)
                    if istext(value{i})
                        eval(sprintf('iValue=%s;', value{i}));
                    else
                        iValue = value{i};
                    end
                    if ~isa(iValue, 'function_handle')
                        error("setValidation:MustBeFunctionHandle",...
                            "Validation must be function handles");
                    end
                end
                obj.Validation = value;
            elseif isa(value, 'function_handle')
                obj.Validation = {value};
            elseif istext(value)
                eval(sprintf('value=%s;', value));
                obj.Validation = {value};
            else
                error("setValidation:InvalidInput",...
                    "Must be convertable to function_handle or a cell array of function_handles");
            end
        end
    end
end 