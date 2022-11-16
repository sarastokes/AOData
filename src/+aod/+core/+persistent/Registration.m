classdef Registration < aod.core.persistent.Entity ...
        & matlab.mixin.Heterogeneous & dynamicprops 

    properties (SetAccess = protected)
        registrationDate
    end

    methods
        function obj = Registration(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            obj.registrationDate = obj.loadDataset("registrationDate");

            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
        end
    end

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.core.persistent.Registration([], [], []);
        end
    end
end