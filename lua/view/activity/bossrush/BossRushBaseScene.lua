local BossRushBaseScene = class("BossRushBaseScene", import("view.base.BaseUI"))

function BossRushBaseScene:getUIName()
	return nil
end

function BossRushBaseScene:Ctor()
	BossRushBaseScene.super.Ctor(self)

	self.chapterAutoDetailPanel = ChapterAutoDetailPanelTypeRush.New(self._tf, self.event, self.contextData)

	self.chapterAutoDetailPanel:RegisterView(self)
end

function BossRushBaseScene:CheckChapterAutoOccupied(arg_3_1)
	local var_3_0 = getProxy(ChapterAutoProxy):GetCommissionList()[1]:GetOccupiedName()

	switch(arg_3_1, {
		[ChapterAutoProxy.TYPE.SLG] = function()
			local var_4_0 = getProxy(ChapterProxy):GetAutoChapterId()
			local var_4_1 = pg.chapter_template[var_4_0].map

			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("auto_drop_is_activation", var_3_0),
				onYes = function()
					pg.m02:sendNotification(GAME.GO_SCENE, SCENE.LEVEL, {
						chapterId = var_4_0,
						mapIdx = var_4_1
					})
				end,
				yesText = i18n("auto_drop_is_activation_go"),
				noText = i18n("auto_drop_is_activation_cancle")
			})
		end,
		[ChapterAutoProxy.TYPE.BOSS] = function()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("auto_drop_is_activation", var_3_0),
				onYes = function()
					pg.m02:sendNotification(GAME.GO_SCENE, SCENE.ACT_BOSS_BATTLE)
				end,
				yesText = i18n("auto_drop_is_activation_go"),
				noText = i18n("auto_drop_is_activation_cancle")
			})
		end,
		[ChapterAutoProxy.TYPE.RUSH] = function()
			self.chapterAutoDetailPanel:ExecuteAction("Enter", (getProxy(ChapterAutoProxy):GetCommissionList()[1]:GetID()))
		end
	})
end

function BossRushBaseScene:UpdateView()
	return
end

function BossRushBaseScene:OnStartChapterAuto(arg_10_1)
	self:UpdateView()
end

function BossRushBaseScene:OnEndChapterAuto()
	self.chapterAutoDetailPanel:ExecuteAction("Hide")
	self:UpdateView()
end

function BossRushBaseScene:willExit()
	BossRushBaseScene.super.willExit(self)

	if self.chapterAutoDetailPanel then
		self.chapterAutoDetailPanel:Destroy()

		self.chapterAutoDetailPanel = nil
	end
end

return BossRushBaseScene
