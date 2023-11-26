classdef SearchPathFixture < matlab.unittest.fixture.Fixture

    properties (SetAccess = private)
        pathPrefs       char
    end

    methods
        function obj = SearchPathFixture()
            obj.pathPrefs = getpref('AOData', 'SearchPaths');
        end

        function setup(fixture)
            rmpref('AOData', 'SearchPaths', '');
        end

        function teardown(fixture)
            setpref('AOData', 'SearchPaths', fixture.pathPrefs);
            fixture.TeardownDescription = "Restored search paths";
        end
    end
end
