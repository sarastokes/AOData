classdef Response < aod.core.persistent.Entity & dynamicprops

    properties
        Data
        Timing 
    end

    methods 
        function obj = Response(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);

            if ismember("Data", dsetNames)
                obj.Data = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, "Data");
            end
            
            % Determine how to map timing
            if ~isempty(obj.info.Groups) && contains(obj.info.Groups(1).Name, 'Timing')
                obj.Timing = obj.factory.create(obj.info.Groups.Name);
            else
                obj.Timing = obj.Parent.Timing;
            end
            obj.setDatasetsToDynProps(dsetNames);
            obj.setLinksToDynProps(linkNames);

        end
    end
end 