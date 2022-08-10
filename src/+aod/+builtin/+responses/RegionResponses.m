classdef RegionResponses < aod.builtin.responses.RegionResponse ...
        & matlab.mixin.indexing.RedefinesParen 

    methods 
        function obj = RegionResponses(varargin)
            obj = obj@aod.builtin.responses.RegionResponse(varargin{:});

            % Temporary for testing
            if isempty(obj.Data)
                obj.setTiming(aod.core.timing.TimeRate(0.04, 100, 0.04));
                obj.Data = randi([0 100], [10, obj.Timing.Count]);
            end
        end

        function varargout = size(obj, varargin)
            varargout{1:nargout} = size(obj.Data);
        end

        function out = cat(~, varargin) %#ok<*STOUT,*INUSD> 
            out = varargin{1}.Data;
            if length(varargin) == 1
                return
            end
            for i = 2:length(varargin)
                out = cat(3, out, varargin{i}.Data);  
            end
        end
    end

    methods (Access = protected)
        function varargout = parenReference(obj, indexOp)
            if isempty(obj.Data)
                error("RegionResponse:DataNotSet",...
                    "Data is empty");
            end
            if numel(indexOp.Indices) > 2
                error("RegionResponses:IncorrectDimensions",...
                    "The number of dimensions exceeds Data");
            end
            [varargout{1:nargout}] = obj.Data( ...
                indexOp.Indices{1}, indexOp.Indices{2});
        end

        function n = parenListLength(~, indexOp, indexingContext)
            assignin('base', 'indexingContext', indexingContext);
            assignin('base', 'indexOp', indexOp);
            warning('Responses/parenListLength triggered!')
            n = listLength(size(obj.Data),indexOp,indexContext);
        end

        function obj = parenAssign(obj, indexOp, varargin)
            error("RegionResponse:AssignNotSupported",...
                "Direct assignment to RegionResponses.Data not supported");
        end

        function obj = parenDelete(obj, indexOp)
            error("RegionResponse:AssignNotSupported",...
                "Direct delete for RegionResponses.Data not supported");
        end
    end

    methods (Static, Access = public)
        function obj = empty()
            obj = RegionResponses(aod.core.Empty());
        end
    end
end 