classdef Epoch < aod.core.Epoch
% EPOCH
%
% Constructor:
%   obj = Epoch(ID, parent, epochType)
%
%
% Properties:
%   epochType           patterson.EpochTypes
% Inherited properties:
%   ID                  epoch ID
%   startTime           datetime
%   Registrations       aod.core.Registration
%   Responses           aod.core.Response
%   Stimuli             aod.core.Stimuli
%   epochParameters     aod.core.Parameters
%   files               aod.core.Parameters
% Dependent properties:
%   transform           aod.builtin.registrations.RigidRegistration
%   homeDirectory
%
%
% Public methods:
%   makeStackSnapshots(obj, fPath)
%   clearTransform(obj)
% Overwritten public methods:
%   imStack = getStack(obj)
% Inherited public methods:
%   clearVideoCache(obj)
%   fPath = getFilePath(obj, whichFile)
% Protected methods:
%   imStack = applyTransform(obj, imStack)   
%   videoName = getCoreVideoName(obj)
% Inherited protected methods:
%   imStack = readStack(obj, videoName)
%   displayName = getLabel(obj)
%   shortName = getShortName(obj)
% aod.core.Creator methods:
%   addRegistration(obj, reg, overwrite)
%   addStimulus(obj, stim)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        epochType           patterson.EpochTypes
    end

    properties (Dependent)
        transform           % aod.builtin.registrations.RigidRegistration
    end

    methods
        function obj = Epoch(ID, parent, epochType)
            obj@aod.core.Epoch(ID, parent);
            if nargin > 2
                obj.epochType = epochType;
            else
                obj.epochType = patterson.EpochTypes.Unknown;
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
                value = obj.Registrations{idx};
            end
        end
    end

    methods 
        function imStack = getStack(obj)
            % GETSTACK
            %
            % Syntax:
            %   imStack = obj.getStack()
            % -------------------------------------------------------------
            [~, fileName, ~] = fileparts(obj.getCoreVideoName);
            if ~isempty(obj.cachedVideo)
                imStack = obj.cachedVideo;
                fprintf('Loaded %s from cache\n', fileName);
                return;
            end

            fprintf('Loading %s... ', fileName);

            videoName = obj.getCoreVideoName();
            imStack = readStack(videoName);
            imStack(:,:,1) = [];

            if ~isempty(obj.transform)
                imStack = obj.transform.apply(imStack);
            end
            obj.cachedVideo = imStack;

            fprintf('Done\n');
        end

        function F = getFluorescence(obj)
            % GETFLUORESCENCE
            F = obj.getResponse('patterson.responses.Fluorescence', true);
        end

        function R = getDff(obj, varargin)
            R = obj.getResponse('patterson.responses.Dff', varargin{:});
        end

        function clearTransform(obj)
            idx = findByClass(obj.Registrations, 'aod.builtin.registrations.RigidRegistration');
            if ~isempty(idx)
                obj.Registrations = obj.Registrations{~idx};
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
                fPath = [obj.Parent.getAnalysisFolder(), 'Snapshots', filesep];
            end
            
            baseName = ['_', 'vis_', int2fixedwidthstr(obj.ID, 4), '.png'];
            imStack = obj.getStack();
            
            imSum = sum(im2double(imStack), 3);
            imwrite(uint8(255 * imSum/max(imSum(:))),...
                [fPath, 'SUM', baseName], 'png');
            imwrite(uint8(mean(imStack, 3)),...
                [fPath, 'AVG', baseName], 'png');
            imwrite(uint8(max(imStack, [], 3)),... 
                [fPath, 'MAX', baseName], 'png');
            imwrite(im2uint8(imadjust(std(im2double(imStack), [], 3))),... 
                [fPath, 'STD', baseName], 'png');
        end
    end

    methods (Access = protected)
        function videoName = getCoreVideoName(obj)
            videoName = obj.getFilePath('AnalysisVideo');
        end

        function value = getLabel(obj)
            value = [obj.Parent.displayName, '#', int2fixedwidthstr(obj.ID, 4)];
        end
    end
end

