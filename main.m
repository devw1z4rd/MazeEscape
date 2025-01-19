function main
disp('Vyberte obtiažnosť:');
disp('1 - Ľahké (60 sekúnd, menej stien, 2 bonusy)');
disp('2 - Stredná (45 sekúnd, viac stien, 3 bonusy)');
disp('3 - Hard (30 sekúnd, väčšina stien, 4 bonusy)');
difficulty = input('Zadajte obtiažnosť (1-3): ');

if difficulty == 1
    wall_chance = 0.2;
    num_bonuses = 2;
    time_limit = 60;
    num_traps = 2;
    maze_size = 5;
elseif difficulty == 2
    wall_chance = 0.3;
    num_bonuses = 3;
    time_limit = 45;
    num_traps = 3;
    maze_size = 7;
else
    wall_chance = 0.4;
    num_bonuses = 4;
    time_limit = 30;
    num_traps = 4;
    maze_size = 10;
end

valid_maze = false;
while ~valid_maze
    maze = ones(maze_size);
    
    for i = 2:maze_size-1
        for j = 2:maze_size-1
            if rand > wall_chance
                maze(i,j) = 0;
            end
        end
    end
    
    maze(2:maze_size-1, 2) = 0;
    maze(maze_size-1, 2:maze_size-1) = 0;
    
    maze(2,2) = 2;
    maze(maze_size-1,maze_size-1) = 3;
    
    empty_count = 0;
    for i = 1:maze_size
        for j = 1:maze_size
            if maze(i,j) == 0
                empty_count = empty_count + 1;
            end
        end
    end
    
    empty_rows = zeros(1, empty_count);
    empty_cols = zeros(1, empty_count);
    idx = 1;
    for i = 1:maze_size
        for j = 1:maze_size
            if maze(i,j) == 0
                empty_rows(idx) = i;
                empty_cols(idx) = j;
                idx = idx + 1;
            end
        end
    end
    
    available_indices = 1:empty_count;
    
    for b = 1:num_bonuses
        if ~custom_isempty(available_indices)
            idx = floor(rand * custom_length(available_indices)) + 1;
            r = empty_rows(available_indices(idx));
            c = empty_cols(available_indices(idx));
            maze(r, c) = 4;
            available_indices(idx) = [];
        end
    end
    
    for t = 1:num_traps
        if ~custom_isempty(available_indices)
            idx = floor(rand * custom_length(available_indices)) + 1;
            r = empty_rows(available_indices(idx));
            c = empty_cols(available_indices(idx));
            maze(r, c) = 5;
            available_indices(idx) = [];
        end
    end
    
    valid_maze = check_path(maze, maze_size);
end

moves = 0;
score = 0;
bonuses_collected = 0;
player_pos = [2,2];
start_time = custom_tic();
message = '';

while true
    clc;
    time_spent = custom_toc(start_time);
    time_left = time_limit - time_spent;
    
    disp(['Zostávajúci čas: ' custom_num2str(floor(time_left)) ' sekundy']);
    disp(['Pohyby: ' custom_num2str(moves) ' | Skóre: ' custom_num2str(score) ' | Bonusy: ' custom_num2str(bonuses_collected) '/' custom_num2str(num_bonuses)]);
    disp(' ');
    
    if ~custom_isempty(message)
        disp(message);
        disp(' ');
    end
    
    for i = 1:maze_size
        row_str = '';
        for j = 1:maze_size
            if i == player_pos(1) && j == player_pos(2)
                row_str = [row_str 'P '];
            else
                cell_value = maze(i,j);
                if cell_value == 0
                    row_str = [row_str '  '];
                elseif cell_value == 1
                    row_str = [row_str '##'];
                elseif cell_value == 2
                    row_str = [row_str '  '];
                elseif cell_value == 3
                    row_str = [row_str 'E '];
                elseif cell_value == 4
                    row_str = [row_str '* '];
                elseif cell_value == 5
                    row_str = [row_str 'X '];
                end
            end
        end
        disp(row_str);
    end
    
    disp('P=hráč, E=výstup, *=bonus, X=pasca, #=stena');
    disp('Použite W/A/S/D na presun, Q na ukončenie.');
    disp(' ');
    
    if time_left <= 0
        disp('Čas vypršal! Koniec hry!');
        break;
    end
    
    move = input('Zadajte pohyb: ', 's');
    if custom_isempty(move), move = ' '; end
    if move == 'q'
        disp('Hra skončila!');
        break;
    end
    
    new_pos = player_pos;
    if move == 'w'
        new_pos(1) = new_pos(1) - 1;
    elseif move == 's'
        new_pos(1) = new_pos(1) + 1;
    elseif move == 'a'
        new_pos(2) = new_pos(2) - 1;
    elseif move == 'd'
        new_pos(2) = new_pos(2) + 1;
    else
        message = 'Zadajte nesprávny znak!';
    end
    
    if new_pos(1) > 0 && new_pos(1) <= maze_size && ...
            new_pos(2) > 0 && new_pos(2) <= maze_size && ...
            maze(new_pos(1), new_pos(2)) ~= 1
        
        cell_value = maze(new_pos(1), new_pos(2));
        if cell_value == 4
            bonuses_collected = bonuses_collected + 1;
            score = score + 100;
            maze(new_pos(1), new_pos(2)) = 0;
            message = 'Zozbieraný bonus! (+100)';
        elseif cell_value == 5
            score = score - 50;
            message = 'Pasca! (-50)';
        elseif cell_value == 3
            if bonuses_collected == num_bonuses
                final_time_bonus = floor(time_left) * 10;
                final_score = score + final_time_bonus;
                
                [best_score, scores_list, has_suspicious] = get_maze_score();
                
                if final_score <= 800
                    save_maze_score(final_score);
                    if final_score > best_score
                        best_score = final_score;
                    end
                end
                
                msgLines = {};
                msgLines{end+1} = 'Vyhrali ste!';
                msgLines{end+1} = custom_sprintf('Konečné skóre: %d = %d (skóre) + %d (časový bonus)', ...
                    final_score, score, final_time_bonus);
                msgLines{end+1} = ['Najlepšie skóre: ' custom_num2str(best_score)];
                msgLines{end+1} = ['Celkový počet pohybov: ' custom_num2str(moves)];
                
                if has_suspicious
                    msgLines{end+1} = ' ';
                    msgLines{end+1} = 'Upozornenie: boli zistené podozrivo vysoké výsledky!';
                    msgLines{end+1} = 'Niektoré výsledky sa zdajú byť nepravdepodobné a mohli byť zadané ručne.';
                end
                
                msgLines{end+1} = ' ';
                msgLines{end+1} = 'Tabuľka rebríčka:';
                
                for iScore = 1:custom_length(scores_list)
                    score_value = scores_list(iScore);
                    if score_value > 800
                        msgLines{end+1} = custom_sprintf('%d. %d (podozrivé)', iScore, score_value);
                    else
                        msgLines{end+1} = custom_sprintf('%d. %d', iScore, score_value);
                    end
                end
                
                display_in_figure(msgLines);
                
                break;
            else
                message = 'Nezískali ste všetky bonusy.';
                new_pos = player_pos;
            end
        else
            message = '';
        end
        
        player_pos = new_pos;
        moves = moves + 1;
    else
        message = 'Neplatný pohyb!';
    end
end
end

function valid = check_path(maze, maze_size)
bonus_count = 0;
bonus_rows = zeros(1, maze_size * maze_size);
bonus_cols = zeros(1, maze_size * maze_size);

for i = 1:maze_size
    for j = 1:maze_size
        if maze(i,j) == 4
            bonus_count = bonus_count + 1;
            bonus_rows(bonus_count) = i;
            bonus_cols(bonus_count) = j;
        end
    end
end

visited = zeros(maze_size);
queue_size = maze_size * maze_size;
queue_rows = zeros(1, queue_size);
queue_cols = zeros(1, queue_size);

queue_front = 1;
queue_back = 2;
queue_rows(1) = 2;
queue_cols(1) = 2;
visited(2, 2) = 1;

dr = [-1, 1, 0, 0];
dc = [0, 0, -1, 1];

while queue_front < queue_back
    row = queue_rows(queue_front);
    col = queue_cols(queue_front);
    queue_front = queue_front + 1;
    
    for i = 1:4
        new_row = row + dr(i);
        new_col = col + dc(i);
        
        if new_row > 0 && new_row <= maze_size && ...
                new_col > 0 && new_col <= maze_size && ...
                ~visited(new_row, new_col) && maze(new_row, new_col) ~= 1
            visited(new_row, new_col) = 1;
            queue_rows(queue_back) = new_row;
            queue_cols(queue_back) = new_col;
            queue_back = queue_back + 1;
        end
    end
end

if visited(maze_size-1, maze_size-1) == 0
    valid = false;
    return;
end

valid = true;
for i = 1:bonus_count
    if visited(bonus_rows(i), bonus_cols(i)) == 0
        valid = false;
        break;
    end
end
end

function [best_score, valid_scores, has_suspicious] = get_maze_score()
best_score = 0;
valid_scores = [];
has_suspicious = false;

if custom_exist('maze_scores.txt')
    fid = fopen('maze_scores.txt', 'r');
    if fid ~= -1
        [file_content, ~] = fscanf(fid, '%c');
        fclose(fid);
        
        scores_count = 0;
        start_idx = 1;
        temp_scores = zeros(1000, 1);
        
        for i = 1:length(file_content)
            if file_content(i) == 10
                if i > start_idx
                    score = decrypt_score(file_content(start_idx:i-1));
                    if ~custom_isnan(score)
                        scores_count = scores_count + 1;
                        temp_scores(scores_count) = score;
                        if score > 800
                            has_suspicious = true;
                        end
                    end
                end
                start_idx = i + 1;
            end
        end
        
        if start_idx <= length(file_content)
            score = decrypt_score(file_content(start_idx:end));
            if ~custom_isnan(score)
                scores_count = scores_count + 1;
                temp_scores(scores_count) = score;
                if score > 800
                    has_suspicious = true;
                end
            end
        end
        
        if scores_count > 0
            valid_scores = temp_scores(1:scores_count);
            valid_scores = sort(valid_scores, 'descend');
            
            first_valid_idx = custom_find_first(valid_scores <= 800);
            if first_valid_idx > 0
                best_score = valid_scores(first_valid_idx);
            end
        end
    end
end
end

function save_maze_score(score)
if score > 800
    return;
end

encrypted_score = encrypt_score(score);

fid = fopen('maze_scores.txt', 'a');
if fid ~= -1
    fprintf(fid, '%s\n', encrypted_score);
    fclose(fid);
end
end

function encrypted = encrypt_score(score)
score_str = custom_num2str(score);
encrypted = '';

for i = 1:custom_length(score_str)
    digit = custom_str2double(score_str(i));
    letter = char('A' + digit);
    encrypted = [encrypted letter];
end

checksum = mod(sum(double(score_str) - '0'), 26);
encrypted = [encrypted char('A' + checksum)];
end

function score = decrypt_score(encrypted)
score = NaN;

if custom_length(encrypted) < 2
    return;
end

checksum_letter = encrypted(end);
encrypted = encrypted(1:end-1);

score_str = '';
for i = 1:custom_length(encrypted)
    letter = encrypted(i);
    if letter >= 'A' && letter <= 'J'
        digit = letter - 'A';
        score_str = [score_str custom_num2str(digit)];
    else
        score = NaN;
        return;
    end
end

actual_checksum = mod(sum(double(score_str) - '0'), 26);
expected_checksum = checksum_letter - 'A';

if actual_checksum == expected_checksum
    score = custom_str2double(score_str);
end
end

function start_time = custom_tic()
current_datetime = datetime('now');
start_time = current_datetime.Hour * 3600 + ...
    current_datetime.Minute * 60 + ...
    current_datetime.Second;
end

function elapsed_time = custom_toc(start_time)
current_datetime = datetime('now');
current_time = current_datetime.Hour * 3600 + ...
    current_datetime.Minute * 60 + ...
    current_datetime.Second;

elapsed_time = current_time - start_time;

if elapsed_time < 0
    elapsed_time = elapsed_time + 24 * 3600;
end
end

function first_idx = custom_find_first(logical_array)
first_idx = 0;
for i = 1:custom_length(logical_array)
    if logical_array(i)
        first_idx = i;
        break;
    end
end
end

function result = custom_isnan(x)
result = (x ~= x);
end

function result = custom_exist(filename)
fid = fopen(filename, 'r');
if fid == -1
    result = false;
else
    fclose(fid);
    result = true;
end
end

function result = custom_isempty(arr)
result = (numel(arr) == 0);
end

function len = custom_length(arr)
len = length(arr);
end

function result = custom_strjoin(cellArray, separator)
if nargin < 2
    separator = char(10);
end

result = '';

array_length = custom_length(cellArray);

for i = 1:array_length
    result = [result cellArray{i}];
    
    if i < array_length
        result = [result separator];
    end
end
end

function result = custom_str2double(str)
result = 0;

if custom_isempty(str)
    result = NaN;
    return;
end

is_negative = false;
start_idx = 1;
if str(1) == '-'
    is_negative = true;
    start_idx = 2;
end

decimal_found = false;
decimal_position = 0;
multiplier = 1;

for i = custom_length(str):-1:start_idx
    current_char = str(i);
    
    if current_char == '.'
        if decimal_found
            result = NaN;
            return;
        end
        decimal_found = true;
        continue;
    end
    
    if current_char < '0' || current_char > '9'
        result = NaN;
        return;
    end
    
    digit = current_char - '0';
    
    if decimal_found
        decimal_position = decimal_position + 1;
        result = result + digit * (0.1 ^ decimal_position);
    else
        result = result + digit * multiplier;
        multiplier = multiplier * 10;
    end
end

if is_negative
    result = -result;
end
end

function result = custom_num2str(num)
if custom_isnan(num)
    result = 'nan';
    return;
end

if num == 0
    result = '0';
    return;
end

is_negative = num < 0;
if is_negative
    num = -num;
end

int_part = floor(num);
result = '';

while int_part > 0
    digit = mod(int_part, 10);
    result = [char(digit + '0') result];
    int_part = floor(int_part / 10);
end

if is_negative
    result = ['-' result];
end

decimal_part = num - floor(num);
if decimal_part > 0
    result = [result '.'];
    precision = 6;
    
    for i = 1:precision
        decimal_part = decimal_part * 10;
        digit = floor(decimal_part);
        result = [result char(digit + '0')];
        decimal_part = decimal_part - digit;
        
        if decimal_part == 0
            break;
        end
    end
end

if custom_isempty(result)
    result = '0';
end
end

function result = custom_sprintf(format_str, varargin)
result = '';
format_length = custom_length(format_str);
arg_index = 1;
i = 1;

while i <= format_length
    if format_str(i) == '%'
        if i < format_length
            format_type = format_str(i + 1);
            
            if arg_index <= nargin - 1
                arg = varargin{arg_index};
                
                if format_type == 'd'
                    is_number = custom_is_number(arg);
                    if is_number
                        result = [result custom_num2str(arg)];
                    else
                        result = [result '(error)'];
                    end
                elseif format_type == 's'
                    if custom_is_char(arg)
                        result = [result arg];
                    else
                        result = [result '(error)'];
                    end
                end
                
                arg_index = arg_index + 1;
                i = i + 2;
                continue;
            end
        end
    end
    
    result = [result format_str(i)];
    i = i + 1;
end
end

function result = custom_is_number(value)
try
    test = value + 0;
    result = ~custom_isnan(test);
catch
    result = false;
end
end

function result = custom_is_char(value)
try
    test_char = value(1);
    result = (test_char >= 0 && test_char <= 255);
catch
    result = false;
end
end

function display_in_figure(msgLines)
fullText = custom_strjoin(msgLines);

f = figure('Name','Maze Game Results','NumberTitle','off',...
    'Position',[200 200 800 800]);

annotation('textbox',[0.05 0.05 0.9 0.9], ...
    'String', fullText, ...
    'Interpreter','none', ...
    'FitBoxToText','on', ...
    'FontSize', 12);
end
