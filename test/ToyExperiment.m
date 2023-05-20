function [coreExpt, persistentExpt] = ToyExperiment(writeToHDF, saveAsMat)
% Create a toy experiment for testing
%
% Description:
%   Builds a quick experiment to serve as a basis for testing
%
% Syntax:
%   [coreExpt, persistentExpt] = ToyExperiment(writeToHDF, saveAsMat)
%
% Inputs:
%   writeToHDF          logical (default=false)
%       Whether to persist the experiment to an HDF5 file
%   saveAsMat           logical (default=false)
%       Whether to save the core experiment as a .mat file
%
% Output:
%   experiment          aod.core.Experiment
%
% Notes:
%   HDF file will write to current directory as 'ToyExperiment.h5'
    
% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        writeToHDF      logical = false
        saveAsMat       logical = false
    end

    experiment = aod.core.Experiment("Tester", cd, '20220823',...
        'Administrator', "Sara Patterson",...
        'Laboratory', "Primate-1P");

    experiment.setDescription('This is a test experiment');
    experiment.setNote('This is the first note');
    experiment.setNote('This is the second note');

    % Add a source
    source = aod.builtin.sources.primate.Primate('MC00851',...
        "Species", "macaca fascicularis",...
        "Sex", "male",...
        "Demographics", "GCaMP6s; rhodamine (right SC)");
    source.add(aod.builtin.sources.primate.Eye(...
        'OS', "AxialLength", 18.47, "PupilSize", 6.7));
    source.Sources(1).add(aod.core.sources.Location("Right"));

    experiment.add(source);

    % System
    system = aod.core.System('Base');
    channel1 = aod.core.Channel('WavefrontSensing');
    channel1.add(aod.builtin.devices.LightSource(847,...
        "Manufacturer", "QPhotonics"));
    
    channel2 = aod.core.Channel("ReflectanceImaging");
    channel2.add(aod.builtin.devices.LightSource(796,...
        "Manufacturer", "SuperLum"));
    channel2.add(aod.builtin.devices.Pinhole(20,...
        "Manufacturer", "ThorLabs", "Model", "P20K"));
    channel2.add(aod.builtin.devices.PMT("ReflectancePMT"));
    
    channel3 = aod.core.Channel("FluorescenceImaging");
    channel3.add(aod.builtin.devices.LightSource(561,...
        "Manufacturer", "Qioptiq"));
    channel3.add(aod.builtin.devices.Pinhole(25,...
        "Manufacturer", "ThorLabs", "Model", "P25K"));
    channel3.add(aod.builtin.devices.PMT("VisiblePMT",...
        "Manufacturer", "Hamamatsu", "Model", "H16722"));
    dichroic = aod.builtin.devices.BandpassFilter(607, 70,...
        "Manufacturer", "Semrock", "Model", "FF01-590/20"); 
    dichroic.setTransmission(fullfile(...
        test.util.getAODataTestFolder(), "test_data", "FF01-607_70.txt"));
    channel3.add(dichroic);

    system.add([channel1, channel2, channel3]);
    experiment.add(system);

    % Calibrations
    calibration1 = aod.builtin.calibrations.PowerMeasurement(...
        'Mustang', getDateYMD(), 488);
    calibration1.addMeasurement(24:26, 16:18);
    experiment.add(calibration1);

    calibration2 = aod.builtin.calibrations.ChannelOptimization([],...
        getDateYMD(), 'PMT', [6 7 8], 'Source', 3,...
        'Channel', experiment.get('Channel', {'Name', 'MustangImaging'}));
    experiment.add(calibration2);

    % Experiment Datasets
    dset1 = aod.core.ExperimentDataset('ExpDataset1',... 
        'Data', eye(3));
    experiment.add(dset1);

    % Epochs
    epoch = aod.core.Epoch(1, 'System', system,...
        'Source', experiment.get('Source', {'Name', 'Right'}));
    epoch.setFile('PresyncFile', fullfile(cd, 'PresyncFile.txt'));
    experiment.add(epoch);
    epoch.setTiming(seconds(1:5));
    epoch.setFile('PostSyncFile', fullfile(cd, 'PostSyncFile.txt'));
    
    experiment.add(aod.core.Epoch(2, 'Source', epoch.Source));
    setAttr(experiment.Epochs, 'RefPmtGain', 0.51);

    % Registrations
    reg = aod.builtin.registrations.RigidRegistration( ...
        'SIFT', '20220823', eye(3));
    epoch.add(reg);

    % Responses
    response1 = aod.core.Response('ResponseWithTiming');
    response1.setData(2:2:8);
    response1.setTiming(seconds(linspace(0.5, 2.5, 4)));
    epoch.add(response1);

    response2 = aod.core.Response('ResponseWithoutTiming');
    response2.setData(2:2:8);
    epoch.add(response2);

    % Stimuli
    stim = aod.builtin.stimuli.ImagingLight('Mustang', 22,...
        'IntensityUnits', "Normalized");
    epoch.add(stim);

    % Datasets
    epoch.add(aod.core.EpochDataset('Dataset1',...
        'Data', magic(5)));

    % Annotation
    experiment.add(aod.core.Annotation('Annotation1'));

    % Analysis
    experiment.add(aod.core.Analysis('TestAnalysis', ...
        'Date', getDateYMD()));

    if writeToHDF
        fileName = fullfile(getpref('AOData', 'BasePackage'), 'test', 'ToyExperiment.h5');
        aod.h5.writeExperimentToFile(fileName, experiment, true);
    end

    if saveAsMat
        matName = fullfile(getpref('AOData', 'BasePackage'), 'test', 'ToyExperiment.mat');
        ToyExperiment = experiment;
        save(matName, 'ToyExperiment');
    end

    coreExpt = experiment;
    if nargout == 2 
        if writeToHDF
            persistentExpt = loadExperiment(fileName);
        else
            warning('ToyExperiment:NotPersisted',...
                'Cannot return persistent experiment because it was not written');
            persistentExpt = [];
        end
    end
