local Trophy = class("Trophy", import(".BaseVO"))

Trophy.INTAMACT_TYPE = 1043
Trophy.COMPLEX_TROPHY_TYPE = 160
Trophy.ALWAYS_SHOW = 0
Trophy.ALWAYS_HIDE = 1
Trophy.HIDE_BEFORE_UNLOCK = 2
Trophy.COMING_SOON = 3

function Trophy:Ctor(arg_1_1)
	self.id = arg_1_1.id
	self.configId = arg_1_1.id
	self.subTrophyList = {}

	self:update(arg_1_1)
end

function Trophy:generateDummyTrophy()
	return (Trophy.New({
		timestamp = -1,
		progress = 0,
		id = self
	}))
end

function Trophy:bindConfigTable()
	return pg.medal_template
end

function Trophy:update(arg_4_1)
	self.progress = arg_4_1.progress
	self.timestamp = arg_4_1.timestamp
	self.new = arg_4_1.new
end

function Trophy:isNew()
	return self.isNew == true
end

function Trophy:clearNew()
	self.isNew = nil
end

function Trophy:updateTimeStamp(arg_7_1)
	if arg_7_1 > 0 then
		self.isNew = true
	end

	self.timestamp = arg_7_1
end

function Trophy:isComplexTrophy()
	return self:getConfig("target_type") == self.COMPLEX_TROPHY_TYPE
end

function Trophy:bindTrophys(arg_9_1)
	self.subTrophyList[arg_9_1.id] = arg_9_1
end

function Trophy:getSubTrophy()
	return self.subTrophyList
end

function Trophy:getTargetID()
	return self:getConfig("target_id")
end

function Trophy:canClaimed()
	return self:getProgressRate() >= 1
end

function Trophy:isClaimed()
	return self.timestamp > 0
end

function Trophy:isDummy()
	return self.timestamp == -1
end

function Trophy:getProgressRate()
	local var_15_0, var_15_1 = self:getProgress()

	return var_15_0 / var_15_1
end

function Trophy:getProgress()
	if self:isComplexTrophy() then
		local var_16_0 = 0

		for iter_16_0, iter_16_1 in pairs(self.subTrophyList) do
			if iter_16_1:isClaimed() then
				var_16_0 = var_16_0 + 1
			end
		end

		return var_16_0, self:getConfig("target_num")
	else
		return self.progress, self:getConfig("target_num")
	end
end

function Trophy:getHideType()
	return self:getConfig("hide")
end

function Trophy:isHide()
	local var_18_0 = self:getConfig("hide")

	if var_18_0 == Trophy.ALWAYS_HIDE then
		return true
	elseif var_18_0 == Trophy.HIDE_BEFORE_UNLOCK and self.timestamp <= 0 then
		return true
	else
		return false
	end
end

function Trophy:isMaxLevel()
	local var_19_0 = self:getConfig("next")

	return var_19_0 == 0 or self:bindConfigTable()[var_19_0] == nil
end

function Trophy:getTargetType()
	return self:getConfig("target_type")
end

function Trophy:isLoverLetter()
	return self.id > 1000000000
end

function Trophy:IsLoveLetterID()
	return self > 1000000000
end

return Trophy
