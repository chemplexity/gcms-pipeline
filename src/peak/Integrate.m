function area = Integrate(varargin)
% ------------------------------------------------------------------------
% Function    : Integrate
% Description : compute the area of the peak signal
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   area = Integrate(x, y, baseline)
%   area = Integrate( __ , Name, Value)
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
%   baseline -- baseline value
%       number
%
% ------------------------------------------------------------------------
% Input (Optional)
% ------------------------------------------------------------------------
%   'xmin' -- the left boundary of integration
%       min(x) (default) | number
%
%   'xmax' -- the right boundary of integration
%       max(x) (default) | number
%
%   'minPoints' -- minimum number of non-zero points to integrate
%       5 (default) | number

% ---------------------------------------
% Defaults
% ---------------------------------------
default.xmin = -1;
default.xmax = -1;
default.minPoints = 5;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'x', @isnumeric);
addRequired(p, 'y', @isnumeric);
addRequired(p, 'baseline', @isnumeric);

addParameter(p, 'xmin', default.xmin);
addParameter(p, 'xmax', default.xmax);
addParameter(p, 'minPoints', default.minPoints);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
x = p.Results.x;
y = p.Results.y;
baseline = p.Results.baseline;

xmin = p.Results.xmin;
xmax = p.Results.xmax;
minPoints = p.Results.minPoints;

% ---------------------------------------
% Validate
% ---------------------------------------

% Check x values
if size(x,1) == 1
    x = x';
end

% Check y values
if size(y,1) == 1
    y = y';
elseif size(y,2) == size(x,1)
    y = y';
end

% Sort array by x values
[x, idx] = sort(x, 'ascend');
y = y(idx,:);

% Check xmin
if xmin == -1 || xmin < min(x)
    xmin = min(x);
end

% Check xmax
if xmax == -1 || xmax > max(x)
    xmax = max(x);
end

% Check minPoints
if minPoints < 3
    minPoints = 3;
end

% ---------------------------------------
% Filter signal
% ---------------------------------------
xFilter = x >= xmin & x <= xmax;
x = x(xFilter);
y = y(xFilter, :);

% ---------------------------------------
% Integrate
% ---------------------------------------
area = 0;

if nnz(y) > minPoints
    
    y = y - baseline;
    
    try
        area = trapz(x,y);
    catch
        
        dx = diff(x);
        dy = y(1:end-1) + y(2:end);

        if length(dx) == length(dy)
            area = sum(dx.*dy) / 2;
        end
        
    end
    
end

if isnan(area)
    area = 0;
end

% ---------------------------------------
% Convert area units to seconds
% ---------------------------------------
area = area * 60;

end
