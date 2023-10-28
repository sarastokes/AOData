function throwWarning(ME)
% THROWWARNING
%
% Description:
%   Throws MException as a warning and formats the message to include the
%   causes (if present) to look similar to throwing an error with causes
%
% Syntax:
%   throwWarning(ME)

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    if isempty(ME.cause)
        warning(ME.identifier, ME.message);
        return
    end

    msg = ME.message;
    for i = 1:numel(ME.cause)
        msg = sprintf('%s\n\t%s', msg, ME.cause{i}.message);
    end

    warning(ME.identifier, msg);
