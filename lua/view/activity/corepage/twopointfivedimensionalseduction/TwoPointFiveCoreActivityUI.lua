local TwoPointFiveCoreActivityUI = class("TwoPointFiveCoreActivityUI", import("view.activity.CorePage.CoreActivityMainScene"))

TwoPointFiveCoreActivityUI.TIME_RES_BG = "time_bg"

function TwoPointFiveCoreActivityUI:getUIName()
	return "TwoPointFiveCoreActivityUI"
end

TwoPointFiveCoreActivityUI.optionsPath = {
	"adapt/TopPage/top/btn_home"
}

function TwoPointFiveCoreActivityUI:init(...)
	TwoPointFiveCoreActivityUI.super.init(self, ...)

	self.topPage = self._tf:Find("adapt/TopPage")
	self.btnBack = self.topPage:Find("top/btn_back")
	self.resTime = self._tf:Find("adapt/TopPage/top/resTime/Text")
	self.resTimebg = self._tf:Find("adapt/TopPage/top/resTime")

	setActive(self.upper, true)
	onButton(self, self._tf:Find("adapt/shop_btn"), function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.SKINSHOP)
	end, SFX_PANEL)
	setText(self._tf:Find("adapt/TopPage/top/deco/Text"), i18n("HelenaCoreActivity_title"))
	setText(self._tf:Find("adapt/TopPage/top/deco/Text/Text_1"), i18n("HelenaCoreActivity_title2"))

	local var_2_0

	self.tabsList:make(function(arg_4_0, arg_4_1, arg_4_2)
		if arg_4_0 == UIItemList.EventUpdate then
			local var_4_0 = underscore.detect(self.activities, function(arg_5_0)
				return tostring(arg_5_0:getConfig("is_show")) == arg_4_2.name
			end)

			if not var_4_0 or var_4_0:isEnd() then
				setActive(arg_4_2, false)
			elseif not self.pageDic[var_4_0.id] then
				warning(string.format("without page in act:", var_4_0.id))
			else
				self:OnToggleName(arg_4_2, var_4_0)

				if self.pageDic[var_4_0.id] ~= nil then
					setActive(arg_4_2:Find("tip"), var_4_0:readyToAchieve())
					self:UpdateTabTipPosition(arg_4_2, GetComponent(arg_4_2, typeof(Toggle)).isOn)
					onToggle(self, arg_4_2, function(arg_6_0)
						if arg_6_0 then
							if var_2_0 ~= var_4_0.id then
								self:refreshTime(var_4_0)
								self:selectActivity(var_4_0)
							end

							var_2_0 = var_4_0.id
						end

						setActive(arg_4_2:Find("off"), not arg_6_0)
						setActive(arg_4_2:Find("on"), arg_6_0)
						self:UpdateTabTipPosition(arg_4_2, arg_6_0)
						self:ScheduleTabTipPositions()
					end, SFX_PANEL)
					self:ScheduleTabTipPositions()
				end
			end
		end
	end)
end

function TwoPointFiveCoreActivityUI:ScheduleTabTipPositions()
	if self.tabTipPositionsPending then
		return
	end

	self.tabTipPositionsPending = true

	onNextTick(function()
		self.tabTipPositionsPending = false

		if self.exited or IsNil(self.tabs) then
			return
		end

		Canvas.ForceUpdateCanvases()

		for iter_8_0 = 0, self.tabs.childCount - 1 do
			local var_8_0 = self.tabs:GetChild(iter_8_0)

			if var_8_0.gameObject.activeSelf then
				self:UpdateTabTipPosition(var_8_0, GetComponent(var_8_0, typeof(Toggle)).isOn)
			end
		end
	end)
end

function TwoPointFiveCoreActivityUI:UpdateTabTipPosition(arg_9_1, arg_9_2)
	local var_9_0 = arg_9_1:Find(arg_9_2 and "on" or "off"):Find("imgName")
	local var_9_1 = arg_9_1:Find("tip")
	local var_9_2 = var_9_1.parent:InverseTransformPoint(var_9_0:TransformPoint(Vector3(var_9_0.rect.xMax, var_9_0.rect.yMax, 0)))

	setLocalPosition(var_9_1, {
		x = var_9_2.x,
		y = var_9_2.y
	})
end

function TwoPointFiveCoreActivityUI:IsImageTgName()
	return true
end

function TwoPointFiveCoreActivityUI:ActiveScenarioLayer(arg_11_1)
	self.contextData.activeScenario = arg_11_1
end

function TwoPointFiveCoreActivityUI:refreshTime(arg_12_1)
	local var_12_0 = arg_12_1.stopTime - pg.TimeMgr.GetInstance():GetServerTime()

	setText(self.resTime, i18n("nier_core_countdown", math.floor(var_12_0 / 86400), math.floor(var_12_0 % 86400 / 3600)))
	GetImageSpriteFromAtlasAsync("ui/" .. string.lower(arg_12_1:getConfig("page_info").class_name) .. "_atlas", TwoPointFiveCoreActivityUI.TIME_RES_BG, self.resTimebg)
end

return TwoPointFiveCoreActivityUI
