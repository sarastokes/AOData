classdef Dataset < aod.core.Entity

    properties
        homeDirectory

        Epochs
        Source

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
        function epoch = idx2epoch(obj, IDs)
            epoch = obj.Epochs(find(obj.epochIDs == IDs));
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
    end
end
