import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "math.lua"

local warning_inited = false

local warning_spr = nil
local warning_alpha = 0

local timer = 0

function set_up_warning()
  warning_alpha = 0
  timer = 0

  warning_spr = create_sprite("gfx/warning", 200, 120)
  warning_spr:add()

  warning_inited = true
end

function clean_warning()
  warning_spr:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)
  warning_spr = clean_sprite(warning_spr)

  warning_alpha = 0
  timer = 0

  warning_inited = false 
end

function update_warning()
  playdate.graphics.clear(playdate.graphics.kColorBlack)

  if not warning_inited then
    set_up_warning()
  end

  if timer < (fps * 5) then
    warning_alpha += 0.05
  elseif timer > (fps * 5) then
    warning_alpha -= 0.05
  end

  warning_alpha = math.clamp(warning_alpha, 0, 1)
  warning_spr:setStencilPattern(warning_alpha, playdate.graphics.image.kDitherTypeBayer8x8)

  timer += 1

  if timer > (fps * 6) then
    clean_warning()
    current_scene = SCENES.MENU
  end

  if playdate.buttonJustPressed(playdate.kButtonA) and timer < (fps * 5) then
    timer = fps * 5
  end

  playdate.timer.updateTimers()
  playdate.graphics.sprite.update()
end