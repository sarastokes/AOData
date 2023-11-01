classdef EpochDataset < aod.core.Entity & matlab.mixin.Heterogeneous
% Any miscellaneous dataset associated with an epoch
%
% Description:
%   Miscellaneous datasets associated with an Epoch
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.EpochDataset(name)
%   obj = aod.core.EpochDataset(name, 'Data', data, varargin)
%
% Properties:
%   Data
%
% Sealed methods:
%   setData(obj, data)
%
% See Also:
%   aod.persistent.EpochDataset

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetObservable, SetAccess = {?aod.core.Entity})
        Data
    end

    methods
        function obj = EpochDataset(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'Data', []);
            parse(ip, varargin{:});

            obj.setData(ip.Results.Data);
        end
    end

    methods (Sealed, Access = protected)
        function setData(obj, data)
            % Validate with any specifications defined in subclasses
            obj.setProp('Data', data);
        end
    end

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "dab85248-adae-47d7-855e-2b4728a54428";
		end
    end
end