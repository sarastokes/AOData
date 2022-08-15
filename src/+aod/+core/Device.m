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
%   obj = Device(varargin)
%
% Properties:
%   model                               Model of the device
%   manufacturer                        Manufacturer of the device
%   deviceParameters                    aod.core.Parameters
%
% Public Sealed methods:
%   setManufacturer(obj, manufacturer)
%   setModel(obj, model)
%   addParameter(obj, varargin)
%   assignUUID(obj, uuid)
% -------------------------------------------------------------------------
    properties (SetAccess = protected)
        model                           char
        manufacturer                    char
        deviceParameters                % aod.core.Parameters
    end
    
    methods
        function obj = Device(parent, varargin)

            obj.allowableParentTypes = {'aod.core.System',...
                'aod.core.Channel', 'aod.core.Empty'};
            obj.setParent(parent);

            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'Model', [], @ischar);
            addParameter(ip, 'Manufacturer', @ischar);
            parse(ip, varargin{:});
            
            obj.setModel(ip.Results.Model);
            obj.setModel(ip.Results.Manufacturer);
            
            obj.deviceParameters = aod.core.Parameters;
        end
    end
    
    methods (Sealed)
        function setManufacturer(obj, manufacturer)
            % SETMANUFACTURER
            %
            % Description:
            %   Sets the manufacturer property
            %
            % Syntax:
            %   setManufacturer(obj, manufacturer)
            % -------------------------------------------------------------

            obj.manufacturer = manufacturer;
        end
        
        function setModel(obj, model)
            % SETMODEL
            %
            % Description:
            %   Sets the model property
            %
            % Syntax:
            %   setModel(obj, model)
            % -------------------------------------------------------------
            obj.model = model;
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