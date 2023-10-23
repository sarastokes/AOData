classdef ExperimentDataset < aod.core.Entity & matlab.mixin.Heterogeneous
% Any miscellaneous dataset associated with an Experiment
%
% Description:
%   Miscellaneous datasets associated with an Expeirment
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.ExperimentDataset(name)
%   obj = aod.core.ExperimentDataset(name, data)
%
% Properties:
%   Data
%
% Sealed methods:
%   setData(obj, data)
%
% See Also:
%   aod.persistent.ExperimentDataset

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetObservable, SetAccess = {?aod.core.Entity})
        Data 
    end

    methods
        function obj = ExperimentDataset(name, varargin)
            obj@aod.core.Entity(name, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'Data', []);
            parse(ip, varargin{:});
            
            if ~isempty(ip.Results.Data)
                obj.setData(ip.Results.Data);
            end
        end
    end

    methods (Sealed, Access = protected)
        function setData(obj, data)
            % Set after validation with any specifications set by subclasses
            obj.setProp('Data', data);
        end
    end
end