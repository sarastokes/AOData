classdef FrameTableReader < aod.core.FileReader 

    properties (SetAccess = protected)
        frameRate 
    end

    methods
        function obj = FrameTableReader(fName)
            obj = obj@aod.core.FileReader(fName);
        end

        function out = read(obj)
            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            T = readtable(obj.fullFile);
            T = T(:, 1:3);
            T.Properties.VariableNames = {'Frame', 'TimeInterval', 'TimeStamp'};
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

            out = T.TimeStamp - T.TimeStamp(1) + T.TimeInterval(1);
            out = out / 1000;

            obj.Data = out;

            obj.frameRate = 1000/mean(T.TimeInterval);
        end
    end
end 