classdef AttributeManager < aod.specification.SpecificationManager
% Manage expected attributes
%
% Superclasses:
%   aod.specification.SpecificationManager
%
% Constructor:
%   obj = aod.core.AttributeManager(className)
%
% Public methods:
%   ip = getParser(obj)
%   ip = parse(obj, varargin)
% Overloaded methods:
%   add(obj, attrName, varargin)
% Restricted methods:
%   setClassName(obj, className)    {?aod.core.Entity}

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        specType = "Attribute"
    end

    methods
        function obj = AttributeManager(className)
            if nargin < 1
                className = "Unknown";
            end
            obj@aod.specification.SpecificationManager(className);
        end
    end

    methods
        function add(obj, attr, varargin)
            % Add a new attribute
            %
            % Syntax:
            %   add(obj, attrName, varargin)
            % -------------------------------------------------------------
            if istext(attr)
                entry = aod.specification.Entry(attr, varargin{:});
            else
                entry = attr;
            end
            add@aod.specification.SpecificationManager(obj, entry);
        end

        function ip = parse(obj, varargin)
            % Parse key/value inputs according to specified attributes
            %
            % Syntax:
            %   ip = parse(obj, varargin)
            % -------------------------------------------------------------

            ip = obj.getParser();
            parse(ip, varargin{:});
        end

        function ip = getParser(obj)
            % Create an input parser for the attributes
            %
            % Syntax:
            %   ip = getParser(obj)
            %
            % See also:
            %   aod.util.InputParser, inputParser
            % -------------------------------------------------------------
            ip = aod.util.InputParser();

            for i = 1:obj.Count
                if aod.util.isempty(obj.Entries(i).Default)
                    defaultValue = [];
                else
                    defaultValue = obj.Entries(i).Default.Value;
                end

                validators = obj.Entries(i).getFullValidation();

                if isempty(validators)
                    addParameter(ip, obj.Entries(i).Name, defaultValue);
                else
                    addParameter(ip, obj.Entries(i).Name, defaultValue, validators);
                end
            end
        end
    end

    methods
        function setClassName(obj, className)
            % Set the class name
            %
            % Description:
            %   Used by core interface to support static method for the
            %   expectedAttributes of a core subclass
            %
            % Syntax:
            %   setClassName(obj, className)
            % -------------------------------------------------------------
            obj.className = className;
        end
    end
end