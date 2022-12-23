classdef Dataset < aod.core.Entity & matlab.mixin.Heterogeneous
% Any miscellaneous dataset associated with an epoch
%
% Description:
%   Miscellaneous datasets associated with an Epoch
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Dataset(name)
%   obj = aod.core.Dataset(name, data)
%
% Properties:
%   Data
%
% Sealed methods:
%   setData(obj, data)
%
% See Also:
%   aod.persistent.Dataset

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data 
    end

    methods
        function obj = Dataset(name, data, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
            if nargin > 1
                obj.setData(data);
            end
        end
    end

    methods (Sealed, Access = protected)
        function setData(obj, data)
            obj.Data = data;
        end
    end
end