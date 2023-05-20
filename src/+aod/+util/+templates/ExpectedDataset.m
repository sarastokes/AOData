classdef ExpectedDataset < handle & matlab.mixin.SetGet
% HDF5 dataset specification
%
% Parent:
%   handle, matlab.mixin.SetGet
%
% Constructor:
%   obj = aod.util.templates.ExpectedDataset(name, className, validator,...
%       description, units)
%
% See also:
%   aod.util.remplates.ExpectedDataset, aod.util.AttributeManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Name                string      = string.empty()
        Class               string      = string.empty()
        Default    
        Validation          cell        = cell.empty()
        Description         string      = string.empty()
        Units               string      = string.empty()
    end

    methods
        function obj = ExpectedDataset(name, className, defaultValue, validator, description, units)
            obj.Name = convertCharsToStrings(name);

            if nargin > 1 && ~isempty(className)
                obj.Class = obj.parseClassName(className);
            end

            if nargin > 2 && ~isempty(defaultValue)
                obj.Default = defaultValue;
            end

            if nargin > 3 && ~isempty(validator)
                obj.Validation = validator;
            end

            if nargin > 4 && ~isempty(description)
                obj.Description = description;
            end

            if nargin > 5 && ~isempty(units)
                obj.Units = units;
            end
        end

        function set.Class(obj, value)
            obj.Class = obj.parseClassName(value);
        end

        function set.Validation(obj, value)
            if isa(value, 'function_handle') && isscalar(value)
                obj.Validation = {value};
                return
            end

            if iscell(value)
                if ~isempty(value)
                    for i = 1:numel(value)
                        assert(isa(value{i}, 'function_handle'),... 
                            'Each member of the cell must be a function handle');
                    end
                end
                obj.Validation = value;
                return
            end

            error('ExpectedDataset:InvalidValue',...
                'Validation must be function handle or cell of function handles');
        end
    end

    methods (Static)
        function value = parseClassName(value)

            if isempty(value)
                value = string.empty();
                return
            end

            % meta.class inputs
            if isa(value, 'meta.class')
                value = value.Name;
                return
            end

            % Class name inputs
            value = convertCharsToStrings(value);
            % If multiple class names are provided split by comma
            if contains(value, ",")
                value = strsplit(value, ",");
            end
            
            % Ensure the classes exist on MATLAB path
            %goodClass = string.empty();
            %badClass = string.empty();
            %for i = 1:numel(value)
            %    iValue = value(i);
                
                %if ~exist(extractBetween(iValue, '"', '"'), 'class') ... 
                %        && ~exist(extractBetween(iValue, '"','"'), 'builtin')
                %    badClass = cat(1, badClass, iValue);
                %else
                %    goodClass = cat(1, goodClass, iValue);
                %end
            %end
            %if ~isempty(badClass)
            %    error("parseClassName:InvalidClass",...
            %        "Class %s is not identified on MATLAB path", badClass);
            %end
            %value = goodClass;
        end
    end
end 