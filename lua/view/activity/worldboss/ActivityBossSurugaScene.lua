local ActivityBossSurugaScene = class("ActivityBossSurugaScene", import(".ActivityBossSceneTemplate"))

function ActivityBossSurugaScene:getUIName()
	return "ActivityBossUI"
end

function ActivityBossSurugaScene:getResource()
	local var_2_0 = ActivityBossSurugaScene.super.getResource(self)

	table.insert(var_2_0, "ui/cysx_fk")

	return var_2_0
end

function ActivityBossSurugaScene:preload(arg_3_1)
	local var_3_0 = PoolMgr.GetInstance()

	var_3_0:GetPrefab("ui/cysx_fk", "cysx_fk", true, function(arg_4_0)
		var_3_0:ReturnPrefab("ui/cysx_fk", "cysx_fk", arg_4_0)
		arg_3_1()
	end)
end

function ActivityBossSurugaScene:init()
	ActivityBossSurugaScene.super.init(self)
	setText(self.rankTF:Find("title/Text"), i18n("word_billboard"))

	self.loader = AutoLoader.New()
end

function ActivityBossSurugaScene:didEnter()
	ActivityBossSurugaScene.super.didEnter(self)
	self.loader:GetPrefab("ui/cysx_fk", "cysx_fk", function(arg_7_0)
		setParent(arg_7_0, self.left)
		setAnchoredPosition(arg_7_0, Vector2(69, 295))
		arg_7_0.transform:SetAsFirstSibling()
	end)
end

function ActivityBossSurugaScene:UpdateRank(arg_8_1)
	arg_8_1 = arg_8_1 or {}

	for iter_8_0 = 1, #self.rankList do
		local var_8_0 = self.rankList[iter_8_0]

		setActive(self.rankList[iter_8_0], iter_8_0 <= #arg_8_1)

		if iter_8_0 <= #arg_8_1 then
			setText(var_8_0:Find("name/Text"), tostring(arg_8_1[iter_8_0].name))
			setText(var_8_0:Find("num/Text"), "NO." .. iter_8_0)
		end
	end
end

function ActivityBossSurugaScene:UpdateDropItems()
	for iter_9_0, iter_9_1 in ipairs(self.contextData.DisplayItems or {}) do
		local var_9_1 = self.barList[iter_9_0]:Find("milestone/item")
		local var_9_2 = {
			type = self.contextData.DisplayItems[5 - iter_9_0][1],
			id = self.contextData.DisplayItems[5 - iter_9_0][2],
			count = self.contextData.DisplayItems[5 - iter_9_0][3]
		}

		updateDrop(var_9_1, var_9_2)
		onButton(self, var_9_1, function()
			self:emit(ActivityBossSurugaScene.ON_DROP, var_9_2)
		end, SFX_PANEL)
	end
end

function ActivityBossSurugaScene:willExit()
	ActivityBossSurugaScene.super.willExit(self)
	self.loader:Clear()
end

return ActivityBossSurugaScene
