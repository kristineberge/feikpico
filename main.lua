MAX_POINTS = 3
dog_sprite_one = {x = 8, y = 0, w = 8, h = 8}
dog_sprite_two = {x = 16, y = 0, w = 8, h = 8}
cat_sprite = {x = 0, y = 0, w = 8, h = 8}
mouse_sprite = {x = 24, y = 0, w = 8, h = 8}
wolf_sprite = {x = 32, y = 0, w = 8, h = 8}
sprites = {cat_sprite, mouse_sprite, dog_sprite_one, dog_sprite_two, wolf_sprite}

dog_one = {sx = 0, sy = 0, p = 0, sprite = dog_sprite_one, x=nil, y=nil, sub_x=nil, sub_y=nil}
dog_two = {sx = 120, sy = 120, p = 0, sprite = dog_sprite_two, x=nil, y=nil, sub_x=nil, sub_y=nil}
cat = {sx = 60, sy = 60, target_x = 60, target_y = 60, sprite = cat_sprite, x=nil, y=nil, sub_x=nil, sub_y=nil}
mouse = {sx = 60, sy = 119, sprite = mouse_sprite, x=nil, y=nil, sub_x=nil, sub_y=nil}
wolf = {sx = 60, sy = 90, sprite = wolf_sprite, x=nil, y=nil, sub_x=nil, sub_y=nil}

entities = {dog_one, dog_two, cat, mouse, wolf}
player_entities = {dog_one, dog_two}
item_entities = {cat, mouse}

win_sprite = {x = 80, y = 0, w = 32, h = 32}
WIN_SCREEN_DURATION = 30
win_screen = 0

victory_sprite = {x = 48, y = 0, w = 32, h = 32}
VICTORY_SCREEN_DURATION = 30
victory_screen = 0

map_index = 1
maps = {{x = 0, y = 0}, {x = 16, y = 0}, {x = 32, y = 0}}

function draw_entity(entity)
    if (entity.sprite) then
        sspr(entity.sprite.x, entity.sprite.y, entity.sprite.w, entity.sprite.h,
             entity.x, entity.y)
    else
        pset(entity.x, entity.y, entity.color)
    end
end

function reset_soft()
    for e in all(entities) do
        e.x = e.sx
        e.y = e.sy
        e.sub_x = 0
        e.sub_y = 0
    end
    wolf.x = 32 + flr(rnd(64))
    wolf.y = 32 + flr(rnd(64))
    mouse.x = 32 + flr(rnd(64))
    mouse.y = 32 + flr(rnd(64))
end

function reset_hard()
    for e in all(entities) do
        e.x = e.sx
        e.y = e.sy
        e.sub_x = 0
        e.sub_y = 0
        e.p = 0
    end
    wolf.x = 32 + flr(rnd(64))
    wolf.y = 32 + flr(rnd(64))
    mouse.x = 32 + flr(rnd(64))
    mouse.y = 32 + flr(rnd(64))
end

function _init()
    reset_hard()
    for s in all(sprites) do
        local pixels = {}
        for x = 0, s.w - 1 do
            for y = 0, s.h - 1 do
                if sget(x + s.x, y + s.y) ~= 0 then
                    add(pixels, {x = x, y = y})
                end
            end
        end
        s.pixels = pixels
    end
end

function entity_as_box(e)
    local w = 1
    local h = 1
    if e.sprite then
        w = e.sprite.w
        h = e.sprite.h
    end
    return {x = e.x, y = e.y, w = w, h = h}
end

function intersect_box(b1, b2)

    return not ((b1.x >= b2.x + b2.w) or (b1.x + b1.w <= b2.x) or
               (b1.y >= b2.y + b2.h) or (b1.y + b1.h <= b2.y))
end

function intersect_pixels(e1, e2)
    local pixels = {}
    local sp1 = (e1.sprite and e1.sprite.pixels) or {{x = 0, y = 0}}
    local sp2 = (e2.sprite and e2.sprite.pixels) or {{x = 0, y = 0}}
    for p1 in all(sp1) do
        local x1 = p1.x + e1.x
        local y1 = p1.y + e1.y
        for p2 in all(sp2) do
            local x2 = p2.x + e2.x
            local y2 = p2.y + e2.y
            if (x1 == x2 and y1 == y2) then
                add(pixels, {x = x1, y = y1})
            end
        end
    end
    return pixels
end

function intersect(e1, e2)
    if (intersect_box(entity_as_box(e1), entity_as_box(e2))) then
        return intersect_pixels(e1, e2)
    end
    return {}
end

function draw_points() print(dog_one.p .. ":" .. dog_two.p, 7 * 8 + 2, 1, 0) end

function draw_win_screen()
    sspr(win_sprite.x, win_sprite.y, win_sprite.w, win_sprite.h, 48, 48)
end

function draw_victory_screen()
    sspr(victory_sprite.x, victory_sprite.y, victory_sprite.w, victory_sprite.h,
         48, 48)
end

function gravity(mover, gravity_objects, attraction_strength)
    local x = 0
    local y = 0

    for obj in all(gravity_objects) do
        local dx = mover.x - obj.x
        local dy = mover.y - obj.y
        local d = max(sqrt(dx * dx + dy * dy), 3)
        local force_strength = - attraction_strength / (d * d)
        x = x + dx * force_strength
        y = y + dy * force_strength
    end
    mover.sub_x = mover.sub_x + x
    mover.sub_y = mover.sub_y + y

    sync_subpixel(mover)
end

function sync_subpixel(mover)
    repeat
        if mover.sub_x >= 1 then
            if is_inside_board(mover.x + 1, mover.y) then mover.x = mover.x + 1 end
            mover.sub_x = mover.sub_x - 1
        elseif mover.sub_x <= -1 then
            if is_inside_board(mover.x - 1, mover.y) then mover.x = mover.x - 1 end
            mover.sub_x = mover.sub_x + 1
        elseif mover.sub_y >= 1 then
            if is_inside_board(mover.x, mover.y + 1) then mover.y = mover.y + 1 end
            mover.sub_y = mover.sub_y - 1
        elseif mover.sub_y <= -1 then
            if is_inside_board(mover.x, mover.y - 1) then mover.y = mover.y - 1 end
            mover.sub_y = mover.sub_y + 1
        end
    until abs(mover.sub_x) < 1 and abs(mover.sub_y) < 1
end

function _draw()
    cls()
    local current_map = maps[map_index]
    map(current_map.x, current_map.y, 0, 0, 16, 16)
    if (win_screen > 0) then
        draw_win_screen()
    elseif (victory_screen > 0) then
        draw_victory_screen()
    else
        for entity in all(entities) do draw_entity(entity) end
    end
    draw_points()
end

function target_acquisition(mover, obj1, obj2)
    local x = max(obj1.x, obj2.x) - (abs(obj1.x - obj2.x) / 2)
    local y = max(obj1.y, obj2.y) - (abs(obj1.y - obj2.y) / 2)

    mover.target_x = x
    mover.target_y = y
end

function random_move(entity)
    local moveto = flr(rnd(4))
    if moveto == 1 then
        if entity.x > 2 then entity.x = entity.x - 2 end
    elseif moveto == 2 then
        if entity.x < 119 then entity.x = entity.x + 2 end
    elseif moveto == 3 then
        if entity.y > 2 then entity.y = entity.y - 2 end
    else
        if entity.y < 119 then entity.y = entity.y + 2 end
    end
end

function move_towards_target(entity)

    local x_diff = entity.target_x - entity.x
    local y_diff = entity.target_y - entity.y

    local speed = 2

    if abs(x_diff) > abs(y_diff) then
        if x_diff > 4 then
            if entity.x < 119 then entity.x = entity.x + speed end
        elseif x_diff < 4 then
            if entity.x > 2 then entity.x = entity.x - speed end
        end
    else
        if y_diff > 4 then
            if entity.y < 119 then entity.y = entity.y + speed end
        elseif y_diff < 4 then
            if entity.y > 2 then entity.y = entity.y - speed end
        end
    end
end

function is_blocked(x, y)
    if (x < 0 or x > 127 or y < 0 or y > 127) then return true end
    local sprite = mget(x / 8, y / 8)
    local flag = fget(sprite, 1)
    if flag then
        return true
    else
        return false
    end

end

function is_inside_board(x, y)
    if (x < 0 or x > 119 or y < 0 or y > 119) then return false end
    return true
end

function move_dog(dog, left, right, up, down)
    if left then
        if not (is_blocked(dog.x - 1, dog.y) or is_blocked(dog.x - 1, dog.y + 7)) then
            dog.x = dog.x - 1
        end
    elseif right then
        if not (is_blocked(dog.x + 8, dog.y) or is_blocked(dog.x + 8, dog.y + 7)) then
            dog.x = dog.x + 1
        end
    elseif up then
        if not (is_blocked(dog.x, dog.y - 1) or is_blocked(dog.x + 7, dog.y - 1)) then
            dog.y = dog.y - 1
        end
    elseif down then
        if not (is_blocked(dog.x, dog.y + 8) or is_blocked(dog.x + 7, dog.y + 8)) then
            dog.y = dog.y + 1
        end
    end

end

function _update()
    if (win_screen > 0) then
        win_screen = win_screen - 1
        return
    elseif (victory_screen > 0) then
        victory_screen = victory_screen - 1
        return
    end
    local left = btn(0, 0)
    local right = btn(1, 0)
    local up = btn(2, 0)
    local down = btn(3, 0)
    local cn = btn(4, 1)

    move_dog(dog_two, left, right, up, down)

    local left_two = btn(0, 1)
    local right_two = btn(1, 1)
    local up_two = btn(2, 1)
    local down_two = btn(3, 1)

    move_dog(dog_one, left_two, right_two, up_two, down_two)

    for dog in all(player_entities) do
        for item in all({cat}) do
            local intersecting_pixels = {}
            if count(item_entities) > 0 then
                intersecting_pixels = intersect(dog, item)
            end

            if count(intersecting_pixels) > 0 then
                sfx(3)
                dog.p = dog.p + 1
                if (dog.p >= MAX_POINTS) then
                    reset_hard()
                    victory_screen = VICTORY_SCREEN_DURATION
                    sfx(1)
                else
                    reset_soft()
                    win_screen = WIN_SCREEN_DURATION
                end
            end
        end
        -- wolf
        for item in all({wolf}) do
            local intersecting_pixels = {}
            if count(item_entities) > 0 then
                intersecting_pixels = intersect(dog, item)
            end

            if count(intersecting_pixels) > 0 then
                sfx(3)
                local other_dog = nil

                if dog == dog_one then other_dog = dog_two
                else other_dog = dog_one 
                end

                other_dog.p = other_dog.p + 1
                if (other_dog.p >= MAX_POINTS) then
                    reset_hard()
                    victory_screen = VICTORY_SCREEN_DURATION
                    sfx(1)
                else
                    reset_soft()
                    win_screen = WIN_SCREEN_DURATION
                end
            end
        end
    end

    -- random_move(cat)
    -- TODO: a* to target
    gravity(cat, {dog_one, dog_two}, -11)
    gravity(cat, {mouse}, 7)
    gravity(mouse, {cat}, -15)
    gravity(mouse, {wolf}, 10)
    gravity(wolf, {mouse}, -7)
    gravity(wolf, {dog_one, dog_two}, 8)
end
