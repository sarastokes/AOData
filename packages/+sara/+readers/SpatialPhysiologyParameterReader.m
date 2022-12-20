classdef SpatialPhysiologyParameterReader < sara.readers.EpochParameterReader
% SPATIALPHYSIOLOGYPARAMETERREADER
%
% Description:
%   Reads epoch parameter files and makes according adjustments to epoch
%
% Parent:
%   sara.readers.EpochParameterReader
%
% Constructor:
%   obj = SpatialPhysiologyParameterReader(fileName)
%   obj = SpatialPhysiologyParameterReader(filePath, ID)
% -------------------------------------------------------------------------

    methods
        function obj = SpatialPhysiologyParameterReader(varargin)
            obj@sara.readers.EpochParameterReader(varargin{:});
        end

        function ep = readFile(obj, ep)
            ep = readFile@sara.readers.EpochParameterReader(obj, ep);

            % If it's spectral physiology, then we know AOM1 was Mustang
            stim = sara.stimuli.Mustang(ep.getParam('AOM1'));
            ep.addStimulus(stim);

            ep.setFile('StimVideoName', obj.readProperty('Stimulus video = '));
            ep.setFile('BackgroundVideoName', obj.readProperty('Background video = '));
            
            % Stimulus location
            txt = obj.readProperty('Stimulus location in linear stabilized space = ');
            txt = erase(txt, '('); txt = erase(txt, ')');
            txt = strsplit(txt, ', ');
            ep.setParam('StimulusLocation', [str2double(txt{1}), str2double(txt{2})]);
            
            % Power modulation 
            ep.setParam('PowerModulation', obj.readYesNo('Stimulus power modulation = '));
        end
    end

    methods 
        function obj = init(filePath, ID)
            fileName = obj.getFileName(filePath, ID);
            obj = sara.readers.SpatialPhysiologyParameterReader(fileName);
        end 
    end
end