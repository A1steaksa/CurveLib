if SERVER then return false end

local _R = debug.getregistry()
if _R.Circles then return _R.Circles end

---@class Circle
local CIRCLE = {}
CIRCLE.__index = CIRCLE

CIRCLE_TYPE_FILLED 	 	= 0
CIRCLE_TYPE_OUTLINED 	= 1
CIRCLE_TYPE_BLURRED 	= 2
---@alias CIRCLE_TYPE
---|`CIRCLE_TYPE_FILLED` 	# A Circle with a filled center.
---|`CIRCLE_TYPE_OUTLINED`  # An unfilled, rim-only Circle.
---|`CIRCLE_TYPE_BLURRED` 	# A Circle with a center filled with a blur effect.

local New
do
	local ERROR_NUMBER = "bad argument #%i to 'New' (number expected, got %s)"

	-- Creates a new Circle
	---@param circleType CIRCLE_TYPE
	---@param radius number The Circle's radius, in pixels
	---@param x number The X position of the Circle's center 
	---@param y number The Y position of the Circle's center
	---@param outlineOrLayers number|integer The outline width, in pixels, if this is a `CIRCLE_TYPE_OUTLINED` Circle, or the `number` of blur layers if this is a `CIRCLE_TYPE_BLURRED` Circle.
	---@param blurDensity number The number of blur layers to apply if this is a `CIRCLE_TYPE_BLURRED` Circle.
	---@return Circle
	function New( circleType, radius, x, y, outlineOrLayers, blurDensity )
		assert( isnumber(circleType), string.format(ERROR_NUMBER, 1, type(circleType)))
		assert(isnumber(radius), 	 string.format(ERROR_NUMBER, 2, type(radius)))
		assert(isnumber(x), 		 string.format(ERROR_NUMBER, 3, type(x)))
		assert(isnumber(y), 		 string.format(ERROR_NUMBER, 4, type(y)))

		local circle = setmetatable( {}, CIRCLE )

		circle:SetType( circleType )
		circle:SetRadius( radius )
		circle:SetX( x )
		circle:SetY( y )

		circle:SetVertices( { [0] = 0 } )

		if circleType == CIRCLE_TYPE_OUTLINED then
			assert( outlineOrLayers == nil or isnumber( outlineOrLayers ), string.format( ERROR_NUMBER, 5, type ( outlineOrLayers ) ) )
			circle:SetOutlineWidth( outlineOrLayers )
		elseif circleType == CIRCLE_TYPE_BLURRED then
			assert( outlineOrLayers == nil or isnumber( outlineOrLayers ), string.format(ERROR_NUMBER, 5, type( outlineOrLayers ) ) )
			assert( blurDensity == nil or isnumber( blurDensity ), string.format( ERROR_NUMBER, 6, type( blurDensity ) ) )

			circle:SetBlurLayers( outlineOrLayers )
			circle:SetBlurDensity( blurDensity )
		end

		return circle
	end
end

local RotateVertices
do
	local ERROR_TABLE = "bad argument #1 to 'RotateVertices' (table expected, got %s)"
	local ERROR_NUMBER = "bad argument #%i to 'RotateVertices' (number expected, got %s)"

	function RotateVertices(vertices, ox, oy, rotation, rotate_uv)
		assert(istable(vertices), string.format(ERROR_TABLE, type(vertices)))
		assert(isnumber(ox), string.format(ERROR_NUMBER, 2, type(ox)))
		assert(isnumber(oy), string.format(ERROR_NUMBER, 3, type(oy)))
		assert(isnumber(rotation), string.format(ERROR_NUMBER, 4, type(rotation)))

		local rotation = math.rad(rotation)
		local c = math.cos(rotation)
		local s = math.sin(rotation)

		for i = 1, vertices[0] or #vertices do
			local vertex = vertices[i]
			local vx, vy = vertex.x, vertex.y

			vx = vx - ox
			vy = vy - oy

			vertex.x = ox + (vx * c - vy * s)
			vertex.y = oy + (vx * s + vy * c)

			if rotate_uv == false then
				local u, v = vertex.u, vertex.v
				u, v = u - 0.5, v - 0.5

				vertex.u = 0.5 + (u * c - v * s)
				vertex.v = 0.5 + (u * s + v * c)
			end
		end
	end
end

local CalculateVertices
do
	local err_number = "bad argument #%i to 'CalculateVertices' (number expected, got %s)"

	function CalculateVertices(x, y, radius, rotation, startAngle, endAngle, distance, rotate_uv)
		assert( isnumber( x ), 			string.format( err_number, 1, type( x ) 		 ) )
		assert( isnumber( y ), 			string.format( err_number, 2, type( y )			 ) )
		assert( isnumber( radius ), 	string.format( err_number, 3, type( radius ) 	 ) )
		assert( isnumber( rotation ), 	string.format( err_number, 4, type( rotation ) 	 ) )
		assert( isnumber( startAngle ), string.format( err_number, 5, type( startAngle ) ) )
		assert( isnumber( endAngle ), 	string.format( err_number, 6, type( endAngle ) 	 ) )
		assert( isnumber( distance ),	string.format( err_number, 7, type( distance ) 	 ) )

		local vertices = {}
		local vertexCount = 0

		local step = distance / radius
		local startAngleRad = math.rad(startAngle)
		local endAngleRad = math.rad(endAngle)
		local rotationRad = math.rad(rotation)

		for a = startAngleRad, endAngleRad + step, step do
			a = math.min( a, endAngleRad )

			local c = math.cos( a + rotationRad )
			local s = math.sin( a + rotationRad )

			local vertex = {
				x = x + c * radius,
				y = y + s * radius,
			}

			if rotate_uv == false then
				vertex.u = 0.5 + math.cos( a ) / 2
				vertex.v = 0.5 + math.sin( a ) / 2
			else
				vertex.u = 0.5 + c / 2
				vertex.v = 0.5 + s / 2
			end

			vertexCount = vertexCount + 1
			vertices[vertexCount] = vertex
		end

		if endAngle - startAngle ~= 360 then
			table.insert( vertices, 1, {
				x = x,
				y = y,
				u = 0.5,
				v = 0.5,
			} )

			vertexCount = vertexCount + 1
		else
			table.remove( vertices )
			vertexCount = vertexCount - 1
		end

		vertices[0] = vertexCount

		return vertices
	end
end

function CIRCLE:__tostring()
	return string.format( "Circle: %p", self )
end

function CIRCLE:Copy()
	return table.Copy( self )
end

function CIRCLE:IsValid()
	return (
		not self.m_Dirty and
		self.m_Vertices[0] >= 3 and
		self.m_Radius >= 1 and
		self.m_Distance >= 1
	)
end

function CIRCLE:Calculate()
	local rotate_uv = self.m_RotateMaterial

	local radius = self.m_Radius
	local x, y = self.m_X, self.m_Y

	local rotation = self.m_Rotation
	local start_angle = self.m_StartAngle
	local end_angle = self.m_EndAngle

	local distance = self.m_Distance

	assert(radius >= 1, string.format("circle radius should be >= 1 (%.4f)", radius))
	assert(distance >= 1, string.format("circle distance should be >= 1 (%.4f)", distance))

	self:SetVertices(CalculateVertices(x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv))

	if self.m_Type == CIRCLE_TYPE_OUTLINED then
		local inner = self.m_ChildCircle or self:Copy()
		local inner_r = radius - self.m_OutlineWidth

		inner:SetType(CIRCLE_TYPE_FILLED)

		inner:SetPos(x, y)
		inner:SetRadius(inner_r)
		inner:SetRotation(rotation)
		inner:SetAngles(start_angle, end_angle)
		inner:SetDistance(distance)

		inner:SetColor(false)
		inner:SetMaterial(false)

		inner:SetShouldRender(inner_r >= 1)
		inner:SetDirty(inner.m_ShouldRender)

		self:SetShouldRender(inner_r < radius)
		self:SetChildCircle(inner)
	elseif self.m_ChildCircle then
		self.m_ChildCircle = nil
	end

	self:SetDirty(false)

	return self
end

do
	local blur = Material("pp/blurscreen")

	function CIRCLE:__call()
		if self.m_Dirty then self:Calculate() end

		if not self:IsValid() then return false end
		if not self.m_ShouldRender then return false end

		do
			local col, mat = self.m_Color, self.m_Material

			if IsColor(col) then
				if col.a <= 0 then return end
				surface.SetDrawColor(col.r, col.g, col.b, col.a)
			end

			if mat == true then
				draw.NoTexture()
			elseif TypeID(mat) == TYPE_MATERIAL then
				surface.SetMaterial(mat)
			end
		end

		if self.m_Type == CIRCLE_TYPE_OUTLINED then
			render.ClearStencil()

			render.SetStencilEnable(true)
			render.SetStencilTestMask(0xFF)
			render.SetStencilWriteMask(0xFF)
			render.SetStencilReferenceValue(0x01)

			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			self.m_ChildCircle()

			render.SetStencilCompareFunction(STENCIL_GREATER)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			surface.DrawPoly(self.m_Vertices)
			render.SetStencilEnable(false)
		elseif self.m_Type == CIRCLE_TYPE_BLURRED then
			render.ClearStencil()

			render.SetStencilEnable(true)
			render.SetStencilTestMask(0xFF)
			render.SetStencilWriteMask(0xFF)
			render.SetStencilReferenceValue(0x01)

			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			surface.DrawPoly(self.m_Vertices)

			render.SetStencilCompareFunction(STENCIL_LESSEQUAL)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			surface.SetMaterial(blur)

			local sw, sh = ScrW(), ScrH()

			for i = 1, self.m_BlurLayers do
				blur:SetFloat("$blur", (i / self.m_BlurLayers) * self.m_BlurDensity)
				blur:Recompute()

				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(0, 0, sw, sh)
			end
			render.SetStencilEnable(false)
		else
			surface.DrawPoly(self.m_Vertices)
		end

		return true
	end

	CIRCLE.Draw = CIRCLE.__call
end

do
	local err_number = "bad argument #%i to 'Translate' (number expected, got %s)"

	function CIRCLE:Translate(x, y)
		assert(isnumber(x), string.format(err_number, 1, type(x)))
		assert(isnumber(y), string.format(err_number, 2, type(y)))

		if x ~= 0 or y ~= 0 then
			self.m_X = self.m_X + x
			self.m_Y = self.m_Y + y

			if self:IsValid() then
				for i = 1, self.m_Vertices[0] do
					local vertex = self.m_Vertices[i]

					vertex.x = vertex.x + x
					vertex.y = vertex.y + y
				end

				if self.m_Type == CIRCLE_TYPE_OUTLINED and self.m_ChildCircle then
					self.m_ChildCircle:Translate(x, y)
				end
			end
		end

		return self
	end
end

do
	local err_number = "bad argument #1 to 'Scale' (number expected, got %s)"

	function CIRCLE:Scale(scale)
		assert(isnumber(scale), string.format(err_number, type(scale)))

		if scale ~= 1 then
			self.m_Radius = self.m_Radius * scale

			if self:IsValid() then
				local x, y = self.m_X, self.m_Y

				for i = 1, self.m_Vertices[0] do
					local vertex = self.m_Vertices[i]

					vertex.x = x + (vertex.x - x) * scale
					vertex.y = y + (vertex.y - y) * scale
				end

				if self.m_Type == CIRCLE_TYPE_OUTLINED and self.m_ChildCircle then
					self.m_ChildCircle:Scale(scale)
				end
			end
		end

		return self
	end
end

do
	local err_number = "bad argument #1 to 'Rotate' (number expected, got %s)"

	function CIRCLE:Rotate(rotation)
		assert(isnumber(rotation), string.format(err_number, type(rotation)))

		if rotation ~= 0 then
			self.m_Rotation = self.m_Rotation + rotation

			if self:IsValid() then
				local x, y = self.m_X, self.m_Y
				local vertices = self.m_Vertices
				local rotate_uv = self.m_RotateMaterial

				RotateVertices(vertices, x, y, rotation, rotate_uv)

				if self.m_Type == CIRCLE_TYPE_OUTLINED and self.m_ChildCircle then
					self.m_ChildCircle:Rotate(rotation)
				end
			end
		end

		return self
	end
end

do
	local function AccessorFunc(name, default, dirty, callback)
		local varname = "m_" .. name

		CIRCLE["Get" .. name] = function(self)
			return self[varname]
		end

		CIRCLE["Set" .. name] = function(self, value)
			if default ~= nil and value == nil then
				value = default
			end

			if self[varname] ~= value then
				if dirty then
					self[dirty] = true
				end

				if callback ~= nil then
					local new = callback(self, self[varname], value)
					value = new ~= nil and new or value
				end

				self[varname] = value
			end

			return self
		end

		CIRCLE[varname] = default
	end

	local function OffsetVerticesX(circle, old, new)
		circle:Translate(new - old, 0)

		if circle.m_Type == CIRCLE_TYPE_OUTLINED and circle.m_ChildCircle then
			circle.m_ChildCircle:Translate(new - old, 0)
		end
	end

	local function OffsetVerticesY(circle, old, new)
		circle:Translate(0, new - old)

		if circle.m_Type == CIRCLE_TYPE_OUTLINED and circle.m_ChildCircle then
			circle.m_ChildCircle:Translate(0, new - old)
		end
	end

	local function UpdateRotation(circle, old, new)
		circle:Rotate(new - old)

		if circle.m_Type == CIRCLE_TYPE_OUTLINED and circle.m_ChildCircle then
			circle.m_ChildCircle:Rotate(new - old)
		end
	end

	-- These are set internally. Only use them if you know what you're doing.
	AccessorFunc( "Dirty", true )
	AccessorFunc( "Vertices", false )
	AccessorFunc( "ChildCircle", false )
	AccessorFunc( "ShouldRender", true )

	AccessorFunc( "Color", false )                    		-- The colour you want the circle to be. If set to false then surface.SetDrawColor's can be used.
	AccessorFunc( "Material", false )                 		-- The material you want the circle to render. If set to false then surface.SetMaterial can be used.
	AccessorFunc( "RotateMaterial", true )            		-- Sets whether or not the circle's UV points should be rotated with the vertices.

	AccessorFunc( "Type", CIRCLE_TYPE_FILLED, "m_Dirty" )	-- The circle's type.
	AccessorFunc( "X", 0, false, OffsetVerticesX )    		-- The circle's X position relative to the top left of the screen.
	AccessorFunc( "Y", 0, false, OffsetVerticesY )    		-- The circle's Y position relative to the top left of the screen.
	AccessorFunc( "Radius", 8, "m_Dirty" )            		-- The circle's radius.
	AccessorFunc( "Rotation", 0, false, UpdateRotation ) 	-- The circle's rotation, measured in degrees.
	AccessorFunc( "StartAngle", 0, "m_Dirty" )        		-- The circle's start angle, measured in degrees.
	AccessorFunc( "EndAngle", 360, "m_Dirty" )        		-- The circle's end angle, measured in degrees.
	AccessorFunc( "Distance", 10, "m_Dirty" )         		-- The maximum distance between each of the circle's vertices. This should typically be used for large circles in 3D2D.

	AccessorFunc( "BlurLayers", 3 )                   		-- The circle's blur layers if Type is set to CIRCLE_BLURRED.
	AccessorFunc( "BlurDensity", 2 )                  		-- The circle's blur density if Type is set to CIRCLE_BLURRED.
	AccessorFunc( "OutlineWidth", 10, "m_Dirty" )     		-- The circle's outline width if Type is set to CIRCLE_OUTLINED.

	function CIRCLE:SetPos(x, y)
		x = tonumber(x) or self.m_X
		y = tonumber(y) or self.m_Y

		if self:IsValid() then
			self:Translate(x - self.m_X, y - self.m_Y)
		else
			self.m_X = x
			self.m_Y = y
		end

		return self
	end

	function CIRCLE:SetAngles(s, e)
		s = tonumber(s) or self.m_StartAngle
		e = tonumber(e) or self.m_EndAngle

		self:SetDirty(self.m_Dirty or s ~= self.m_StartAngle or e ~= self.m_EndAngle)

		self.m_StartAngle = s
		self.m_EndAngle = e

		return self
	end

	function CIRCLE:GetPos()
		return self.m_X, self.m_Y
	end

	function CIRCLE:GetAngles()
		return self.m_StartAngle, self.m_EndAngle
	end

	function CIRCLE:SetVertexCount(count)
		self:SetDistance(math.tau * self.m_Radius / math.floor(0.5 + count))
		return self
	end

	function CIRCLE:GetVertexCount()
		if self.m_Dirty then
			return math.ceil(math.tau * self.m_Radius / self.m_Distance) -- rough estimate, only accounts for full circles, m_Vertices[0] will always be right.
		end

		return self.m_Vertices[0]
	end
end

_R.Circles = {
	_MT = CIRCLE,

	New = New,
	RotateVertices = RotateVertices,
	CalculateVertices = CalculateVertices,
}

return _R.Circles
