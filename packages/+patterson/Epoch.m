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
%   transform           aod.builtin.registrations.SiftRegistration
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
%   displayName = getDisplayName(obj)
%   shortName = getShortName(obj)
% aod.core.Creator methods:
%   addRegistration(obj, reg, overwrite)
%   addStimulus(obj, stim)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        epochType       patterson.EpochTypes
    end

    properties (Dependent)
        transform
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
                'aod.builtin.registrations.SiftRegistration'));
            if ~isempty(idx)
                value = obj.Registrations{idx}.Data;
            end
        end
    end

    methods 
        function signals = getFluorescence(obj)
            signals = obj.getResponse('patterson.responses.Fluorescence');
        end

        function clearTransform(obj)
            idx = findByClass(obj.Registrations, 'aod.builtin.registrations.SiftRegistration');
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
            
            baseName = ['_', obj.getShortName(), '.png'];
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

        function imStack = applyTransform(obj, imStack)
            % APPLYTRANSFORM
            %
            % Syntax:
            %   imStack = applyTransform(obj, imStack)
            % -------------------------------------------------------------
            if isempty(obj.transform)
                return
            end

            fprintf('Applying transform... ');
            try
                tform = affine2d_to_3d(obj.transform);
                viewObj = affineOutputView(size(imStack), tform,... 
                    'BoundsStyle','SameAsInput');
                imStack = imwarp(imStack, tform, 'OutputView', viewObj);
            catch
                [x, y, t] = size(imStack);
                refObj = imref2d([x y]);
                for i = 1:t
                    imStack(:,:,i) = imwarp(imStack(:,:,i), refObj,...
                        obj.transform, 'OutputView', refObj);
                end
            end
        end
    end

    % Overwritten methods
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
            imStack = obj.readStack(videoName);
            imStack(:,:,1) = [];

            imStack = obj.applyTransform(imStack);
            obj.cachedVideo = imStack;

            fprintf('Done\n');
        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            value = [obj.Parent.displayName, '#', int2fixedwidthstr(obj.ID, 4)];
        end
    end
end

