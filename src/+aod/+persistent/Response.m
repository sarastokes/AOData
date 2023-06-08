classdef Response < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% A Response in an HDF5 file
%
% Description:
%   Represents a persisted Response in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = Response(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Response
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data
        Timing 
    end

    methods 
        function obj = Response(hdfFile, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            %! Special handling of Timing w/ implicit inheritance from Epoch
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
end 