pico-8 cartridge // http://www.pico-8.com
version 32
__lua__


dog_sprite_one= {x=8,y=0,w=8,h=8}
dog_sprite_two={x=16,y=0,w=8,h=8}
cat_sprite={x=0,y=0,w=8,h=8}
sprites={ cat_sprite, dog_sprite_one, dog_sprite_two}

dog_one = {x=120,y=120, sprite=dog_sprite_one}
dog_two = {x=0, y=0, sprite=dog_sprite_two}
cat = {x=60, y=60, sprite=cat_sprite}

entities = {dog_one, dog_two, cat}
player_entities = {dog_one, dog_two}
item_entities = {cat}

function draw_entity(entity)
  if (entity.sprite) then
    sspr(entity.sprite.x, entity.sprite.y, entity.sprite.w, entity.sprite.h, entity.x, entity.y)
  else
    pset(entity.x, entity.y, entity.color)
  end
end


function _init()
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

  return not ((b1.x >= b2.x + b2.w) or (b1.x + b1.w <= b2.x) or (b1.y >= b2.y + b2.h) or (b1.y + b1.h <= b2.y))
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


function _draw()
	cls()
	map(0,0,0,0,16,16)
 for entity in all(entities)
  do draw_entity(entity) 
 end
	
end

function random_move(entity)
	local moveto = flr(rnd(4))
	if moveto == 1 then
			if entity.x > 2 then
					entity.x = entity.x - 2
			end
	elseif moveto == 2 then
			if entity.x < 119 then
				entity.x = entity.x + 2
			end
	elseif moveto == 3 then
			if entity.y > 2 then
				entity.y = entity.y - 2
			end
	else 
			if entity.y < 119 then
				entity.y = entity.y + 2
			end
	end
end

function is_blocked(x,y)
	local sprite = mget(x,y)
	local flag = fget(sprite, 1)
	
	if flag then
		return true
	else
		return false
	end

end


function move_dog(dog, left, right, up, down)
	
	if left then
			if not is_blocked(dog.x-1, dog.y) then
    dog.x = dog.x - 1
   end
 elseif right then
 		if not is_blocked(dog.x+1, dog.y) then
    dog.x = dog.x + 1
   end
 elseif up then
 		if not is_blocked(dog.x, dog.y-1) then
    dog.y = dog.y - 1
   end
 elseif down then
 		if not is_blocked(dog.x, dog.y+1) then
    dog.y = dog.y + 1
   end
 end

end

function _update()

	local left=btn(0, 0)
	local right=btn(1, 0)
	local up=btn(2, 0)
	local down=btn(3, 0)
	local cn = btn(4, 1)
	
	move_dog(dog_one, left, right, up, down)
	
	local left_two=btn(0, 1)
	local right_two=btn(1, 1)
	local up_two=btn(2, 1)
	local down_two=btn(3, 1)
	
 move_dog(dog_two, left_two, right_two, up_two, down_two)
	
	for dog in all(player_entities) do
		for item in all(item_entities) do
			local intersecting_pixels = {}
		 if count(item_entities) > 0 then
		 	intersecting_pixels = intersect(dog, item)
		 end
 
		 if count(intersecting_pixels) > 0 then
		 	sfx(3)
		 	del(item_entities, item)
		 	del(entities, item)
		 end
			
		end
	end
	
 random_move(cat)

end
__gfx__
01000010000770000040040033335353335335330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1001e1067777600440044033335553335535530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1111e16677776604ffff4035550505335555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166577566041ff14035555e55355a5a530700007000000000000000000000000000000000000000000000000000000000000000000000000000000000
1191191166777766444ff44455555555335555537777777700000000000000000000000000000000000000000000000000000000000000000000000000000000
111ee111007557000445544055555553355707550700007000000000000000000000000000000000000000000000000000000000000000000000000000000000
01666610007777000044440035555333333777330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00166100000ee0000008800033333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55444454333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44454444333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444454333383333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
445444443338a83333333333333333c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444445438338333333333333333c333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
544444448a83b333333333333c73373c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444554453833b333333333333733c3c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
544444443b33333333333333333c3733000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333bb333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33b8bb33336666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbb8bb366665660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b8bbbbbb666655650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbb8666666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8bbb8bb3666665550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33344433565555330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33344433355333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33344433b33bbb3bcccccc1300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33344433ccc333cc3ccccc1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33344433ccc1111cb3cccc1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33344433ccccccccb3c1ccc300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33344433ccc1c11133c1ccc300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333c1cccccc3cc1ccc300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333331ccccccc3cccccb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333b3b333bbccccccc300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000001000000000000000000000000000000010100000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121211121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212101010101010121120121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1221121212101212121230122012121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212101212121212213012121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212101212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1211121112121212121213121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212111212121212121312121010101012121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121211121212111212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1220121212121312042112121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1220122012121212212112121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1330123012121212121212111212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131231313131321212121212111212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212321212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212031212121212321111121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212321212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1203121212313131121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000d62010630136501565008650006000c65014650176501b6500e650176000f650186501c6501e650006000c65013650176501965007650006001b6501e65021650246500b6301f60023f0023f0023f00
0001000026120291202c1202f120311503215034150381503915030150281501f1501015008150021500015030d0031d0033d0000000000000000000000000000000000000000000000000000000000000000000
0001000037150381503a1503b1503b150391503715035150321500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

