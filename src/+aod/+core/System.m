classdef System < aod.core.Entity & matlab.mixin.Heterogeneous
% SYSTEM
%
% Description:
%    A configuration of the AO imaging system 
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = System(parent, name)
%
% Properties:
%   Channels
%
% Methods:
%   addChannel(obj, channel)
%   removeChannel(obj, ID)
%   clearChannels(obj)
%   assignUUID(obj, uuid)
% -------------------------------------------------------------------------
    
    properties (SetAccess = protected)
        Channels            = aod.core.Channel.empty();
    end
    
    methods
        function obj = System(name)
            obj = obj@aod.core.Entity(name);
        end      
    end
    
    methods (Sealed)
        function addChannel(obj, channel)
            % ADDCHANNEL
            %
            % Syntax:
            %   addChannel(obj, channel)
            % -------------------------------------------------------------
            assert(isSubclass(channel, 'aod.core.Channel'),...
                'Invalid type: must be a subclass of aod.core.Channel');
            channel.setParent(obj);
            obj.Channels = cat(1, obj.Channels, channel);
        end

        function removeChannel(obj, ID)
            if ischar(ID)
                ID = find(strcmp(obj.Channels.Name, ID));
                if isempty(ID)
                    error("removeChannel:NameDoesNotExist",...
                        "No channel found named %s", ID);
                end
            elseif isnumeric(ID)
                assert(ID <= numel(obj.Channels), 'Invalid Channel number');
            end
            obj.Channels(ID) = [];
        end
        
        function clearChannels(obj)
            % CLEARCHANNELS
            %
            % Description:
            %   Clear all channels
            %
            % Syntax:
            %   clearChannels(obj)
            % -------------------------------------------------------------
            obj.Channels = [];
        end

        function assignUUID(obj, UUID)
            % ASSIGNUUID
            %
            % Description:
            %   The same system may be used over multiple experiments and
            %   should share UUIDs. This function provides public access
            %   to aod.core.Entity's setUUID function to facilitate hard-
            %   coded UUIDs for common sources
            %
            % Syntax:
            %   obj.assignUUID(UUID)
            %
            % See also:
            %   aod.util.generateUUID
            % -------------------------------------------------------------
            obj.setUUID(UUID);
        end
    end
    
    % Overloaded methods
    methods (Access = protected)
        function value = getLabel(obj)
            value = [obj.Name, 'System'];
        end
    end
end