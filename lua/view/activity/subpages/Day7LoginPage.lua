local Day7LoginPage = class("Day7LoginPage", import("...base.BaseActivityPage"))

function Day7LoginPage:getResource()
	local var_1_0 = {
		"ui/activityuipage/day7_login_atlas"
	}

	table.insertto(var_1_0, Day7LoginPage.super.getResource(self))

	return var_1_0
end

function Day7LoginPage:OnInit()
	self.bg = self._tf:Find("bg")
	self.labelDay = self._tf:Find("days")
	self.items = self._tf:Find("items")
	self.item = self._tf:Find("item")
end

function Day7LoginPage:OnDataSetting()
	self.config = pg.activity_7_day_sign[self.activity:getConfig("config_id")]
end

function Day7LoginPage:OnFirstFlush()
	setActive(self.item, false)

	for iter_4_0 = 1, 7 do
		local var_4_0 = cloneTplTo(self.item, self.items)
		local var_4_1 = Drop.Create(self.config.front_drops[iter_4_0])

		updateDrop(var_4_0:Find("item"), var_4_1)
		onButton(self, var_4_0, function()
			self:emit(BaseUI.ON_DROP, var_4_1)
		end, SFX_PANEL)
	end
end

function Day7LoginPage:OnUpdateFlush()
	GetImageSpriteFromAtlasAsync("ui/activityuipage/day7_login_atlas", string.format("0%d", math.max(self.activity.data1, 1)), self.labelDay, true)

	for iter_6_0 = 1, 7 do
		local var_6_0 = self.items:GetChild(iter_6_0 - 1)
		local var_6_1 = iter_6_0 <= self.activity.data1

		GetImageSpriteFromAtlasAsync("ui/activityuipage/day7_login_atlas", string.format("day%d", iter_6_0) .. (iter_6_0 <= self.activity.data1 and "_sel" or ""), var_6_0:Find("day"), true)
		setActive(var_6_0:Find("got"), var_6_1)
	end
end

function Day7LoginPage:OnDestroy()
	clearImageSprite(self.bg)
	removeAllChildren(self.items)
end

return Day7LoginPage
