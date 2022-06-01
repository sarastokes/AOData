classdef (Abstract) Epoch < aod.core.Entity 
% EPOCH
%
% Abstract methods:
%   videoName = getCoreVideoName(obj)
% 
% Public methods:
%   fName = getFilePath(obj, whichFile)
%   addTransform(obj, tform)
%   clearVideoCache(obj)
%   getStack(obj, varargin)
%   makeStackSnapshots(obj)
%
% Protected methods:
%   imStack = readStack(obj, videoName)
%
% aod.core.Creator methods:
%   addRegistration(obj, reg, overwrite)
%   addStimulus(obj, stim)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ID(1,1)                     double     = 0
    end

    properties (SetAccess = protected)
        Responses                   aod.core.Response
        epochParameters             % aod.core.Parameters
        files                       % aod.core.Parameters             
    end

    properties (SetAccess = ?aod.core.Creator)
        startTime(1,1)              datetime
        Registrations               % aod.core.Registration
        Stimuli                     % aod.core.Stimulus
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
            
            obj.epochParameters = aod.core.Parameters();
            obj.files = aod.core.Parameters();
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
            assert(isKey(obj.files, whichFile), sprintf('File named %s not found', whichFile));
            fName = obj.Parent.homeDirectory + obj.files(whichFile);
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

    % Core methods
    methods 
        function imStack = getStack(obj)
            % GETSTACK
            %
            % Syntax:
            %   imStack = obj.getStack()
            % -------------------------------------------------------------
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

    methods (Access = protected)
        function imStack = readStack(~, videoName)
            % READSTACK
            %
            % Syntax:
            %   imStack = readStack(obj, videoName)
            % -------------------------------------------------------------
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
        function addParameter(obj, paramName, paramValue)
            % ADDPARAMETER
            %
            % Syntax:
            %   addParameter(obj, paramName, paramValue)
            % -------------------------------------------------------------
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

        function addRegistration(obj, reg, overwrite)
            % ADDREGISTRATION
            %
            % Syntax:
            %   obj.addRegistration(reg, overwrite)
            % -------------------------------------------------------------
            if nargin < 3
                overwrite = false;
            end

            if ~isempty(obj.Registrations)
                idx = find(findByClass(obj.Registrations, reg));
                if ~isempty(idx) && ~overwrite
                    warning('Set overwrite=true to replace existing registration');
                    return
                end
                obj.Registrations{idx} = reg;
            end
            obj.Registrations = cat(1, obj.Registrations, reg);
        end
    end
end 