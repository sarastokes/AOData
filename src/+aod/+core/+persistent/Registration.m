classdef Registration < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        registrationDate
    end

    methods
        function obj = Registration(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            obj.registrationDate = obj.loadDataset("registrationDate");

            obj.setDatasetsToDynProps(dsetNames);
            obj.setLinksToDynProps(linkNames);
        end
    end
end