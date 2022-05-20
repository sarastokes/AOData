function imStack = video2stack(videoPath, varargin)
    % VIDEO2STACK
    % 
    % Description:
    %   Converts video to [X, Y, T] matrix in matlab
    % 
    % Syntax:
    %   imStack = video2stack(videoPath, varargin)
    %
    % Inputs:
    %   videoPath           char
    %       file path and name of video (if empty, uses uigetfile)
    % Optional key/value inputs:
    %   side                char ['right']
    %       Side with GCaMP6 signal {'left', 'right', 'none'}
    %   save                logical [false]
    %       Whether to save stack as .mat file with same name/path as .avi
    %
    % History:
    %   03Nov2020 - SSP
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Side', 'none', @ischar);
    addParameter(ip, 'Save', false, @islogical);
    parse(ip, varargin{:});

    if isempty(videoPath) || nargin == 0
        [fileName, filePath, idx] = uigetfile({'*.avi'});
        if idx == 0
            imStack = [];
            return;
        end
        videoPath = [filePath, fileName];
    end

    v = VideoReader(videoPath);

    frame = im2double(readFrame(v));
    numFrames = v.Duration / v.CurrentTime;

    switch ip.Results.Side 
        case 'right'
            imWindow = floor(v.Width/2):v.Width;
        case 'left'
            imWindow = 1:ceil(v.Width/2);
        case 'none'
            imWindow = 1:v.Width;
    end

    imStack = zeros(v.Height, numel(imWindow), numFrames);
    imStack(:, :, 1) = frame(:, imWindow);

    for i = 2:numFrames
        frame = im2double(readFrame(v));
        imStack(:, :, i) = frame(:, imWindow);
    end 
    
    if ip.Results.Save
        savePath = [videoPath(1:end-4), '.mat'];
        fprintf('Saved as: %s\n', savePath);
        save(savePath, 'imStack');
    end
