function out = getEmpty(className)
% Convert the class name to an empty array
%
% Syntax:
%   out = getEmpty(className)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments 
        className    (1,1)   string 
    end

    switch className
        case "duration"
            out = seconds([]);
        case "containers.Map"
            out = containers.Map();
        otherwise
            try
                eval(sprintf("out = %s.empty();", className));
            catch 
                warning('getEmpty:UnhandledType',...
                    '%s could not be converted to empty', className);
            end
    end