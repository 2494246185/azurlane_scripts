local AtelierCompositeBaseScene = class("AtelierCompositeBaseScene", import("view.base.BaseUI"))

function AtelierCompositeBaseScene:getUIName()
	return "AtelierCompositeUI"
end

function AtelierCompositeBaseScene:InitStr()
	self.bundleName = "ui/AtelierCompositeUI_atlas"
	self.commonBundleName = "ui/AtelierCommonUI_atlas"
	self.chatText = {
		idle = {
			"ryza_atellier1"
		},
		clickFormula = {
			"ryza_atellier2",
			"ryza_atellier3",
			"ryza_atellier4"
		},
		showMaterialSelectWindow = {
			"ryza_atellier2",
			"ryza_atellier3",
			"ryza_atellier4"
		},
		selectMaterial = {
			"ryza_atellier5",
			"ryza_atellier6",
			"ryza_atellier7"
		},
		compositeResult = {
			"ryza_atellier8",
			"ryza_atellier9"
		},
		compositeResult2 = {
			"ryza_atellier10",
			"ryza_atellier11"
		}
	}
	self.soundStr = {
		formulaDetailUnlock = "event:/ui/ryza_atellier_ui_3",
		showMaterialSelectWindow = "event:/ui/ryza_atellier_ui_1",
		compositeConfirm = "event:/ui/ryza_atellier_ui_6",
		selectMaterial = "event:/ui/ryza_atellier_ui_2",
		formulaDetail = "event:/ui/ryza_atellier_ui_5",
		clickFormula = "event:/ui/ryza_atellier_ui_1",
		formulaDetailFill = "event:/ui/ryza_atellier_ui_4"
	}
	self.helpStr = "ryza_composite_help_tip"
	self.tipStr = "ryza_composite_words"
	self.unlockText = "ryza_tip_composite_unlock"
end

function AtelierCompositeBaseScene:InitView()
	self.atelierFormulaListView = AtelierFormulaListView.New(self.layerFormulaPanel, self)
	self.atelierFormulaDetailView = AtelierFormulaDetailView.New(self.layerFormulaDetailPanel, self)
	self.atelierMaterialSelectView = AtelierMaterialSelectView.New(self.materialSelectPanel, self)
	self.atelierMaterialsPreview = AtelierFormulaMaterialsPreview.New(self.materialsPreviewPanel, self)
	self.atelierCompositeConfirmView = AtelierCompositeConfirmView.New(self.compositeConfirmPanel, self)
	self.atelierCompositeResultView = AtelierCompositeResultView.New(self.compositeResultPanel, self)
end

function AtelierCompositeBaseScene:OnClickStore()
	addSubLayer(Context.New({
		mediator = AtelierStoreBaseMediator,
		viewComponent = AtelierStoreBaseScene,
		data = {
			activity = self.activity
		}
	}), (getProxy(ContextProxy):getCurrentContext():getContextByMediator(AtelierCompositeMediator)))
end

function AtelierCompositeBaseScene:preload(arg_5_1)
	self:InitStr()

	self.loader = AutoLoader.New()

	table.ParallelIpairsAsync({
		self.bundleName,
		self.commonBundleName
	}, function(arg_6_0, arg_6_1, arg_6_2)
		self.loader:LoadBundle(arg_6_1, arg_6_2)
	end, arg_5_1)
end

function AtelierCompositeBaseScene:getResource()
	self:InitStr()

	local var_7_0 = AtelierCompositeBaseScene.super.getResource(self)

	for iter_7_0, iter_7_1 in ipairs({
		self.bundleName,
		self.commonBundleName,
		"ui/laisha_ui_huo_o",
		"ui/laisha_ui_huo_6",
		"ui/laisha_ui_bing_o",
		"ui/laisha_ui_bing_6",
		"ui/laisha_ui_lei_o",
		"ui/laisha_ui_lei_6",
		"ui/laisha_ui_feng_o",
		"ui/laisha_ui_feng_6",
		"ui/laisha_ui_sairen_o",
		"ui/laisha_ui_sairen_6",
		"ui/laisha_ui_wupinshanguang",
		"ui/laisha_ui_jiesuo",
		"ui/laisha_ui_lianjie01",
		"ui/laisha_ui_lianjie02",
		"ui/laisha_ui_lianjie_qiehuan",
		"ui/laisha_ui_wupinzhiru",
		"ui/laisha_ui_baoshi",
		"ui/" .. self:GetAtelierCompositEffect()
	}) do
		if noEmptyStr(iter_7_1) and not table.contains(var_7_0, iter_7_1) then
			table.insert(var_7_0, iter_7_1)
		end
	end

	return var_7_0
end

function AtelierCompositeBaseScene:init()
	self.top = self._tf:Find("Top")
	self.layerFormulaPanel = self._tf:Find("FormulaList")
	self.layerFormulaOverlayPanel = self._tf:Find("FormulaDetail/Overlay")
	self.layerFormulaDetailPanel = self._tf:Find("FormulaDetail")
	self.scrollView = self._tf:Find("FormulaDetail/ScrollView")
	self.materialSelectPanel = self._tf:Find("FormulaDetail/Overlay/AvaliableMaterials")
	self.materialsPreviewPanel = self._tf:Find("FormulaMaterialsPreview")
	self.compositeConfirmPanel = self._tf:Find("CompositeConfirmWindow")
	self.compositeResultPanel = self._tf:Find("CompositeResultWindow")

	self:InitCustom()
	setActive(self.layerEmpty, false)
end

function AtelierCompositeBaseScene:InitCustom()
	self.layerEmpty = self._tf:Find("Empty")

	setText(self._tf:Find("Empty/Bar/Text"), i18n(self.unlockText))

	self.painting = self._tf:Find("Painting")
	self.chat = self.painting:Find("Chat")

	setActive(self.chat, false)
	pg.ViewUtils.SetSortingOrder(self._tf:Find("Mask/BG"):GetChild(0), -1)
end

function AtelierCompositeBaseScene:SetContextData(arg_10_1)
	self.contextData = arg_10_1

	self.atelierFormulaListView:SetContextData(arg_10_1)
	self.atelierFormulaDetailView:SetContextData(arg_10_1)
	self.atelierMaterialSelectView:SetContextData(arg_10_1)
	self.atelierMaterialsPreview:SetContentData(arg_10_1)
	self.atelierCompositeConfirmView:SetContentData(arg_10_1)
	self.atelierCompositeResultView:SetContentData(arg_10_1)
end

function AtelierCompositeBaseScene:SetActivity(arg_11_1)
	self.activity = arg_11_1

	self.atelierFormulaListView:SetActivity(arg_11_1)
	self.atelierFormulaDetailView:SetActivity(arg_11_1)
	self.atelierMaterialSelectView:SetActivity(arg_11_1)
	self.atelierMaterialsPreview:SetActivity(arg_11_1)
	self.atelierCompositeConfirmView:SetActivity(arg_11_1)
	self.atelierCompositeResultView:SetActivity(arg_11_1)
end

function AtelierCompositeBaseScene:SetEnabled(arg_12_1)
	self.unlockSystem = arg_12_1
end

function AtelierCompositeBaseScene:didEnter()
	self:RefreshEmptyPanel()
	self.atelierFormulaListView:didEnter()
	self.atelierFormulaDetailView:didEnter()
	self.atelierMaterialSelectView:didEnter()
	self.atelierMaterialsPreview:didEnter()
	self.atelierCompositeConfirmView:didEnter()
	self.atelierCompositeResultView:didEnter()
	onButton(self, self._tf:Find("Top/TopBar/Back"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("Top/TopBar/Home"), function()
		self:quickExitFunc()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("Top/TopBar/Help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n(self.helpStr)
		})
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Top/TopBar/StoreHouse"), function()
		self:OnClickStore()
	end, SFX_PANEL)
	pg.UIMgr.GetInstance():OverlayPanel(self.top)

	if self.unlockSystem then
		if self.contextData.formulaId then
			self:ShowFormulaDetail(self.activity:GetFormulas()[self.contextData.formulaId])
		else
			self:DispalyChat(self.chatText.idle)
			self:ShowFormulaList()
		end
	end

	self:PlayGuide()
end

function AtelierCompositeBaseScene:PlayGuide()
	if self.unlockSystem then
		if PlayerPrefs.GetInt(string.format("first_enter_ryza_atelier_%s_%s", getProxy(PlayerProxy):getRawData().id, self.activity.id), 0) == 0 then
			triggerButton(self._tf:Find("Top/TopBar/Help"))
			PlayerPrefs.SetInt(string.format("first_enter_ryza_atelier_%s_%s", getProxy(PlayerProxy):getRawData().id, self.activity.id), 1)
		end
	end
end

function AtelierCompositeBaseScene:willExit()
	self.loader:Clear()
	self:LoadingOff()
	self:HideChat()
	self:ClearSound()
	self.atelierMaterialsPreview:HideMaterialsPreview()
	self.atelierCompositeResultView:HideCompositeResult()
	self.atelierCompositeConfirmView:HideCompositeConfirmWindow()
	self.atelierMaterialSelectView:HideCandicatePanel()
	self:HideFormulaDetail()
	self:HideFormulaList()
	self.atelierFormulaListView:willExit()

	self.atelierFormulaListView = nil

	self.atelierFormulaDetailView:willExit()

	self.atelierFormulaDetailView = nil

	self.atelierMaterialSelectView:willExit()

	self.atelierMaterialSelectView = nil

	self.atelierMaterialsPreview:willExit()

	self.atelierMaterialsPreview = nil

	self.atelierCompositeConfirmView:willExit()

	self.atelierCompositeConfirmView = nil

	self.atelierCompositeResultView:willExit()

	self.atelierCompositeResultView = nil

	pg.UIMgr.GetInstance():UnOverlayPanel(self.top, self._tf)

	if self.nodePools then
		for iter_19_0, iter_19_1 in pairs(self.nodePools) do
			iter_19_1:ClearItems()
		end
	end
end

function AtelierCompositeBaseScene:UpdateRyzaDrop(arg_20_1, arg_20_2, arg_20_3)
	updateDrop(arg_20_1, arg_20_2)
	SetCompomentEnabled(arg_20_1:Find("icon_bg"), typeof(Image), false)
	setActive(arg_20_1:Find("bg"), false)
	setActive(arg_20_1:Find("icon_bg/frame"), false)
	setActive(arg_20_1:Find("icon_bg/stars"), false)

	local var_20_0 = arg_20_2:getConfig("rarity")

	if arg_20_2.type == DROP_TYPE_EQUIP or arg_20_2.type == DROP_TYPE_EQUIPMENT_SKIN then
		var_20_0 = var_20_0 - 1
	end

	local var_20_1 = "icon_frame_" .. var_20_0

	if arg_20_3 then
		var_20_1 = var_20_1 .. "_small"
	end

	self.loader:GetSpriteQuiet(self.commonBundleName, var_20_1, arg_20_1)

	if arg_20_2.type ~= DROP_TYPE_RYZA_DROP then
		onButton(self, arg_20_1, function()
			self:emit(AtelierCompositeBaseScene.ON_DROP, arg_20_2)
		end, SFX_PANEL)
	else
		removeOnButton(arg_20_1)
	end
end

function AtelierCompositeBaseScene:UpdateRyzaItem(arg_22_1, arg_22_2, arg_22_3)
	local var_22_0 = "icon_frame_" .. arg_22_2:GetRarity()

	if arg_22_3 then
		var_22_0 = var_22_0 .. "_small"
	end

	self.loader:GetSpriteQuiet(self.commonBundleName, var_22_0, arg_22_1)
	self.loader:GetSpriteQuiet(arg_22_2:GetIconPath(), "", arg_22_1:Find("Icon"))

	if not IsNil(arg_22_1:Find("Lv")) then
		setText(arg_22_1:Find("Lv/Text"), arg_22_2:GetLevel())
	end

	local var_22_1 = arg_22_2:GetProps()

	for iter_22_0, iter_22_1 in ipairs((CustomIndexLayer.Clone2Full(arg_22_1:Find("List"), #var_22_1))) do
		self.loader:GetSpriteQuiet(self.commonBundleName, "element_" .. AtelierFormulaCircle.ELEMENT_NAME[var_22_1[iter_22_0]], iter_22_1)
	end

	if not IsNil(arg_22_1:Find("Text")) then
		setText(arg_22_1:Find("Text"), arg_22_2.count)
	end
end

function AtelierCompositeBaseScene:OnClickFormula(arg_23_1)
	self:HideFormulaList()
	self:ShowFormulaDetail(arg_23_1)
	self:DispalyChat(self.chatText.clickFormula)
	self:PlaySoundEffect(self.soundStr.clickFormula)
end

function AtelierCompositeBaseScene:OnClickFormulaBack()
	self:HideFormulaDetail()

	self.contextData.formulaId = nil

	self:ShowFormulaList()
end

function AtelierCompositeBaseScene:ShowMaterialSelectWindow(arg_25_1, arg_25_2, arg_25_3)
	self:DispalyChat(self.chatText.showMaterialSelectWindow)
	self:PlaySoundEffect(self.soundStr.showMaterialSelectWindow)
	self.atelierMaterialSelectView:ShowCandicatePanel(arg_25_1, arg_25_2, arg_25_3)
end

function AtelierCompositeBaseScene:ShowCompositeConfirmWindow(arg_26_1)
	self.atelierCompositeConfirmView:ShowCompositeConfirmWindow(arg_26_1)
end

function AtelierCompositeBaseScene:OnSelectMaterial(arg_27_1, arg_27_2)
	self:DispalyChat(self.chatText.selectMaterial)
	self:PlaySoundEffect(self.soundStr.selectMaterial)
	self.atelierFormulaDetailView:FillNode(arg_27_1, arg_27_2)
end

function AtelierCompositeBaseScene:RefreshEmptyPanel()
	setActive(self.layerEmpty, not self.unlockSystem)
	setActive(self.painting, self.unlockSystem)
end

function AtelierCompositeBaseScene:ShowFormulaList()
	self:AddIdleTimer()
	self.atelierFormulaListView:ShowFormulaList()
end

function AtelierCompositeBaseScene:HideFormulaList()
	if not self.layerFormulaPanel then
		return
	end

	self:RemoveIdleTimer()
	setParent(self.layerFormulaPanel, self._tf)
	setActive(self.layerFormulaPanel, false)

	return true
end

function AtelierCompositeBaseScene:ShowFormulaDetail(arg_31_1)
	self.contextData.formulaId = arg_31_1:GetConfigID()

	self.atelierFormulaDetailView:Show(arg_31_1)
	setParent(self.layerFormulaOverlayPanel, self.top)
	self.layerFormulaOverlayPanel:SetSiblingIndex(0)
	setParent(self.painting, self.layerFormulaOverlayPanel)
	setActive(self.materialSelectPanel, false)
end

function AtelierCompositeBaseScene:HideFormulaDetail()
	if not isActive(self.layerFormulaDetailPanel) then
		return
	end

	self.atelierMaterialSelectView:HideCandicatePanel()
	setParent(self.painting, self._tf)
	self.painting:SetSiblingIndex(1)
	setParent(self.layerFormulaOverlayPanel, self.layerFormulaDetailPanel)
	setActive(self.layerFormulaDetailPanel, false)

	return true
end

function AtelierCompositeBaseScene:ShowMaterialsPreview()
	self.atelierMaterialsPreview:ShowMaterialsPreview(self.atelierFormulaDetailView.nodeList)
end

function AtelierCompositeBaseScene:DispalyChat(arg_34_1)
	self:HideChat()
	setActive(self.chat, true)

	self.chatTween = LeanTween.delayedCall(go(self.chat), 4, System.Action(function()
		self:HideChat()
	end)).uniqueId

	local var_34_0 = arg_34_1[math.random(#arg_34_1)]
	local var_34_1 = _.detect(pg.gametip[self.tipStr].tip, function(arg_36_0)
		return arg_36_0[1] == var_34_0
	end)

	setText(self.chat:Find("Text"), var_34_1 and var_34_1[2])
	self:PlaySound(self:GetSoundPath() .. var_34_0)
end

function AtelierCompositeBaseScene:GetSoundPath()
	return "event:/cv/" .. 1090001 .. "/"
end

function AtelierCompositeBaseScene:PlaySoundEffect(arg_38_1)
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(arg_38_1)
end

function AtelierCompositeBaseScene:ShowItemDetail(arg_39_1)
	self:emit(AtelierMaterialDetailMediator.SHOW_DETAIL, arg_39_1)
end

function AtelierCompositeBaseScene:LoadingOn()
	if self.animating then
		return
	end

	self.animating = true

	pg.UIMgr.GetInstance():LoadingOn(false)
end

function AtelierCompositeBaseScene:LoadingOff()
	if not self.animating then
		return
	end

	pg.UIMgr.GetInstance():LoadingOff()

	self.animating = false
end

function AtelierCompositeBaseScene:PlaySound(arg_42_1, arg_42_2)
	if not self.playbackInfo or arg_42_1 ~= self.prevCvPath or self.playbackInfo.channelPlayer == nil then
		self:StopSound()
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(arg_42_1, function(arg_43_0)
			if arg_43_0 then
				self.playbackInfo = arg_43_0

				self.playbackInfo:SetIgnoreAutoUnload(true)

				if arg_42_2 then
					arg_42_2(self.playbackInfo.cueInfo)
				end
			elseif arg_42_2 then
				arg_42_2()
			end
		end)

		self.prevCvPath = arg_42_1

		if self.playbackInfo == nil then
			return nil
		end

		return self.playbackInfo.cueInfo
	elseif self.playbackInfo then
		self.playbackInfo:PlaybackStop()
		self.playbackInfo:SetStartTimeAndPlay()

		if arg_42_2 then
			arg_42_2(self.playbackInfo.cueInfo)
		end

		return self.playbackInfo.cueInfo
	elseif arg_42_2 then
		arg_42_2()
	end

	return nil
end

function AtelierCompositeBaseScene:StopSound()
	if self.playbackInfo then
		pg.CriMgr.GetInstance():StopPlaybackInfoForce(self.playbackInfo)
		self.playbackInfo:SetIgnoreAutoUnload(false)
	end
end

function AtelierCompositeBaseScene:ClearSound()
	self:StopSound()

	if self.playbackInfo then
		self.playbackInfo:Dispose()

		self.playbackInfo = nil
	end
end

function AtelierCompositeBaseScene:HideChat()
	if self.chatTween then
		LeanTween.cancel(self.chatTween)

		self.chatTween = nil
	end

	setActive(self.chat, false)
end

function AtelierCompositeBaseScene:AddIdleTimer()
	self:RemoveIdleTimer()

	self.idleTimer = Timer.New(function()
		self:DispalyChat(self.chatText.idle)
		self:AddIdleTimer()
	end, 8 + math.random() * 4)

	self.idleTimer:Start()
end

function AtelierCompositeBaseScene:RemoveIdleTimer()
	if not self.idleTimer then
		return
	end

	self.idleTimer:Stop()

	self.idleTimer = nil
end

function AtelierCompositeBaseScene:GetAtelierCompositEffect()
	return "laisha_lianjin"
end

function AtelierCompositeBaseScene:GetAtelierCompositEffectPos()
	return Vector2.zero
end

function AtelierCompositeBaseScene:OnCompositeResult(arg_52_1)
	self:LoadingOn()
	self:DispalyChat(self.chatText.compositeResult)

	local var_52_0 = 1.5
	local var_52_1 = 0.5

	self.loader:GetPrefab("ui/" .. self:GetAtelierCompositEffect(), "", function(arg_53_0)
		pg.UIMgr.GetInstance():OverlayPanel(tf(arg_53_0))
		setAnchoredPosition(arg_53_0, self:GetAtelierCompositEffectPos())
		self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self._tf, typeof(CanvasGroup)), 0, var_52_0):setFrom(1)
		self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self.top, typeof(CanvasGroup)), 0, var_52_0):setFrom(1)
		self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self.compositeConfirmPanel, typeof(CanvasGroup)), 0, var_52_0):setFrom(1)
		self:managedTween(LeanTween.delayedCall, function()
			self.atelierCompositeConfirmView:HideCompositeConfirmWindow()
			setCanvasGroupAlpha(self.compositeConfirmPanel, 1)
			self:CleanNodeInstance()
			self.atelierCompositeResultView:ShowCompositeResult(arg_52_1)
			self:DispalyChat(self.chatText.compositeResult2)
			self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self._tf, typeof(CanvasGroup)), 1, var_52_1):setFrom(0)
			self:managedTween(LeanTween.alphaCanvas, nil, GetComponent(self.top, typeof(CanvasGroup)), 1, var_52_1):setFrom(0)
			self:managedTween(LeanTween.alphaCanvas, nil, GetOrAddComponent(self.compositeResultPanel, typeof(CanvasGroup)), 1, var_52_1):setFrom(0)
			self:managedTween(LeanTween.delayedCall, function()
				self:LoadingOff()
				pg.UIMgr.GetInstance():UnOverlayPanel(tf(arg_53_0), self._tf)
				self.loader:ClearRequest("CompositeResult")
			end, go(self.compositeResultPanel), var_52_1, nil)
		end, go(self.compositeResultPanel), var_52_0, nil)
	end, "CompositeResult")
end

function AtelierCompositeBaseScene:OnReceiveFormualRequest(arg_56_1)
	self.atelierMaterialSelectView:HideCandicatePanel()
	self.atelierCompositeConfirmView:HideCompositeConfirmWindow()
	self.atelierCompositeResultView:HideCompositeResult()
	self.atelierMaterialsPreview:HideMaterialsPreview()
	self:HideFormulaList()
	self:ShowFormulaDetail(self.activity:GetFormulas()[arg_56_1])
end

function AtelierCompositeBaseScene:CleanNodeInstance()
	local var_57_0 = self.activity:GetFormulas()[self.contextData.formulaId]

	if not var_57_0:IsAvaliable() then
		self:HideFormulaDetail()

		self.contextData.formulaId = nil

		self:ShowFormulaList()

		return
	end

	_.each(self.atelierFormulaDetailView.nodeList, function(arg_58_0)
		arg_58_0.Instance = nil
		arg_58_0.Change = true
	end)
	self:ShowFormulaDetail(var_57_0)
end

function AtelierCompositeBaseScene:onBackPressed()
	if self.animating then
		return true
	end

	if self.atelierMaterialsPreview:HideMaterialsPreview() then
		return true
	end

	if self.atelierCompositeResultView:HideCompositeResult() then
		return true
	end

	if self.atelierCompositeConfirmView:HideCompositeConfirmWindow() then
		return true
	end

	if self.atelierMaterialSelectView:HideCandicatePanel() then
		return true
	end

	if self:HideFormulaDetail() then
		self.contextData.formulaId = nil

		self:ShowFormulaList()

		return true
	end

	self:emit(AtelierCompositeBaseScene.ON_BACK_PRESSED)
end

return AtelierCompositeBaseScene
