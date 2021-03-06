local vector = require "vector"
local os = os
local love = love
local setmetatable = setmetatable
local math = math
local print = print

local Bonus = {}

if setfenv then
   setfenv(1, Bonus) -- for 5.1
else
   _ENV = Bonus -- for 5.2
end

image = love.graphics.newImage( "img/800x600/bonuses.png" )
bonus_tile_width = 64
bonus_tile_height = 32
local tileset_width = 512
local tileset_height = 32

bonus_collected_sound = {
   love.audio.newSource("sounds/bonus/bonus1.wav", "static"),
   love.audio.newSource("sounds/bonus/bonus2.wav", "static"),
   love.audio.newSource("sounds/bonus/bonus3.wav", "static")
}

function Bonus:new( o )
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   o.name = o.name or "bonus"
   o.position = o.position or vector( 100, 100 )
   o.radius = o.radius or 14
   o.speed = o.speed or vector( 0, 100 )
   o.bonustype = o.bonustype or 11
   o.collider = o.collider or {}
   o.collider_shape = o.collider:circle( o.position.x,
					 o.position.y,
					 o.radius )
   o.collider_shape.game_object = o
   o.to_destroy = o.to_destroy or false
   if o.bonustype then
      o.quad = o:bonustype_to_quad()
   else
      o.quad = nil
   end
   return o
end

function Bonus:update( dt )
   self.position = self.position + self.speed * dt
   self.collider_shape:moveTo( self.position:unpack() )
end

function Bonus:draw()
   if self.quad then
      love.graphics.draw( self.image,
			  self.quad, 
			  self.position.x - bonus_tile_width / 2,
			  self.position.y - bonus_tile_height / 2 )
   end
end

function Bonus:bonustype_to_quad()
   if self.bonustype == nil or
      self.bonustype <= 10  or
      self.bonustype >=20 then
	 return nil
   end
   local row = math.floor( self.bonustype / 10 )
   local col = self.bonustype % 10
   local x_pos = bonus_tile_width * ( col - 1 )
   local y_pos = bonus_tile_height * ( row - 1 )
   return love.graphics.newQuad( x_pos, y_pos,
                                 bonus_tile_width, bonus_tile_height,
                                 tileset_width, tileset_height )
end

function Bonus:is_slowdown()
   local col = self.bonustype % 10
   return ( col == 1 )
end

function Bonus:is_accelerate()
   local col = self.bonustype % 10
   return ( col == 5 )
end

function Bonus:is_increase()
   local col = self.bonustype % 10
   return ( col == 3 )
end

function Bonus:is_decrease()
   local col = self.bonustype % 10
   return ( col == 6 )
end

function Bonus:is_add_new_ball()
   local col = self.bonustype % 10
   return ( col == 4 )
end

function Bonus:is_glue()
   local col = self.bonustype % 10
   return ( col == 2 )
end

function Bonus:is_life()
   local col = self.bonustype % 10
   return ( col == 8 )
end

function Bonus:is_next_level()
   local col = self.bonustype % 10
   return ( col == 7 )
end

function Bonus:react_on_platform_collision( another_shape, separating_vector )
   self.to_destroy = true
   local snd = bonus_collected_sound[ math.random( #bonus_collected_sound ) ]
   snd:play()
end

bonustype_rng = love.math.newRandomGenerator( os.time() )

function Bonus:random_bonustype()
   -- once in 5 levels (~400 blocks): L or N
   -- once in 10 blocks - any others with roughly equal prob
   local bonustype
   local common_bonuses = { 11, 12, 13, 14, 15, 16 }
   local prob = bonustype_rng:random( 402 )
   if prob == 402 then
      bonustype = 18
   elseif prob == 401 then
      bonustype = 17
   elseif prob > 360 then
      bonustype = common_bonuses[ math.ceil( (prob - 360)/7 ) ]
   else
      bonustype = nil
   end
   return bonustype
end

return Bonus
