local MainSplitPackSequence = class("MainSplitPackSequence")

function MainSplitPackSequence:Execute(arg_1_1)
	if not SplitPackHelper.Inst:IsSplitPackMode() then
		arg_1_1()

		return
	end

	local var_1_0 = pg.SplitPackDownloadMgr.GetInstance()

	if not var_1_0:ShouldShowTip() then
		arg_1_1()

		return
	end

	var_1_0:MarkTipShown()
	pg.MsgboxMgr.GetInstance():ShowMsgBox({
		modal = true,
		hideClose = true,
		content = i18n("auto_download_tip", (HashUtil.BytesToString(var_1_0:GetTotalSize()))),
		noText = pg.MsgboxMgr.TEXT_CONFIRM,
		onNo = arg_1_1,
		yesText = i18n("auto_download_btn"),
		onYes = function()
			pg.m02:sendNotification(GAME.GO_SCENE, SCENE.SETTINGS, {
				page = NewSettingsScene.PAGE_RES
			})
		end
	})
end

return MainSplitPackSequence
