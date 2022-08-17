classdef (Abstract) Experiment < aod.core.Entity
% EXPERIMENT
%
% Description:
%   Parent class for a single experiment
%
% Constructor:
%   obj = Experiment(expDate, source)
%
% Properties:
%   Epochs                      Container for Epochs
%   Source                      Container experiment's for Sources
%   Regions                     Container for experiment's Regions
%   Calibrations                Container for experiment's Calibrations
%   Systems                     Container for experiment's Systems
%   homeDirectory               File path for experiment files 
%   experimentDate              Date the experiment occurred
%   experimentParameters        Additional parameters related to experiment
%   epochIDs                    List of epoch IDs in experiment
%
% Dependent properties:
%   numEpochs                   Number of epochs in experiment
%
% Private properties:
%   baseDirectory               Folder used to initialize Experiment
%
% Abstract methods:
%   value = getFileHeader(obj)
% 
% Public methods:
%   setHomeDirectory(obj, filePath)
%   id = id2epoch(obj, epochID)
%   idx = id2index(obj, epochID)
%
%   calibration = getCalibration(obj, className)
%   imStack = getStacks(obj, epochIDs)
%
%   data = getResponse(obj, epochIDs, className, varargin)
%   data = getRegionResponses(obj, epochIDs)
%   clearAllResponses(obj, epochIDs)
%   addParameter(obj, varargin)
%
% Protected methods with Creator access:
%   addCalibration(obj, calibration)
%   addEpoch(obj, epoch)
%   addSystem(obj, system)
%   sortEpochs(obj)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime
        experimentParameters    %aod.core.Parameters

        Epochs                  %aod.core.Epoch
        Sources                 aod.core.Source
        Regions                 aod.core.Regions
        Calibrations            aod.core.Calibration
        Systems                 aod.core.System

        epochIDs(1,:)           double
    end

    properties (Dependent)
        numEpochs
    end

    properties (Hidden, SetAccess = private)
        baseDirectory       % File path used to initialize Experiment
    end

    methods (Abstract)
        value = getFileHeader(obj)
    end
    
    methods 
        function obj = Experiment(homeDirectory, expDate, varargin)
            obj.setHomeDirectory(homeDirectory);
            obj.experimentDate = datetime(expDate, 'Format', 'yyyyMMdd');
            obj.experimentParameters = aod.core.Parameters();

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Administrator', '', @ischar);
            addParameter(ip, 'System', '', @ischar);
            parse(ip, varargin{:});

            obj.addParameter(ip.Results);
        end

        function value = get.numEpochs(obj)
            value = numel(obj.Epochs);
        end

        function setHomeDirectory(obj, filePath)
            % SETHOMEDIRECTORY
            %
            % Description:
            %   Set a new base filepath. Useful if you are analyzing data 
            %   on multiple computers
            %
            % Syntax:
            %   setHomeDirectory(obj, filePath)
            % -------------------------------------------------------------
            assert(isfolder(filePath), 'filePath is not valid!');
            obj.homeDirectory = filePath;
        end
    end

    methods
        function epoch = id2epoch(obj, IDs)
            % ID2EPOCH
            %
            % Description:
            %   Input epoch ID(s), get Epoch(s)
            %
            % Syntax:
            %   epoch = id2epoch(obj, IDs)
            % -------------------------------------------------------------
            epoch = obj.Epochs(find(obj.epochIDs == IDs));
        end

        function idx = id2index(obj, IDs)
            % ID2INDEX
            %
            % Description:
            %   Returns index of in Epochs for a given epoch ID
            %
            % Syntax:
            %   idx = id2index(obj, IDs)
            % -------------------------------------------------------------
            idx = find(obj.epochIDs == IDs);
        end
    end

    % Property access methods
    methods 
        function cal = getCalibration(obj, className)
            % GETCALIBRATION
            %
            % Syntax:
            %   cal = obj.getCalibration(className)
            % -------------------------------------------------------------
            cal = getByClass(obj.Calibrations, className);
        end
    
        function addRegions(obj, regions, overwrite)
            % ADDREGIONS
            %
            % Syntax:
            %   imStack = addRegions(obj, regions, overwrite)
            % -------------------------------------------------------------
            if nargin < 3
                overwrite = false;
            end
            assert(isa(regions, 'aod.core.Regions'), 'Input must be Regions object');
            if ~isempty(obj.Regions)
                if overwrite
                    obj.Regions = regions;
                    % Cancel out any existing region responses as their
                    % relationship to Regions is no longer valid
                    for i = 1:numel(obj.Epochs)
                        obj.Epochs(i).clearRegionResponses();
                    end
                else
                    error('Set overwrite=true to overwrite existing regions');
                end
            else
                obj.Regions = regions;
            end
        end
    end

    methods 
        function imStack = getStacks(obj, epochIDs, varargin)
            % GETSTACKS
            %
            % Syntax:
            %   imStack = getStack(obj, epochIDs, varargin)
            %
            % -------------------------------------------------------------
            ip = inputParser();
            addParameter(ip, 'Average', false, @islogical);
            parse(ip, varargin{:});
            avgFlag = ip.Results.Average;

            imStack = [];
            for i = 1:numel(epochIDs)
                epoch = obj.id2epoch(epochIDs(i));
                imStack = cat(4, imStack, epoch.getStack());
            end

            if avgFlag && ndims(imStack) == 4
                imStack = mean(imStack, 4);
            end
        end

        function data = getResponse(obj, epochIDs, className, varargin)
            % GETRESPONSE
            %
            % Description:
            %   Get a response from specified epoch(s)
            %
            % Syntax:
            %   data = getResponse(obj, epochIDs, className, varargin)
            % -------------------------------------------------------------
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Average', false, @islogical);
            parse(ip, varargin{:});
            avgFlag = ip.Results.Average;

            data = [];
            for i = 1:numel(epochIDs)
                epoch = obj.id2epoch(epochIDs(i));
                resp = epoch.getResponse(className, ip.Unmatched);
                data = cat(3, data, resp.Data);
            end

            if avgFlag && ndims(data) == 3
                data = mean(data, 3);
            end
        end

        function clearAllResponses(obj, epochIDs)
            % CLEARALLRESPONSES
            %
            % Description:
            %   Clear responses in all or a subset of Epochs
            %
            % Syntax:
            %   clearAllResponses(obj)
            %   clearAllResponses(obj, epochIDs)
            % -------------------------------------------------------------
            if nargin < 2
                epochIDs = obj.epochIDs;
            end
            for i = 1:numel(epochIDs)
                ep = obj.id2epoch(epochIDs(i));
                ep.clearResponses();
            end
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['MC00', num2str(obj.Sources(1).getParentID()), '_', obj.Sources(1).whichEye,...
                '_', char(obj.experimentDate)];
        end
    end

    methods (Access = {?aod.core.Experiment, ?aod.core.Creator})
        function addSource(obj, source)
            % ADDSOURCE
            %
            % Description:
            %   Assign source(s) to the experiment
            %
            % Syntax:
            %   obj.addSource(source, overwrite)
            %
            % See also:
            %   aod.core.Source
            % -------------------------------------------------------------
            assert(isSubclass(source, 'aod.core.Source'),...
                'Must be a subclass of aod.core.Source');
            for i = 1:numel(source)
                if ~isempty(obj.Sources)
                    assert(obj.Sources(1).getParentID() == source.getParentID(),...
                        'Experiment may only contain 1 animal');
                end
                obj.Sources = cat(1, obj.Sources, source);
            end
        end

        function addSystem(obj, system)
            % ADDSYSTEM
            %
            % Description:
            %   Add a System to the expeirment
            %
            % Syntax:
            %   obj.addSystem(system)
            % -------------------------------------------------------------
            assert(isSubclass(system, 'aod.core.System'),...
                'Must be a subclass of aod.core.System');
            for i = 1:numel(system)

                obj.Systems = cat(1, obj.Systems, system);
            end
        end

        function clearSystems(obj)
            % CLEARSYSTEMS
            %
            % Syntax:
            %   obj.clearSystems()
            % -------------------------------------------------------------
            obj.Systems = aod.core.System.empty();
        end

        function addEpoch(obj, epoch)
            % ADDEPOCH
            %
            % Syntax:
            %   obj.addEpoch(obj, epoch)
            % -------------------------------------------------------------
            assert(isa(epoch, 'aod.core.Epoch'), 'Input must be an Epoch');
            obj.Epochs = cat(1, obj.Epochs, epoch);
            obj.epochIDs = cat(2, obj.epochIDs, epoch.ID);
        end

        function addCalibration(obj, calibration)
            % ADDCALIBRATION
            %
            % Syntax:
            %   obj.addCalibration(obj, calibration, overwrite)
            % -------------------------------------------------------------
            if nargin < 3
                overwrite = false;
            end

            % Determine if calibration exists and should be overwritten
            if ~isempty(obj.Calibrations)
                idx = find(findByClass(obj.Calibrations, class(calibration)));
                if ~isempty(idx)
                    if ~overwrite
                        warning('Set overwrite=true to replace existing %s', class(calibration));
                    else % Overwrite existing
                        if numel(obj.Calibrations) == 1
                            obj.Calibrations = calibration;
                        else
                            obj.Calibrations{idx} = calibration;
                        end
                        return
                    end
                end
            end
            obj.Calibrations = cat(1, obj.Calibrations, calibration);
        end

        function clearCalibrations(obj)
            % CLEARCALIBRATIONS
            %
            % Syntax:
            %   obj.clearCalibrations()
            % -------------------------------------------------------------
            obj.Calibrations = aod.core.Calibration.empty();
        end

        function sortEpochs(obj)
            % SORTEPOCHS
            %
            % Description:
            %   Sorts epochIDs and epochs by increasing numerical order
            % 
            % Syntax:
            %   obj.sortEpochs();
            % -------------------------------------------------------------
            [obj.epochIDs, idx] = sort(obj.epochIDs);
            obj.Epochs = obj.Epochs(idx);
        end
    end

    methods (Sealed)
        function addParameter(obj, varargin)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, value)
            %   obj.addParameter(paramName, value, paramName, value)
            %   obj.addParameter(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.experimentParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.experimentParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end
    end
end
