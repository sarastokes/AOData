classdef (Abstract) Epoch < aod.core.Entity 
% EPOCH
%
% Abstract methods:
%   videoName = getCoreVideoName(obj)
% 
% Public methods:
%   getStack(obj, varargin)
%   fName = getFilePath(obj, whichFile)
%   clearResponses(obj)
%   clearVideoCache(obj)
%
% Protected methods:
%   imStack = readStack(obj, videoName)
%
% aod.core.Creator methods:
%   addFile(obj, fileName, filePath)
%   addParameter(obj, paramName, paramValue)
%   addRegistration(obj, reg, overwrite)
%   addResponse(obj, resp)
%   addStimulus(obj, stim)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ID(1,1)                     double     = 0
    end

    properties (SetAccess = protected)
        Responses                   % aod.core.Response
        epochParameters             % aod.core.Parameters
        files                       % aod.core.Parameters             
    end

    properties (SetAccess = {?aod.core.Creator, ?aod.core.Epoch})
        startTime(1,1)              datetime
        Registrations               = cell.empty()
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

            obj.cachedVideo = imStack;
        end

        function clearResponses(obj)
            % CLEARRESPONSES
            %
            % Syntax:
            %   obj.clearResponses()
            % -------------------------------------------------------------
            obj.Responses = [];
        end
    end

    methods (Access = protected)
        function imStack = readStack(~, videoName)
            % READSTACK
            %
            % Syntax:
            %   imStack = readStack(obj, videoName)
            % -------------------------------------------------------------
            [~, ~, extension] = fileparts(videoName);
            switch extension
                case {'.tif', '.tiff'}
                    reader = aod.core.readers.TiffReader(videoName);
                case '.avi'
                    reader = aod.core.readers.AviReader(videoName);
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

    methods (Access = {?aod.core.Creator, ?aod.core.Epoch})
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
            %   Adds to files prop, stripping out homeDirectory and
            %   trailing/leading whitespace, if needed
            %
            % Syntax:
            %   obj.addFile(fileName, filePath)
            % -------------------------------------------------------------
            filePath = erase(filePath, obj.Parent.homeDirectory);
            filePath = strtrim(filePath);
            obj.files(fileName) = filePath;
        end

        function addStimulus(obj, stim, overwrite)
            % ADDSTIMULUS
            %
            % Syntax:
            %   obj.addStimulus(stim, overwrite)
            % -------------------------------------------------------------
            if nargin < 3
                overwrite = false;
            end

            if ~isempty(obj.Stimuli)
                idx = find(findByClass(obj.Stimuli, stim));
                if ~isempty(idx) 
                    if ~overwrite
                        warning('Set overwrite=true to replace existing registration');
                        return
                    else
                        obj.Stimuli(idx) = stim;
                        return
                    end
                end
                obj.Stimuli = {obj.Stimuli; stim};
            else
                obj.Stimuli = stim;
            end
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
                idx = find(findByClass(obj.Registrations, class(reg)));
                if ~isempty(idx) 
                    if ~overwrite
                        warning('Set overwrite=true to replace existing registration');
                        return
                    else % overwrite existing
                        if numel(obj.Registrations) == 1
                            obj.Registrations = reg;
                        else
                            obj.Registrations{idx} = reg;
                        end
                        return
                    end
                end
                obj.Registrations = {obj.Registrations; reg};
            else
                obj.Registrations = reg;
            end
        end

        function addResponse(obj, resp, overwrite)
            % ADDRESPONSE
            %
            % Syntax:
            %   obj.addResponse(reg, overwrite)
            % -------------------------------------------------------------
            if nargin < 3
                overwrite = false;
            end

            if ~isempty(obj.Responses)
                idx = find(findByClass(obj.Responses, class(resp)));
                if ~isempty(idx)
                    if ~overwrite
                        warning('Set overwrite=true to replace existing %s', class(resp));
                        return
                    else  % Overwrite existing
                        if numel(obj.Responses) == 1
                            obj.Responses = resp;
                        else
                            obj.Responses{idx} = resp;
                        end
                        return
                    end
                end
                obj.Responses = {obj.Responses; resp};
            else
                obj.Responses = resp;
            end
        end
    end
end 