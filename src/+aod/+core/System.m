classdef System < aod.core.Entity & matlab.mixin.Heterogeneous
% SYSTEM
%
% Parent:
%   aod.core.Entity 
%   matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = System(parent)
%
% Properties:
%   Channels
%   systemParameters
%
% Methods:
%   addChannel(obj, channel)
%   removeChannel(obj, ID)
%   clearChannels(obj)
%   addParameter(obj, varargin)
%   assignUUID(obj, uuid)
% -------------------------------------------------------------------------
    
    properties
        Name
        Channels            = aod.core.Channel.empty();
        systemParameters    % aod.core.Parameters     
    end
    
    methods
        function obj = System(parent, name)
            obj.allowableParentTypes = {'aod.core.Experiment', 'aod.core.Empty'};
            if nargin > 0
                obj.setParent(parent)
            end
            if nargin > 1
                obj.Name = name;
            end
        end      
    end
    
    methods (Sealed)
        function addChannel(obj, channel)
            assert(isSubclass(channel, 'aod.core.Channel'),...
                'Invalid type: must be a subclass of aod.core.Channel');
            if isempty(channel.Parent)
                channel.setParent(obj);
            end
            obj.Channels = cat(1, obj.Channels, channel);
        end
        
        function removeChannel(obj, channelID)
            assert(channelID <= numel(obj.Channels), 'Invalid Channel number');
            obj.Channels(channelID) = [];
        end
        
        function clearChannels(obj)
            obj.Channels = [];
        end
               
        function addParameter(obj, varargin)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, value)
            %   obj.addParameter(paramName, value, paramName, value)
            %   obj.addParameter(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.deviceParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.deviceParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
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
            %   generateUUID
            % -------------------------------------------------------------
            obj.setUUID(UUID);
        end
    end
    
    methods (Access = protected)
        function value = getLabel(obj)
            if ~isempty(obj.name)
                value = obj.name;
            else
                value = 'System';
            end
        end
    end
end