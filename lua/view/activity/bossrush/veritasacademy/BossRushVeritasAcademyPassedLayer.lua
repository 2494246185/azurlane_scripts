local BossRushVeritasAcademyPassedLayer = class("BossRushVeritasAcademyPassedLayer", import("view.activity.BossRush.EscapeManor.BossRushEscapeManorPassedLayer"))

function BossRushVeritasAcademyPassedLayer:getUIName()
	return "BossRushVeritasAcademyPassedUI"
end

function BossRushVeritasAcademyPassedLayer:didEnter()
	pg.UIMgr.GetInstance():OverlayPanel(self._tf)

	local var_2_0 = {
		glow = true
	}

	eachChild(self._tf:Find("Main"), function(arg_3_0, arg_3_1)
		setActive(arg_3_0, var_2_0[arg_3_0.name] or arg_3_0.name == tostring(BossRushVeritasAcademyPassedLayer.seriesId))
	end)

	local function var_2_1(arg_4_0, arg_4_1)
		setActive(arg_4_0:Find("UnFinished"), arg_4_1 > 0)
		setActive(arg_4_0:Find("Challengeing"), arg_4_1 == 0)
		setActive(arg_4_0:Find("Finished"), arg_4_1 < 0)
	end

	local function var_2_2(arg_5_0, arg_5_1)
		setSlider(self.rtSlider, 0, arg_5_1 - 1, arg_5_0 - 1)
		UIItemList.StaticAlign(self.rtContent, self.rtTpl, arg_5_1 - 1, function(arg_6_0, arg_6_1, arg_6_2)
			arg_6_1 = arg_6_1 + 1

			if arg_6_0 == UIItemList.EventUpdate then
				var_2_1(arg_6_2:Find("left"), arg_6_1 - arg_5_0)
				var_2_1(arg_6_2:Find("right"), arg_6_1 + 1 - arg_5_0)
			end
		end)
	end

	seriesAsync({
		function(arg_7_0)
			var_2_2(self.contextData.curIndex, self.contextData.maxIndex)
			onDelayTick(arg_7_0, 0.5)
		end
	}, function()
		var_2_1(self.rtContent:GetChild(self.contextData.curIndex - 1):Find("left"), -1)

		if self.contextData.curIndex > 1 then
			var_2_1(self.rtContent:GetChild(self.contextData.curIndex - 2):Find("right"), -1)
		end

		self:combatPreload(function()
			seriesAsync({
				function(arg_10_0)
					var_2_2(self.contextData.curIndex + 1, self.contextData.maxIndex)
					onDelayTick(arg_10_0, 1.5)
				end
			}, function()
				self:emit(ChallengePassedCombatLoadMediator.FINISH, self._loadObs)
			end)
		end)
	end)
end

return BossRushVeritasAcademyPassedLayer
