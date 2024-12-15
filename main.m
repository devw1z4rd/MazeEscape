function maze_game()
    clc;
    clear;
    close all;

    % Výber zložitosti
    disp('Zvoľte obtiažnosť:');
    disp('1 - Ľahko (od 5x5 do 10x10)');
    disp('2 - Stredné (od 15x15 do 20x20)');
    disp('3 - Ťažký (od 25x25 do 30x30)');
    diff_choice = input('Zadajte číslo: ');
    while ~ismember(diff_choice, [1,2,3])
        diff_choice = input('Nesprávny výber. Zadajte 1, 2 alebo 3: ');
    end

    if diff_choice == 1
        maze_size = randi([5,10]);
    elseif diff_choice == 2
        maze_size = randi([15,20]);
    else
        maze_size = randi([25,30]);
    end

    fig = figure;
    axis off;
    hold on;
    set(fig, 'Color', 'w'); % biele pozadie

    % Zobrazenie pravidiel
    rules_str = sprintf(['Pravidlá:\n' ...
                         '- Pozbierajte všetky bonusy v bludisku.\n' ...
                         '- Vyhnite sa monštrám: kolízia zabíja.\n' ...
                         '- Jedinou cestou z bludiska je nazbierať všetky bonusy.\n']);
    rules_box = annotation('textbox', [0.1, 0.4, 0.8, 0.2], ...
                           'String', rules_str, 'FontSize', 14, 'FontWeight', 'bold', ...
                           'BackgroundColor', 'w', 'EdgeColor', 'none', ...
                           'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

    drawnow;
    pause(0); 

    % Vymazanie pravidiel
    delete(rules_box);
    cla; % Čistenie

    % Generovanie bludiska
    max_tries = 50; 
    for attempt = 1:max_tries
        [lvl1, start_pos, exit_pos] = generate_solvable_maze(maze_size);
        if ~isempty(lvl1)
            break;
        end
    end

    if isempty(lvl1)
        disp('Po niekoľkých pokusoch sa nepodarilo vygenerovať priechodné bludisko.');
        return;
    end

    [rows, cols] = size(lvl1);

    % Nahrávanie obrázkov
    bg = imresize(imread('img/bg.png'), [100, 100], 'nearest');
    stena = imresize(imread('img/stena.png'), [100, 100], 'nearest');
    exit_img = imresize(imread('img/exit.png'), [100, 100], 'nearest');
    monster_img = imresize(imread('img/monster.png'), [100, 100], 'nearest');
    bonus_img = imresize(imread('img/bonus.png'), [100, 100], 'nearest');
    pers = imresize(imread('img/pers.png'), [100, 100], 'nearest');

    cell_size = 1;
    score = 0;

    total_bonuses = sum(lvl1(:)==3);

    axis([0 cols 0 rows]);
    axis equal;
    axis off;

    % Kreslenie bludiska
    for r = 1:rows
        for c = 1:cols
            x_pos = (c-1)*cell_size;
            y_pos = (rows-r)*cell_size;

            val = lvl1(r,c);
            if val == 1
                image([x_pos, x_pos+cell_size], [y_pos, y_pos+cell_size], stena);
            elseif val == 0 || val == 2 || val == 5
                image([x_pos, x_pos+cell_size], [y_pos, y_pos+cell_size], bg);
                if val == 5
                    image([x_pos, x_pos+cell_size], [y_pos, y_pos+cell_size], exit_img);
                end
            elseif val == 3
                image([x_pos, x_pos+cell_size], [y_pos, y_pos+cell_size], bonus_img);
            elseif val == 4
                image([x_pos, x_pos+cell_size], [y_pos, y_pos+cell_size], monster_img);
            end
        end
    end

    player_row = start_pos(1);
    player_col = start_pos(2);
    x_pos = (player_col-1)*cell_size;
    y_pos = (rows-player_row)*cell_size;
    player_img = image([x_pos, x_pos+cell_size], [y_pos, y_pos+cell_size], pers);

    message_box = annotation('textbox', [0.1, 0.85, 0.8, 0.1], ...
                             'String', '', 'FontSize', 14, 'FontWeight', 'bold', ...
                             'BackgroundColor', 'w', 'EdgeColor', 'k', ...
                             'HorizontalAlignment', 'center');
    set(message_box, 'Units', 'pixels');
    pos = get(message_box, 'Position');
    pos(2) = pos(2) + 20; 
    set(message_box, 'Position', pos);

    drawnow;

    % Hlavný herný cyklus
    game_over = false;
    win_condition = false;
    while true
        w = waitforbuttonpress;
        if w
            key = get(fig, 'CurrentKey');
            new_row = player_row;
            new_col = player_col;

            if strcmp(key, 'uparrow')
                new_row = player_row - 1;
            elseif strcmp(key, 'downarrow')
                new_row = player_row + 1;
            elseif strcmp(key, 'leftarrow')
                new_col = player_col - 1;
            elseif strcmp(key, 'rightarrow')
                new_col = player_col + 1;
            end

            if new_row > 0 && new_row <= rows && new_col > 0 && new_col <= cols && lvl1(new_row, new_col) ~= 1
                old_row = player_row;
                old_col = player_col;
                player_row = new_row;
                player_col = new_col;

                if lvl1(old_row, old_col) ~= 1 && lvl1(old_row, old_col) ~= 5
                    lvl1(old_row, old_col) = 0;
                    x_pos_old = (old_col-1)*cell_size;
                    y_pos_old = (rows - old_row)*cell_size;
                    image([x_pos_old, x_pos_old+cell_size], [y_pos_old, y_pos_old+cell_size], bg);
                end

                x_pos_new = (player_col-1)*cell_size;
                y_pos_new = (rows - player_row)*cell_size;
                set(player_img, 'XData', [x_pos_new, x_pos_new+cell_size], 'YData', [y_pos_new, y_pos_new+cell_size]);
                uistack(player_img, 'top'); 

                cell_val = lvl1(player_row, player_col);
                if cell_val == 3
                    set(message_box, 'String', 'Našli ste bonus!');
                    lvl1(player_row, player_col) = 0;
                    total_bonuses = total_bonuses - 1;
                    image([x_pos_new, x_pos_new+cell_size], [y_pos_new, y_pos_new+cell_size], bg);
                    uistack(player_img, 'top');
                elseif cell_val == 4
                    score = score - 1;
                    if score < 0
                        set(message_box, 'String', 'Chizzy zomrel na jed zlých krys. Smola...');
                        uistack(player_img, 'top');
                        drawnow;
                        pause(1); % Pauza na zobrazenie správy
                        game_over = true;
                        break; % Strata
                    end
                elseif cell_val == 5
                    if total_bonuses == 0
                        set(message_box, 'String', 'Gratulujeme! Dostali ste sa z bludiska.');
                        uistack(player_img, 'top');
                        drawnow;
                        pause(1); % Pauza na zobrazenie správy
                        win_condition = true;
                        break; % Výhra
                    else
                        set(message_box, 'String', 'Bonus sa nezbiera!');
                    end
                else
                    set(message_box, 'String', '');
                end

                drawnow;
            end
        end
    end

    % Zatvorenie starého čísla
    close(fig);

    % Vytvorenie nového tvaru na zobrazenie konečného obrázka v plnej veľkosti
    if game_over && ~win_condition
        lose_img = imread('img/lose.png');
        hFig = figure('MenuBar','none','ToolBar','none');
        imshow(lose_img, 'Border', 'tight');
        truesize(hFig);
    else
        win_img = imread('img/win.png');
        hFig = figure('MenuBar','none','ToolBar','none');
        imshow(win_img, 'Border', 'tight');
        truesize(hFig);
    end
end

function [maze, start_pos, exit_pos] = generate_solvable_maze(size_)
    max_tries = 20;
    maze = [];
    start_pos = [];
    exit_pos = [];
    for i=1:max_tries
        m = generate_maze_matrix(size_);
        m = add_extra_passages(m, round(size_/2));
        [start_r, start_c] = find_first_free(m, 'top-left');
        m(start_r,start_c) = 2;
        [exit_r,exit_c] = find_first_free(m, 'bottom-right');
        if (exit_r == start_r && exit_c == start_c)
            continue;
        end
        m(exit_r,exit_c) = 5;

        path = bfs_find_path(m, [start_r,start_c], [exit_r,exit_c]);
        if ~isempty(path)
            m = place_bonuses_and_monsters_on_path(m, path, size_);
            new_path = bfs_find_path(m, [start_r,start_c], [exit_r,exit_c]);
            if ~isempty(new_path)
                maze = m;
                start_pos = [start_r, start_c];
                exit_pos = [exit_r, exit_c];
                return;
            end
        end
    end
end

function maze = generate_maze_matrix(size_)
    maze = ones(size_);
    row = 2; col = 2;
    if row>size_ || col>size_
        return;
    end
    maze(row,col) = 0;
    stack = [row col];
    directions = [-2 0;2 0;0 -2;0 2];

    while ~isempty(stack)
        cur = stack(end,:);
        r = cur(1); c = cur(2);
        neighbors = [];
        for i=1:size(directions,1)
            nr = r+directions(i,1);
            nc = c+directions(i,2);
            if nr>1 && nr<size_ && nc>1 && nc<size_ && maze(nr,nc)==1
                neighbors = [neighbors; nr nc];
            end
        end
        if isempty(neighbors)
            stack(end,:) = [];
        else
            idx = randi(size(neighbors,1));
            nr = neighbors(idx,1);
            nc = neighbors(idx,2);
            maze(nr,nc) = 0;
            maze((r+nr)/2,(c+nc)/2) = 0;
            stack = [stack; nr nc];
        end
    end
end

function maze = add_extra_passages(maze, count)
    [rows,cols] = size(maze);
    for i=1:count
        r = randi([2 rows-1]);
        c = randi([2 cols-1]);
        if maze(r,c)==1
            maze(r,c)=0;
        end
    end
end

function [r,c] = find_first_free(maze, corner)
    [rows, cols] = size(maze);
    if strcmp(corner, 'top-left')
        for rr=1:rows
            for cc=1:cols
                if maze(rr,cc)==0
                    r=rr; c=cc; return;
                end
            end
        end
    elseif strcmp(corner, 'bottom-right')
        for rr=rows:-1:1
            for cc=cols:-1:1
                if maze(rr,cc)==0
                    r=rr; c=cc; return;
                end
            end
        end
    end
    [r,c] = find(maze==0,1);
end

function path = bfs_find_path(maze, start_pos, end_pos)
    [rows, cols] = size(maze);
    start = sub2ind([rows cols], start_pos(1), start_pos(2));
    goal = sub2ind([rows cols], end_pos(1), end_pos(2));

    visited = false(rows*cols,1);
    parent = zeros(rows*cols,1);
    queue = start;
    visited(start) = true;

    dirs = [0 1;0 -1;1 0;-1 0];

    while ~isempty(queue)
        cur = queue(1);
        queue(1) = [];
        if cur == goal
            break;
        end
        [r,c] = ind2sub([rows cols], cur);
        for i=1:4
            nr = r+dirs(i,1);
            nc = c+dirs(i,2);
            if nr>=1 && nr<=rows && nc>=1 && nc<=cols
                if maze(nr,nc)~=1 && maze(nr,nc)~=4 && ~visited(sub2ind([rows cols],nr,nc))
                    visited(sub2ind([rows cols],nr,nc)) = true;
                    parent(sub2ind([rows cols],nr,nc)) = cur;
                    queue(end+1) = sub2ind([rows cols],nr,nc);
                end
            end
        end
    end

    if ~visited(goal)
        path = [];
    else
        path = goal;
        while path(1)~=start
            path = [parent(path(1)); path];
        end
    end
end

function maze = place_bonuses_and_monsters_on_path(maze, path, size_)
    [rows, cols] = size(maze);

    rc_path = zeros(length(path),2);
    for i=1:length(path)
        [r,c] = ind2sub([rows cols], path(i));
        rc_path(i,:) = [r,c];
    end

    if size_ <= 10
        num_bonuses = 1;
        num_monsters = 1;
    elseif size_ <= 20
        num_bonuses = 2;
        num_monsters = 1;
    else
        num_bonuses = 2;
        num_monsters = 2;
    end

    path_candidates = rc_path(2:end-1,:);
    if num_bonuses > size(path_candidates,1)
        num_bonuses = size(path_candidates,1);
    end

    if num_bonuses > 0
        chosen_idx = randsample(size(path_candidates,1), num_bonuses);
        for i=1:num_bonuses
            r = path_candidates(chosen_idx(i),1);
            c = path_candidates(chosen_idx(i),2);
            maze(r,c) = 3; % bonus
        end
    end

    all_free = find(maze==0);
    path_linear = sub2ind([rows cols], rc_path(:,1), rc_path(:,2));
    all_free = setdiff(all_free, path_linear);
    if num_monsters > length(all_free)
        num_monsters = length(all_free);
    end

    if num_monsters > 0 && ~isempty(all_free)
        chosen_idx = randsample(length(all_free), num_monsters);
        maze(all_free(chosen_idx)) = 4; % monster
    end
end
