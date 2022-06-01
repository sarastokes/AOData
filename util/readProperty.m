function lineValue = readProperty(filePath, header, N)
    % READPROPERTY  
    %
    % Description:
    %   Read specific property from parameter file
    %
    % Syntax:
    %   lineValue = readProperty(filePath, header, N)
    %
    % History:
    %   26Oct2021 - SSP - moved from ao.core.Dataset
    %   25Jan2021 - SSP - Added option to specify nth occurence
    % ---------------------------------------------------------------------

    if nargin < 3
        N = 1;
    end
    
    fid = fopen(filePath, 'r');
    if fid == -1
        warning('File %s could not be opened', filePath);
        lineValue = 'NaN'; 
        return
    end
    
    counter = 0;
    lineValue = [];
    tline = fgetl(fid);
    while ischar(tline)
        ind = strfind(tline, header);
        if ~isempty(ind)
            counter = counter + 1;
            if counter == N
                lineValue = tline(ind + numel(header) : end);
                break
            else
                tline = fgetl(fid);
            end
        else
            tline = fgetl(fid);
        end
    end
    fclose(fid);
        