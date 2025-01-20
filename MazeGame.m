function varargout = MazeGame(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @MazeGame_OpeningFcn, ...
        'gui_OutputFcn',  @MazeGame_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && custom_ischar(varargin{1})
        gui_State.gui_Callback = custom_str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end

function MazeGame_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
end

function varargout = MazeGame_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end

% main change for req.
function update_results(handles, msgLines) 
    fullText = custom_strjoin(msgLines);
    set(handles.result_staticText, 'String', fullText);
end


% help func.'s 
function result = custom_strcmp(str1, str2)
    len1 = custom_length(str1);
    len2 = custom_length(str2);
    
    if len1 ~= len2
        result = false;
        return;
    end
    
    result = true;
    for i = 1:len1
        if str1(i) ~= str2(i)
            result = false;
            return;
        end
    end
end

function result = custom_strcat(str1, str2)
    result = [str1 str2];
end

function handle = custom_str2func(str)
    
    if custom_strcmp(str, 'MazeGame_OpeningFcn')
        handle = @MazeGame_OpeningFcn;
    elseif custom_strcmp(str, 'MazeGame_OutputFcn')
        handle = @MazeGame_OutputFcn;
    elseif custom_strcmp(str, 'update_results')
        handle = @update_results;
    else
        handle = [];
        error('Function not found');
    end
end

function str = custom_func2str(func_handle)
    
    if func_handle == @MazeGame_OpeningFcn
        str = 'MazeGame_OpeningFcn';
    elseif func_handle == @MazeGame_OutputFcn
        str = 'MazeGame_OutputFcn';
    elseif func_handle == @update_results
        str = 'update_results';
    else
        str = '';
    end
end

function len = custom_length(arr)
    len = 0;
    while (len + 1 <= numel(arr)) && ~custom_isempty(arr(len + 1))
        len = len + 1;
    end
end

function result = custom_isempty(arr)
    result = (numel(arr) == 0);
end

function result = custom_ischar(var)
    try
        if numel(var) == 0
            result = true;
            return;
        end
        val = var(1);
        result = val >= 0 && val <= 255;
    catch
        result = false;
    end
end

function result = custom_substr(str, start, len)
    if nargin < 3
        len = custom_length(str) - start + 1;
    end
    
    result = '';
    for i = start:min(start + len - 1, custom_length(str))
        result = [result str(i)];
    end
end

function result = custom_startswith(str, prefix)
    prefix_len = custom_length(prefix);
    str_len = custom_length(str);
    
    if prefix_len > str_len
        result = false;
        return;
    end
    
    result = custom_strcmp(custom_substr(str, 1, prefix_len), prefix);
end

function result = custom_endswith(str, suffix)
    suffix_len = custom_length(suffix);
    str_len = custom_length(str);
    
    if suffix_len > str_len
        result = false;
        return;
    end
    
    result = custom_strcmp(custom_substr(str, str_len - suffix_len + 1), suffix);
end
