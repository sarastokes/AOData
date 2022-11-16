classdef Segmentation < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% SEGMENTATION
%
% Description:
%   Represents a persisted Segmentation in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = Segmentation(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Segmentation
% -------------------------------------------------------------------------


    properties (SetAccess = protected)
        Data 
        Source 
    end

    methods 
        function obj = Segmentation(hdfFile, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed)
        function setData(obj, data)
            % SETDATA
            % 
            % Description:
            %   Change Data saved in HDF5 file
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data = data;

            evtData = aod.persistent.events.DatasetEvent('Data',...
                data, obj.Data);
            notify(obj, 'DatasetChanged', evtData);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            % DATASETS
            obj.Data = obj.loadDataset("Data");

            % LINKS
            obj.Source = obj.loadLink("Source");
        end
    end

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.persistent.Segmentation([], [], []);
        end
    end
end