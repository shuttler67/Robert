class = require("classes")
camera = require("camera")

camera:setOffSet(love.window.getWidth()/2, love.window.getHeight()/2)
camera:setScale(2,2)

local Robert = class.new()
    
    function Robert:_init()
        self.image = love.graphics.newImage('Robert_new.png')
        self.particleSystem = love.graphics.newParticleSystem(love.graphics.newImage('smoke_particle.png'), 30)
        self.particleSystem:setSpin(-math.pi/2,math.pi/2)
        self.particleSystem:setParticleLifetime(2,2.5)
        self.particleSystem:setSizes(1.0, 0.9, 0.75, 0.6, 0.4, 0.3)
        self.particleSystem:setLinearAcceleration(-2, -3 , 2 , -5)
        self.particleSystem:setDirection(math.pi*1.7)
        self.particleSystem:setSpread(math.pi/3)
        self.particleSystem:setSpeed(60,80)
        self.particleSystem:setEmissionRate(9)
        self.particleSystem:start()
        
        self.isOnGround = false

        self.body = love.physics.newBody(world, 300, 300, "dynamic")
        self.shape = love.physics.newRectangleShape(170,280)
        self.fixture = love.physics.newFixture(self.body, self.shape, 0.1)
        --objects.robert.body:setFixedRotation(true)
        self.body:setLinearDamping(0.1)
        self.fixture:setFriction(0.99)
        self.fixture:setUserData("Robert")
    end

    function Robert:update(dt)
        self.isOnGround = false
        
        self.particleSystem:update(dt)
        
        vx,vy = self.body:getLinearVelocity()
        if vy == 0 or playerInContact then
            self.isOnGround = true
        end
        
        local force
        if self.isOnGround then
            force = 1800
        else
            force = 300
        end
      
        if love.keyboard.isDown( "a" ) then
            self.body:applyForce(-force,0)
        end
        if love.keyboard.isDown( "d" ) then
            self.body:applyForce(force,0)
        end
        
        local radians = self.body:getAngle()
        
        if radians >  0.08 or radians <  -0.08 then
            self.body:applyTorque(-radians*70000)
            
        elseif math.abs( self.body:getAngularVelocity() )> 1.5 then
            self.body:setAngularVelocity(0)
        end
    end
    
    function Robert:draw()
        love.graphics.setColor(255,255,255)
    
        local x,y = self.body:getPosition()
        love.graphics.draw(self.particleSystem, x + 30 , y + 20 )
        love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.image:getWidth()/2, self.image:getHeight()/2)
        --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    end
    
function love.load()
    love.window.setMode(650,650)
    love.window.setFullscreen(true)
    love.window.setTitle("Robert")
    love.graphics.setBackgroundColor(0,124,180)
    
    world = love.physics.newWorld(0,9.81*64, true)
    love.physics.setMeter(64)
    player = Robert()
    
    playerInContact = false
    world:setCallbacks(nil,nil,function (fixt1,fixt2,contact)
        nx, ny = contact:getNormal( )
        if math.abs(nx) < math.abs(ny) then
            if fixt1:getUserData() == "Robert" or fixt2:getUserData() == "Robert" then
                playerInContact = true end end end)
            
    
    objects = {}
    
    objects.ground = {}
    objects.ground.body = love.physics.newBody(world, 650/2, 650-200, "static")
    objects.ground.shape = love.physics.newRectangleShape(0,100,650,50)
    objects.ground.fixture = love.physics.newFixture(objects.ground.body , objects.ground.shape)
    objects.ground.shape2 = love.physics.newRectangleShape(200,100)
    objects.ground.fixture2 = love.physics.newFixture(objects.ground.body , objects.ground.shape2)

end

function love.update(dt)
    playerInContact = false
    
    world:update(dt)
    player:update(dt)
    
    if love.keyboard.isDown("r") then
        if love.keyboard.isDown("lshift","rshift") then
            camera:rotate(-math.pi/100)
        else
            camera:rotate(math.pi/100)
        end
    end
    
    local cx, cy = 0,0
    
    if love.keyboard.isDown("left") then
        cx = cx - 40
    end
    if love.keyboard.isDown("right") then
        cx = cx + 40
    end
    if love.keyboard.isDown("up") then
        cy = cy - 40
    end
    if love.keyboard.isDown("down") then
        cy = cy + 40
    end
    
    camera:move(cx,cy)
end

function love.keypressed(key)
    if key == "w" and player.isOnGround then
        player.body:applyLinearImpulse(0,-700)
    end
    if key == " " then
        player.body:setPosition(300,300)
    end
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    
    camera:set()
    
    love.graphics.setColor(0,0,0)
    love.graphics.print( player.fixture:getUserData() .."  " .. tostring(player.isOnGround),200,200)
    
    player:draw()
    
    love.graphics.setColor(72, 160, 14)
    for _,v in pairs(objects) do
        if v.shape:type() == "PolygonShape" then
            love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
            love.graphics.polygon("fill", v.body:getWorldPoints(v.shape2:getPoints()))
        end
    end
    
    camera:unset()
end




