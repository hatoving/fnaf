import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "sprite.lua"
import "math.lua"

local game_ui_inited = false

local power_imgtable = nil
local hour_imgtable = nil

local power_spr = nil
local hour_spr = nil

function set_up_game_ui()
  power_imgtable = playdate.graphics.imagetable.new("gfx/office/office_powerleft")
  hour_imgtable = playdate.graphics.imagetable.new("gfx/office/office_hour")

  power_spr = create_sprite_from_image(power_imgtable:getImage(5), 33, 27)
  hour_spr = create_sprite_from_image(hour_imgtable:getImage(1), 363, 27)

  game_ui_inited = true
end

function clean_game_ui()
  power_spr = clean_sprite(power_spr)
  hour_spr = clean_sprite(hour_spr)

  power_imgtable = nil
  hour_imgtable = nil

  game_ui_inited = false
end

function update_game_ui(power, hour)
  if not game_ui_inited then
    set_up_game_ui()
  end

  power_spr:setImage(power_imgtable:getImage(power + 1))
  hour_spr:setImage(hour_imgtable:getImage(hour + 1))
end