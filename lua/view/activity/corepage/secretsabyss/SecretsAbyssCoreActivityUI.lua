local SecretsAbyssCoreActivityUI = class("SecretsAbyssCoreActivityUI", import("view.activity.CorePage.CoreActivityMainScene"))

function SecretsAbyssCoreActivityUI:getUIName()
	return "SecretsAbyssCoreActivityUI"
end

SecretsAbyssCoreActivityUI.optionsPath = {
	"adapt/TopPage/top/btn_home"
}

function SecretsAbyssCoreActivityUI:init(...)
	SecretsAbyssCoreActivityUI.super.init(self, ...)
	quickPlayAnimation(self._tf:Find("adapt/TopPage/top"), "Anim_SecretsAbyssCoreActivityUI_top_In")
	setText(self._tf:Find("adapt/TopPage/top/deco/Text"), i18n("masaina_main_title"))
	setText(self._tf:Find("adapt/TopPage/top/deco/Text/Text_1"), i18n("masaina_main_title_en"))

	local var_2_0

	self.tabsList:make(function(arg_3_0, arg_3_1, arg_3_2)
		if arg_3_0 == UIItemList.EventUpdate then
			local var_3_0 = underscore.detect(self.activities, function(arg_4_0)
				return tostring(arg_4_0:getConfig("is_show")) == arg_3_2.name
			end)

			if not var_3_0 or var_3_0:isEnd() then
				setActive(arg_3_2, false)
			elseif not self.pageDic[var_3_0.id] then
				warning(string.format("without page in act:", var_3_0.id))
			else
				self:UpdateBtnText(var_3_0, arg_3_2)

				if self.pageDic[var_3_0.id] ~= nil then
					setActive(arg_3_2:Find("tip"), var_3_0:readyToAchieve())
					onToggle(self, arg_3_2, function(arg_5_0)
						if arg_5_0 then
							self:selectActivity(var_3_0)

							if var_2_0 ~= var_3_0.id then
								quickPlayAnimation(arg_3_2, "Anim_SecretsAbyssCoreActivityUI_tabs_on_In")
							end

							var_2_0 = var_3_0.id
						end
					end, SFX_PANEL)
				end
			end
		end
	end)

	self.camEventId = pg.CameraFixMgr.GetInstance():bind(pg.CameraFixMgr.ASPECT_RATIO_UPDATE, function(arg_6_0, arg_6_1)
		self:UpdateAdapt()
	end)

	self:UpdateAdapt()
	onButton(self, self._tf:Find("adapt/TopPage/top/btn_back"), function()
		self:emit(SecretsAbyssCoreActivityUI.ON_BACK)
	end, SOUND_BACK)
end

function SecretsAbyssCoreActivityUI:UpdateBtnText(arg_8_1, arg_8_2)
	local var_8_0 = arg_8_1:getConfig("title_res_tag")

	if pg.gametip[var_8_0] then
		local var_8_1 = i18n(var_8_0)

		setText(arg_8_2:Find("off/name"), var_8_1)
		setText(arg_8_2:Find("on/name"), var_8_1)
	else
		setText(arg_8_2:Find("off/name"), i18n("masaina_main_sheet" .. arg_8_1:getConfig("is_show")))
		setText(arg_8_2:Find("on/name"), i18n("masaina_main_sheet" .. arg_8_1:getConfig("is_show")))
	end
end

function SecretsAbyssCoreActivityUI:UpdateAdapt()
	local var_9_0 = pg.CameraFixMgr.GetInstance()

	self._tf:GetComponent(typeof(AspectRatioFitter)).aspectRatio = math.clamp(var_9_0.currentWidth / var_9_0.currentHeight, 1.3333333333333333, 2.1666666666666665)
end

function SecretsAbyssCoreActivityUI:willExit()
	SecretsAbyssCoreActivityUI.super.willExit(self)

	if self.camEventId then
		pg.CameraFixMgr.GetInstance():disconnect(self.camEventId)

		self.camEventId = nil
	end
end

return SecretsAbyssCoreActivityUI
