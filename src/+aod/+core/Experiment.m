classdef Experiment < aod.core.Entity

    properties
        experimentDate
        workingDirectory

        Datasets
        Sources         % Obtained from Datasets
        Epochs          % Obtained from Datasets
    end

    properties (Hidden, SetAccess = private)
        baseDirectory
    end

    methods
        function obj = Experiment(expDate, source)
            obj.experimentDate = expDate;
            obj.source = source;
        end
    end

    methods (Access = protected)
        function displayName = getDisplayName(obj)
            displayName = [string(obj.source.ID) + "_" + string(obj.experimentDate)];
        end
    end
end