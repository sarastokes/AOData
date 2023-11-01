classdef TestDevice < aod.core.Device 
%#ok<*MANU,*NASGU,*ASGLU> 

% TODO: Constant properties

    properties (SetObservable, SetAccess = {?aod.core.Entity})
        EmptyProp           % If remains empty, will not be persisted
        PublicProp = 123;
    end

    properties (Access = protected)
        % Properties without public GetAccess properties are not persisted
        ProtectedProp = 123;
    end

    properties (SetAccess = protected)
        ProtectedSetProp        
    end

    properties (Access = private)
        % These properties are not persisted
        PrivateProp = 123;
    end

    properties (Transient)
        % Transient properties will not be persisted
        TransientProp = 123;
    end

    properties (Dependent)
        % TODO: This should throw a warning about dependent properties
        DependentProp
    end

    properties (Hidden, Dependent)
        % Hidden dependent properties will not be written
        HiddenDependentProp
    end

    methods 
        function obj = TestDevice(varargin)
            obj@aod.core.Device("Test", varargin{:});
        end

        function out = get.DependentProp(obj)
            out = 123;
        end

        function out = get.HiddenDependentProp(obj)
            out = 123;
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Device(value);

            value.set('ProtectedSetProp', "TEXT",...
                "Size", "(1,1)",...
                'Description', 'A property with protected set access');
            value.set('PublicProp', "NUMBER",...
                "Default", 123,...
                "Size", "(1,1)", "Minimum", 0,...
                'Description', 'A property with public set access');
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add("AttrOne", "NUMBER",...
                "Size", "(1,2)", "Minimum", 0, "Maximum", 100);
            value.add("AttrTwo", "TEXT",...
                "Size", "(1,2)", "Enum", ["a", "b", "c"],...
                "Description", "This must be two strings, each can only be a, b or c");
            value.add("AttrThree", "UNKNOWN",...
                "Description", "This one has an unknown primitive type");
        end

        function value = specifyFiles()
            value = specifyFiles@aod.core.Device();

            value.add('FileOne', "FILE",...
                "Extension", ".json",...
                "Description", "This is a JSON file");
            value.add("FileTwo",...
                "Extension", ".txt",...
                "Description", "This is a .txt file");
        end
    end
end  