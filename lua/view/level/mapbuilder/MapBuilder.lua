local MapBuilder = class("MapBuilder", import("view.base.BaseSubView"))

MapBuilder.TYPENORMAL = 1
MapBuilder.TYPEESCORT = 2
MapBuilder.TYPESHINANO = 3
MapBuilder.TYPESKIRMISH = 4
MapBuilder.TYPEBISMARCK = 5
MapBuilder.TYPESSSS = 6
MapBuilder.TYPEATELIER = 7
MapBuilder.TYPESENRANKAGURA = 8
MapBuilder.TYPESP = 9
MapBuilder.TYPESPFULL = 10
MapBuilder.TYPESPSERIES = 11
MapBuilder.TYPESPSERIESFULL = 12
MapBuilder.TYPEATELIERYUMIA = 13
MapBuilder.TYPEEXSP = 14
MapBuilder.TYPESPSERIESRECREW = 15

function MapBuilder:Ctor(arg_1_1, arg_1_2)
	MapBuilder.super.Ctor(self, arg_1_1, arg_1_2.event, arg_1_2.contextData)

	self.sceneParent = arg_1_2
	self.map = arg_1_1:Find("maps")
	self.float = arg_1_1:Find("float")
	self.tweens = {}
	self.mapWidth, self.mapHeight = self.sceneParent._tf.rect.size.x, self.sceneParent._tf.rect.size.y
	self.buffer = setmetatable({}, {
		__index = function(arg_2_0, arg_2_1)
			return function(arg_3_0, ...)
				if arg_2_1 == "UpdateMapItems" and underscore.any(self._funcQueue, function(arg_4_0)
					return arg_4_0.funcName == arg_2_1
				end) then
					errorMsg("Multiple Calls of function 'UpdateMapItems' in Mapbuilder")

					return
				end

				self:ActionInvoke(arg_2_1, ...)
			end
		end,
		__newindex = function()
			errorMsg("Cant write Data in ActionInvoke buffer")
		end
	})
	self.isFrozen = nil

	self:bind(LevelUIConst.ON_FROZEN, function()
		self.isFrozen = true
	end)
	self:bind(LevelUIConst.ON_UNFROZEN, function()
		self.isFrozen = nil
	end)
end

function MapBuilder:Load()
	if self._state ~= MapBuilder.STATES.NONE then
		return
	end

	self._state = MapBuilder.STATES.LOADING

	pg.UIMgr.GetInstance():LoadingOn()
	PoolMgr.GetInstance():GetUI(self:getUIName(), true, function(arg_9_0)
		self:Loaded(arg_9_0)
		self:Init()
	end)
end

function MapBuilder:isfrozen()
	return self.isFrozen
end

function MapBuilder:GetType()
	return 0
end

function MapBuilder:Destroy()
	if self._state == MapBuilder.STATES.INITED then
		self:Hide()
	end

	MapBuilder.super.Destroy(self)
end

function MapBuilder:OnDestroy()
	self.tweens = nil
end

function MapBuilder:Show()
	MapBuilder.super.Show(self)
	self:OnShow()
end

function MapBuilder:Hide()
	self:OnHide()
	MapBuilder.super.Hide(self)
end

function MapBuilder:OnShow()
	return
end

function MapBuilder:OnHide()
	for iter_17_0, iter_17_1 in pairs(self.tweens) do
		LeanTween.cancel(iter_17_1)
	end

	self.tweens = {}
end

function MapBuilder:UpdateMapVO(arg_18_1)
	self.data = arg_18_1
end

function MapBuilder:UpdateView()
	self:UpdateButtons()
end

function MapBuilder:UpdateButtons()
	return
end

function MapBuilder:UpdateMapItems()
	return
end

function MapBuilder:HideFloat()
	return
end

function MapBuilder:ShowFloat()
	return
end

function MapBuilder:RecordTween(arg_24_1, arg_24_2)
	self.tweens[arg_24_1] = arg_24_2
end

function MapBuilder:DeleteTween(arg_25_1)
	if self.tweens[arg_25_1] then
		LeanTween.cancel(self.tweens[arg_25_1])

		self.tweens[arg_25_1] = nil
	end
end

function MapBuilder:UpdateChapterTF(arg_26_1)
	return
end

function MapBuilder:TryOpenChapter(arg_27_1)
	errorMsg("Not Implent TryOpenChapter in " .. self.__cname)
end

function MapBuilder:TryOpenChapterInfo(arg_28_1, arg_28_2, arg_28_3)
	if self:isfrozen() then
		return
	end

	local var_28_0 = getProxy(ChapterProxy):getChapterById(arg_28_1, true)
	local var_28_1 = getProxy(ChapterAutoProxy)

	if var_28_1:IsCommissionDoing() and not var_28_1:HasTypeCommission(ChapterAutoProxy.TYPE.WORLD) then
		self:ChapterAutoOccupied(var_28_0)

		return
	end

	if var_28_0.active then
		self.sceneParent:switchToChapter(var_28_0)

		return
	end

	if not var_28_0:isUnlock() then
		local var_28_2 = var_28_0:GetPrevChapterNames()

		if #var_28_2 == 1 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_tracking_error_pre", var_28_2[1]))
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_tracking_error_pre_2", var_28_2[1], var_28_2[2]))
		end

		return
	end

	if not getProxy(ChapterProxy):getMapById(var_28_0:getConfig("map")):isRemaster() and not var_28_0:inActTime() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("battle_levelScene_close"))

		return
	end

	local var_28_3 = var_28_0:getConfig("unlocklevel")

	if var_28_3 > getProxy(PlayerProxy):getRawData().level then
		pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_chapter_level_limit", var_28_3))

		return
	end

	local var_28_4 = getProxy(ChapterProxy):getActiveChapter(true)

	if var_28_4 and var_28_4.id ~= arg_28_1 then
		self:emit(LevelMediator2.ON_STRATEGYING_CHAPTER)

		return
	end

	if var_28_0:IsSpChapter() then
		SettingsProxy.SetActivityMapSPTip()
		self:UpdateChapterTF(arg_28_1)
	end

	if not arg_28_3 then
		self.sceneParent:DisplayLevelInfoPanel(arg_28_1, arg_28_2)
	else
		self.sceneParent:DisplayLevelInfoSPPanel(arg_28_1, arg_28_3, arg_28_2)
	end
end

function MapBuilder:ChapterAutoOccupied(arg_29_1)
	switch(getProxy(ChapterAutoProxy):GetCommissionDoingType(), {
		[ChapterAutoProxy.TYPE.SLG] = function()
			local var_30_0 = getProxy(ChapterProxy):GetAutoChapterId()

			if var_30_0 then
				if var_30_0 == arg_29_1.id then
					self.sceneParent:ShowChapterAutoDetailPanel(arg_29_1)
				else
					local var_30_1 = getProxy(ChapterProxy):getChapterById(var_30_0)

					self.sceneParent:HandleShowMsgBox({
						content = i18n("auto_drop_is_activation", var_30_1:getConfig("name")),
						onYes = function()
							self.sceneParent:ShowChapterAutoDetailPanel(var_30_1)
						end,
						yesText = i18n("auto_drop_is_activation_go"),
						noText = i18n("auto_drop_is_activation_cancle")
					})
				end
			end
		end
	})
end

function MapBuilder:OnSubmitTaskDone()
	return
end

function MapBuilder:PlayEnterAnim()
	return
end

return MapBuilder
