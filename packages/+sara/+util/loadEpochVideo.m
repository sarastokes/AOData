function imStack = loadEpochVideo(epoch, varargin)
% Load epoch video, ensure type is double and apply optional registration
%
% Syntax:
%   imStack = loadEpochVideo(epoch, varargin)
%
% Inputs:
%   epoch           aod.core.Epoch
%       The epoch associated with the video
% Optional key/value inputs:
%   Name            char/string (default 'AnalysisVideo')
%       Name of video to load in epoch's files property
% Additional key/value inputs are passed to imwarp
%
% Outputs:
%   imStack             double
%       Epoch video [X Y T]
%
% See also:
%   imwarp, aod.util.findFileReader

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    ip = aod.util.InputParser();
    addParameter(ip, 'Name', 'AnalysisVideo', @istext);
    parse(ip, varargin{:});

    videoName = ip.Results.Name;

    sift = epoch.get('Registration', {'Name', 'SIFT'});

    fprintf('Loading video... ');
    reader = aod.util.findFileReader(epoch.getExptFile(videoName));
    imStack = reader.read();
    if ~isa(imStack, 'double')
        imStack = im2double(imStack);
    end
    
    if ~isempty(sift)
        fprintf('Applying transform... ');
        imStack = sift.apply(imStack, ip.Unmatched);
    end

    fprintf('Done.\n');
