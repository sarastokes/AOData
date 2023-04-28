function fPath = getIconFolder()
% Returns AOData's icon folder
%
% Syntax:
%   fPath = aod.app.util.getIconFolder()

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    fPath = [fileparts(fileparts(mfilename('fullpath'))),...
          filesep, '+icons', filesep];
    fPath = string(fPath);