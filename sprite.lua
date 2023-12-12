import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

function create_sprite(path, x, y)
  if x == nil then x = 200 end
  if y == nil then y = 120 end

  local img = playdate.graphics.image.new(path)
  assert(img)

  local spr = playdate.graphics.sprite.new(img)
  spr:moveTo(x, y)
  spr:add()

  return spr
end

function create_sprite_from_image(image, x, y)
  if x == nil then x = 200 end
  if y == nil then y = 120 end
  
  local spr = playdate.graphics.sprite.new()
  spr:setImage(image)

  spr:moveTo(x, y)
  spr:add()

  return spr
end

function clean_sprite(sprite)
  if sprite ~= nil then
    sprite:remove()
    sprite = nil
    return sprite
  end
  return nil
end

function is_sprite_in_dlist(sprite) 
  for i = 1, playdate.graphics.sprite.spriteCount() do
    if playdate.graphics.sprite.getAllSprites()[i] == sprite then
      print("Found sprite, {0}", i)
      return true
    else return false end
  end
end

function set_pattern_and_mode(level, color)
  playdate.graphics.setStencilPattern(level)
  playdate.graphics.setImageDrawMode(color)
end