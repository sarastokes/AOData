function out = extractCellData(data)
% Convert cell with non-datatype specific missing values to matrix  
%
% Syntax:
%   out = extractCellData(data)
%
% See also:
%   NaN, missing, NaT

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        data            cell
    end
  
    % Get the class names of the non-empty cells
    classNames = [];
    for i = 1:numel(data)
        if ~isempty(data{i}) && ~ismissing(data{i})
            classNames = cat(1, classNames, string(class(data{i})));
        end
    end

    classNames = unique(classNames);

    % If there is more than one class, data cannot be extracted
    if numel(classNames) > 1
        out = data;
        return
    end

    % Cast to datatype to convert missing/NaN/NaT to appropriate value
    out = vertcat(data{:});