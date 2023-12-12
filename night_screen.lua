import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "sprite.lua"
import "math.lua"

local night_screen_inited = false

local night_spr = nil
local loading_spr = nil

local timer = 0
local alpha = 1

function set_up_night_screen()
  if back_to_menu_item == nil then
    back_to_menu_item, error = system_menu:addMenuItem("back to title", function()
      print("Back to title!")
  
      clean_up()
      current_scene = SCENES.MENU

      system_menu:removeMenuItem(back_to_menu_item)
      back_to_menu_item = nil
    end)
  end

  sfx_blip:play()
  
  night_spr = create_sprite("gfx/nights/" .. current_data.current_night, 200, 120)
  loading_spr = create_sprite("gfx/loading", 371, 211)

  gfx_d_static_spr:add()
  gfx_d_static_animator.frame = 1

  timer = fps * 2.5
  night_screen_inited = true
end

function clean_night_screen()
  night_spr = clean_sprite(night_spr)
  loading_spr = clean_sprite(loading_spr)

  timer = 0
  alpha = 1

  gfx_d_static_spr:remove()
  night_screen_inited = false 
end

function update_night_screen()
  if not night_screen_inited then
    set_up_night_screen()
  end

  timer -= 1

  if timer < 0 then
    timer = 0
    alpha -= 0.05
  end

  night_spr:setStencilPattern(alpha, playdate.graphics.image.kDitherTypeBayer8x8)

  if alpha < -1 then
    clean_night_screen()
    current_scene = SCENES.GAME
  end

    playdate.timer.updateTimers()
    playdate.graphics.sprite.update()
end