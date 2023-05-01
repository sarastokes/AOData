classdef AODataViewerTest < matlab.uitest.TestCase
% Test AODataViewer
%
% Syntax:
%   results = runtests('AODataViewerTest');
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        EXPT
        VIEW
        APP
    end

    methods (TestClassSetup)
        function openApp(testCase)
            % Creates an experiment, writes to HDF5 and reads back in  
            fileName = fullfile(getpref('AOData', 'BasePackage'), ...
                'test', 'ToyExperiment.h5');            
            if ~exist(fileName, 'file')
                ToyExperiment(true, true);
            end
            testCase.EXPT = loadExperiment(fileName);
            testCase.APP = aod.app.presenters.ExperimentPresenter(testCase.EXPT);
            testCase.APP.show();
            testCase.VIEW = testCase.APP.getView();
            drawnow;
        end
    end

    methods (TestClassTeardown)
        function closeApp(testCase)
            testCase.VIEW.close();
        end
    end

    methods (Test)
        function Appearance(testCase)
            fh1 = testCase.APP.getFigure(); %#ok<NASGU>
            fh = testCase.VIEW.getFigure();
            pos = fh.Position(3:4);
            testCase.VIEW.changeFontSize(2);
            testCase.VIEW.resizeFigure(100, 0);
            testCase.verifyEqual(fh.Position(3:4), pos + [100 0]);
        end

        function SelectAndExpandExperiment(testCase)
            % Make sure all nodes are de-selected
            testCase.VIEW.Tree.SelectedNodes = [];

            % Select Experiment
            h = testCase.VIEW.Tree.Children(1);
            testCase.choose(h);
            testCase.verifyTrue(...
                any(contains(testCase.VIEW.Attributes.Data{:,1}, 'Administrator')));
            % Test node identification methods
            entity = testCase.APP.node2entity(h);
            testCase.verifyEqual(entity.UUID, testCase.EXPT.UUID);
            testCase.verifyTrue(strcmp(testCase.APP.getNodePath(h), "/Experiment"));
            
            % Expand Experiment
            expand(h);
            notify(testCase.VIEW, 'NodeExpanded', appbox.EventData(struct('Node', h)));

            testCase.choose(h.Children(1));
            testCase.verifyEqual(...
                string(testCase.VIEW.Attributes.Data{1,2}), "Container");
        end

        function Experiment_ExpectedParameters(testCase)
            testCase.VIEW.Tree.SelectedNodes = [];

            h = findobj(testCase.VIEW.Tree.Children.Children,...
                'Tag', '/Experiment/expectedParameters');

            testCase.choose(h(1));

            testCase.verifyEqual(testCase.VIEW.TablePanel.Visible,... 
                matlab.lang.OnOffSwitchState('on'));
            testCase.verifyEqual(testCase.VIEW.TextPanel.Visible,... 
                matlab.lang.OnOffSwitchState('off'));

            testCase.VIEW.Tree.SelectedNodes = [];
        end 

        function Experiment_EpochIDs(testCase)
            testCase.VIEW.Tree.SelectedNodes = [];

            h = findobj(testCase.VIEW.Tree.Children.Children,...
                'Tag', '/Experiment/epochIDs');
            testCase.choose(h(1));

            testCase.verifyEqual(testCase.VIEW.TablePanel.Visible,...
                matlab.lang.OnOffSwitchState('on'));

            testCase.VIEW.Tree.SelectedNodes = [];
        end
        
        function Experiment_Description(testCase)
            testCase.VIEW.Tree.SelectedNodes = [];

            h = findobj(testCase.VIEW.Tree.Children.Children,...
                'Tag', '/Experiment/description');
            testCase.choose(h(1));

            testCase.verifyEqual(testCase.VIEW.TextPanel.Visible,...
                matlab.lang.OnOffSwitchState('on'));
            testCase.VIEW.Tree.SelectedNodes = [];
        end

        function Epoch_Source(testCase) 
            testCase.VIEW.Tree.SelectedNodes = [];

            h = testCase.VIEW.Tree.Children(1);
            testCase.choose(h);
            notify(testCase.VIEW, 'NodeExpanded',... 
                appbox.EventData(struct('Node', h)));
            testCase.VIEW.Tree.SelectedNodes = [];
            
            % Experiment/Epochs
            h = findobj(testCase.VIEW.Tree.Children, 'Tag',...
                '/Experiment/Epochs');
            testCase.choose(h);
            notify(testCase.VIEW, 'NodeExpanded',... 
                appbox.EventData(struct('Node', h)));
            testCase.VIEW.Tree.SelectedNodes = [];
            
            % Experiment/Epochs/0001
            h = h.Children(1);
            testCase.choose(h);
            notify(testCase.VIEW, 'NodeExpanded',...
                appbox.EventData(struct('Node', h)));
            testCase.VIEW.Tree.SelectedNodes = [];

            % Click the "Sources" link
            h = findobj(h.Children, 'Tag', '/Experiment/Epochs/0001/Source');
            testCase.choose(h);
            testCase.verifyEqual(testCase.VIEW.LinkPanel.Visible,...
                matlab.lang.OnOffSwitchState('on'));
            b = findobj(testCase.VIEW.LinkPanel.Children.Children, ...
                'Tag', 'FollowLinkButton');
            testCase.press(b);

            selectedNode = testCase.VIEW.Tree.SelectedNodes;
            testCase.verifyEqual(selectedNode.Text, 'Right');

            % Return to experiment
            testCase.VIEW.scroll(h);
        end
    end
end