classdef (Abstract) Epoch < aod.core.Entity 
% EPOCH
%
% Abstract methods:
%   populateEpoch(obj, varargin)
%   videoName = getCoreVideoName(obj)
% 
% Public methods:
%   fName = getFilePath(obj, whichFile)
%   addTransform(obj, tform)
%   clearTransform(obj)
%   clearVideoCache(obj)
%   getStack(obj, varargin)
%   makeStackSnapshots(obj)
%
% Protected methods:
%   imStack = readStack(obj, videoName)
%   imStack = applyTransform(obj, imStack)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ID(1,1)                     double     = 0
        Responses                   aod.core.Response
        epochParameters
    end

    properties (SetAccess = protected)
        files                       
        transform                   affine2d
    end

    properties (SetAccess = ?aod.core.Creator)
        startTime(1,1)              datetime
        Registration                aod.core.Registration
        Stimuli                     
    end

    properties (Dependent, Hidden)
        homeDirectory
    end

    properties (Hidden, Transient, Access = protected)
        cachedVideo
    end

    % Methods for subclasses to overwrite
    methods (Abstract, Access = protected)
        % Main analysis video name, accessed with 'getStack'
        videoName = getCoreVideoName(obj);
    end

    methods 
        function obj = Epoch(ID, parent)
            if nargin > 0
                obj.ID = ID;
            end

            obj.allowableParentTypes = {'aod.core.Dataset'};
            if nargin == 2
                obj.setParent(parent);
            end
            obj.epochParameters = containers.Map();
            obj.files = containers.Map();
        end

        function value = get.homeDirectory(obj)
            if ~isempty(obj.Parent)
                value = obj.Parent.homeDirectory;
            else
                value = [];
            end
        end
        
        function fName = getFilePath(obj, whichFile)
            % GETFILEPATH
            %
            % Syntax:
            %   fName = obj.getFilePath(whichFile)
            % -------------------------------------------------------------
            assert(isKey(obj.files, whichFiles), sprintf('File named %s not found', whichFile));
            fName = obj.Parent.homeDirectory + obj.files(whichFile);
        end
    end

    % Core methods
    methods 
        function imStack = getStack(obj)
            % GETSTACK
            if ~isempty(obj.cachedVideo)
                imStack = obj.cachedVideo;
                return;
            end

            videoName = obj.getCoreVideoName();
            imStack = obj.readStack(videoName);

            obj.applyTransform(imStack);

            obj.cachedVideo = imStack;
        end
    end

    % Misc access methods (see also Entity)
    methods 
        function clearVideoCache(obj)
            obj.cachedVideo = [];
        end

        function addTransform(obj, tform)
            obj.transform = tform;
        end

        function clearTransform(obj)
            obj.transform = [];
        end
    end

    methods
        function makeStackSnapshots(obj, IDs, fPath)
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
            %   IDs         array
            %       Epoch IDs to create snapshots (default = obj.epochIDs)
            % -------------------------------------------------------------
            if nargin < 3
                fPath = [obj.homeDirectory, 'Analysis', filesep, 'Snapshots', filesep];
            end
            
            if nargin < 2 || isempty(obj.IDs)
                IDs = 1:numel(obj.Epochs);
            end

            baseName = ['_', obj.getShortName(), '.png'];
            imStack = obj.Epochs(IDs).getStack();
            
            % TODO: Omit dropped frames
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
        function imStack = readStack(~, videoName)
            switch videoName(end-2:end)
                case 'tif'
                    reader = ao.builtin.readers.TiffReader(videoName);
                case 'avi'
                    reader = ao.builtin.readers.AviReader(videoName);
                otherwise
                    error('Unrecognized file extension!');
            end
            imStack = reader.read();
            fprintf('Loaded %s\n', videoName);
        end

        function imStack = applyTransform(obj, imStack)
            if isempty(obj.transform)
                return
            end

            disp('Applying transform');
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

        function displayName = getDisplayName(obj)  
            % GETDISPLAYNAME
            % May be overwritten by subclasses          
            % -------------------------------------------------------------
            if isempty(obj.Parent)
                displayName = obj.shortName;
            else
                displayName = sprintf("Epoch%u_%s", obj.ID, obj.Parent.displayName);
            end
        end

        function shortName = getShortName(obj)
            % GETSHORTNAME
            % 
            % Syntax:
            %   shortName = obj.getShortName()
            % -------------------------------------------------------------
            shortName = sprintf('Epoch%u', obj.ID);
        end
    end

    methods (Access = ?aod.core.Creator)
        function setStartTime(obj, value)
            obj.startTime = value;
        end
        
        function addParameter(obj, paramName, paramValue)
            obj.epochParameters(paramName) = paramValue;
        end

        function addFile(obj, fileName, filePath)
            % ADDFILE
            %
            % Description:
            %   Adds to files prop, stripping out homeDirectory if needed
            %
            % Syntax:
            %   obj.addFile(fileName, filePath)
            % -------------------------------------------------------------
            filePath = erase(filePath, obj.Parent.homeDirectory);
            obj.files(fileName) = filePath;
        end

        function addStimulus(obj, stim)
            % ADDSTIMULUS
            %
            % Syntax:
            %   obj.addStimulus(stim)
            % -------------------------------------------------------------
            obj.Stimuli = cat(1, obj.Stimuli, stim);
        end
    end
end 