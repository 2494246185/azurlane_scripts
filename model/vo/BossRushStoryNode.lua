local BossRushStoryNode = class("BossRushStoryNode", import("model.vo.BaseVO"))

BossRushStoryNode.TRIGGER_TYPE = {
	HIDE_READED = 4,
	ANY_STORY_READED = 6,
	STORY_READED = 3,
	SERIES_PASSED = 2,
	PT_GOT = 1,
	STORY_BRANCH = 5
}
BossRushStoryNode.NODE_TYPE = {
	BATTLE = 3,
	LOCATION = 4,
	NORMAL = 1,
	EVENT = 2
}
BossRushStoryNode.REPEATABLE_KEY = "repeatable"

function BossRushStoryNode:bindConfigTable()
	return pg.activity_series_enemy_story
end

function BossRushStoryNode:Ctor(arg_2_1, ...)
	BossRushStoryNode.super.Ctor(self, arg_2_1, ...)

	self.configId = self.id
end

function BossRushStoryNode:GetTriggers()
	local function var_3_0(arg_4_0)
		if type(arg_4_0) ~= "table" then
			return {}
		end

		return arg_4_0
	end

	local var_3_1 = var_3_0(self:getConfig("trigger_type"))
	local var_3_2 = var_3_0(self:getConfig("trigger_value"))
	local var_3_3 = {}

	for iter_3_0 = 1, #var_3_1 do
		table.insert(var_3_3, {
			type = var_3_1[iter_3_0],
			value = var_3_2[iter_3_0]
		})
	end

	return var_3_3
end

function BossRushStoryNode:IsActive(arg_5_1, arg_5_2)
	return underscore.all(self:GetTriggers(), function(arg_6_0)
		return self:_IsActive(arg_5_1, arg_5_2, arg_6_0)
	end)
end

function BossRushStoryNode:_IsActive(arg_7_1, arg_7_2, arg_7_3)
	return switch(arg_7_3.type, {
		[BossRushStoryNode.TRIGGER_TYPE.PT_GOT] = function()
			return arg_7_2.data1 >= arg_7_3.value
		end,
		[BossRushStoryNode.TRIGGER_TYPE.SERIES_PASSED] = function()
			return BossRushSeriesData.New({
				id = arg_7_3.value,
				actId = arg_7_1.id
			}):IsUnlock(arg_7_1)
		end,
		[BossRushStoryNode.TRIGGER_TYPE.STORY_READED] = function()
			return BossRushStoryNode.New({
				id = arg_7_3.value
			}):IsReaded()
		end,
		[BossRushStoryNode.TRIGGER_TYPE.HIDE_READED] = function()
			return not BossRushStoryNode.New({
				id = arg_7_3.value
			}):IsReaded()
		end,
		[BossRushStoryNode.TRIGGER_TYPE.STORY_BRANCH] = function()
			return self:IsActiveBranchType(arg_7_1.id, arg_7_3.value)
		end,
		[BossRushStoryNode.TRIGGER_TYPE.ANY_STORY_READED] = function()
			return underscore.any(arg_7_3.value, function(arg_14_0)
				return BossRushStoryNode.New({
					id = arg_14_0
				}):IsReaded()
			end)
		end
	}, function()
		return false
	end)
end

function BossRushStoryNode:IsReaded()
	local var_16_0 = self:GetStory()

	if var_16_0 and var_16_0 ~= "" then
		return tobool(pg.NewStoryMgr.GetInstance():IsPlayed(var_16_0))
	else
		return true
	end
end

function BossRushStoryNode:IsActiveBranchType(arg_17_1, arg_17_2)
	local var_17_0 = arg_17_2[2]

	if not BossRushStoryNode.New({
		id = arg_17_2[1]
	}):IsReaded() then
		return false
	end

	if underscore.any(arg_17_2[3], function(arg_18_0)
		return not BossRushStoryNode.New({
			id = arg_18_0
		}):IsReaded()
	end) then
		return true
	end

	local var_17_1 = BossRushStoryNode.GetLocalBranchFlag(arg_17_1, arg_17_2[1])

	return var_17_1 == 0 or var_17_1 == var_17_0
end

function BossRushStoryNode:IsLockBranchType(arg_19_1, arg_19_2)
	local var_19_0 = self:GetTriggers()

	if underscore.all(var_19_0, function(arg_20_0)
		return arg_20_0.type ~= BossRushStoryNode.TRIGGER_TYPE.STORY_BRANCH
	end) then
		return false
	end

	return underscore.all(var_19_0, function(arg_21_0)
		if arg_21_0.type == BossRushStoryNode.TRIGGER_TYPE.STORY_BRANCH then
			if not BossRushStoryNode.New({
				id = arg_21_0.value[1]
			}):IsReaded() then
				return false
			end

			return not BossRushStoryNode:IsActiveBranchType(arg_19_1.id, arg_21_0.value)
		else
			return self:_IsActive(arg_19_1, arg_19_2, arg_21_0)
		end
	end)
end

function BossRushStoryNode:GetType()
	return self:getConfig("type")
end

function BossRushStoryNode:GetName()
	return self:getConfig("name")
end

function BossRushStoryNode:GetIconName()
	return self:getConfig("icon")
end

function BossRushStoryNode:GetStory()
	return self:getConfig("story")
end

function BossRushStoryNode:GetActiveLink()
	return self:getConfig("line")
end

function BossRushStoryNode:GetCleanBG()
	return noEmptyStr(self:getConfig("change_background"))
end

function BossRushStoryNode:GetCleanBGM()
	return noEmptyStr(self:getConfig("change_bgm"))
end

function BossRushStoryNode:GetCleanAnimator()
	return noEmptyStr(self:getConfig("change_prefab"))
end

function BossRushStoryNode:GetParams(arg_30_1)
	local var_30_0 = noEmptyStr(self:getConfig("params"))

	if not var_30_0 then
		return nil
	end

	for iter_30_0, iter_30_1 in ipairs(var_30_0) do
		if iter_30_1[1] == arg_30_1 then
			return iter_30_1
		end
	end

	return nil
end

function BossRushStoryNode:IsRecrew()
	local var_31_0 = self:getConfig("label_key")

	if type(var_31_0) ~= "table" then
		return nil
	end

	local var_31_1 = StoryStep.GetGlobalFlagKey(var_31_0.flagID) .. var_31_0.flagIndex

	if not PlayerPrefs.HasKey(var_31_1) then
		return nil
	end

	return PlayerPrefs.GetInt(var_31_1) > 0
end

function BossRushStoryNode:GetBranchFlagKey(arg_32_1)
	return string.format("BossRushStoryNode_BranchSel_%s_%s_%s", getProxy(PlayerProxy):getRawData().id, self, arg_32_1)
end

function BossRushStoryNode:GetLocalBranchFlag(arg_33_1)
	return PlayerPrefs.GetInt(BossRushStoryNode.GetBranchFlagKey(self, arg_33_1), 0)
end

function BossRushStoryNode:SetLocalBranchFlag(arg_34_1, arg_34_2)
	PlayerPrefs.SetInt(BossRushStoryNode.GetBranchFlagKey(self, arg_34_1), arg_34_2)
	PlayerPrefs.Save()
end

return BossRushStoryNode
