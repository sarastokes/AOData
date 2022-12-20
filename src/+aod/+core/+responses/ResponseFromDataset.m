classdef ResponseFromDataset < aod.core.Response 


    properties (SetAccess = protected)
        Dataset             aod.core.Dataset = aod.core.Dataset.empty()
    end

    methods
        function obj = ResponseFromDataset(name, dataset, varargin)
            obj@aod.core.Response(name, varargin{:});

            obj.Dataset = dataset;
        end
    end
end 