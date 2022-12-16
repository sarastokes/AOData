function ip = InputParser()
% INPUTPARSER
%
% Description:
%   A wrapper for the builtin inputParser class that simplify setting
%   3 defaults that would otherwise need to be retyped with every class
%
% Syntax:
%   ip = inputParser()
%
% Notes:
%   Why these three defaults?
%   1) Having two parameters to the same class that are identical other
%      than their case ('MyParam' and 'myparam') is bad practice and 
%      should never be done so we might as well ignore case 
%   2) When you have a subclass that uses varargin/inputParser and also
%      want to pass varargin to the parent class's inputParser, you 
%      need KeepUnmatched=true to avoid errors at each stage for 
%      unrecognized parameters. The downside is that you won't get an 
%      error when you type an incorrect parameter
%   3) Disabling partial matching was a hard choice but it can cause 
%      fatal errors for classes where a text input is the required 
%      parameter occurring before varargin. 

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    ip.PartialMatching = false;