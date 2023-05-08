classdef Source < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% A Source in an HDF5 file
%
% Description:
%   Represents a persisted Source in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Source(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Source
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        SourcesContainer
    end

    methods
        function obj = Source(hdfFile, hdfName, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfName, factory);
        end
    end

    methods (Sealed)
        function obj = add(obj, entity)
            % ADD
            % 
            % Description:
            %   Add a Source to the Experiment and the HDF5 file
            %
            % Syntax:
            %   add(obj, source)
            % -------------------------------------------------------------
            arguments
                obj
                entity      {mustBeA(entity, 'aod.core.Source')}
            end

            entity.setParent(obj);
            obj.addEntity(entity);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
            
            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
        end

        function populateContainers(obj)
            obj.SourcesContainer = obj.loadContainer('Sources');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Sources(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SourcesContainer(idx));
            end
        end
    end
end 