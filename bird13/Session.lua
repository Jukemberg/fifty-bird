--[[
    Session Class

    The Session class represents a game session with all it's components
]]

Session = Class{}

SPAWN_TIMER = 2

function Session:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
    self.spawnTimer = SPAWN_TIMER
end

function Session:resume(bird, pipePairs, timer, score, spawnTimer)
    self.bird = bird
    self.pipePairs = pipePairs
    self.timer = timer
    self.score = score
    self.spawnTimer = spawnTimer
end