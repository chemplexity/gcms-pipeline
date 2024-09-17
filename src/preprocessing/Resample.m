function [x0, y0] = Resample(varargin)
% ------------------------------------------------------------------------
% Function    : Resample
% Description : resample the signal to a desired sample rate (Hz)
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   [x0, y0] = Resample(x, y)
%   [x0, y0] = Resample( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Required)
% ------------------------------------------------------------------------
%   x -- time values
%       array (size = n x 1)
%
%   y -- intensity values
%       array (size = n x 1)
%
% ------------------------------------------------------------------------
% Input (Optional)
% ------------------------------------------------------------------------
%   'sampleRate' -- the target sample rate to resample signal (Hz)
%       500 (default) | number

% ---------------------------------------
% Defaults
% ---------------------------------------
default.minSize = 25;
default.freqTol = 25;
default.sampleRate = 500;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'x', @isnumeric);
addRequired(p, 'y', @isnumeric);

addParameter(p, 'sampleRate', default.sampleRate);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
x = p.Results.x;
y = p.Results.y;

sampleRate = p.Results.sampleRate;

% ---------------------------------------
% Validate
% ---------------------------------------
if isempty(x) || isempty(y) || ~any(x) || ~any(y)
    return
end

if length(x) < default.minSize || length(y) < default.minSize
    default.minSize = length(x);
end

% ---------------------------------------
% Resample
% ---------------------------------------
x0 = [];
y0 = [];

f0 = 1 / mean(diff(x(1:default.minSize)));

% Downsample signal
if f0 > sampleRate
    
    dx = round(1./(x(3:20)-x(2)));
    
    if any(dx == sampleRate)
        
        ii = find(dx == sampleRate, 1);
        x0 = x(1:ii:end);
        y0 = y(1:ii:end);
        
    elseif any(dx >= sampleRate - default.freqTol & dx <= sampleRate + default.freqTol)
        
        ii = find(dx >= sampleRate - default.freqTol & dx <= sampleRate + default.freqTol, 1);
        x0 = x(1:ii:end);
        y0 = y(1:ii:end);
        
    else

        x0 = min(x):1/sampleRate:max(x);
        y0 = interp1(x,y,x0);

    end

% Upsample signal
elseif f0 < sampleRate

    x0 = min(x):1/sampleRate:max(x);
    y0 = interp1(x,y,x0);

end

if size(x0,1) == 1
    x0 = x0';
end

if size(y0,1) == 1
    y0 = y0';
end

end
