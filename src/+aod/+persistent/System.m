classdef System < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% SYSTEM
%
% Description:
%   Represents a persisted System in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = System(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.System
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
        function addChannel(obj, channel)
            % ADDCHANNEL
            % 
            % Description:
            %   Add an Analysis to the Experiment and the HDF5 file
            %
            % Syntax:
            %   addChannel(obj, channel)
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

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.persistent.System([], [], []);
        end
    end
end