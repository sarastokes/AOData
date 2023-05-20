function PM = readExpectedAttributes(hdfName, pathName, dsetName)
% Read a table of expected attributes from an HDF5 file
%
% Syntax:
%   PM = aod.h5.readExpectedAttributes(hdfName, pathName, dsetName)
%
% See also:
%   aod.util.AttributeManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    % Read as a table
    T = h5tools.read(hdfName, pathName, dsetName);

    % Convert to AttributeManager
    PM = aod.util.AttributeManager();
    numParams = height(T);
    for i = 1:numParams
        try
            eval(sprintf('default = %s;', T.Default(i)));
        catch
            warning("readExpectedAttributes:DefaultEvalError",...
                "Could not evaluate %s", T.Default(i));
            default = [];
        end
        try
            eval(sprintf('validation = %s;', T.Validation(i)));
        catch 
            warning("readExpectedAttributes:ValidationEvalError",...
                "Could not evaluate %s", T.Validation(i));
            validation = [];
        end
        PM.add(T.Name(i), default, validation, T.Description(i));
    end