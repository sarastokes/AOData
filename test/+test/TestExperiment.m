classdef TestExperiment < aod.core.Experiment 

    properties
        Date = getDateYMD();
        IntegerScalar = uint8(3);
        Double2D = eye(3);
        Double3D = repmat([1 2 3], [2 1 3]);
        String = "test"
        StringArray = ["this", "is", "a", "test"]';
        Char = 'test';
        CellStr = {'A'; 'B'; 'C'}
        StructEqual = struct('A', 123, 'B', 555);
        StructUnequal = struct('A', 123, 'B', [123; 456]);
        Table
        MapEqual
        MapUnequal
    end

    methods 
        function obj = TestExperiment(varargin)
            obj@aod.core.Experiment(varargin{:});
            
            obj.MapUnequal = containers.Map();
            obj.MapUnequal('A') = 123;
            obj.MapUnequal('B') = [123; 456];

            obj.MapEqual('A') = 123;
            obj.MapEqual('B') = "test";

            obj.Table = table([1 2 3]', ["A", "B", "C"]',...
                'VariableNames', ["Numbers", "Letters"]);
        end
    end
end 