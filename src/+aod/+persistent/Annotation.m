classdef Annotation < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% An Annotation in an HDF5 file
%
% Description:
%   Represents a persisted Annotation in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = aod.persistent.Annotation(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Annotation
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data 
        Source 
    end

    methods 
        function obj = Annotation(hdfFile, hdfPath, factory)
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
            obj.addDataset('Data', data);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            % DATASETS
            obj.Data = obj.loadDataset("Data");

            % LINKS
            obj.Source = obj.loadLink("Source");

            % Add additional user-defined datasets and links
            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
        end
    end
end