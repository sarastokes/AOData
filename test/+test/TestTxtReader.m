classdef TestTxtReader < aod.util.readers.TxtReader 

    methods
        function obj = TestTxtReader(varargin)
            obj = obj@aod.util.readers.TxtReader(varargin{:});

            % Read now rather than waiting for end-user to call read()
            obj.read();
        end

        function out = read(obj)
            obj.Data = struct();
            obj.Data.PMTGain = obj.readNumber('PMTGain =');
            obj.Data.FieldOfView = obj.readNumber('FieldOfView =');
            obj.Data.Video = obj.readText('Video =');
            obj.Data.Stabilization = obj.readYesNo('Stabilization =');
            obj.Data.ClosedLoop = obj.readTrueFalse('ClosedLoop =');
            out = obj.Data;
        end
    end
end