local LevelAwardPage = class("LevelAwardPage", import("...base.BaseActivityPage"))

function LevelAwardPage:getResource()
	local var_1_0 = {
		"ui/activityuipage/level_award_atlas"
	}

	table.insertto(var_1_0, LevelAwardPage.super.getResource(self))

	return var_1_0
end

function LevelAwardPage:OnInit()
	self.bg = self._tf:Find("bg")
	self.award = self._tf:Find("scroll/award")
	self.content = self._tf:Find("scroll/content")
	self.scrollTF = self._tf:Find("scroll")
	self.pageSignDownTF = self._tf:Find("sign")
	self.pageSignUpTF = self._tf:Find("sign_up")
end

function LevelAwardPage:OnDataSetting()
	self.config = pg.activity_level_award[self.activity:getConfig("config_id")]
end

function LevelAwardPage:OnFirstFlush()
	setActive(self.award, false)

	for iter_4_0 = 1, #self.config.front_drops do
		local var_4_0 = self.config.front_drops[iter_4_0][1]
		local var_4_1 = cloneTplTo(self.award, self.content, "award" .. tostring(iter_4_0))
		local var_4_2 = var_4_1:Find("limit_label/labelLevel")
		local var_4_3 = var_4_1:Find("btnAchieve")
		local var_4_4 = var_4_1:Find("items")
		local var_4_5 = var_4_1:Find("item")

		setActive(var_4_5, false)
		GetImageSpriteFromAtlasAsync("ui/activityuipage/level_award_atlas", tostring(self.config.front_drops[iter_4_0][1]), var_4_2, true)

		for iter_4_1 = 2, #self.config.front_drops[iter_4_0] do
			local var_4_6 = cloneTplTo(var_4_5, var_4_4)
			local var_4_7 = {
				type = self.config.front_drops[iter_4_0][iter_4_1][1],
				id = self.config.front_drops[iter_4_0][iter_4_1][2],
				count = self.config.front_drops[iter_4_0][iter_4_1][3]
			}

			updateDrop(var_4_6, var_4_7)
			onButton(self, var_4_6, function()
				self:emit(BaseUI.ON_DROP, var_4_7)
			end, SFX_PANEL)
		end

		onButton(self, var_4_3, function()
			self:emit(ActivityMediator.EVENT_OPERATION, {
				cmd = 1,
				activity_id = self.activity.id,
				arg1 = var_4_0
			})
		end, SFX_PANEL)
		onScroll(self, self.scrollTF, function(arg_7_0)
			setActive(self.pageSignDownTF, arg_7_0.y > 0.01)
			setActive(self.pageSignUpTF, arg_7_0.y < 0.99)
		end)
	end
end

function LevelAwardPage:OnUpdateFlush()
	for iter_8_0 = 1, #self.config.front_drops do
		local var_8_0 = self.config.front_drops[iter_8_0]
		local var_8_1 = self.content:Find("award" .. tostring(iter_8_0))
		local var_8_2 = var_8_1:Find("btnAchieve")
		local var_8_3 = var_8_1:Find("achieve_sign")
		local var_8_4 = _.include(self.activity.data1_list, self.config.front_drops[iter_8_0][1])

		if var_8_4 then
			var_8_1.transform:SetAsLastSibling()
		end

		setGray(var_8_1:Find("limit_label"), var_8_4)
		setGray(var_8_1:Find("items"), var_8_4)
		setActive(var_8_3, var_8_4)
		setActive(var_8_2, self.shareData.player.level >= var_8_0[1] and not var_8_4)
	end
end

function LevelAwardPage:OnDestroy()
	return
end

return LevelAwardPage
