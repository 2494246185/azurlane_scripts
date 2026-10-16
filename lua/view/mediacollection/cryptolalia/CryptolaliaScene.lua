local CryptolaliaScene = class("CryptolaliaScene", import("view.base.BaseUI"))

CryptolaliaScene.ON_UNLOCK = "CryptolaliaScene:ON_UNLOCK"
CryptolaliaScene.ON_DELETE = "CryptolaliaScene:ON_DELETE"
CryptolaliaScene.ON_SELECT = "CryptolaliaScene:ON_SELECT"

function CryptolaliaScene:getUIName()
	return "CryptolaliaUI"
end

function CryptolaliaScene.GetAllCryptolaliaShipRes()
	local var_2_0 = {}

	for iter_2_0, iter_2_1 in ipairs(pg.soundstory_template.all) do
		if pg.soundstory_template[iter_2_1] and pg.soundstory_template[iter_2_1].ship_id then
			table.insert(var_2_0, "CryptolaliaShip/" .. (pg.soundstory_template[iter_2_1] and pg.soundstory_template[iter_2_1].ship_id))
		end
	end

	return var_2_0
end

function CryptolaliaScene.GetAllCryptolaliaAuditionRes()
	local var_3_0 = {}

	for iter_3_0, iter_3_1 in ipairs(pg.soundstory_template.all) do
		if pg.soundstory_template[iter_3_1] then
			if pg.soundstory_template[iter_3_1].audition_resource_CN and pg.soundstory_template[iter_3_1].audition_resource_CN ~= "" then
				table.insert(var_3_0, "cue/" .. pg.soundstory_template[iter_3_1].audition_resource_CN .. ".b")
			end

			if pg.soundstory_template[iter_3_1].audition_resource_JP and pg.soundstory_template[iter_3_1].audition_resource_JP ~= "" then
				table.insert(var_3_0, "cue/" .. pg.soundstory_template[iter_3_1].audition_resource_JP .. ".b")
			end
		end
	end

	return var_3_0
end

function CryptolaliaScene:getResource()
	return ResPathSupport.UniqueLuaArr(ResPathSupport.MergeLuaArr(CryptolaliaScene.super.getResource(self), {
		"ui/CryptolaliaUI_atlas",
		"ui/CryptolaliaListui",
		"ui/CryptolaliaPurchaseWindowui",
		"ui/CryptolaliaResDeleteWindowui"
	}, CryptolaliaScene.GetAllCryptolaliaShipRes(), CryptolaliaScene.GetAllCryptolaliaAuditionRes()))
end

function CryptolaliaScene:SetCryptolaliaList(arg_5_1)
	self.cryptolaliaList = arg_5_1
end

function CryptolaliaScene:init()
	self.cg = self._tf:GetComponent(typeof(CanvasGroup))
	self.backBtn = self._tf:Find("Top/blur_panel/adapt/top/back_btn")
	self.auditionBtn = self._tf:Find("Main/audition/toggle")
	self.auditionBtnOn = self._tf:Find("Main/audition/toggle/on")
	self.auditionBtnOff = self._tf:Find("Main/audition/toggle/off")
	self.cdImg = self._tf:Find("Main/cd"):GetComponent(typeof(Image))
	self.cdSignatureImg = self._tf:Find("Main/cd/signature"):GetComponent(typeof(Image))
	self.shipName = self._tf:Find("Main/cd/name"):GetComponent(typeof(Text))
	self.timeLimit = self._tf:Find("Main/cd/timelimit")
	self.timeTxt = self._tf:Find("Main/cd/timelimit/Text"):GetComponent(typeof(Text))
	self.nameTxt = self._tf:Find("Main/name"):GetComponent(typeof(Text))
	self.authorTxt = self._tf:Find("Main/author"):GetComponent(typeof(Text))
	self.descTxt = self._tf:Find("Main/desc"):GetComponent(typeof(Text))
	self.signatureImg = self._tf:Find("Main/desc/signature"):GetComponent(typeof(Image))
	self.auditionTxt = self._tf:Find("Main/audition/mask/Text"):GetComponent("ScrollText")
	self.auditionEffect = self._tf:Find("Main/audition/p2/Lines"):GetComponent(typeof(Animation))

	self.auditionEffect:Play("anim_line_reset")

	self.btnsTr = self._tf:Find("Main/btns")
	self.lockBtn = self.btnsTr:Find("lock")
	self.downloadBtn = self.btnsTr:Find("download")
	self.downloadingBtn = self.btnsTr:Find("downloading")
	self.playBtn = self.btnsTr:Find("play")
	self.playPrevBtn = self.btnsTr:Find("play/prev")
	self.playNextBtn = self.btnsTr:Find("play/next")
	self.deleteBtn = self.btnsTr:Find("delete")
	self.stateBtn = self.btnsTr:Find("state")
	self.stateBtnTxt = self.stateBtn:Find("Text"):GetComponent(typeof(Text))
	self.switchBtn = self.btnsTr:Find("switch")
	self.listBtn = self.btnsTr:Find("list")
	self.optionBtn = self._tf:Find("Top/blur_panel/adapt/top/option")
	self.purchaseWindow = CryptolaliaPurchaseWindow.New(self._tf, self.event)
	self.resDeleteWindow = CryptolaliaResDeleteWindow.New(self._tf, self.event)
	self.downloadMgr = CryptolaliaDownloadMgr.New()
	self.soundPlayer = CryptolaliaSoundPlayer.New()
	self.mainView = CryptolaliaMainView.New(self)
	self.listView = CryptolaliaListView.New(self._tf, self.event)
	self.scrollRect = CryptolaliaScrollRect.New(self._tf:Find("Main/list/tpl"), (CryptolaliaScrollRectAnimation.New(self._tf)))

	self.scrollRect:Make(function(arg_7_0)
		self:OnItemUpdate(arg_7_0)
	end, function(arg_8_0)
		self:OnItemSelected(arg_8_0:GetInitIndex())
	end)

	self.dftAniEvent = self._tf:GetComponent(typeof(DftAniEvent))

	setText(self._tf:Find("Main/cd/timelimit/label"), i18n("cryptolalia_timelimie"))
	setText(self.downloadingBtn:Find("label"), i18n("cryptolalia_label_downloading"))

	Input.multiTouchEnabled = false
end

function CryptolaliaScene:didEnter()
	self.cards = {}
	self.downloadReqList = {}

	parallelAsync({
		function(arg_10_0)
			self.dftAniEvent:SetEndEvent(arg_10_0)
		end,
		function(arg_11_0)
			self:InitCryptolaliaList(arg_11_0)
		end
	}, function()
		self.dftAniEvent:SetEndEvent(nil)
		self.scrollRect:SetUp()
		self:ActiveDefault()
		self:RegisterEvent()
	end)
end

function CryptolaliaScene:ActiveDefault()
	if not self.contextData.groupId then
		return
	end

	local var_13_0 = -1

	for iter_13_0, iter_13_1 in ipairs(self.displays) do
		if iter_13_1 and iter_13_1:IsSameGroup(self.contextData.groupId) then
			var_13_0 = iter_13_0

			break
		end
	end

	if var_13_0 <= 0 then
		return
	end

	for iter_13_2, iter_13_3 in pairs(self.cards) do
		if iter_13_3:GetInitIndex() == var_13_0 then
			triggerButton(iter_13_3._go)

			break
		end
	end
end

function CryptolaliaScene:OnItemUpdate(arg_14_1)
	local var_14_0 = self.displays[arg_14_1:GetInitIndex()]

	arg_14_1:Interactable(false)

	if not var_14_0 then
		return
	end

	arg_14_1:Interactable(true)
	LoadSpriteAtlasAsync("CryptolaliaShip/" .. var_14_0:GetShipGroupId(), "icon", function(arg_15_0)
		arg_14_1:UpdateSprite(arg_15_0)
	end)

	self.cards[var_14_0.id] = arg_14_1
end

function CryptolaliaScene:OnItemSelected(arg_16_1)
	local var_16_0 = self.displays[arg_16_1]

	if not self.displays[arg_16_1] then
		return
	end

	if not self.langType or not var_16_0:ExistLang(self.langType) or self.selectedIndex ~= arg_16_1 then
		self.langType = var_16_0:GetDefaultLangType()
	end

	local var_16_1 = self.downloadMgr:IsDownloadState((Cryptolalia.BuildCpkPath((var_16_0:GetCpkName(self.langType)))))

	if var_16_1 and self.downloadReqList[var_16_0.id] == nil then
		self:OnUpdateForResDownload("ReConnection", var_16_0, arg_16_1)
	end

	self.mainView:Flush(var_16_0, self.langType, var_16_1)

	self.selectedIndex = arg_16_1

	if self.auditionFlag then
		triggerButton(self.auditionBtn)
	end
end

function CryptolaliaScene:Filter()
	local var_17_0 = {}

	for iter_17_0, iter_17_1 in ipairs(self.cryptolaliaList or {}) do
		if iter_17_1:InTime() or not iter_17_1:IsLock() then
			table.insert(var_17_0, iter_17_1)
		end
	end

	table.sort(var_17_0, function(arg_18_0, arg_18_1)
		local var_18_0 = arg_18_0:GetSortIndex()
		local var_18_1 = arg_18_1:GetSortIndex()

		if var_18_0 == var_18_1 then
			return arg_18_0.id < arg_18_1.id
		else
			return var_18_0 < var_18_1
		end
	end)

	return var_17_0
end

function CryptolaliaScene:InitCryptolaliaList(arg_19_1)
	self.displays = self:FillEmptyDisplayIfNeed((self:Filter()))

	self.scrollRect:Align(#self.displays, arg_19_1)
end

function CryptolaliaScene:FillEmptyDisplayIfNeed(arg_20_1)
	local var_20_0 = {}

	for iter_20_0 = 1, math.max(5, #arg_20_1) do
		local var_20_1 = defaultValue(arg_20_1[iter_20_0], false)

		if iter_20_0 % 2 == 0 then
			table.insert(var_20_0, var_20_1)
		else
			table.insert(var_20_0, 1, var_20_1)
		end
	end

	return var_20_0
end

function CryptolaliaScene:RegisterEvent()
	self:bind(CryptolaliaScene.ON_UNLOCK, function(arg_22_0, arg_22_1)
		self:OnUnlockCryptolalia(arg_22_1)
	end)
	self:bind(CryptolaliaScene.ON_DELETE, function(arg_23_0)
		if not self.selectedIndex then
			return
		end

		self:OnItemSelected(self.selectedIndex)
	end)
	self:bind(CryptolaliaScene.ON_SELECT, function(arg_24_0, arg_24_1)
		if self.cards[arg_24_1] then
			triggerButton(self.cards[arg_24_1]._go)
		end
	end)
	onButton(self, self.optionBtn, function()
		self:emit(CryptolaliaScene.ON_HOME)
	end, SFX_PANEL)
	onButton(self, self.backBtn, function()
		self:emit(CryptolaliaScene.ON_BACK)
	end, SFX_CANCEL)
	onButton(self, self.switchBtn, function()
		if not self.selectedIndex then
			return
		end

		local var_27_0 = self.displays[self.selectedIndex]

		if not self.displays[self.selectedIndex] then
			return
		end

		if not var_27_0:IsMultiVersion() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("cryptolalia_coming_soom"))

			return
		end

		self.langType = 1 - self.langType

		self:OnItemSelected(self.selectedIndex)
	end, SFX_PANEL)
	onButton(self, self.listBtn, function()
		if not self.selectedIndex then
			return
		end

		if self.displays[self.selectedIndex] then
			self.listView:ExecuteAction("Show", self:Filter(), self.langType, self.displays[self.selectedIndex].id, self.scrollRect)
		end
	end, SFX_PANEL)
	onButton(self, self.deleteBtn, function()
		if not self.selectedIndex then
			return
		end

		local var_29_0 = self.displays[self.selectedIndex]

		if self.displays[self.selectedIndex] and var_29_0:IsPlayableState(self.langType) then
			self.resDeleteWindow:ExecuteAction("Show", var_29_0, self.langType)
		end
	end, SFX_PANEL)
	onButton(self, self.playBtn:Find("play"), function()
		if not self.selectedIndex then
			return
		end

		self:PlayVedio(self.selectedIndex)
	end, SFX_PANEL)
	onButton(self, self.playNextBtn, function()
		if not self.selectedIndex then
			return
		end

		if self.displays[self.selectedIndex + 1] then
			self:emit(CryptolaliaScene.ON_SELECT, self.displays[self.selectedIndex + 1].id)
		end
	end, SFX_PANEL)
	onButton(self, self.playPrevBtn, function()
		if not self.selectedIndex then
			return
		end

		if self.displays[self.selectedIndex - 1] then
			self:emit(CryptolaliaScene.ON_SELECT, self.displays[self.selectedIndex - 1].id)
		end
	end, SFX_PANEL)
	onButton(self, self.downloadBtn, function()
		if not self.selectedIndex then
			return
		end

		self:DownloadRes(self.selectedIndex)
	end, SFX_PANEL)
	onButton(self, self.lockBtn, function()
		if not self.selectedIndex then
			return
		end

		local var_34_0 = self.displays[self.selectedIndex]

		if self.displays[self.selectedIndex] and var_34_0:IsLockState() then
			self.purchaseWindow:ExecuteAction("Show", var_34_0, self.langType)
		end
	end, SFX_PANEL)

	self.auditionFlag = false

	onButton(self, self.auditionBtn, function()
		if not self.selectedIndex then
			return
		end

		local var_35_0 = self.displays[self.selectedIndex]

		if not self.displays[self.selectedIndex] then
			return
		end

		self.auditionFlag = not self.auditionFlag

		if self.auditionFlag then
			self:PlayAudition(var_35_0)
			pg.BgmMgr.GetInstance():StopPlay()
		else
			self:ClearAuditionTimer()
			self.soundPlayer:Stop()
			self.auditionEffect:Play("anim_line_reset")
			pg.BgmMgr.GetInstance():ContinuePlay()
		end

		self:UpdateAudition(self.auditionFlag)
	end, SFX_PANEL)
	self:UpdateAudition(self.auditionFlag)
end

function CryptolaliaScene:UpdateAudition(arg_36_1)
	setActive(self.auditionBtnOn, arg_36_1)
	setActive(self.auditionBtnOff, not arg_36_1)
end

function CryptolaliaScene:PlayAudition(arg_37_1)
	self:ClearAuditionTimer()
	self.auditionEffect:Play("anim_line_loop")

	local var_37_0 = getProxy(PlayerProxy):getRawData():GetFlagShip()

	self.soundPlayer:Load(arg_37_1:GetAudition(self.langType), arg_37_1:GetAuditionVoice(self.langType), 0, function(arg_38_0)
		self.timer = Timer.New(function()
			if self.auditionFlag then
				triggerButton(self.auditionBtn)
			end
		end, arg_38_0, 1)

		self.timer:Start()
	end)
end

function CryptolaliaScene:ClearAuditionTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function CryptolaliaScene:IsDownloading(arg_41_1)
	if not arg_41_1 then
		return false
	end

	if arg_41_1:ExistLang(Cryptolalia.LANG_TYPE_CH) and self.downloadMgr:IsDownloadState((Cryptolalia.BuildCpkPath((arg_41_1:GetCpkName(Cryptolalia.LANG_TYPE_CH))))) then
		return true
	end

	if arg_41_1:ExistLang(Cryptolalia.LANG_TYPE_JP) and self.downloadMgr:IsDownloadState((Cryptolalia.BuildCpkPath((arg_41_1:GetCpkName(Cryptolalia.LANG_TYPE_JP))))) then
		return true
	end

	return false
end

function CryptolaliaScene:DownloadRes(arg_42_1)
	for iter_42_0, iter_42_1 in ipairs(self.displays or {}) do
		if self:IsDownloading(iter_42_1) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("cryptolalia_download_task_already_exists", iter_42_1:GetName()))

			return
		end
	end

	if IsUnityEditor then
		pg.TipsMgr.GetInstance():ShowTips(i18n("common_no_open"))

		return
	end

	local var_42_1 = self.displays[arg_42_1]

	originalPrint(self.displays[arg_42_1]:IsDownloadableState(self.langType))

	if var_42_1 and var_42_1:IsDownloadableState(self.langType) and not self.downloadReqList[var_42_1.id] then
		originalPrint("Downloading............")
		self:OnUpdateForResDownload("Request", var_42_1, arg_42_1)
		self:OnItemSelected(self.selectedIndex)
	end
end

function CryptolaliaScene:OnUpdateForResDownload(arg_43_1, arg_43_2, arg_43_3)
	local var_43_0 = arg_43_2:GetCpkName(self.langType)

	self.downloadMgr[arg_43_1](self.downloadMgr, {
		Cryptolalia.BuildSubtitlePath(var_43_0),
		(Cryptolalia.BuildCpkPath(var_43_0))
	}, function(arg_44_0, arg_44_1)
		if not self.downloadReqList[arg_43_2.id] or self.downloadReqList[arg_43_2.id].index ~= self.selectedIndex then
			return
		end

		if arg_44_1 == CryptolaliaDownloadMgr.PROGRESS_FINISH or arg_44_1 == CryptolaliaDownloadMgr.PROGRESS_ERROR then
			self.downloadReqList[arg_43_2.id] = nil
			self.cg.blocksRaycasts = false

			onNextTick(function()
				self:OnItemSelected(self.selectedIndex)

				self.cg.blocksRaycasts = true
			end)

			if arg_44_1 == CryptolaliaDownloadMgr.PROGRESS_FINISH then
				pg.TipsMgr.GetInstance():ShowTips(i18n("cryptolalia_download_done"))
			end
		else
			setSlider(self.downloadingBtn, 0, 1, arg_44_1)
		end
	end)

	self.downloadReqList[arg_43_2.id] = {
		index = arg_43_3
	}
end

function CryptolaliaScene:PlayVedio(arg_46_1)
	if self.displays[arg_46_1] and self.displays[arg_46_1]:IsPlayableState(self.langType) then
		pg.BgmMgr.GetInstance():StopPlay()

		local var_46_0 = CryptolaliaVedioPlayer.New(self._tf)

		var_46_0:Play(self.displays[arg_46_1]:GetCpkName(self.langType), self.displays[arg_46_1]:GetCaptionsColor(), function()
			pg.BgmMgr.GetInstance():ContinuePlay()
		end)

		self.player = var_46_0
	end
end

function CryptolaliaScene:OnUnlockCryptolalia(arg_48_1)
	for iter_48_0, iter_48_1 in ipairs(self.cryptolaliaList) do
		if iter_48_1.id == arg_48_1 then
			iter_48_1:Unlock()
		end
	end

	for iter_48_2, iter_48_3 in ipairs(self.displays) do
		if iter_48_3 and iter_48_3.id == arg_48_1 then
			iter_48_3:Unlock()
		end
	end

	if not self.selectedIndex then
		return
	end

	if self.displays[self.selectedIndex] and self.displays[self.selectedIndex].id == arg_48_1 then
		self:OnItemSelected(self.selectedIndex)
	end

	if self.purchaseWindow and self.purchaseWindow:GetLoaded() and self.purchaseWindow:isShowing() then
		self.purchaseWindow:Hide()
	end
end

function CryptolaliaScene:onBackPressed()
	if self.purchaseWindow and self.purchaseWindow:GetLoaded() and self.purchaseWindow:isShowing() then
		self.purchaseWindow:Hide()

		return
	end

	if self.resDeleteWindow and self.resDeleteWindow:GetLoaded() and self.resDeleteWindow:isShowing() then
		self.resDeleteWindow:Hide()

		return
	end

	if self.listView and self.listView:GetLoaded() and self.listView:isShowing() then
		self.listView:Hide()

		return
	end

	CryptolaliaScene.super.onBackPressed(self)
end

function CryptolaliaScene:willExit()
	self:ClearAuditionTimer()

	if self.scrollRect then
		self.scrollRect:Dispose()

		self.scrollRect = nil
	end

	self.downloadReqList = nil

	if self.purchaseWindow then
		self.purchaseWindow:Destroy()

		self.purchaseWindow = nil
	end

	if self.resDeleteWindow then
		self.resDeleteWindow:Destroy()

		self.resDeleteWindow = nil
	end

	if self.mainView then
		self.mainView:Dispose()

		self.mainView = nil
	end

	if self.player then
		self.player:Dispose()

		self.player = nil
	end

	if self.downloadMgr then
		self.downloadMgr:Dispose()

		self.downloadMgr = nil
	end

	if self.listView then
		self.listView:Destroy()

		self.listView = nil
	end

	self.cards = nil

	if self.soundPlayer then
		self.soundPlayer:Dispose()

		self.soundPlayer = nil
	end

	Input.multiTouchEnabled = true
end

return CryptolaliaScene
