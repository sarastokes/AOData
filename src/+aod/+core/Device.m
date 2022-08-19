classdef Device < aod.core.Entity & matlab.mixin.Heterogeneous
% DEVICE
%
% Description:
%   A light source, NDF, filter, PMT, etc used in an experiment
%
% Parent:
%   aod.core.Entity
%   matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Device(parent, varargin)
%
% Properties:
%   deviceParameters                    aod.core.Parameters
%
% Parameters:
%   Model                               Model of the device
%   Manufacturer                        Manufacturer of the device
%
% Public Sealed methods:
%   addParameter(obj, varargin)
%   assignUUID(obj, uuid)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        deviceParameters                = aod.core.Parameters
    end
    
    methods
        function obj = Device(parent, varargin)
            obj.allowableParentTypes = {'aod.core.System',...
                'aod.core.Channel', 'aod.core.Empty'};
            obj.setParent(parent);

            ip = aod.util.InputParser();
            addParameter(ip, 'Model', [], @ischar);
            addParameter(ip, 'Manufacturer', [], @ischar);
            parse(ip, varargin{:});
            
            obj.addParameter(ip.Results);
        end
    end
    
    methods (Sealed)
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
            %   The same devices may be used over multiple experiments and
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
end