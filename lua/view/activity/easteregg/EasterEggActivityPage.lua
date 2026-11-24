local EasterEggActivityPage = class("EasterEggActivityPage", import("view.activity.CorePage.CoreActivityPage"))

function EasterEggActivityPage:OnInit()
	onButton(self, self.uiRewardBtn, function()
		return
	end, SFX_PANEL)
	setText(self.uiComplateText, i18n("easter_egg_complate"))
	setText(self.uiTipsText, i18n("easter_egg_tips"))
end

function EasterEggActivityPage:OnFirstFlush()
	for iter_3_0 = 1, self:GetMaxBtnCnt() do
		onButton(self, self[string.format("uiBtn%s", iter_3_0)], function()
			if table.contains(getProxy(ActivityProxy):getActivityById(self.activity.id).data2_list, pg.activity_event_picturepuzzle[self.activity.id].pickup_picturepuzzle[iter_3_0]) then
				self:emit(BaseUI.ON_ADD_SUBLAYER, Context.New({
					viewComponent = EasterEggPopScene,
					mediator = EasterEggPopMediator,
					data = {
						id = pg.activity_event_picturepuzzle[self.activity.id].pickup_picturepuzzle[iter_3_0]
					}
				}))
			else
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					hideNo = true,
					content = pg.activity_secret_template[pg.activity_event_picturepuzzle[self.activity.id].pickup_picturepuzzle[iter_3_0]].page
				})
			end
		end, SFX_PANEL)
	end

	onButton(self, self.uiRewardBtn, function()
		self:emit(EasterEggView.ON_CLICK_EASTER_EGG, {
			actId = getProxy(ActivityProxy):getActivityById(self.activity.id).id,
			cmd = PuzzleActivity.CMD_COMPLETE
		})
	end, SFX_PANEL)
	self:RefreshBtnState()
end

function EasterEggActivityPage:OnUpdateFlush()
	self:RefreshBtnState()
end

function EasterEggActivityPage:RefreshBtnState()
	local var_7_0 = getProxy(ActivityProxy):getActivityById(self.activity.id)
	local var_7_1 = pg.activity_event_picturepuzzle[self.activity.id]

	for iter_7_0 = 1, self:GetMaxBtnCnt() do
		local var_7_2 = table.contains(var_7_0.data2_list, var_7_1.pickup_picturepuzzle[iter_7_0])

		setActive(findTF(self[string.format("uiBtn%s", iter_7_0)], "Image"), var_7_2)
		setActive(findTF(self[string.format("uiBtn%s", iter_7_0)], "lockImage"), not var_7_2)
	end

	local var_7_3 = #var_7_0.data2_list >= #var_7_1.pickup_picturepuzzle

	setActive(self.uiComplateImage, #var_7_0.data2_list >= #var_7_1.pickup_picturepuzzle)
	setGray(self.uiRewardIcon, not var_7_3)
	setButtonEnabled(self.uiRewardBtn, var_7_3)
	setText(self.uiCntText, string.format("<color=#ce659f>%s</color>/%s", #var_7_0.data2_list, self:GetMaxBtnCnt()))
end

function EasterEggActivityPage:GetMaxBtnCnt()
	return #pg.activity_event_picturepuzzle[self.activity.id].pickup_picturepuzzle
end

return EasterEggActivityPage
