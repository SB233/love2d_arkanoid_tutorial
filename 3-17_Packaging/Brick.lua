local vector = require "vector"
local love = love
local setmetatable = setmetatable
local math = math
local print = print

local Brick = {}

if setfenv then
   setfenv(1, Brick) -- for 5.1
else
   _ENV = Brick -- for 5.2
end

image = love.graphics.newImage( "img/800x600/bricks.png" )
brick_tile_width = 64
brick_tile_height = 32
local tileset_width = 384
local tileset_height = 160

simple_break_sound = {
   love.audio.newSource("sounds/simple_break/recordered_glass_norm.ogg",
			"static"),   
   love.audio.newSource("sounds/simple_break/edgardedition_glass_hit_norm.ogg",
			"static") }

armored_hit_sound = {
   love.audio.newSource("sounds/armored_hit/qubodupImpactMetal_short_norm.ogg",
			"static"),
   love.audio.newSource("sounds/armored_hit/cast_iron_clangs_14_short_norm.ogg",
			"static"),
   love.audio.newSource("sounds/armored_hit/cast_iron_clangs_22_short_norm.ogg",
			"static") }

armored_break_sound = {
   love.audio.newSource(
      "sounds/armored_break/armored_glass_break_short_norm.ogg", "static"),
   love.audio.newSource(
      "sounds/armored_break/ngruber__breaking-glass_6_short_norm.ogg", "static") }

ball_heavyarmored_sound = {
   love.audio.newSource("sounds/heavyarmored_hit/cast_iron_clangs_11_short_norm.ogg",
			"static"),
   love.audio.newSource("sounds/heavyarmored_hit/cast_iron_clangs_18_short_norm.ogg",
			"static") }

function Brick:new( o )
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   o.name = o.name or "brick"
   o.position = o.position or vector( 100, 100 )
   o.width = o.width or brick_tile_width
   o.height = o.height or brick_tile_height
   o.bricktype = o.bricktype or 11
   o.bonustype = o.bonustype or nil
   o.collider = o.collider or {}
   o.collider_shape = o.collider:rectangle( o.position.x,
					    o.position.y,
					    o.width,
					    o.height )
   o.collider_shape.game_object = o
   o.to_destroy = o.to_destroy or false
   if o.bricktype then
      o.quad = o:bricktype_to_quad()
   else
      o.quad = nil
   end
   return o
end

function Brick:update( dt )
end

function Brick:draw()
   if self.quad then
      love.graphics.draw( self.image,
			  self.quad, 
			  self.position.x,
			  self.position.y )
   end
end

function Brick:react_on_ball_collision(	another_shape, separating_vector )
   local big_enough_overlap = 0.5
   local dx, dy = separating_vector.x, separating_vector.y
   if ( math.abs( dx ) > big_enough_overlap ) or
      ( math.abs( dy ) > big_enough_overlap ) then
	 if self:is_simple() then
	    self.to_destroy = true
	    local snd = simple_break_sound[ math.random( #simple_break_sound ) ]
	    snd:play()
	 elseif self:is_armored() then
	    self:armored_to_scrathed()
	    local snd = armored_hit_sound[ math.random( #armored_hit_sound ) ]
	    snd:play()
	 elseif self:is_scratched() then
	    self:scrathed_to_cracked()
	    local snd = armored_hit_sound[ math.random( #armored_hit_sound ) ]
	    snd:play()
	 elseif self:is_cracked() then
	    self.to_destroy = true
	    local snd = armored_break_sound[ math.random( #armored_break_sound ) ]
	    snd:play()
	 elseif self:is_heavyarmored() then
	    local snd =
	       ball_heavyarmored_sound[ math.random( #ball_heavyarmored_sound ) ]
	    snd:play()
	 end
   end
end

function Brick:bricktype_to_quad()
   if self.bricktype == nil or self.bricktype < 10 then
      return nil
   end
   local row = math.floor( self.bricktype / 10 )
   local col = self.bricktype % 10
   local x_pos = brick_tile_width * ( col - 1 )
   local y_pos = brick_tile_height * ( row - 1 )
   return love.graphics.newQuad( x_pos, y_pos,
                                 brick_tile_width, brick_tile_height,
                                 tileset_width, tileset_height )
end

function Brick:is_simple()
   local row = math.floor( self.bricktype / 10 )
   return ( row == 1 )
end

function Brick:is_armored()
   local row = math.floor( self.bricktype / 10 )
   return ( row == 2 )
end

function Brick:is_scratched()
   local row = math.floor( self.bricktype / 10 )
   return ( row == 3 )
end

function Brick:is_cracked()
   local row = math.floor( self.bricktype / 10 )
   return ( row == 4 )
end

function Brick:is_heavyarmored()
   local row = math.floor( self.bricktype / 10 )
   return ( row == 5 )
end

function Brick:armored_to_scrathed()
   self.bricktype = self.bricktype + 10
   self.quad = self:bricktype_to_quad()
end

function Brick:scrathed_to_cracked()
   self.bricktype = self.bricktype + 10
   self.quad = self:bricktype_to_quad()
end

      
return Brick
