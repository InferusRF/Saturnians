require "/items/active/weapons/melee/meleeslash.lua"

-- Spear stab attack
-- Extends normal melee attack and adds a hold state
KytaDrillSpearStab = MeleeSlash:new()

function KytaDrillSpearStab:init()
  MeleeSlash.init(self)

  self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
  self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage
end

function KytaDrillSpearStab:fire()
  animator.setAnimationState("drill", "active1")

  MeleeSlash.fire(self)
  self.tileDamageTimer = 0

  animator.setAnimationState("drill", "idle")

  if self.fireMode == "primary" and self.allowHold ~= false then
    self:setState(self.hold)
  else 
  self.cooldownTimer = self:cooldownTime()
  end
end

function KytaDrillSpearStab:hold()
  self.weapon:setStance(self.stances.hold)
  self.weapon:updateAim()

  animator.setAnimationState("drill", "active1")

  while self.fireMode == "primary" do
    local damageArea = partDamageArea("spear")
    self.weapon:setDamage(self.holdDamageConfig, damageArea)
	
	self.tileDamageTimer = math.max(0, self.tileDamageTimer - self.dt)
    if self.tileDamageTimer == 0 then
      self.tileDamageTimer = self.tileDamageRate
      self:damageTiles()
    end
    coroutine.yield()
  end
  

  animator.setAnimationState("drill", "idle")

  self.cooldownTimer = self:cooldownTime()
end

function KytaDrillSpearStab:damageTiles()
  local pos = mcontroller.position()
  local tipPosition = vec2.add(pos, activeItem.handPosition(animator.partPoint("drillenergy", "drillTip")))
  for i = 1, 3 do
    local sourcePosition = vec2.add(pos, activeItem.handPosition(animator.partPoint("drillenergy", "drillSource" .. i)))
    local drillTiles = world.collisionBlocksAlongLine(sourcePosition, tipPosition, nil, self.damageTileDepth)
    if #drillTiles > 0 then
      world.damageTiles(drillTiles, "foreground", sourcePosition, "blockish", self.tileDamage, 99, activeItem.ownerEntityId())
      world.damageTiles(drillTiles, "background", sourcePosition, "blockish", self.tileDamage, 99, activeItem.ownerEntityId())
    end
  end
end
