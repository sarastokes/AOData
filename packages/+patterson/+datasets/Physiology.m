classdef Physiology < patterson.Dataset

    properties (SetAccess = protected)
        location
    end

    methods
        function obj = Physiology(homeDirectory, expDate, location)
            obj = obj@patterson.Dataset(homeDirectory, expDate);
            if nargin < 3
                obj.location = 'Unknown';
            else
                obj.location = capitalize(location);
            end
        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            value = ['MC', int2fixedwidthstr(num2str(obj.Source.ID), 5),...
                '_', obj.Source.whichEye,...
                obj.location(1), '_', char(obj.experimentDate)];
        end

        function value = getShortName(obj)
            value = [num2str(obj.Source.ID), '_', obj.Source.whichEye,...
                obj.location(1), '_', char(obj.experimentDate)];
        end
    end
end