import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/timer"

-- TODO: Maybe create classes for each scene? This is fucking stupid
import "warning.lua"
import "menu.lua"
import "night_screen.lua"
import "game.lua"
import "power_out.lua"
import "game_over.lua"

fps = 30

playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
playdate.setCrankSoundsDisabled(true)
playdate.display.setRefreshRate(fps)

system_menu = playdate.getSystemMenu()

--#region Static

gfx_static_table = playdate.graphics.imagetable.new("gfx/static")
gfx_static_animator = playdate.graphics.animation.loop.new(35, gfx_static_table, true)

gfx_static_spr = playdate.graphics.sprite.new(gfx_static_animator:image())
gfx_static_spr:moveTo(200, 120)

-------------------------------------------------------

gfx_d_static_table = playdate.graphics.imagetable.new("gfx/devided_static")
gfx_d_static_animator = playdate.graphics.animation.loop.new(10, gfx_d_static_table, false)

gfx_d_static_spr = playdate.graphics.sprite.new(gfx_d_static_animator:image())
gfx_d_static_spr:moveTo(200, 120)

--#endregion

sfx_blip = playdate.sound.sampleplayer.new("aud/blip")
sfx_monitor_down = playdate.sound.sampleplayer.new("aud/monitor_down")

consolas_font = playdate.graphics.font.new("fnt/consolas")
playdate.graphics.setFont(consolas_font)

game_data = {
  current_night = 1,
  stars = 0
}

current_data = game_data

global_hour = -1
global_hour_timer = -1

local enum SCENES = {
  WARNING = 1,
  MENU = 2,
  NIGHT_SCREEN = 3,
  GAME = 4,
  POWER_OUT = 5,
  GAME_OVER = 6,
  CUSTOM_NIGHT = 7
}

current_scene = SCENES.WARNING

settings_menu_item = nil
back_to_title_menu_item = nil

if playdate.file.exists("save.json") then
  current_data = playdate.datastore.read("save")
else
  current_data.current_night = 1
  current_data.stars = 0

  playdate.datastore.write(current_data, "save", true)
end

function clean_up()
  if current_scene == SCENES.WARNING then
    clean_warning()
  elseif current_scene == SCENES.MENU then
    clean_menu()
  elseif current_scene == SCENES.NIGHT_SCREEN then
    clean_night_screen()
  elseif current_scene == SCENES.GAME then
    clean_game()
  elseif current_scene == SCENES.POWER_OUT then
    clean_power_out()
  elseif current_scene == SCENES.GAME_OVER then
    clean_game_over()
  end
end

function playdate.update()
  gfx_static_spr:setImage(gfx_static_animator:image())
  gfx_d_static_spr:setImage(gfx_d_static_animator:image())

  local update_case = {
    [SCENES.WARNING] = function ()
      update_warning()
    end,
    [SCENES.MENU] = function ()
      update_menu()
    end,
    [SCENES.NIGHT_SCREEN] = function ()
      update_night_screen()
    end,
    [SCENES.GAME] = function ()
      update_game()
    end,
    [SCENES.POWER_OUT] = function ()
      update_power_out()
    end,
    [SCENES.GAME_OVER] = function ()
      update_game_over()
    end
  }

  if update_case[current_scene] then
    update_case[current_scene]()
  end

  playdate.drawFPS(0, 0)
end

function playdate.gameWillTerminate()
  clean_up()
end

function playdate.deviceWillLock()
  sfx_monitor_down:play()
end
