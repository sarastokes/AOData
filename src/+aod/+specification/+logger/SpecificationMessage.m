classdef SpecificationMessage < mlog.Message 
% Logging for property validation 
%
% Superclasses:
%   mlog.Message

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Name            (1,1)       string 
        Specification   (1,1)       string 
    end

    methods 
        function t = toTable(obj)
            % Convert array of messages to a table

            % Call superclass method
            t = obj.toTable@mlog.Message();

            % Find any invalid handles
            idxValid = isvalid(obj);

            % Create variables
            Name(idxValid, 1) = vertcat(obj(idxValid).Name);
            Specification(idxValid, 1) = vertcat(obj(idxValid).Specification);

            % Insert variables
            t = addvars(t, Name, Specification, 'after', "Level");
        end
    end

    methods (Access = {?mlog.Message, ?mlog.Logger})
        function str = createDisplayMessage(obj)
            % Customize the message display format
        
            str = sprintf("%-10s %10s.  %s -- %s",...
                obj.Level, obj.Name, obj.Specification, obj.Text);
        end
    end
end 