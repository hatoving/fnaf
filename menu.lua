import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "math.lua"
import "sprite.lua"

local menu_inited = false
local new_game = false

--#region Sprites

local menu_select_spr = nil

local menu_selected = 0
local menu_max_selected = 3

local menu_select_y = 152.0

local menu_freddy_spr = nil
local menu_freddy_imgtable = nil

local menu_stars_spr = nil
local menu_stars_imgtable = nil

local newspaper_spr = nil

local newspaper_alpha = 0
local sprites_alpha = 1

local menu_logo_spr = nil
local menu_credits_spr = nil

local menu_ng_spr = nil

local menu_continue_spr = nil
local menu_continue_night_spr = nil

local menu_night6_spr = nil
local menu_custom_spr = nil

--#endregion
--#region Sounds

local menu_bgm = nil
local menu_static = nil

local freddy_timer = 0
local freddy_duration = 0

local ng_timer = 0

--#endregion

function set_up_menu()
  settings_menu_item, error = system_menu:addMenuItem("settings", function()
    print("Settings!")
  end)

  if playdate.file.exists("save.json") then
    current_data = playdate.datastore.read("save")
  end

  menu_freddy_imgtable = playdate.graphics.imagetable.new("gfx/menu/menu_freddy")
  menu_stars_imgtable = playdate.graphics.imagetable.new("gfx/menu/menu_stars")

  menu_freddy_spr = create_sprite_from_image(menu_freddy_imgtable:getImage(1), 200, 120)
  menu_stars_spr = create_sprite_from_image(menu_stars_imgtable:getImage(1), 44, 122)

  gfx_static_spr:add()

  menu_logo_spr = create_sprite("gfx/menu/menu_logo", 79, 70)
  menu_credits_spr = create_sprite("gfx/menu/menu_credits", 310, 225)

  menu_ng_spr = create_sprite("gfx/menu/menu_newgame", 70, 150)

  menu_continue_spr = create_sprite("gfx/menu/menu_continue", 70, 173)
  menu_continue_night_spr = create_sprite("gfx/menu/nights/" .. current_data.current_night, 46, 185)

  menu_night6_spr = create_sprite("gfx/menu/menu_night6", 76, 197)
  menu_custom_spr = create_sprite("gfx/menu/menu_custom", 92, 220)
  
  menu_select_spr = create_sprite("gfx/menu/menu_select", 156, 132)
  newspaper_spr = create_sprite("gfx/newspaper", 200, 120)

  gfx_d_static_spr:add()
  gfx_d_static_animator.frame = 1

  menu_static = playdate.sound.sampleplayer.new("aud/static")

  menu_bgm = playdate.sound.fileplayer.new()
  menu_bgm:load("aud/menu")

  menu_static:play(1)
  menu_bgm:play(0)

  selected = 0

  menu_inited = true
  new_game = false

  newspaper_alpha = 0
  sprites_alpha = 1

  ng_timer = 0

  freddy_timer = fps * math.random(4)
  freddy_duration = fps * math.random(2)
end

function clean_menu_sprites()
  menu_freddy_spr = clean_sprite(menu_freddy_spr)
  menu_freddy_imgtable = nil

  menu_stars_spr = clean_sprite(menu_stars_spr)
  menu_stars_imgtable = nil

  menu_logo_spr = clean_sprite(menu_logo_spr)
  menu_credits_spr = clean_sprite(menu_credits_spr)

  menu_ng_spr = clean_sprite(menu_ng_spr)

  menu_continue_spr = clean_sprite(menu_continue_spr)
  menu_continue_night_spr = clean_sprite(menu_continue_night_spr)

  menu_night6_spr = clean_sprite(menu_night6_spr)
  menu_custom_spr = clean_sprite(menu_custom_spr)
  
  menu_select_spr = clean_sprite(menu_select_spr)
end

function cleam_menu_vars()
  menu_static:stop()
  menu_static = nil

  menu_bgm:stop()
  menu_bgm = nil

  menu_inited = false
  new_game = false
  
  newspaper_alpha = 0
  sprites_alpha = 1

  ng_timer = 0
  freddy_timer = 0
end


function clean_menu()
  clean_menu_sprites()
  newspaper_spr = clean_sprite(newspaper_spr)

  cleam_menu_vars()

  system_menu:removeMenuItem(settings_menu_item)
  settings_menu_item = nil
  
  gfx_d_static_spr:remove()
  gfx_static_spr:remove()
end

function update_menu()
  if not menu_inited then
    set_up_menu()
  end

  if not new_game then
    if current_data.stars < 1 then
      menu_max_selected = 1
      menu_stars_spr:setImage(menu_stars_imgtable:getImage(1))

      menu_night6_spr:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)
      menu_custom_spr:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)
    elseif current_data.stars < 2 then
      menu_max_selected = 2
      menu_stars_spr:setImage(menu_stars_imgtable:getImage(2))

      menu_night6_spr:setStencilPattern(1, playdate.graphics.image.kDitherTypeBayer8x8)
      menu_custom_spr:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)
    elseif current_data.stars >= 2 then
      menu_max_selected = 3
      menu_stars_spr:setImage(menu_stars_imgtable:getImage(current_data.stars + 1))

      menu_night6_spr:setStencilPattern(1, playdate.graphics.image.kDitherTypeBayer8x8)
      menu_custom_spr:setStencilPattern(1, playdate.graphics.image.kDitherTypeBayer8x8)
    end

    if playdate.buttonJustPressed(playdate.kButtonUp) and menu_selected > 0 then
      menu_selected -= 1
      sfx_blip:play()
    elseif playdate.buttonJustPressed(playdate.kButtonDown) and menu_selected < menu_max_selected then
      menu_selected += 1
      sfx_blip:play()
      end
  
    if menu_selected == 0 then
      menu_continue_night_spr:remove()
      if playdate.buttonJustPressed(playdate.kButtonA) then
        current_data.current_night = 1
        current_data.stars = 0

        new_game = true
      end
    elseif menu_selected == 1 then
      menu_continue_night_spr:add()

      if playdate.buttonJustPressed(playdate.kButtonA) then
        clean_menu()
        current_scene = SCENES.NIGHT_SCREEN
      end
    else
      menu_continue_night_spr:remove()
    end
  elseif new_game then
    newspaper_alpha = math.clamp(newspaper_alpha, 0, 1)
    gfx_static_animator.paused = true
    ng_timer += 1

    if ng_timer < (fps * 8) then
      newspaper_alpha += 0.01

      if playdate.buttonJustPressed(playdate.kButtonA) then
        ng_timer = fps * 8
      end
    end
    if ng_timer > (fps * 8) then
      clean_menu_sprites()
      gfx_static_spr:remove()

      newspaper_alpha -= 0.01
    end
    if ng_timer > (fps * 11.5) then
      newspaper_spr:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)
      cleam_menu_vars()
      newspaper_spr = clean_sprite(newspaper_spr)

      system_menu:removeMenuItem(settings_menu_item)
      settings_menu_item = nil

      gfx_static_animator.paused = false
      current_scene = SCENES.NIGHT_SCREEN
    end
  end

  menu_select_y = 150 + (menu_selected * 23)
  if menu_select_spr ~= nil then menu_select_spr:moveTo(176, menu_select_y) end

  freddy_timer -= 1

  if not new_game then
    if menu_freddy_spr ~= nil and freddy_timer < 0 then
      menu_freddy_spr:setImage(menu_freddy_imgtable:getImage(math.random(3) + 1))
    elseif menu_freddy_spr ~= nil and freddy_timer > 0 then
      menu_freddy_spr:setImage(menu_freddy_imgtable:getImage(1))
    end
  end

  if freddy_timer < -freddy_duration then
    freddy_duration = fps * math.random(2)
    freddy_timer = fps * math.random(4)
  end

  if newspaper_spr ~= nil then
    newspaper_spr:setStencilPattern(newspaper_alpha, playdate.graphics.image.kDitherTypeBayer8x8)
  end

  gfx_static_spr:setStencilPattern(0.25, playdate.graphics.image.kDitherTypeBayer8x8)

  playdate.timer.updateTimers()
  playdate.graphics.sprite.update()
end