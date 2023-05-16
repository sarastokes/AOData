function textToNewFile(txt)
% Create a new file in MATLAB's editor containing input text
%
% Description:
%   Creates a new untitled file containing input text in MATLAB's editor
%
% Syntax:
%   textToNewFile(txt)
%
% Inputs:
%   txt         string
%       Text to paste into the new file

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    com.mathworks.mlservices.MLEditorServices.getEditorApplication.newEditor(txt);
