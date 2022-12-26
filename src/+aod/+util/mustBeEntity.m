function mustBeEntity(obj)
    % MUSTBEENTITY
    %
    % Description:
    %   Argument validation function to determine whether input is an
    %   AOData entity (either core or persistent interface)
    %
    % Syntax:
    %   mustBeEntity(obj)
    %
    % Inputs:
    %   obj             AOData object
    % ---------------------------------------------------------------------

    if ~isscalar(obj)
        for i = 1:numel(obj)
            aod.util.mustBeEntity(obj(i));
        end
    end

    if ~isSubclass(obj, {'aod.core.Entity', 'aod.persistent.Entity'})
        eidType = 'mustBeEntity:InvalidInput';
        msgType = 'Input must be subclass of aod.core.Entity or aod.persistent.Entity';
        throwAsCaller(MException(eidType, msgType));
    end