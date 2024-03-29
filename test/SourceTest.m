classdef SourceTest < matlab.unittest.TestCase 

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        EXPT
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Create an experiment
            testCase.EXPT = aod.core.Experiment(...
                '851_20221117', cd, '20221117',...
                'Administrator', "Sara Patterson",... 
                'Laboratory', "1P Primate");
        end
    end

    
    methods (Static)
        function source = createSource()
            % Create a source with two sub-sources
            source = aod.core.Source('MC00851');
            source1a = aod.core.Source('OS');
            source1b = aod.core.Source('OD');
            source.add([source1a, source1b]);
        end
    end
    
    methods(Test, TestTags=["Source", "Core", "LevelOne"])
        function SourceLevel(testCase)
            source = testCase.createSource();

            testCase.verifyEqual(source.getLevel(), 1);
            testCase.verifyEqual(source.Sources.getLevel(), [2 2]);
        end

        function SourceIO(testCase)
            import matlab.unittest.constraints.Throws

            % Create a parent source
            source1 = aod.core.Source('MC00851');
            source2 = aod.core.Source('MC00838');
            testCase.EXPT.add([source1, source2]);
            testCase.verifyEqual(numel(testCase.EXPT.get('Source')), 2);

            % Create second-level source
            source1a = aod.core.Source('OS');
            source1b = aod.core.Source('OD');
            source1.add([source1a, source1b]);
            testCase.verifyEqual(numel(testCase.EXPT.get('Source')), 4);
            testCase.verifyNumElements(source1.get('Source', {'Name', 'OS'}), 1);
            
            % Check labels
            testCase.verifyEqual(source1a.label, "MC00851_OS");

            % Check has functionality
            testCase.verifyTrue(source1.has({'Name', 'OS'}));
            testCase.verifyFalse(source1.has({'Name', 'OU'}));
            testCase.verifyTrue(source1.has({'Class', 'aod.core.Source'}));

            % Create third-level source
            source1a1 = aod.core.Source('Right');
            source1a2 = aod.core.Source('Left');
            source1a.add([source1a1, source1a2]);
            testCase.verifyEqual(numel(testCase.EXPT.get('Source')), 6);

            source1b1 = aod.core.Source('Right');
            source1b.add(source1b1);
            testCase.verifyEqual(numel(testCase.EXPT.get('Source')), 7);

            % Check remove all files
            source1.setFile('MyFile1', 'test.txt');
            source1.setFile('MyFile2', 'test2.txt');
            testCase.verifyEqual(source1.files.Count, uint64(2));
            source1.removeFile('all');
            testCase.verifyEmpty(source1.files);

            % Remove a single source
            testCase.EXPT.remove('Source', 2);
            testCase.verifyEqual(numel(testCase.EXPT.get('Source')), 6);

            % Clear all the sources
            testCase.EXPT.remove('Source', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.get('Source')), 0);
        end

        function GetSource(testCase)
            source = aod.core.Source('Test');
            testCase.verifyEmpty(source.get('Source'));
            testCase.verifyEmpty(source.get());

            source = testCase.createSource();
            testCase.verifyNumElements(source.get('Source', {'Name', 'OS'}), 1);

            testCase.verifyNumElements(source.get('Source'), 2);
        end
        
        function RemoveSourceByQuery(testCase)
            % Create a source with two sub-sources
            source = testCase.createSource();
            testCase.verifyNumElements(source.Sources, 2);

            source.remove('Source', {'Name', 'OS'});
            testCase.verifyNumElements(source.Sources, 1);

            source.remove({'Name', 'OD'});
            testCase.verifyEmpty(source.Sources);
        end

        function RemoveSourceByAll(testCase)
            source = testCase.createSource();
            source.remove('all');
            testCase.verifyEmpty(source.Sources);
        end
        
        function RemoveSourceByID(testCase)
            source = testCase.createSource();
            testCase.verifyNumElements(source.Sources, 2);

            firstSourceName = source.Sources(1).Name;
            testCase.verifyNumElements(source.get(...
                'Sources', {'Name', firstSourceName}), 1);

            source.remove('Source', 1);
            testCase.verifyNumElements(source.Sources, 1);
            testCase.verifyNotEqual(source.Sources(1).Name, firstSourceName);
            testCase.verifyWarning(...
                @() source.remove('Sources', {'Name', firstSourceName}),...
                "remove:NoQueryMatches");

            source.remove(1);
            testCase.verifyEmpty(source.Sources);
        end

        function GetParent(testCase)
            % Confirm returns empty w/ no error if ancestor isn't present
            source = testCase.createSource();
            testCase.verifyEmpty(source.getParent('Experiment'));
        end
        
        function SourceErrors(testCase)
            % Misc errors not covered in other tests
            source = testCase.createSource();
            testCase.verifyError(@() source.get('Source', "badID"),... 
                "get:InvalidInput");
            
            testCase.verifyError(@() source.get('Epoch'),...
                "get:InvalidEntityType");

            testCase.verifyError(@() source.remove('Source', struct('A', 1)),...
                "remove:InvalidID")
        end
    end

    methods (Test, TestTags="Primate")
        function PrimateEye(testCase)
            OS = aod.builtin.sources.primate.Eye('OS',...
                'AxialLength', 17);
            testCase.verifyEqual(OS.micronsPerDegree,... 
                291.2 * (17/24.2));
            testCase.verifyEqual(OS.um2deg(1), 1/OS.micronsPerDegree);
            testCase.verifyEqual(OS.deg2um(1), OS.micronsPerDegree * 1);

            OD = aod.builtin.sources.primate.Eye('OD');
            testCase.verifyEmpty(OD.micronsPerDegree);
        end
    end
end 