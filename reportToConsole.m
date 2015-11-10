function reverseStr = reportToConsole(str, reverseStr,varargin)  
    %Does not work with strings containing '%%'!
    msg = sprintf(str, varargin{:});
    fprintf('%s',[reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
    pause(0.1)
end