function txt = int2fixedwidthstr(x, numDigits)
    % FOURDIGITCHAR
    %
    % Syntax:
    %   txt = int2fixedwidthstr(x, numDigits)
    %
    % Input:
    %   x           Integer
    %   numDigits   Integer
    %       Number of digits to convert integer x to (by adding leading 0s)
    %
    % Output:
    %   txt         char
    %       Integer with preceeding zeros needed to have length = numDigits
    %
    % History:
    %   04Nov2020 - SSP
    % ---------------------------------------------------------------------

    txt = num2str(x);

    if numel(txt) > numDigits
        error('Upper limit is 4 digits');
    elseif numel(txt) < numDigits
        leadingZeros = numDigits - numel(txt);
        txt = [repmat('0', [1, leadingZeros]), txt];
    end

