classdef LedVoltageReader < aod.core.FileReader
% LEDVOLTAGEREADER
%
% Constructor:
%   obj = patterson.readers.LedVoltageReader(fName)
%
% See also:
%   READJSONLED
% -------------------------------------------------------------------------

    methods
        function obj = LedVoltageReader(fName)
            obj = obj@aod.core.FileReader(fName);
        end

        function out = read(obj)
            J = loadjson(obj.fullFile);
            dataTable = J.datatable;
            lines = strsplit(dataTable, newline);
        
        
            frameNumber = []; ID = []; voltage1 = []; voltage2 = []; voltage3 = [];
            timestamp = []; 
        
            for i = 2:numel(lines)
                if isempty(lines{i})
                    continue
                end
                entries = strsplit(lines{i}, ', ');
                frameNumber = cat(1, frameNumber, str2double(entries{1}));
                ID = cat(1, ID, str2double(entries{2}));
                voltage1 = cat(1, voltage1, str2double(entries{4}));
                voltage2 = cat(1, voltage2, str2double(entries{5}));
                voltage3 = cat(1, voltage3, str2double(entries{6}));
                timestamp = cat(1, timestamp, str2double(entries{7}));
            end

            timestamp = timestamp - timestamp(1) + mean(diff(timestamp));
        
            TT = timetable(milliseconds(timestamp - timestamp(1)),... 
                frameNumber, ID, voltage1, voltage2, voltage3,...
                'VariableNames', {'Frame', 'ID', 'R', 'G', 'B'});
            TT{end, 'Frame'} = TT{end-1, 'Frame'};
            obj.Data = TT;
            out = obj.Data;
        end
    end
end