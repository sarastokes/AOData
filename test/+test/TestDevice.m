classdef TestDevice < aod.core.Device 

    properties 
        EmptyProp 
        PublicProp = 123;
    end

    properties (Access = protected)
        ProtectedProp = 123;
    end

    properties (Access = private)
        PrivateProp = 123;
    end

    properties (Transient)
        TransientProp = 123;
    end

    properties (Dependent)
        DependentProp
    end

    properties (Hidden, Dependent)
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
end  