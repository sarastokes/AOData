classdef Dataset < aod.core.Entity
% DATASET
%
% Constructor:
%   obj = Dataset(expDate, source)
%
% Public methods:
%   setHomeDirectory(obj, filePath)
%   id = id2epoch(obj, epochID)
%   idx = id2idx(obj, epochID)
%   imStack = getStacks(obj, epochIDs)
%   data = getRegionResponses(obj, epochIDs)
% -------------------------------------------------------------------------

    properties
        homeDirectory {mustBeFolder}
        experimentDate(1,1) datetime

        Epochs
        Source 
        Regions

        epochIDs
    end

    properties (Hidden, SetAccess = private)
        baseDirectory       % File path used to initialize Dataset
    end
    
    methods 
        function obj = Dataset(expDate, source)
            obj.experimentDate = datetime(expDate, 'Format', 'yyyyMMdd');
            obj.Source = source;
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
            epoch = obj.Epochs(find(obj.epochIDs == IDs));
        end

        function idx = id2idx(obj, IDs)
            idx = find(obj.epochIDs == IDs);
        end
    end

    methods 
        function imStack = getStacks(obj, epochIDs, varargin)
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

        function data = getRegionResponses(obj, epochIDs, varargin)
            ip = inputParser();
            addParameter(ip, 'Average', false, @islogical);
            parse(ip, varargin{:});
            avgFlag = ip.Results.Average;

            data = [];
            for i = 1:numel(epochsIDs)
                epoch = obj.id2epoch(epochIDs(i));
                data = cat(3, data, epoch.getRegionResponses(ip.Unmatched));
            end

            if avgFlag && ndims(data) == 3
                data = mean(data, 3);
            end
        end
    end
end
