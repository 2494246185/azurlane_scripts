local ActivityRemasterLoginPage = class("ActivityRemasterLoginPage", import("view.activity.CorePage.templatePage.CoreLoginSignTemplatePage"))

function ActivityRemasterLoginPage:OnInit()
	ActivityRemasterLoginPage.super.OnInit(self)

	self.bgImg = self.bg:GetComponent(typeof(Image))
	self.startTm = self.bg:Find("time"):GetComponent(typeof(Text))
	self.endTm = self.bg:Find("time/Text"):GetComponent(typeof(Text))
	self.timeLabel = self.bg:Find("time/label"):GetComponent(typeof(Text))
end

function ActivityRemasterLoginPage:OnFirstFlush()
	setActive(self.item, false)
	self.itemList:make(function(arg_3_0, arg_3_1, arg_3_2)
		if arg_3_0 == UIItemList.EventInit then
			local var_3_0 = Drop.Create(self.config.front_drops[arg_3_1 + 1])

			updateDrop(arg_3_2:Find("item"), var_3_0)
			onButton(self, arg_3_2, function()
				self:emit(BaseUI.ON_DROP, var_3_0)
			end, SFX_PANEL)
			GetImageSpriteFromAtlasAsync("ui/share/light_login_atlas", "DAY" .. arg_3_1 + 1, arg_3_2:Find("day"), true)
		elseif arg_3_0 == UIItemList.EventUpdate then
			local var_3_1 = arg_3_1 < self.nday

			setActive(arg_3_2:Find("got"), arg_3_1 < self.nday)
			setActive(arg_3_2:Find("get"), var_3_1)
			setActive(arg_3_2:Find("bg"), not var_3_1)
		end
	end)
	self:UpdateBg()
	self:UpdateTime()
end

function ActivityRemasterLoginPage:UpdateBg()
	self.bgImg.sprite = LoadSprite("ActRemasterBg/" .. (self.activity:getConfig("config_client").bg or "1"))
end

function ActivityRemasterLoginPage:UpdateTime()
	local var_6_0, var_6_1 = getProxy(ActivityRemasterProxy):InActTime()

	if not var_6_0 then
		return
	end

	self.startTm.text = pg.activity_re_timer[var_6_1].timer[2][1][2] .. "." .. pg.activity_re_timer[var_6_1].timer[2][1][3]
	self.endTm.text = pg.activity_re_timer[var_6_1].timer[3][1][2] .. "." .. pg.activity_re_timer[var_6_1].timer[3][1][3]
	self.timeLabel.text = i18n("act_remaster_tip_2", "")
end

return ActivityRemasterLoginPage
