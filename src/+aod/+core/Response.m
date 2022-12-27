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
%   obj = aod.core.Response(name, varargin)
%
% Inputs:
%   name        string or char
%       A name for the Response
% Optional key/value inputs:
%   Data        
%       The data which is the response itself
%   Timing      duration or numeric
%       The timing for each response point
%
% Properties:
%   Data 
%   Timing
%
% Methods:
%   setData(obj, data)
%   addTiming(obj, timing)
%   clearTiming(obj)
%
% The following methods operate directly on the Data property and will 
% return a numeric output rather than a Response:
%   plus (+), minus (-), not (~), ge (>), gt (>=), le (<), lt (<=), eq (=), 
%   ne (~=), uminus, uplus, abs, mean, median, std, sum, cumsum, iqr, 
%   prctile, quantile, sign

%>@file aod.core.Response.m
%>@brief A response extracted from data acquired during an Epoch

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        %> Response data (rows are samples) 
        Data                          
        %> Timing of each sample in the Response  (*double/duration*)    
        Timing (:,1)         {mustBeA(Timing, ["double", "duration"])} = []                   
    end

    methods 
        % -----------------------------------------------------------------
        %> @brief Class constructor
        %>
        %> @par Syntax
        %> @code
        %> obj = aod.core.Response(name, varargin)
        %> @endcode
        %>
        %> @param name  @b string or @b char \n
        %>      Response name 
        %>
        %> @par Optional key/value inputs:
        %> - @c Data passed to @c setData()
        %> - @c Timing \n 
        %>      passed to @c setTiming()
        %> - @c Parent aod.core.Experiment or aod.persistent.Experiment \n
        %>      The Parent entity
        %>
        %> @return instance of the aod.core.Response class.
        % -----------------------------------------------------------------
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
        % -----------------------------------------------------------------
        %> @brief Set the Data property
        %>
        %> @par Syntax
        %> @code
        %> setData(obj, data)
        %> @endcode
        %>
        %> @param obj aod.core.Response
        %> @param data \n
        %>      The response's data
        %>
        %> @par Example
        %> Set the data
        %> @code
        %> obj.setData(data);
        %> @endcode
        %>
        %> Clear the data
        %> @code
        %> obj.setData([]);
        %> @endcode
        % -----------------------------------------------------------------
        function setData(obj, data)
            % SETDATA
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data = data;
        end

        % -----------------------------------------------------------------
        %> @brief Sets Timing, the time each sample was acquired
        %>
        %> @par Syntax
        %> @code
        %> addTiming(obj, timing)
        %> @endcode
        %>
        %> @param Timing @b double, @b duration \n 
        %>      The time of each sample in the Response. If empty, the 
        %>      Timing property will be cleared.
        %>
        %> @par Examples
        %> Set the timing
        %> @code
        %> obj.setTiming(timing);
        %> @endcode
        %>
        %> Clear the timing
        %> @code
        %> obj.setTiming([])
        %> @endcode
        %>
        %> @attention If Timing is unset, it will be inherited from 
        %> the parent Epoch
        % -----------------------------------------------------------------
        function setTiming(obj, timing)
            % Set Response "Timing", the time each sample was acquired
            %
            % Syntax:
            %   addTiming(obj, timing)
            %
            % Inputs:
            %   timing      vector, numeric or duration
            %       The timing for each sample in Response. If empty, the 
            %       contents of Timing will be cleared.
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
            %
            % Notes:
            %   If Timing is left empty, the Response will inherit the 
            %   Timing from its parent Epoch (if it exists)
            % -------------------------------------------------------------
            arguments 
                obj
                timing         
            end

            if ~isempty(timing) 
                assert(isvector(timing), 'Timing must be a vector');
                timing = timing(:);  % Columnate
            end
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