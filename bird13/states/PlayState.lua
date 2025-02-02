--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288
GAP_HEIGHT = 120

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init(params)
    self.session = Session()
    if params then
        self.session.resume(
            params.bird,
            params.pipePairs,
            params.timer,
            params.score,
            params.spawnTimer
        )
    end
    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    -- update timer for pipe spawning
    self.session.timer = self.session.timer + dt

    -- spawn a new pipe pair every second and a half
    if self.session.timer > self.session.spawnTimer then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        local y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y

        local gap = GAP_HEIGHT + math.random(-10, 10)

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.session.pipePairs, PipePair(y, gap))

        -- reset timer
        self.session.timer = 0
        self.session.spawnTimer = SPAWN_TIMER + math.random()
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.session.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.session.bird.x then
                self.session.score = self.session.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.session.pipePairs) do
        if pair.remove then
            table.remove(self.session.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.session.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.session.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', self.session.score)
            end
        end
    end

    -- update bird based on gravity and input
    self.session.bird:update(dt)

    -- reset if we get to the ground
    if self.session.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()

        gStateMachine:change('score', self.session.score)
    end

    if love.keyboard.wasPressed('P') or love.keyboard.wasPressed('p') then
        gStateMachine:change('pause', {
            bird = self.session.bird,
            pipePairs = self.session.pipePairs,
            timer = self.session.timer,
            score = self.session.score,
            spawnTimer = self.session.spawnTimer;
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.session.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.session.score), 8, 8)

    self.session.bird:render()
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end