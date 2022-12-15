function S = getAODataEnv()
% Returns information about the environment code is operating in
%
% Description:
%   Provides information on the computer, MATLAB installation and AOData
%
% Syntax:
%   S = aod.infra.getAODataEnv()
%
% Inputs:
%   N/A
%
% Outputs:
%   S           struct
%       Contains information about computer, MATLAB and AOData
%
% See Also:
%   aod.infra.getVersionNumber

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    S = struct();

    % Computer type 
    S.ComputerType = computer();
    S.ComputerArchitecture = computer('arch');

    % Information about current MATLAB installation
    matlabInfo = ver('MATLAB');
    S.MatlabVersion = matlabInfo.Version;
    S.MatlabRelease = matlabInfo.Release;
    S.MatlabDate = matlabInfo.Date;

    % Information about AOData installation
    S.AODataVersion = aod.infra.getVersionNumber();
    