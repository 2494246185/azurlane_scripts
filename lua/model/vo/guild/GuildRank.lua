local GuildRank = class("GuildRank")

function GuildRank:Ctor(arg_1_1)
	self.id = arg_1_1
	self.weekScore = 0
	self.monthScore = 0
	self.totalScore = 0
end

function GuildRank:GetName()
	return self.name
end

function GuildRank:SetName(arg_3_1)
	self.name = arg_3_1
end

function GuildRank:SetWeekScore(arg_4_1)
	self.weekScore = arg_4_1
end

function GuildRank:SetMonthScore(arg_5_1)
	self.monthScore = arg_5_1
end

function GuildRank:SetTotalScore(arg_6_1)
	self.totalScore = arg_6_1
end

function GuildRank:SetScore(arg_7_1, arg_7_2)
	if arg_7_1 == 1 then
		self:SetWeekScore(arg_7_2)
	elseif arg_7_1 == 2 then
		self:SetMonthScore(arg_7_2)
	elseif arg_7_1 == 3 then
		self:SetTotalScore(arg_7_2)
	end
end

function GuildRank:GetWeekScore()
	return self.weekScore
end

function GuildRank:GetMonthScore()
	return self.monthScore
end

function GuildRank:GetTotalScore()
	return self.totalScore
end

function GuildRank:GetScore(arg_11_1)
	if arg_11_1 == 0 then
		return self:GetWeekScore()
	elseif arg_11_1 == 1 then
		return self:GetMonthScore()
	elseif arg_11_1 == 2 then
		return self:GetTotalScore()
	end
end

return GuildRank
