function tf = iswithin(x, a, b)
    % Determine whether number is within range
    %
    % Description:
    %   Convenience method for determining if a number is between (or equal
    %   to) two other numbers
    %
    % Syntax:
    %   tf = iswithin(x, a, b)
    %
    % Inputs:
    %   x           numeric
    %       Number(s) to evaluate
    %   a           numeric
    %       Lower bound
    %   b           numeric
    %       Upper bound
    %   
    % Outputs:
    %   tf          logical
    %       Whether x is between the a and b
    %
    % See also:
    %   isbetween
    
    % By Sara Patterson, 2023 (AOData)
    % -------------------------------------------------------------------------
    
        arguments
            x       {mustBeNumeric}
            a       {mustBeNumeric}
            b       {mustBeNumeric}
        end
    
        tf = (x >= a) & (x <= b);
        