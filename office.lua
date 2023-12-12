import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "sprite.lua"
import "math.lua"

local office_inited = false

local office_spr = nil

--region Doors

local office_door_left_spr = nil
local office_door_right_spr = nil

local office_door_close_table = nil

local office_door_frame_left = 1
local office_door_frame_right = 1

local left_door_closed = false
local right_door_closed = false

local door_close = nil

--endregion
--region Monitor

local office_monitor_table = nil
local office_monitor_spr = nil

local office_monitor_frame = 1

--endregion

function set_up_office()
  office_spr = create_sprite("gfx/office/office")

  office_door_close_table = playdate.graphics.imagetable.new("gfx/office/office_ldoor_close")

  door_close = playdate.sound.sampleplayer.new("aud/door")
  
  office_door_left_spr = create_sprite_from_image(office_door_close_table:getImage(1), 35, 120)
  office_door_right_spr = create_sprite_from_image(office_door_close_table:getImage(1), 400 - 35, 120)

  office_monitor_table = playdate.graphics.imagetable.new("gfx/office/office_monitor")
  office_monitor_spr = create_sprite_from_image(office_monitor_table:getImage(1), 200, 120)

  office_inited = true
end

function clean_office()
  office_spr = clean_sprite(office_spr)

  office_door_left_spr = clean_sprite(office_door_left_spr)
  office_door_right_spr = clean_sprite(office_door_right_spr)

  office_door_close_table = nil
  door_close = nil

  office_door_frame_left = 1
  office_door_frame_right = 1

  left_door_closed = false
  right_door_closed = false

  office_monitor_spr = clean_sprite(office_monitor_spr)
  office_monitor_table = nil

  office_monitor_frame = 1

  office_inited = false 
end

function update_office()
  if not office_inited then
    set_up_office()
  end

  office_door_frame_left = math.clamp(office_door_frame_left, 1, 14)
  office_door_frame_right = math.clamp(office_door_frame_right, 1, 14)

  office_monitor_frame = math.clamp(office_monitor_frame, 1, 10)

  office_door_left_spr:setImage(office_door_close_table:getImage(math.floor(office_door_frame_left)))
  office_door_right_spr:setImage(office_door_close_table:getImage(math.floor(office_door_frame_right)))
  
  office_door_right_spr:setImageFlip(1)

  if left_door_closed then 
    office_door_frame_left += 1.5
  else 
    office_door_frame_left -= 1.5
  end

  if right_door_closed then 
    office_door_frame_right += 1.5
  else 
    office_door_frame_right -= 1.5
  end

  if playdate.buttonIsPressed(playdate.kButtonLeft) then
    if playdate.buttonJustPressed(playdate.kButtonB) then
      if left_door_closed then 
        left_door_closed = false
        power_used -= 1
      else 
        left_door_closed = true
        power_used += 1
      end
      door_close:play()
    end
  elseif playdate.buttonIsPressed(playdate.kButtonRight) then
    if playdate.buttonJustPressed(playdate.kButtonB) then
      if right_door_closed then 
        right_door_closed = false
        power_used -= 1
      else 
        right_door_closed = true
        power_used += 1
      end
      door_close:play()
    end
  end

  if playdate.buttonJustPressed(playdate.kButtonUp) and not monitor_up then
    monitor_up = true
    sfx_monitor_down:play()

    office_monitor_spr:setStencilPattern(1, playdate.graphics.image.kDitherTypeBayer8x8)
    power_used += 1
  end

  if monitor_up then
    office_monitor_frame += 1.4
    if office_monitor_frame < 11 then office_monitor_spr:setImage(office_monitor_table:getImage(math.floor(office_monitor_frame))) end

    if office_monitor_frame > 10 then
      print("cams")
      in_office = false
    end
  else
    office_monitor_frame -= 1.4
    if math.floor(office_monitor_frame) > 1 then office_monitor_spr:setImage(office_monitor_table:getImage(math.floor(office_monitor_frame))) end
    if math.floor(office_monitor_frame) == 1 then office_monitor_spr:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8) end
  end
end