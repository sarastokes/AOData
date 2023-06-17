classdef SpecificationLogger < mlog.Logger 
% Logger for validation against a specification
%
% Superclasses:
%   mlog.Logger
%
% Constructor:
%   obj = aod.specification.logger.SpecificationLogger(varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = SpecificationLogger(varargin)
            obj@mlog.Logger(varargin{:});

            obj.MessageConstructor = @aod.specification.logger.SpecificationMessage;
        end
    end

    methods
        function varargout = write(obj, propName, specName, varargin)

            arguments 
                obj         (1,1)
                propName    (1,1)       string 
                specName    (1,1)       string 
            end

            arguments (Repeating)
                varargin 
            end

            % Construct the message
            msg = constructMessage(obj, varargin{:});

            % Was a message created? It might be empty if it didn't meet 
            % any of the log level thresholds
            if ~isempty(msg)
                % Add custom properties
                msg.Name = propName;
                msg.Specification = specName;
                
                % Add the message to the log
                obj.addMessage(msg);
            end

            % Set msg output if requested 
            if nargout
                varargout{1} = msg;
            end
        end
    end
end 