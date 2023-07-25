classdef Boolean < aod.specification.primitives.Primitive

    properties (Hidden, SetAccess = protected)
        OPTIONS = ["Size", "Default", "Description"]
    end

    methods
        function obj = Boolean(name, parent, varargin)
            obj = obj@aod.specification.primitives.Primitive(name, parent);

            obj.setFormat("logical");
            obj.parseInputs(varargin{:});
        end
    end

    methods
        function setDefault(obj, value)
            arguments
                obj
                value       {mustBeNumericOrLogical}
            end

            if isempty(value)
                obj.Default.setValue([]);
                return
            end

            if islogical(value)
                obj.Default.setValue(value);
                return
            end

            if isa(value, 'double')
                if any(~ismember(value, [0 1]))
                    error('setDefault:InvalidInput',...
                        'Boolean defaults must be either 0 or 1.');
                else
                    obj.Default.setValue(logical(value));
                end
            end

            obj.checkIntegrity();
        end
    end
end