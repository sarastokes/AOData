classdef Analysis < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% An Analysis in an HDF5 file
%
% Description:
%   An Analysis in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Analysis

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        analysisDate                    
    end

    methods
        function obj = Analysis(hdfFile, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            obj.analysisDate = obj.loadDataset("analysisDate");

            % Add user-defined datasets and links
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end 
    end
end 