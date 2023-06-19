classdef Channel < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% A Channel in an HDF5 file
%
% Syntax:
%   obj = aod.persistent.Channel(hdfName, hdfPath, factory)
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Channel(hdfName, hdfPath, factory)
%
% See Also:
%   aod.core.Channel

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        DevicesContainer
    end

    methods
        function obj = Channel(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed)
        function tf = has(obj, varargin)
            % Search Channel's child entities and return if matches exist
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria and return whether matches exist
            %
            % Syntax:
            %   tf = has(obj, varargin)
            %
            % Inputs:
            %   Identical to aod.persistent.Channel.get()
            %
            % See also:
            %   aod.persistent.Channel/get
            % -------------------------------------------------------------

            out = obj.get(varargin{:});
            tf = ~isempty(out);
        end

        function out = get(obj, varargin)
            % Search Channel's child entities
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (described below in examples)
            %
            % Syntax:
            %   out = get(obj, entityType)
            %   out = get(obj, queries)   
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            %       Child entity type to access (Device)
            %   queries             cell
            %       One or more queries within cells
            %
            % Notes:
            %   - Queries are documented in aod.common.EntitySearch
            %
            % See Also:
            %   aod.common.EntitySearch
            % -------------------------------------------------------------

            import aod.common.EntityTypes

            try
                entityType = EntityTypes.get(varargin{1});
                startIdx = 2;
            catch
                startIdx = 1;
            end

            % If entity type is provided, make sure its valid
            if startIdx == 2 && entityType ~= EntityTypes.DEVICE
                error('get:InvalidEntityType',...
                    'Only Devices can be searched from channel');
            end

            if nargin > 2
                out = aod.common.EntitySearch.go(obj.Devices,...
                    varargin{startIdx:end});
            else
                out = obj.Devices;
            end
        end
        
        function add(obj, device)
            % Add a Device to the Channel and the HDF5 file
            %
            % Syntax:
            %   add(obj, device)
            % -------------------------------------------------------------
            arguments
                obj 
                device          {mustBeA(device, 'aod.core.Device')}
            end

            device.setParent(obj);
            obj.addEntity(device);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            % Add user-defined datasets and links
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end

        function populateContainers(obj)
            obj.DevicesContainer = obj.loadContainer('Devices');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Devices(obj, idx)

            if nargin < 2
                idx = 0;
            end

            out = [];

            for i = 1:numel(obj)
                out = cat(1, out, obj(i).DevicesContainer(idx));
            end
        end
    end
end 