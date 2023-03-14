classdef System < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% A System in an HDF5 file
%
% Description:
%   Represents a persisted System in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.System(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.System

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        ChannelsContainer
    end

    methods 
        function obj = System(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end
    end

    methods (Sealed)
        function add(obj, channel)
            % ADD
            % 
            % Description:
            %   Add a Channel to the Experiment and the HDF5 file
            %
            % Syntax:
            %   add(obj, channel)
            % -------------------------------------------------------------
            arguments
                obj
                channel             {mustBeA(channel, 'aod.core.Channel')}
            end

            channel.setParent(obj);
            obj.addEntity(channel);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);

            obj.setDatasetsToDynProps();
            obj.setLinksToDynProps();
            obj.ChannelsContainer = obj.loadContainer('Channels');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Channels(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj.ChannelsContainer(idx));
            end
        end
    end
end