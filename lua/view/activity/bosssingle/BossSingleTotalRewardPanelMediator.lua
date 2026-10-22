local BossSingleTotalRewardPanelMediator = class("BossSingleTotalRewardPanelMediator", import("view.activity.worldboss.ActivityBossTotalRewardPanelMediator"))

function BossSingleTotalRewardPanelMediator:register()
	getProxy(SettingsProxy):ResetContinuousOperationAutoSub()
end

return BossSingleTotalRewardPanelMediator
