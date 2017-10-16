
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Include physics module
local physics = require("physics")
physics.start()
physics.setGravity( 0, 9.8 )
physics.setDrawMode( "hybrid" )

local sheetData = require("spritesheet.aw3spriteSheet")
local heroSheet = graphics.newImageSheet( "assets/img/aw3spriteSheet.png", sheetData.getSheet() )

-- Initialize variables
local lives = 3
local score = 0
local died = false

local foesTable = {}
local alpha = 0.5
local cw
local ch
local ground
local hero
local gameLoopTimer
local livesText
local scoreText
local xScale = 0.3
local yScale = 0.3
local musicTrack
local atkSound = audio.loadSound( "assets/audio/AW_atk.wav")
local hitFoeSound
local takeDamageSound
local jumpSound

local backGroup
local mainGroup
local uiGroup

-- Animation Sequence data
local sequenceData = {
	{ name = "left-iddle", frames = {17} },
	{ name = "right-iddle", frames = {18} },
	{ name = "right-walk", start = 13, count = 4, time = 300, loopCount = 0 },
	{ name = "left-walk", start = 9, count = 4, time = 300, loopCount = 0 },
	{ name = "left-attack", frames = {5, 1, 17}, time = 250, loopCount = 1 },
	{ name = "right-attack", frames = {7, 2, 18}, time = 250, loopCount = 1 },
	{ name = "left-jump", frames = {5, 6, 17}, time = 1000, loopCount = 1 },
	{ name = "right-jump", frames = {7, 8, 18}, time = 1000, loopCount = 1 },
	{ name = "HeroTakingDamage", frames = {3, 4} }
	}


-- Function to update Lives and Score
local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end

-- Function to create a foe
local function createFoe()

	newFoe = display.newSprite( mainGroup, heroSheet, sequenceData)
	table.insert( foesTable, newFoe )
	newFoe.x = display.contentCenterX
	newFoe.y = display.contentHeight - 250
	-- newfoe.xScale = xScale
	-- newFoe.yScale = yScale
	physics.addBody( newFoe, "kinematic")

	newFoe.isFixedRotation = true
	newFoe.sensorOverlaps = 0
	newFoe.myName = "foe"

	local whereFrom = math.random( 2 )

		if ( whereFrom == 1 ) then
			-- From the left
			newFoe:setSequence("right-walk")
			newFoe:play()
			newFoe.x = -60
			newFoe:setLinearVelocity( math.random( 80,180 ), 0)
		elseif ( whereFrom == 2 ) then
			-- From the right
			newFoe:setSequence("left-walk")
			newFoe:play()
			newFoe.x = display.contentWidth + 60
			newFoe:setLinearVelocity( math.random( -180,-80 ), 0)
		end

end

local function atk()
  -- audio.play( punchTrack )
	audio.play(atkSound)
  if (  hero.sequence == "right-iddle" or
    hero.sequence == "right-walk" or hero.sequence == "right-attack"
		or hero.sequence == "right-jump") then
    hero:setSequence( "right-attack" )  -- switch to "attackRight" sequence
    hero:play()  -- play the new sequence
  else
    hero:setSequence( "left-attack" )  -- switch to "attackLeft" sequence
    hero:play()  -- play the new sequence
  end

end

local function moveRight( event )
  if ( "began" == event.phase ) then
    -- audio.play( moveTrack )
    hero:setSequence( "right-walk" )
		hero:play()
    -- start moving hero
    hero:applyLinearImpulse( 5, 0, hero.x, hero.y )
  elseif ( "ended" == event.phase ) then
    hero:setSequence( "right-iddle" )
    hero:setFrame(1)
    -- stop moving hero
    hero:setLinearVelocity( 0,0 )
  end
end

local function moveLeft( event )
  if ( "began" == event.phase ) then
    -- audio.play( moveTrack )
    hero:setSequence( "left-walk" )
    hero:play()
    hero:applyLinearImpulse( -5, 0, hero.x, hero.y )
  elseif ( "ended" == event.phase ) then
    hero:setSequence( "left-iddle" )
    hero:setFrame(1)
    hero:setLinearVelocity( 0,0 )
  end
end

local function jump( event )

	if ( event.phase == "began" ) then--and hero.sensorOverlaps > 0 ) then
		-- Jump procedure here
		local vx, vy = hero:getLinearVelocity()
		--
		-- if (hero.sequence == ("right-iddle" or "right-walk" or "right-jump") )
		-- then
		-- 	hero:setSequence("right-jump")
		-- -- 	hero:play()
		-- 	hero:setLinearVelocity( vx, 0 )
		-- 	hero:applyLinearImpulse( nil, -75, hero.x, hero.y )
		-- elseif (hero.sequence == ("left-iddle" or "left-walk" or "left-jump"))
		-- then
		-- 	hero:setSequence("left-jump")
		-- 	hero:play()
			hero:setLinearVelocity( vx, 0 )
			hero:applyLinearImpulse( nil, -5, hero.x, hero.y )
		-- end
	end
end

local function gameLoop()
	-- Create new foe
	createFoe()

	-- Remove Foes which have drifted off screen
	for i = #foesTable, 1, -1 do
		local thisFoe = foesTable[i]

		if ( thisFoe.x < -80 or
			 thisFoe.x > display.contentWidth + 80 or
			 thisFoe.y < -80 or
			 thisFoe.y > display.contentHeight + 80 )
		then
			display.remove( thisFoe )
			table.remove( foesTable, i )
		end
	end
end

local function restoreHero()

	hero.isBodyActive = false
	hero.x = display.contentCenterX
	hero.y = display.contentHeight - 250
	hero:setLinearVelocity( 0, 0)
	-- Fade in the hero
	transition.to( hero, { alpha=1, time=1000,
		onComplete = function()
			hero.isBodyActive = true
			died = false
		end
	} )
end

local function endGame()

	composer.setVariable( "finalScore", score )
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )

end

local function onLocalCollision(self, event)

	if ( event.selfElement == 2 and event.other.objType == "ground" ) then
		-- Foot sensor has entered (overlapped) a ground object
		if ( event.phase == "began" ) then
			self.sensorOverlaps = self.sensorOverlaps + 1
			-- Foot sensor has exited a ground object
		elseif ( event.phase == "ended" ) then
			self.sensorOverlaps = self.sensorOverlaps - 1
		end
	end

	if ( event.phase == "began" ) then

		-- local obj1 = event.self
		-- local obj2 = event.other

		if ( self.myName == "hero" and event.other.myName == "foe") then
				if (hero.sequence == "right-attack" or hero.sequence == "left-attack")
				then
					-- Remove both the hero and foe
					event.other.isSensor = true
					display.remove(event.other )

					for i = #foesTable, 1, -1 do
						if ( foesTable[i] == event.other ) then
							table.remove( foesTable, i )
							break
						end
					end
					-- Increase score
					score = score + 10
					scoreText.text = "Score: " .. score
			else
				if ( died == false ) then
					died = true

					-- Update lives
					lives = lives - 1
					livesText.text = "Lives: " .. lives

					if ( lives == 0 ) then
						display.remove( hero )
						timer.performWithDelay( 2000, endGame )
						atk_button:setEnabled( false )
						jump_button:setEnabled( false )
						right_button:setEnabled( false )
						left_button:setEnabled( false )
					else
						hero.alpha = 0
						timer.performWithDelay( 1000, restoreHero )
					end
				end
			end
		end
	end
end

-- Colision handler - Hero and ground
local function sensorCollide( self, event )
	-- Confirm that the colliding elements are the foot sensor and a ground object

end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause() -- Temporarily pause the physics engine

	-- Set up display groups
	backGroup = display.newGroup() -- Display group for the background image
	sceneGroup:insert( backGroup ) -- Insert into the scene's view group

	mainGroup = display.newGroup() -- Display group for the hero, foes, atks, etc.
	sceneGroup:insert( mainGroup ) -- Insert into the scene's view group

	uiGroup = display.newGroup()   -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )   -- Insert into the scene's view group

	-- Load the background
	local background = display.newImageRect( backGroup, "assets/img/bg1.png", display.actualContentWidth, display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-- Create ground object
	cw, ch = display.actualContentWidth, display.actualContentHeight
	ground = display.newRect( mainGroup, display.contentCenterX, ch+10, cw, 20 )
	ground.alpha = 0.000001
	ground.objType = "ground"
	physics.addBody( ground, "static", {friction = 32} )

	-- Load hero
	hero = display.newSprite( mainGroup, heroSheet, sequenceData)
	hero.x = display.contentCenterX
	hero.y = display.contentHeight - 250
	physics.addBody( hero, "dynamic")

	hero.sequenceData = "right-iddle"
	hero.isFixedRotation = true
	hero.sensorOverlaps = 0
	hero.myName = "hero"


	-- Associate collision handler function with hero
	hero.collision = onLocalCollision
	hero:addEventListener( "collision" )


	-- Display lives and score
	livesText = display.newText( uiGroup, "Lives: " .. lives, display.contentCenterX - 400, display.contentCenterY - 230, native.systemFont, 36 )
	livesText:setFillColor(0, 0, 0)
	scoreText = display.newText( uiGroup, "Score: " .. score, display.contentCenterX - 200, display.contentCenterY - 230, native.systemFont, 36 )
	scoreText:setFillColor(0, 0, 0)


musicTrack = audio.loadStream( "assets/audio/AW_02_Level_1.mp3")

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		system.activate( "multitouch" )
		physics.start()
		-- Runtime:addEventListener( "collision", onCollision )
		gameLoopTimer = timer.performWithDelay( 1300, gameLoop, 0 )
		--Runtime:addEventListener( "touch", touchAction )
		--hero:addEventListener( "touch", dragHero )

		-- Initialize widget
		widget = require("widget")

		-- Load gamepad start
		atk_button = widget.newButton( {
			-- The id can be used to tell you what button was pressed in your button event
			id = "atk_button",
			-- Size of the button
			width = 100,
			height = 100,
			-- This is the default button image
			defaultFile = "assets/img/atk_button.png",
			-- This is the pressed button image
			overFile = "assets/img/atk_button_on_press.png",
			-- Position of the button
			left = display.contentCenterX + 350,
			top = display.contentCenterY + 180,
			-- This tells it what function to call when you press the button
			onPress = atk
		} )

		jump_button = widget.newButton( {
			id = "jumpButton",
			width = 100,
			height = 100,
			defaultFile = "assets/img/jump_button.png",
			overFile = "assets/img/jump_button_on_press.png",
			left = display.contentCenterX + 240,
			top = display.contentCenterY + 180,
			onEvent = jump
		} )

		right_button = widget.newButton( {
			id = "right_button",
			width = 100,
			height = 100,
			defaultFile = "assets/img/right_button.png",
			overFile = "assets/img/right_button_on_press.png",
			left = 120,
			top = display.contentCenterY + 180,
			onEvent = moveRight
		} )

		left_button = widget.newButton( {
			id = "left_button",
			width = 100,
			height = 100,
			defaultFile = "assets/img/left_button.png",
			overFile = "assets/img/left_button_on_press.png",
			left = 10,
			top = display.contentCenterY + 180,
			onEvent = moveLeft
		} )

		atk_button.alpha = alpha;
		jump_button.alpha = alpha;
		right_button.alpha = alpha;
		left_button.alpha = alpha;

		uiGroup:insert( atk_button )
		uiGroup:insert( jump_button )
		uiGroup:insert( right_button )
		uiGroup:insert( left_button )
		-- Load gamepad end



		-- Start the music!
		audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		audio.stop( )
		composer.removeScene( "game" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
