display.setStatusBar(display.HiddenStatusBar)

local physics = require 'physics'
physics.setDrawMode( "hybrid" )
physics.start()
physics.setGravity( 0,5)


local screen_width = display.contentWidth
local screen_height = display.contentHeight
local center_x = display.contentCenterX
local center_y = display.contentCenterY

local back
local front

local data_sheet = {frames = {{x=2, y=86, width=72, height=82, sourceX = 0, sourceY = 0, sourceWidth = 72, sourceHeight = 81 }, {x=2, y=2, width=76, height=82, sourceX = 0, sourceY = 0, sourceWidth = 76, sourceHeight = 81 }, {x=2, y=170, width=30, height=80, sourceX = 0, sourceY = 0, sourceWidth = 30, sourceHeight = 79 }, {x=80, y=2, width=46, height=68, sourceX = 0, sourceY = 0, sourceWidth = 46, sourceHeight = 67 }, {x=80, y=72, width=44, height=66, sourceX = 0, sourceY = 0, sourceWidth = 44, sourceHeight = 65 }, {x=34, y=170, width=60, height=76, }, }, sheetContentWidth = 128, sheetContentHeight = 256 }
local data_sprite = {
	{
		name = 'normal',
		start = 6,
		count = 1,
		time = 1000
	},
	{
		name = 'exploding',
		start = 1,
		count = 3,
		time = 200,
		loopCount = 1
	}
}

local function create_balloon()
	local cor = {
		--'azul',
		'vermelho'
		--'verde',
		--'amarelo'
	}
	local posicao = math.random( #cor )
	local image_sheet = graphics.newImageSheet( 'img/b'.. cor[posicao].. '.png', data_sheet )
	local balloon = display.newSprite(image_sheet, data_sprite )
	back:insert( balloon )
	--gera posicao do ballon aleatoria
	balloon:setSequence( 'normal' )
	balloon.x = math.random(0, screen_width)
	balloon.name = 'balloon'
	balloon.isAlive = true
	balloon:play()
	
	physics.addBody( balloon, 'dynamic', { radius = 30 } )
end

local background
local pedra

local score_display
local score = 0

local function init( )
	back = display.newGroup()
	front = display.newGroup()

	background =  display.newImage('img/ceu1.png')

	floor = display.newImage('img/chao.png')
	floor.y = display.contentHeight - floor.contentHeight/2
	floor.name = 'floor'
	physics.addBody(floor, 'static', {shape = { -160, -20, 160, -20, 160, 100, -160, 100}})

	back:insert( background )
	front:insert( floor)

	score_display = display.newText( 'Score: 0', 0, 0, nil, 20 )
	score_display.x = center_x
	score_display.y = 20
	score_display:setTextColor( 255, 255, 0 )


	pedra = display.newCircle( 0, 0, 10 )
	pedra.x = screen_center_x
	pedra.y = screen_height - 20
	pedra.cos = 0
	pedra.sin = 0
	pedra.speed = .2
	pedra.can_shot = true

	function pedra:collision( event )
		if event.other.name == 'balloon' and event.other.isAlive == true then
			event.other:setSequence('exploding')
			event.other:play()
			event.other.isAlive = false
			local agua = display.newCircle(event.other.x, event.other.y + 20, 30)
			back:insert(agua)
			agua.isSensor = true
			agua.name = 'agua'
			timer.performWithDelay( 10, function() physics.addBody(agua) end, 1)
		end

	end
	pedra:addEventListener ('collision', pedra)
	physics.addBody(pedra, 'kinematic')
	pedra.isSensor = true
	
	front:insert( floor)

end

local function refresh_score()
	score_display.text = 'Score: '..score
	score_display.x = center_x
end

local function collision( event )
	if event.object1.name == 'floor' and event.object2.name == 'balloon' then
		
		if event.object2.isAlive then
			score = score - 50
			refresh_score()
		end
		event.object2:removeSelf()
		event.object2 = nil
		
	elseif event.object1.name == 'floor' and event.object2.name == 'agua' then
		event.object2:removeSelf()
		event.object2 = nil
		score = score + 50
		refresh_score()
	end

end 


local function shot( event )	
	if pedra.can_shot == true then
		pedra.can_shot = false
		local angle = ( (math.atan2( event.x - pedra.x, event.y - pedra.y )*180 / math.pi) - 180 ) * -1
		pedra.cos =  math.cos( math.rad( angle-90 ) ) * 100
		pedra.sin =  math.sin( math.rad( angle-90 ) ) * 100
	end
end

local function update()
	pedra.x = pedra.x + (pedra.cos * pedra.speed )
	pedra.y = pedra.y + (pedra.sin * pedra.speed )
	if pedra.x < 0 or pedra.x > screen_width or pedra.y < 0 or pedra.y > screen_height then
		pedra.x = screen_center_x
		pedra.y = screen_height - 20
		pedra.cos = 0
		pedra.sin = 0
		pedra.can_shot = true
	end
end


local function init_floor()
	-- body
end


local function add_listeners()
	background:addEventListener( 'tap', shot )	
	Runtime:addEventListener( 'enterFrame', update)
	Runtime:addEventListener('collision', collision)
end


init()
add_listeners()
timer.performWithDelay(2000, create_balloon, 0)