classdef SpatialFrameTableReader < aod.util.FileReader

    properties (SetAccess = protected)
        frameRate
    end

    methods 
        function obj = SpatialFrameTableReader(fName)
            obj = obj@aod.util.FileReader(fName);
        end

        function out = readFile(obj)
            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            T = readtable(obj.fullFile);
            if isempty(T)
                out = [];
                return
            end
            T = T(:, [1, 3, 4, 7:11]);
            T.Properties.VariableNames = {'Frame', 'TimeStamp',...
                'TimeInterval', 'StimIndex',...
                'Background', 'StimLocX', 'StimLocY', 'TrackingStatus'};
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

            out = T.TimeStamp - T.TimeStamp(1) + T.TimeInterval(1);
            out = out / 1000;

            obj.Data = out;

            obj.frameRate = 1000/mean(T.TimeInterval);
        end
    end
end