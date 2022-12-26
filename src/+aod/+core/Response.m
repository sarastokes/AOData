classdef Response < aod.core.Entity & matlab.mixin.Heterogeneous
% A Response extracted from data acquired during an Epoch
%
% Description:
%   A Response extracted from data acquired during an Epoch
%
% Parent: 
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Response(name, fileName, fileReader)
%
% Properties:
%   Data 
%   Timing
%
% Methods:
%   setData(obj, data)
%   addTiming(obj, timing)
%   clearTiming(obj)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                             
        Timing (1,:)         {mustBeA(Timing, ["double", "duration"])} = []                   
    end

    methods
        function obj = Response(name, varargin)
            obj@aod.core.Entity(name, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'Data', []);
            addParameter(ip, 'Timing', []);
            parse(ip, varargin{:});

            obj.setData(ip.Results.Data);
            obj.setTiming(ip.Results.Timing);
        end
    end

    methods (Sealed)
        function setData(obj, data)
            % SETDATA
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data = data;
        end

        function setTiming(obj, timing)
            % SETTIMING
            %
            % Syntax:
            %   addTiming(obj, timing)
            %
            % Examples:
            %   % Set numeric timing
            %   obj.setTiming(1:4)
            %
            %   % Set duration timing
            %   obj.setTiming(seconds(1:4))
            %   
            %   % Clear timing
            %   obj.setTiming([])
            % -------------------------------------------------------------
            obj.Timing = timing;
        end
    end

    % Overwritten Entity methods
    methods (Access = protected)
        function sync(obj)
            % Adopt epoch's timing if Response Timing is empty
            sync@aod.core.Entity(obj);
            if isempty(obj.Timing) && ~isempty(obj.Parent.Timing)
                obj.Timing = obj.Parent.Timing;
            end
        end
    end

    % Overwritten MATLAB methods (dimensions)
    methods
        %function varargout = size(obj, varargin)
        %    [varargout{1:nargout}] = size(obj.Data, varargin{:});
        %end

        function out = reshape(obj, varargin)
            out = reshape(obj.Data, varargin{:});
        end

        function out = length(obj)
            out = length(obj.Data);
        end

        function out = ndims(obj)
            out = ndims(obj.Data);
        end

        function out = nnz(obj)
            out = nnz(obj.Data);
        end

        %function out = numel(obj)
        %    out = numel(obj.Data);
        %end
    end

    % Overwritten MATLAB methods (datatype)
    methods 
        function out = double(obj)
            if ~isdouble(obj.Data)
                out = double(obj.Data);
            else
                out = obj.Data;
            end
        end

        function out = logical(obj)
            out = obj.Data;
        end
    end

    % Overwritten MATLAB methods (operators)
    methods
        function out = plus(obj1, obj2)
            obj1 = aod.core.Response.extractData(obj1);
            obj2 = aod.core.Response.extractData(obj2);
            out = obj1 + obj2;
        end

        function out = minus(obj1, obj2)
            obj1 = aod.core.Response.extractData(obj1);
            obj2 = aod.core.Response.extractData(obj2);
            out = obj1 - obj2;
        end

        function out = uminus(obj)
            out = -obj.Data;
        end

        function out = uplus(obj)
            out = obj.Data;
        end

        function out = eq(obj1, obj2)
            obj1 = aod.core.Response.extractData(obj1);
            obj2 = aod.core.Response.extractData(obj2);
            out = obj1 == obj2;
        end

        function out = ne(obj1, obj2)
            obj1 = aod.core.Response.extractData(obj1);
            obj2 = aod.core.Response.extractData(obj2);
            out = obj1 ~= obj2;
        end
        
        function out = ge(obj1, obj2)
            obj1 = aod.core.Response.extractData(obj1);
            obj2 = aod.core.Response.extractData(obj2);
            out = obj1 >= obj2;
        end

        function out = gt(obj1, obj2)
            obj1 = aod.core.Response.extractData(obj1);
            obj2 = aod.core.Response.extractData(obj2);
            out = obj1 > obj2;
        end

        function out = le(obj1, obj2)
            obj1 = aod.core.Response.extractData(obj1);
            obj2 = aod.core.Response.extractData(obj2);
            out = obj1 <= obj2;
        end

        function out = lt(obj1, obj2)
            obj1 = aod.core.Response.extractData(obj1);
            obj2 = aod.core.Response.extractData(obj2);
            out = obj1 < obj2;
        end
        
        function out = not(obj)
            out = ~not(obj.Data);
        end

        function out = transpose(obj)
            out = obj.Data';
        end

        function out = ctranspose(obj)
            out = obj.Data.';
        end
    end

    % Overwritten MATLAB methods (is)
    methods
        function out = isnan(obj)
            out = isnan(obj.Data);
        end

        function out = ismissing(obj)
            out = ismissing(obj.Data);
        end

        function out = isnumeric(obj)
            out = isnumeric(obj.Data);
        end

        function out = isinf(obj)
            out = isinf(obj.Data);
        end

        function out = isfinite(obj)
            out = isfinite(obj.Data);
        end

        function out = isreal(obj)
            out = isread(obj.Data);
        end
    end

    % Overwritten MATLAB methods (stats)
    methods
        function out = abs(obj)
            out = abs(obj.Data);
        end

        function out = mean(obj, varargin)
            out = mean(obj.Data, varargin{:});
        end

        function out = median(obj, varargin)
            out = median(obj.Data, varargin{:});
        end

        function out = std(obj, varargin)
            out = std(obj.Data, varargin{:});
        end

        function out = sum(obj, varargin)
            out = sum(obj.Data, varargin{:});
        end

        function out = iqr(obj, varargin)
            out = iqr(obj.Data, varargin{:});
        end

        function out = prctile(obj, varargin)
            out = prctile(obj.Data, varargin{:});
        end

        function out = quantile(obj, varargin)
            out = quantile(obj.Data, varargin{:});
        end

        function out = sign(obj)
            out = sign(obj.Data);
        end

        function out = cumsum(obj, varargin)
            out = cumsum(obj.Data, varargin{:});
        end
    end

    methods (Static)
        function out = extractData(input)
            if aod.util.isEntitySubclass(input, 'Response')
                out = input.Data;
            else
                out = input;
            end
        end
    end
end