--[[
    PauseState Class
    
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PauseState is triggered when the player presses the 'P' key and stops the game 
    allowing the player to resume when he prefers
]]

PauseState = Class{__includes = BaseState}

function PauseState:init(params)
    self.params = params
    -- nothing
end

function PauseState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown', self.params)
    end
end

function PauseState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Pause', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press Enter to resume', 0, 100, VIRTUAL_WIDTH, 'center')
end