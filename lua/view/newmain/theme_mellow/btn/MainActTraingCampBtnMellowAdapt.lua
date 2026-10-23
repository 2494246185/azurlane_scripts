local MainActTraingCampBtnMellowAdapt = class("MainActTraingCampBtnMellowAdapt", import(".MainDifferentStyleSpActBtnAdapt"))

function MainActTraingCampBtnMellowAdapt:GetContainer()
	return self.root:Find("left/list")
end

function MainActTraingCampBtnMellowAdapt:OnRegister()
	self.redDotUI = self._tf:Find("tip")

	pg.EasyRedDotMgr.GetInstance():RegisterRedDot(self.redDotUI, {
		"COMMANDER_MANUAL"
	}, function(arg_3_0)
		local var_3_0, var_3_1 = TechnologyConst.isTecActOn()
		local var_3_2 = getProxy(CommanderManualProxy):ShouldShowTaskOrGuideTip()

		var_3_2 = var_3_2 or var_3_1

		setActive(arg_3_0, var_3_2)
	end)
	self._tf:SetAsFirstSibling()
end

function MainActTraingCampBtnMellowAdapt:OnClear()
	if self.redDotUI then
		pg.EasyRedDotMgr.GetInstance():UnRegisterRedDot(self.redDotUI)

		self.redDotUI = nil
	end
end

return MainActTraingCampBtnMellowAdapt
