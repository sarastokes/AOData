classdef SpatialProtocolFactory < aod.util.Factory
% SPATIALPROTOCOLFACTORY
%
% Description:
%   Creates the appropriate Protocol for a given filename
%
% Syntax:
%   obj = SpatialProtocolFactory(calibration)
%
% Methods:
%   protocol = get(obj, fileName)
%   protocol = create(calibration, fileName)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        calibration
    end

    methods
        function obj = SpatialProtocolFactory(calibration)
            if nargin < 1 || isempty(calibration)
                calibration = aod.core.Calibration.empty();
            end
            assert(isSubclass(calibration, 'aod.core.Calibration'),...
                'Initial input must be a aod.core.Calibration subclass');
            obj.calibration = calibration;
        end
    end

    methods
        function protocol = get(obj, fileName)
            import sara.protocols.spatial.*;   
            
            [~, fileName, ~] = fileparts(char(fileName));

            % DecIncBar series
            if contains(fileName, 'mod_bar_')
                [barID, numBars] = obj.extractBarParameters(fileName);

                protocol = DecrementIncrementBar(obj.calibration,...
                    'PreTime', 20, 'StimTime', 40, 'TailTime', 30,...
                    'BaseIntensity', 0.5, 'Contrast', 1,...
                    'BarID', barID, 'NumBars', numBars, 'Orientation', 'vertical');
                return
            end

            % bar_intensity_10s_50c_29_of_32
            if contains(fileName, 'bar_intensity_')
                [barID, numBars] = obj.extractBarParameters(fileName);
                stimTime = extractFlaggedNumber(fileName, 's_');
                [cnst, tf] = extractFlaggedNumber(fileName, 'c_');
                if ~tf
                    cnst = 1;
                else
                    cnst = cnst / 100;
                end
                [totalTime, tf] = extractFlaggedNumber(fileName, 't_');
                if ~tf
                    totalTime = 80;
                end

                protocol = PulseBar(obj.calibration,...
                    'PreTime', 20, 'StimTime', stimTime, 'TailTime', totalTime-20-stimTime,...
                    'BaseIntensity', 0, 'Contrast', cnst,...
                    'BarID', barID, 'NumBars', numBars, 'Orientation', 'vertical');
                return
            end

            % SpacedOutIntBars
            if startsWith(fileName, 'spaced')
                
                [ID, numBars] = obj.extractBarParameters(fileName);
                if contains(fileName, 'horizontal')
                    orientation = 'horizontal';
                else
                    orientation = 'vertical';
                end

                if contains(fileName, '_int_bars_')   
                    protocol = PulseSpacedBars(obj.calibration,...
                        'PreTime', 20, 'StimTime', 10, 'TailTime', 40,...
                        'BaseIntensity', 0.5, 'Contrast', 1,...
                        'SeriesID', ID, 'BarSpacing', numBars, 'BarWidth', 3,...
                        'Orientation', orientation);
                    return
                end

                if contains(fileName, 'decinc_bars_')
                    [barSize, tf] = extractFlaggedNumber(fileName, 'pix');
                    if ~tf 
                        barSize = 2;
                    end
                    protocol = sara.protocols.spatial.DecrementIncrementSpacedBars(...
                        obj.calibration,...
                        'PreTime', 20, 'StimTime', 40, 'TailTime', 30,...
                        'BarWidth', barSize, 'BarSpacing', numBars,...
                        'Orientation', orientation, 'SeriesID', ID);
                    return
                end
            end

            % MovingBarsFourDirections
            if contains(fileName, {'e_n_w_s', 'ne_nw_sw_se'})
                apertureFlag = ~contains(fileName, 'full');
                if contains(fileName, 'e_n_w_s')
                    directionClass = 'cardinal';
                else
                    directionClass = 'diagonal';
                end

                barSpeed = extractFlaggedNumber(fileName, 'v');
                barSize = extractFlaggedNumber(fileName, 'pix');

                protocol = MovingBarsFourDirections(obj.calibration,...
                    'PreTime', 20, 'StimTime', 20, 'BarSize', barSize,...
                    'BarSpeed', barSpeed, 'UseAperture', apertureFlag,...
                    'DirectionClass', directionClass);
                return
            end

            % Intensity increments (full-field)
            if contains(fileName, 'zero_mean_increment_')
                stimTime = extractFlaggedNumber(fileName, 's');

                [totalTime, tf] = extractFlaggedNumber(fileName, 't');
                if ~tf
                    totalTime = 80;
                end
                
                [cnst, tf] = extractFlaggedNumber(fileName, 'c_');
                if ~tf
                    cnst = 1;
                else
                    cnst = cnst / 100;
                end

                protocol = Pulse(obj.calibration,...
                    'PreTime', 20, 'StimTime', stimTime, 'TailTime', totalTime-stimTime,...
                    'BaseIntensity', 0, 'Contrast', cnst);
                return
            end

            % Contrast decrements
            if contains(fileName, {'temporal_contrast_dec', 'temporal_contrast_inc'})...
                    && ~contains(fileName, 'decinc')
                if contains(fileName, 'inc')
                    contrast = 1;
                else
                    contrast = -1;
                end
                stimTime = extractFlaggedNumber(fileName, 's');
                totalTime = extractFlaggedNumber(fileName, 't');
                if isempty(totalTime)
                    totalTime = 60;
                end
                tailTime = totalTime-(20+stimTime);


                protocol = Pulse(obj.calibration,...
                    'PreTime', 20, 'StimTime', stimTime, 'TailTime', tailTime,...
                    'BaseIntensity', 0.5, 'Contrast', contrast);
                return
            end

            % Hard-coded filenames (mainly for backwards compatibility)
            switch fileName 
                case 'zero_mean_bkgd'
                    protocol = Baseline(obj.calibration,...
                        'StimTime', 100, 'BaseIntensity', 0);
                case 'temporal_contrast_bkgd'
                    protocol = Baseline(obj.calibration,...
                        'StimTime', 60, 'BaseIntensity', 0.5);
                case 'lights_on_toptica'
                    protocol = Step(obj.calibration,...
                        'PreTime', 20, 'StimTime', 60, 'TailTime', 0,...
                        'BaseIntensity', 0, 'Contrast', 1);
                case 'temporal_contrast_inc_20s_80t'
                    protocol = Step(obj.calibration,...
                        'PreTime', 20, 'StimTime', 20, 'TailTime', 40,...
                        'Contrast', 1, 'BaseIntensity', 0.5);
                case 'temporal_contrast_decinc_20s_90t'
                    protocol = DecrementIncrement(obj.calibration,...
                        'PreTime', 20, 'StimTime', 40, 'TailTime', 30,...
                        'BaseIntensity', 0.5, 'Contrast', 1);
                otherwise
                    warning('Unrecognized file name %s', fileName);
                    protocol = aod.util.Protocol.empty();
            end
        end
    end 

    methods (Static, Access = private)
        function [barID, numBars] = extractBarParameters(fName)
            txt = strsplit(fName, '_');
            idx = cellfind(txt, 'of');
            barID = str2double(txt{idx-1});
            numBars = str2double(txt{idx+1});
        end
    end

    methods (Static)
        function protocol = create(calibration, fileName)
            obj = sara.factories.SpatialProtocolFactory(calibration);
            protocol = obj.get(fileName);
            fprintf('\t%s <-- %s\n', class(protocol), fileName);
        end
    end
end 