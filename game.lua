import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "math.lua"

import "office.lua"
import "cameras.lua"
import "game_ui.lua"

local game_inited = false

power_left = 100
power_timer = 8
power_used = 0

hour = 0
hour_timer = 0

local fan_buzz = nil
local phone_call = nil

local night_clear_bg = nil

local night_clear_nums = nil
local night_clear_nums_y = 129

local night_clear_timer = 0

local chimes = nil

monitor_up = false
in_office = true

local survived = false
local clear_screen_alpha = 0

--region AI
--This is where the actual game logic gets programmed.

local freddy_ai = 0
local bonnie_ai = 0
local chica_ai = 0
local foxy_ai = 0

--endregion

function set_up_game()
  game_inited = true

  monitor_up = false
  in_office = true

  hour_timer = 90 * fps
  power_timer = 8 * fps

  clear_screen_alpha = 0

  night_clear_bg = playdate.graphics.image.new("gfx/night_clear_am")
  night_clear_nums = playdate.graphics.image.new("gfx/night_clear_nums")

  fan_buzz = playdate.sound.sampleplayer.new("aud/fan")

  phone_call = playdate.sound.fileplayer.new()
  phone_call:load("aud/voiceovers/" .. current_data.current_night)

  chimes = playdate.sound.fileplayer.new()
  chimes:load("aud/night_clear")

  phone_call:play(1)
  fan_buzz:play(0)
end

function clean_game()
  clean_office()
  clean_cameras()
  clean_game_ui()

  night_clear_bg = nil
  night_clear_nums = nil

  night_clear_nums_y = 129
  night_clear_timer = 0

  survived = false

  hour = 0
  power_left = 100
  power_used = 0

  hour_timer = 90 * fps
  power_timer = 8 * fps

  monitor_up = false
  in_office = true

  fan_buzz:stop()
  fan_buzz = nil

  phone_call:stop()
  phone_call = nil

  chimes:stop()
  chimes = nil

  game_inited = false
end

function update_game_status()
  hour_timer -= 1
  power_timer -= 1

  if hour_timer < 0 then
    hour_timer = 90 * fps
    hour += 1
  end

  local case = {
    [0] = function() 
      return 8
    end,
    [1] = function() 
      return 4.5
    end,
    [2] = function() 
      return 2.3
    end,
    [3] = function() 
      return 1.1
    end,
    [4] = function() 
      return 0.6
    end
  }

  if power_timer <= 0 then
    if case[power_used] then
      power_timer = case[power_used]() * fps
    end
    power_left -= 1
  end
end

function update_game()
  if not game_inited then
    set_up_game()
  end

  if not survived then
    update_game_status()

    if in_office then
      update_office()
    else
      show_cameras()
      update_cameras()
    end

    if playdate.buttonJustPressed(playdate.kButtonA) then
      power_left = 0
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
      hour = 6
    end
  end

  power_used = math.clamp(power_used, 0, 4)
  hour = math.clamp(hour, 0, 6)

  update_game_ui(power_used, hour)

  if hour == 6 then
    if not survived then
      chimes:play(1)
      survived = true
    end

    fan_buzz:stop()
    phone_call:stop()
  end

  if power_left < 0 then
    global_hour = hour
    global_hour_timer = hour_timer

    clean_game()
    gfx_static_spr:remove()

    current_scene = SCENES.POWER_OUT
  end

  playdate.timer.updateTimers()
  playdate.graphics.sprite.update()

  local mode = playdate.graphics.getImageDrawMode()

  -- draw misc. tex
  set_pattern_and_mode(0.5, playdate.graphics.kDrawModeFillBlack)
  playdate.graphics.fillRect(10, 42, 47, 12)
  set_pattern_and_mode(1, playdate.graphics.kDrawModeFillWhite)

  playdate.graphics.drawText(power_left .. "%", 13, 42)
  playdate.graphics.drawText("Night " .. current_data.current_night, 341, 12)

  playdate.graphics.setImageDrawMode(mode)

  if survived then
    print(night_clear_timer)
    night_clear_timer += 1
    gfx_static_animator.paused = true

    night_clear_nums_y = math.clamp(night_clear_nums_y, 112, 129)

    if night_clear_timer < 3.5 * fps then
      clear_screen_alpha += 0.01
    elseif night_clear_timer > 3.5 * fps then
      night_clear_nums_y -= 0.2
    end

    set_pattern_and_mode(clear_screen_alpha, playdate.graphics.kDrawModeFillBlack)
    playdate.graphics.fillRect(0, 0, 400, 240)
    set_pattern_and_mode(clear_screen_alpha, mode)

    night_clear_nums:drawCentered(192, night_clear_nums_y)
    night_clear_bg:drawCentered(200, 120)

    playdate.graphics.setStencilPattern(1)
  end

  if night_clear_timer > 11.5 * fps and survived then
    clean_game()

    gfx_static_animator.paused = false
    gfx_static_spr:remove()

    if current_data.current_night ~= 5 then
      current_data.current_night += 1
    end

    playdate.datastore.write(current_data, "save", true)
    current_scene = SCENES.NIGHT_SCREEN
  end
end