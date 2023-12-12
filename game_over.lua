import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "sprite.lua"
import "math.lua"

local game_over_inited = false
local menu_static = nil

local game_over_spr = nil
local game_over_alpha = 0

local to_menu = false

function set_up_game_over()
  gfx_static_spr:add()
  menu_static = playdate.sound.sampleplayer.new("aud/static")

  game_over_alpha = 0

  game_over_spr = create_sprite("gfx/game_over", 200, 120)
  game_over_spr:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)

  menu_static:play(1)
  game_over_inited = true
end

function clean_game_over()
  gfx_static_animator.paused = false

  menu_static:stop()
  menu_static = nil

  game_over_alpha = 0
  to_menu = false

  game_over_spr = clean_sprite(game_over_spr)
  game_over_inited = false 
end

function update_game_over()
  if not game_over_inited then
    set_up_game_over()
  end

  if not menu_static:isPlaying() and not to_menu then
    gfx_static_animator.paused = true
    game_over_spr:setZIndex(gfx_static_spr:getZIndex() + 1)

    game_over_alpha += 0.01

    if playdate.buttonJustPressed(playdate.kButtonA) then
      to_menu = true
    end
  end
  if to_menu then
    gfx_static_spr:remove()
    game_over_alpha -= 0.01

    if game_over_alpha <= 0 then
      clean_game_over()
      current_scene = SCENES.MENU
    end
  end

  if game_over_spr ~= nil then
    game_over_spr:setStencilPattern(game_over_alpha, playdate.graphics.image.kDitherTypeBayer8x8)
  end

  playdate.timer.updateTimers()
  playdate.graphics.sprite.update()
end