local Brick = require "Brick"
local vector = require "vector"
local love = love
local setmetatable = setmetatable
local table = table
local pairs = pairs
local next = next
local print = print

local BricksContainer = {}

if setfenv then
   setfenv(1, BricksContainer) -- for 5.1
else
   _ENV = BricksContainer -- for 5.2
end

function BricksContainer:new( o )
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   o.name = o.name or "bricks_container"
   o.bricks = o.bricks or {}
   o.level = o.level or nil
   o.bonuses_container = o.bonuses_container or nil
   o.collider = o.collider or {}
   o.rows = 11
   o.columns = 8
   o.top_left_position = vector( 47, 34 )
   o.horizontal_distance = o.horizontal_distance or 0
   o.vertical_distance = o.vertical_distance or 0
   o.brick_width = o.brick_width or Brick.brick_tile_width
   o.brick_height = o.brick_height or Brick.brick_tile_height
   if not o.level then
      o:default_level_construction_procedure()
   else
      o:construct_from_level()
   end
   o.no_more_bricks = o.no_more_bricks or false
   return o
end

function BricksContainer:default_level_construction_procedure()
   for row = 1, self.rows do
      local new_row = {}
      for col = 1, self.columns do	 
	 local new_brick_position = self.top_left_position +
	    vector(
	       ( col - 1 ) * ( self.brick_width + self.horizontal_distance ),
	       ( row - 1 ) * ( self.brick_height + self.vertical_distance ) )
	 local new_brick = Brick:new{
	    width = self.brick_width,
	    height = self.brick_height,
	    position = new_brick_position,
	    collider = self.collider
	 }
	 new_row[ col ] = new_brick
      end
      self.bricks[ row ] = new_row
   end   
end


function BricksContainer:construct_from_level()
   for row = 1, self.rows do
      local new_row = {}
      for col = 1, self.columns do
	 local bricktype = self.level.bricks[row][col]
	 local bonustype = self.level.bonuses[row][col]
	 if bricktype ~= 0 then
	    local new_brick_position = self.top_left_position +
	       vector(
		  ( col - 1 ) *
		     ( self.brick_width + self.horizontal_distance ),
		  ( row - 1 ) *
		     ( self.brick_height + self.vertical_distance ) )
	    local new_brick = Brick:new{
	       width = self.brick_width,
	       height = self.brick_height,
	       position = new_brick_position,
	       bricktype = bricktype,
	       bonustype = bonustype,
	       collider = self.collider
	    }
	    new_row[ col ] = new_brick
	 end
      end
      self.bricks[ row ] = new_row
   end   
end

function BricksContainer:update( dt )
   for i, brick_row in pairs( self.bricks ) do
      for j, brick in pairs( brick_row ) do
	 brick:update( dt )
	 if brick.to_destroy then
	    local new_bonus_properties = 
	       { bonustype = brick.bonustype,
		 position = brick.position +
		    vector( brick.width / 2, brick.height / 2 ),
		 collider = brick.collider }
	    self.bonuses_container:add_bonus( new_bonus_properties )
	    brick.collider:remove( brick.collider_shape )
	    self.bricks[i][j] = nil
	 end
      end
   end
   self:check_if_no_more_bricks()
end

function BricksContainer:draw()
   for _, brick_row in pairs( self.bricks ) do
      for _, brick in pairs( brick_row ) do
	 brick:draw()
      end
   end   
end

function BricksContainer:check_if_no_more_bricks()
   local empty_row = true
   for _, brick_row in pairs( self.bricks ) do
      local __, brick = next( brick_row )
      if brick == nil then
	 empty_row = empty_row and true
      else
	 if brick:is_heavyarmored() then
	    empty_row = empty_row and true
	 else
	    empty_row = empty_row and false
	 end
      end
   end
   self.no_more_bricks = empty_row
end

return BricksContainer
