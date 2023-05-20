classdef DataObject < handle 

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Name            (1,1)     string
        Size            (1,1)     aod.specification.Size = aod.specification.Size([]);
        Class           (1,1)     aod.specification.MatlabClass = aod.specification.MatlabClass([]);
        Default         (1,1)     aod.specification.DefaultValue = aod.specification.DefaultValue([])
        Functions       (1,1)     aod.specification.ValidationFunction = aod.specification.ValidationFunction([])
        Description     (1,1)     aod.specification.Description = aod.specification.Description([])
    end

    properties (Hidden, Constant)
        FIELDS = ["size", "class", "default", "function", "description"];
    end

    methods
        function obj = DataObject(prop, varargin)

            % Defaults
            obj.Size = aod.specification.Size([]);

            % Initialize from meta.property
            if isa(prop, 'meta.property')
                obj.Name = prop.Name;
                arrayfun(@(x) obj.parse(x, prop), obj.FIELDS);
                obj.checkIntegrity();
                return
            end

            % Initialize from user-defined inputs
            obj.Name = prop;
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Size', []);
            addParameter(ip, 'Description', "");
            addParameter(ip, 'Class', []);
            addParameter(ip, 'Function', {});
            addParameter(ip, 'Default', []);
            parse(ip, varargin{:});

            %setParams = setdiff(ip.Parameters, ip.UsingDefaults);
            %cellfun(@(x) obj.parse(x, ip.Results.(x)), setParams);
            arrayfun(@(x) obj.parse(x, ip.Results.(x)), string(ip.Parameters));
            obj.checkIntegrity();
        end

        function tf = validate(obj, input)
            tf1 = obj.Size.validate(input);
            tf2 = obj.Class.validate(input);
            tf3 = obj.Functions.validate(input);
            tf = all([tf1, tf2, tf3]);
        end

        function setClass(obj, input)
            obj.Class.setValue(input);
            obj.checkIntegrity();
        end
    
        function setSize(obj, input)
            obj.Size.setValue(input);
            obj.checkIntegrity();
        end

        function setFunctions(obj, input)
            obj.Functions.setValue(input);
            obj.checkIntegrity();
        end

        function setDefault(obj, input)
            obj.Default.setValue(input);
            obj.checkIntegrity();
        end
    end

    methods (Access = private)
        function parse(obj, specType, specValue)
            arguments
                obj
                specType        char
                specValue 
            end

            switch lower(specType) 
                case 'size'
                    obj.setSize(specValue);
                case 'function'
                    obj.setFunctions(specValue);
                case 'class'
                    obj.setClass(specValue);
                case 'default'
                    obj.setDefault(specValue);
                case 'description'
                    obj.Description.setValue(specValue);
                otherwise
                    error('DataObject:InvalidType',...
                        'Specification type must be size, function class, default or description');
            end
        end

        function checkIntegrity(obj)
            if aod.util.isempty(obj.Default)
                return
            end

            % Is default value the correct size?
            obj.Size.validate(obj.Default.Value);

            % Is default value of the appropriate class?
            if ~isempty(obj.Class)
                obj.Class.validate(obj.Default.Value);
            end

            % Does default value pass the validation functions
            if ~isempty(obj.Functions)
                tf = obj.Functions.validate(obj.Default.Value);
                if ~tf 
                    error('checkIntegrity:DefaultValueDoesNotValidate',...
                        'The default value did not pass the validation')
                end
            end
        end
    end
end 