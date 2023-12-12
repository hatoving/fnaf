import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "sprite.lua"
import "math.lua"

local power_out_inited = false

local freddy_table = nil
local jumpscare_table = nil

local freddy_spr = nil
local jumpscare_spr = nil

local survived = false
local clear_screen_alpha = 0

local night_clear_bg = nil

local night_clear_nums = nil
local night_clear_nums_y = 129

local night_clear_timer = 0

local power_out = nil
local chimes = nil

local hour = -1
local hour_timer = -1

--region Jumpscare

local steps = nil
local music_box = nil
local jumpscare = nil
local freddy_disa = nil

local wait_before_mbox_timer = 0
local wait_before_darkness_timer = 0
local wait_before_jumpscare_timer = 0

local jumpscare_timer = 0
local jumpscare_frame = 1

local general_timer = 0
local rand_num = 1

--endregion

function set_up_power_out()
  hour = global_hour
  hour_timer = global_hour_timer

  clear_screen_alpha = 0

  night_clear_bg = playdate.graphics.image.new("gfx/night_clear_am")
  night_clear_nums = playdate.graphics.image.new("gfx/night_clear_nums")

  freddy_table = playdate.graphics.imagetable.new("gfx/office/office_power_out")
  jumpscare_table = playdate.graphics.imagetable.new("gfx/jumps/freddy/jumps_freddy_lightsout")

  freddy_spr = create_sprite_from_image(freddy_table:getImage(2), 45, 105)
  freddy_spr:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)

  jumpscare_spr = create_sprite_from_image(jumpscare_table:getImage(1), 200, 120)
  jumpscare_spr:remove()

  chimes = playdate.sound.fileplayer.new()
  chimes:load("aud/night_clear")

  steps = playdate.sound.fileplayer.new()
  steps:load("aud/steps")

  jumpscare = playdate.sound.fileplayer.new()
  jumpscare:load("aud/xscream")

  music_box = playdate.sound.fileplayer.new()
  music_box:load("aud/music_box")

  power_out = playdate.sound.fileplayer.new()
  power_out:load("aud/power_out")

  freddy_disa = playdate.sound.sampleplayer.new("aud/disap")

  power_out:play(1)

  wait_before_mbox_timer = math.random(20) * fps
  wait_before_jumpscare_timer = math.random(20) * fps
  wait_before_darkness_timer = math.random(20) * fps

  jumpscare_frame = 1
  jumpscare_timer = 0

  general_timer = 0

  power_out_inited = true
end

function clean_power_out()
  night_clear_bg = nil
  night_clear_nums = nil

  night_clear_nums_y = 129
  night_clear_timer = 0

  freddy_spr = clean_sprite(freddy_spr)
  freddy_table = nil

  jumpscare_spr = clean_sprite(jumpscare_spr)
  jumpscare_table = nil

  survived = false

  hour = -1
  hour_timer = -1

  chimes:stop()
  chimes = nil

  jumpscare:stop()
  jumpscare = nil

  music_box:stop()
  music_box = nil

  steps:stop()
  steps = nil

  power_out:stop()
  power_out = nil

  wait_before_mbox_timer = math.random(5, 20) * fps
  wait_before_jumpscare_timer = math.random(5, 20) * fps
  wait_before_darkness_timer = math.random(5, 20) * fps

  power_out_inited = false 
end

function update_power_out()
  if not power_out_inited then
    set_up_power_out()
  end

    --This whole thing is so bad. There is definitely a better way I could've implemented this... oh well. Too bad!
  if not survived then
    jumpscare_frame = math.clamp(jumpscare_frame, 1, 19)

    wait_before_mbox_timer -= 1
    general_timer += 1

    rand_num = math.random(1, 2)

    if general_timer > 3 * fps and not steps:isPlaying() and wait_before_mbox_timer > 0 then
      steps:play(1)
    end

    if wait_before_mbox_timer <= 0 then
      if not music_box:isPlaying() and wait_before_darkness_timer > 0 then
        music_box:play(1)
      end

      steps:stop()

      freddy_spr:setStencilPattern(1, playdate.graphics.image.kDitherTypeBayer8x8)
      freddy_spr:setImage(freddy_table:getImage(rand_num))

      wait_before_darkness_timer -= 1

      if wait_before_darkness_timer <= 25 and wait_before_darkness_timer > 0 then
        if not freddy_disa:isPlaying() then
          freddy_disa:play(1)
        end
      end
      if wait_before_darkness_timer <= 0 then
        music_box:stop()
        freddy_disa:stop()

        freddy_spr:remove()

        wait_before_jumpscare_timer -= 1

        if wait_before_jumpscare_timer <= 0 then
          if not jumpscare:isPlaying() then
            jumpscare:play(1)
            jumpscare_spr:add()
          end

          jumpscare_timer += 1
          jumpscare_frame += 1

          jumpscare_spr:setImage(jumpscare_table:getImage(jumpscare_frame))

          if jumpscare_timer > 0.55 * fps then
            clean_power_out()
            current_scene = SCENES.GAME_OVER
          end
        end
      end
    end
  end

  hour_timer -= 1
  power_timer -= 1

  if hour_timer < 0 then
    hour_timer = 90 * fps
    hour += 1
  end

  if hour == 6 and not survived then
    music_box:stop()
    steps:stop()
    power_out:stop()
    jumpscare:stop()

    chimes:play(1)
    survived = true
  end

  playdate.timer.updateTimers()
  playdate.graphics.sprite.update()

  if survived then
    night_clear_timer += 1
    gfx_static_animator.paused = true

    night_clear_nums_y = math.clamp(night_clear_nums_y, 112, 129)

    if night_clear_timer < 3.5 * fps then
      clear_screen_alpha += 0.01
    elseif night_clear_timer > 3.5 * fps then
      night_clear_nums_y -= 0.2
    end

    local mode = playdate.graphics.getImageDrawMode()

    set_pattern_and_mode(clear_screen_alpha, playdate.graphics.kDrawModeFillBlack)
    playdate.graphics.fillRect(0, 0, 400, 240)
    set_pattern_and_mode(clear_screen_alpha, mode)
    
    night_clear_nums:drawCentered(192, night_clear_nums_y)
    night_clear_bg:drawCentered(200, 120)

    playdate.graphics.setStencilPattern(1)
  end

  if night_clear_timer > 11.5 * fps and survived then
    clean_power_out()
    
    gfx_static_animator.paused = false
    gfx_static_spr:remove()

    if current_data.current_night ~= 5 then
      current_data.current_night += 1
    end

    playdate.datastore.write(current_data, "save", true)
    current_scene = SCENES.NIGHT_SCREEN
  end
end