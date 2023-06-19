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
            %obj.specType = "Attribute";
        end
    end

    methods 
        function add(obj, attrName, varargin)
            % Add a new attribute
            %
            % Syntax:
            %   add(obj, attrName, varargin)
            % -------------------------------------------------------------
            entry = aod.specification.Entry(attrName, varargin{:});
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
                    defaultValue = obj.Entries(i).Default;
                end

                if isempty(obj.Entries(i).Class)
                    classFcn = {};
                else
                    eval(sprintf("classFcn = @(x) mustBeA(x, %s);",...
                        value2string(obj.Entries(i).Class.text())));
                end
                if isempty(obj.Entries(i).Functions)
                    if ~isempty(classFcn)
                        validators = classFcn;
                    else
                        validators = [];
                    end
                else
                    validators = cat(2, obj.Entries(i).Functions.Value, {classFcn});
                end

                if isempty(validators)
                    addParameter(ip, obj.Entries(i).Name, defaultValue);
                else
                    addParameter(ip, obj.Entries(i).Name, defaultValue,... 
                        aod.specification.util.combineFunctionHandles(validators));
                end
            end
        end
    end

    methods (Access = {?aod.core.Entity})
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