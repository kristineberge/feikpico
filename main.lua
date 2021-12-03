MAX_POINTS = 2
dog_sprite_one = {x = 8, y = 0, w = 8, h = 8}
dog_sprite_two = {x = 16, y = 0, w = 8, h = 8}
cat_sprite = {x = 0, y = 0, w = 8, h = 8}
mouse_sprite = {x = 24, y = 0, w = 8, h = 8}
sprites = {cat_sprite, mouse_sprite, dog_sprite_one, dog_sprite_two}

dog_one = {sx = 0, sy = 0, p = 0, m = 1, sprite = dog_sprite_one}
dog_two = {sx = 120, sy = 120, p = 0, m = 1, sprite = dog_sprite_two}
cat = {sx = 60, sy = 60, sprite = cat_sprite}
mouse = {sx = 60, sy = 120, sprite = mouse_sprite}

entities = {dog_one, dog_two, cat, mouse}
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
    end
end

function reset_hard()
    for e in all(entities) do
        e.x = e.sx
        e.y = e.sy
        e.p = 0
    end
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

function gravity(mover, gravity_objects)
    local x = mover.x
    local y = mover.y

    for obj in all(gravity_objects) do
        local dx = mover.x - obj.x
        local dy = mover.y - obj.y
        local d = sqrt(dx * dx + dy * dy) / obj.m
        x = mover.x + dx * d
        y = mover.y + dy * d
    end

    if (not is_blocked(x, y)) then
        mover.x = x
        mover.y = y
    end

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
        for item in all(item_entities) do
            local intersecting_pixels = {}
            if count(item_entities) > 0 then
                intersecting_pixels = intersect(dog, item)
            end

            if count(intersecting_pixels) > 0 then
                sfx(3)
                dog.p = dog.p + 1
                map_index = ((map_index + 1) % count(maps)) + 1
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
    end

    random_move(cat)
    gravity(cat, {dog_one, dog_two})

end
