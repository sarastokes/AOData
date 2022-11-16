classdef Response < aod.core.persistent.Entity ...
        & matlab.mixin.Heterogeneous & dynamicprops

    properties
        Data
        Timing 
    end

    methods 
        function obj = Response(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);

            % Special handling of Timing w/ implicit inheritance from Epoch
            info = h5info(obj.hdfName, obj.hdfPath);
            if ~isempty(info.Groups) && contains(info.Groups(1).Name, 'Timing')
                obj.Timing = obj.factory.create(info.Groups.Name);
            else
                obj.Timing = obj.Parent.Timing;
            end
            
            obj.Data = obj.loadDataset("Data");
            obj.setDatasetsToDynProps();
            
            obj.setLinksToDynProps();
        end
    end

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.core.persistent.Response([], [], []);
        end
    end
end 