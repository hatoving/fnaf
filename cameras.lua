import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "math.lua"

local cameras_inited = false

local cameras_border = nil
local cameras_rec = nil

local original_static_zindex = 0

function set_up_cameras()
  cameras_border = create_sprite("gfx/cams/cams_border", 200, 120)
  cameras_rec = create_sprite("gfx/cams/cams_rec", 37, 221)

  cameras_inited = true
end

function hide_cameras() 
  cameras_border:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)
  cameras_rec:setStencilPattern(0, playdate.graphics.image.kDitherTypeBayer8x8)
end

function show_cameras() 
  if cameras_inited then
    cameras_border:setStencilPattern(1, playdate.graphics.image.kDitherTypeBayer8x8)
    cameras_rec:setStencilPattern(1, playdate.graphics.image.kDitherTypeBayer8x8)
  end
end

function clean_cameras()
  cameras_border = clean_sprite(cameras_border)
  cameras_rec = clean_sprite(cameras_rec)

  cameras_inited = false 
end

function update_cameras()
  if not cameras_inited then
    set_up_cameras()
  end

  if not is_sprite_in_dlist(gfx_static_spr) then
    original_static_zindex = gfx_static_spr:getZIndex()

    gfx_static_spr:add()
    gfx_static_spr:setZIndex(cameras_rec:getZIndex() + 1)
  end

  if playdate.buttonJustPressed(playdate.kButtonUp) then
    monitor_up = false

    hide_cameras()

    gfx_static_spr:setZIndex(original_static_zindex)
    gfx_static_spr:remove()

    sfx_monitor_down:play()

    power_used -= 1
    in_office = true
  end
end