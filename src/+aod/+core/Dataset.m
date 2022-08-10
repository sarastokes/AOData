classdef (Abstract) Dataset < aod.core.Entity
% DATASET
%
% Constructor:
%   obj = Dataset(expDate, source)
%
% Properties:
%   Epochs
%   Source
%   Regions
%   Calibrations
%   homeDirectory
%   experimentDate              
%   datasetParameters
%   epochIDs                    list of epoch IDs in dataset
%
% Private properties:
%   baseDirectory               folder used to initialize Dataset
%
% Public methods:
%   setHomeDirectory(obj, filePath)
%   id = id2epoch(obj, epochID)
%   idx = id2index(obj, epochID)
%   imStack = getStacks(obj, epochIDs)
%   data = getRegionResponses(obj, epochIDs)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        homeDirectory           %{mustBeFolder}
        experimentDate(1,1)     datetime
        datasetParameters       %aod.core.Parameters

        Epochs                  %aod.core.Epoch
        Source                  %aod.core.Source
        Regions                 %aod.core.Regions
        Calibrations            = aod.core.Calibration.empty();

        epochIDs(1,:)           double
    end

    properties (Dependent)
        numEpochs
    end

    properties (Hidden, SetAccess = private)
        baseDirectory       % File path used to initialize Dataset
    end

    methods (Abstract)
        value = getFileHeader(obj)
    end
    
    methods 
        function obj = Dataset(homeDirectory, expDate)
            obj = obj@aod.core.Entity();
            
            obj.datasetParameters = containers.Map();
            if nargin > 0
                obj.setHomeDirectory(homeDirectory);
            end
            if nargin > 1
                obj.experimentDate = datetime(expDate, 'Format', 'yyyyMMdd');
            end
            obj.setParent([]);
            obj.datasetParameters = aod.core.Parameters();
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
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['MC00', num2str(obj.Source.ID), '_', obj.Source.whichEye,...
                '_', char(obj.experimentDate)];
        end
    end

    methods (Access = {?aod.core.Dataset, ?aod.core.Creator})
        function addSource(obj, source)
            % ADDSOURCE
            %
            % Description:
            %   Assign source(s) to the dataset
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
                obj.Source = cat(1, obj.Source, source);
            end
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
                    obj.datasetParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.datasetParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end
    end
end
