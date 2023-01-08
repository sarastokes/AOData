classdef Epoch < aod.core.Epoch
% EPOCH
%
% Description:
%   A continuous period of data acquisition within an experiment
%
% Parent:
%   aod.core.Epoch
%
% Constructor:
%   obj = Epoch(ID, source, epochType)
%
% Properties:
%   epochType           sara.EpochTypes
% Inherited properties:
%   ID                  epoch ID
%   startTime           datetime
%   Registrations       aod.core.Registration
%   Responses           aod.core.Response
%   Stimuli             aod.core.Stimuli
%   epochParameters     aod.util.Parameters
%   files               aod.util.Parameters
% Dependent properties:
%   transform           aod.builtin.registrations.RigidRegistration
%
% Public methods:
%   makeStackSnapshots(obj, fPath)
%   clearRigidTransform(obj)
% Overwritten public methods:
%   imStack = getStack(obj)
% Inherited public methods:
%   clearVideoCache(obj)
% Protected methods:
%   imStack = applyTransform(obj, imStack)   
%   videoName = getCoreVideoName(obj)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        epochType           sara.EpochTypes
    end

    properties (Hidden, Dependent)
        transform           % aod.builtin.registrations.RigidRegistration
    end

    properties (Hidden, Transient)
        cachedData
    end

    methods
        function obj = Epoch(ID, epochType, varargin)
            obj@aod.core.Epoch(ID, varargin{:});
            obj.epochType = epochType;
            obj.setFile('CH1', 'Ref');
            if epochType.numChannels == 2
                obj.setFile('CH2', 'Vis');
            end
        end
        
        function value = get.transform(obj)
            value = [];
            if isempty(obj.Registrations)
               return  
            end
            idx = find(findByClass(obj.Registrations,... 
                'aod.builtin.registrations.RigidRegistration'));
            if ~isempty(idx)
                value = obj.Registrations(idx);
            end
        end
    end

    methods 
        function imStack = getStack(obj, cacheFlag)
            % GETSTACK
            %
            % Syntax:
            %   imStack = obj.getStack(cacheFlag)
            % -------------------------------------------------------------
            
            if nargin < 2
                cacheFlag = false;
            end

            [~, fileName, ~] = fileparts(obj.getCoreVideoName);
            if ~isempty(obj.cachedData)
                imStack = obj.cachedData;
                fprintf('Loaded %s from cache\n', fileName);
                return;
            end

            fprintf('Loading %s... ', fileName);

            videoName = obj.getCoreVideoName();
            imStack = readStack(videoName);
            imStack = im2double(imStack);
            imStack(:,:,1) = [];

            if ~isempty(obj.transform)
                imStack = obj.transform.apply(imStack);
                fprintf('Applying transform...');
            end
            
            if cacheFlag
                obj.cachedData = imStack;
            end

            fprintf('Done\n');
        end

        function F = getFluorescence(obj)
            % GETFLUORESCENCE
            F = obj.getResponse('sara.responses.Fluorescence', true);
        end

        function R = getDff(obj, varargin)
            R = obj.getResponse('sara.responses.Dff', varargin{:});
        end

        function clearRegionResponses(obj)
            % CLEARREGIONRESPONSES
            %
            % Syntax:
            %   obj.clearRegionResponses()
            % -------------------------------------------------------------
            if isempty(obj.Responses)
                return
            end
            idx = findByClass(obj.Responses, 'aod.builtin.responses.RegionResponse');
            if numel(obj.Responses) > 1
                obj.Responses{idx} = [];
            else
                obj.Responses(idx) = [];
            end
        end

        function clearRigidTransform(obj)
            idx = findByClass(obj.Registrations, 'aod.builtin.registrations.RigidRegistration');
            if ~isempty(idx)
                obj.Registrations = obj.Registrations(~idx);
            end
            % TODO: Clear cached video as well
        end

        function makeStackSnapshots(obj, fPath)
            % MAKESTACKSNAPSHOTS
            %
            % Description:
            %   Mimics the Z-projections created by ImageJ and saves an
            %   AVG, MAX, SUM and STD projection to 'Analysis/Snapshots/'
            %
            % Syntax:
            %   obj.makeStackSnapshots(fPath);
            %
            % Optional Inputs:
            %   fPath       char
            %       Where to save (default = 'Analysis/Snapshots/')
            % -------------------------------------------------------------
            if nargin < 2
                fPath = fullfile(obj.Parent.getAnalysisFolder(), 'Snapshots');
            end
            
            baseName = ['_', 'vis_', int2fixedwidthstr(obj.ID, 4), '.png'];
            imStack = obj.getStack();
            
            imSum = sum(im2double(imStack), 3);
            imwrite(uint8(255 * imSum/max(imSum(:))),...
                fullfile(fPath, ['SUM', baseName]), 'png');
            imwrite(uint8(mean(imStack, 3)),...
                fullfile(fPath, ['AVG', baseName]), 'png');
            imwrite(im2uint8(imadjust(std(im2double(imStack), [], 3))),... 
                fullfile(fPath, ['STD', baseName]), 'png');
        end

        function clearVideoCache(obj)
            % CLEARVIDEOCACHE
            %
            % Syntax:
            %   obj.clearVideoCache()
            % -------------------------------------------------------------
            obj.cachedVideo = [];
        end
    end

    methods (Access = protected)
        function videoName = getCoreVideoName(obj)
            videoName = obj.getExptFile('AnalysisVideo');
        end

        function value = getLabel(obj)
            value = [obj.Parent.label, '#', int2fixedwidthstr(obj.ID, 4)];
        end

        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.core.Epoch(obj);

            value.add('Defocus', [], @isnumeric,...
                'The AO defocus during the Epoch');
        end
    end
end

