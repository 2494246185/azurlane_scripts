local NewShipLayer = class("NewShipLayer", import("..base.BaseUI"))

NewShipLayer.PAINT_DURATION = 0.35
NewShipLayer.STAR_DURATION = 0.5
NewShipLayer.STAR_ANIMATION_DUR1 = 0.075
NewShipLayer.STAR_ANIMATION_DUR2 = 0.1
NewShipLayer.STAR_ANIMATION_DUR3 = 0.4
NewShipLayer.STAR_ANIMATION_DUR4 = 0.26

function NewShipLayer:getUIName()
	return "NewShipUI"
end

function NewShipLayer:getResource()
	local var_2_0 = {
		"clutter/new",
		"shiptype"
	}

	table.insert(var_2_0, string.format(ResPathSupport.ConstPath.Ship.Rarity.NewShipBG, self.contextData.ship:rarity2bgPrintForGet()))

	if self.contextData.ship:isBluePrintShip() then
		table.insert(var_2_0, string.format(ResPathSupport.ConstPath.Ship.Rarity.EffectDesign, self.contextData.ship:getRarity()))
	end

	local var_2_1 = self.contextData.ship:isMetaShip()

	if var_2_1 then
		table.insert(var_2_0, string.format(ResPathSupport.ConstPath.Ship.Rarity.EffectMeta, self.contextData.ship:getRarity()))
	end

	if var_2_1 then
		table.insert(var_2_0, MetaCharacterConst.getReMetaTransItem(self.contextData.ship):getConfig("icon"))
	end

	local var_2_2 = Ship.getPaintingName(self.contextData.ship.configId)

	table.insertto(var_2_0, (ResPathSupport.GetPaintingListByPaintingName(var_2_2)))
	table.insertto(var_2_0, (ResPathSupport.GetPaintingFaceListByPaintingName(var_2_2)))

	local var_2_3 = self.contextData.ship:getNation()

	_.each(ResPathSupport.ConstPath.Ship.Nation.PrintsFixList, function(arg_3_0)
		table.insert(var_2_0, (string.format(ResPathSupport.ConstPath.Ship.Nation.Prints, nation2print(var_2_3), arg_3_0)))
	end)

	local var_2_4 = self.contextData.ship:getRarity()

	_.each(ResPathSupport.ConstPath.Ship.Rarity.ShipRarityFixList1, function(arg_4_0)
		_.each(ResPathSupport.ConstPath.Ship.Rarity.ShipRarityFixList2, function(arg_5_0)
			table.insert(var_2_0, (string.format(ResPathSupport.ConstPath.Ship.Rarity.ShipRarity, arg_4_0, var_2_4, arg_5_0)))
		end)
	end)
	_.each(ResPathSupport.ConstPath.Ship.Rarity.GetRoleFixList, function(arg_6_0)
		table.insert(var_2_0, (string.format(ResPathSupport.ConstPath.Ship.Rarity.GetRole, var_2_4, arg_6_0)))
	end)

	local var_2_5 = self.contextData.ship:getGroupId()

	_.each({
		ShipGroup.GetGroupConfig(var_2_5).trans_skin,
		ShipGroup.getDefaultSkin(var_2_5).id
	}, function(arg_7_0)
		table.insert(var_2_0, "ui/skinunlockanim/star_level_unlock_anim_" .. arg_7_0)
	end)

	return table.insertto(var_2_0, NewShipLayer.super.getResource(self))
end

function NewShipLayer:preload(arg_8_1)
	LoadSpriteAsync("newshipbg/bg_" .. self.contextData.ship:rarity2bgPrintForGet(), function(arg_9_0)
		self.bgSprite = arg_9_0
		self.isLoadBg = true

		arg_8_1()
	end)
end

function NewShipLayer:init()
	self._animator = GetComponent(self._tf, "Animator")
	self._canvasGroup = GetOrAddComponent(self._tf, typeof(CanvasGroup))
	self._shake = self._tf:Find("shake_panel")
	self._shade = self._tf:Find("shade")
	self._bg = self._shake:Find("bg")
	self._drag = self._shake:Find("drag")
	self._paintingTF = self._shake:Find("paint")
	self._paintingShadowTF = self._shake:Find("shadow")
	self._dialogue = self._shake:Find("dialogue")
	self._shipName = self._dialogue:Find("bg/name"):GetComponent(typeof(Text))
	self._shipType = self._dialogue:Find("bg/type"):GetComponent(typeof(Text))
	self._dialogueText = self._dialogue:Find("Text")
	self._left = self._shake:Find("ForNotch/left_panel")
	self._lockTF = self._left:Find("lock")
	self._lockBtn = self._left:Find("lock/lock")
	self._unlockBtn = self._left:Find("lock/unlock_btn")
	self._viewBtn = self._left:Find("view_btn")
	self._evaluationBtn = self._left:Find("evaluation_btn")
	self._shareBtn = self._left:Find("share_btn")
	self.audioBtn = self._shake:Find("property_btn")
	self.clickTF = self._shake:Find("click")
	self.npc = self._tf:Find("shake_panel/npc")

	setActive(self.npc, false)

	self.newTF = self._shake:Find("New")
	self.rarityTF = self._shake:Find("rarity")
	self.starsTF = self.rarityTF:Find("stars")
	self.starsCont = self.starsTF:Find("content")
	self._skipButton = self._shake:Find("ForNotch/skip")

	setActive(self._skipButton, self.contextData.canSkipBatch)
	setActive(self._left, true)
	setActive(self.audioBtn, true)
	pg.UIMgr.GetInstance():OverlayPanel(self._tf)

	self.metaRepeatTF = self.rarityTF:Find("MetaRepeat")
	self.metaDarkTF = self._shake:Find("MetaMask")
	self.rarityEffect = {}

	if self.contextData.autoExitTime then
		self.autoExitTimer = Timer.New(function()
			self:showExitTip()
		end, self.contextData.autoExitTime)

		self.autoExitTimer:Start()

		self.contextData.autoExitTime = nil
	end

	self:PauseAnimation()
end

function NewShipLayer:voice(arg_12_1)
	if not arg_12_1 then
		return
	end

	self:stopVoice()

	self._currentVoice = arg_12_1

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(arg_12_1)
end

function NewShipLayer:stopVoice()
	if self._currentVoice then
		pg.CriMgr.GetInstance():UnloadSoundEffect_V3(self._currentVoice)
	end

	self._currentVoice = nil
end

function NewShipLayer:setShip(arg_14_1)
	self:recyclePainting()

	self._shipVO = arg_14_1
	self.isRemoulded = arg_14_1:isRemoulded()

	local var_14_0 = arg_14_1:isBluePrintShip()

	setImageSprite(self._bg, self.bgSprite)
	setActive(self.metaDarkTF, arg_14_1:isMetaShip())

	if var_14_0 then
		if self.metaBg then
			setActive(self.metaBg, false)
		end

		if self.designBg and self.designName ~= "raritydesign" .. arg_14_1:getRarity() then
			PoolMgr.GetInstance():ReturnUI(self.designName, self.designBg)

			self.designBg = nil
		end

		if not self.designBg then
			PoolMgr.GetInstance():GetUI("raritydesign" .. arg_14_1:getRarity(), true, function(arg_15_0)
				self.designBg = arg_15_0
				self.designName = "raritydesign" .. arg_14_1:getRarity()

				arg_15_0.transform:SetParent(self._shake, false)

				arg_15_0.transform.localPosition = Vector3(1, 1, 1)
				arg_15_0.transform.localScale = Vector3(1, 1, 1)

				arg_15_0.transform:SetSiblingIndex(1)
				setActive(arg_15_0, true)
			end)
		else
			setActive(self.designBg, true)
		end
	elseif arg_14_1:isMetaShip() then
		if self.designBg then
			setActive(self.designBg, false)
		end

		if self.metaBg and self.metaName ~= "raritymeta" .. arg_14_1:getRarity() then
			PoolMgr.GetInstance():ReturnUI(self.metaName, self.metaBg)

			self.metaBg = nil
		end

		if not self.metaBg then
			PoolMgr.GetInstance():GetUI("raritymeta" .. arg_14_1:getRarity(), true, function(arg_16_0)
				self.metaBg = arg_16_0
				self.metaName = "raritymeta" .. arg_14_1:getRarity()

				arg_16_0.transform:SetParent(self._shake, false)

				arg_16_0.transform.localPosition = Vector3(1, 1, 1)
				arg_16_0.transform.localScale = Vector3(1, 1, 1)

				arg_16_0.transform:SetSiblingIndex(1)
				setActive(arg_16_0, true)
			end)
		else
			setActive(self.metaBg, true)
		end
	else
		if self.designBg then
			setActive(self.designBg, false)
		end

		if self.metaBg then
			setActive(self.metaBg, false)
		end
	end

	if arg_14_1.virgin and not self.isRemoulded and not arg_14_1:isActivityNpc() then
		setActive(self.newTF, true)
		LoadImageSpriteAsync("clutter/new", self.newTF)

		if OPEN_TEC_TREE_SYSTEM and table.indexof(pg.fleet_tech_ship_template.all, self._shipVO.groupId, 1) then
			pg.ToastMgr.GetInstance():ShowToast(pg.ToastMgr.TYPE_TECPOINT, {
				point = pg.fleet_tech_ship_template[self._shipVO.groupId].pt_get,
				typeList = ShipType.FilterOverQuZhuType(pg.fleet_tech_ship_template[self._shipVO.groupId].add_get_shiptype),
				attr = pg.fleet_tech_ship_template[self._shipVO.groupId].add_get_attr,
				value = pg.fleet_tech_ship_template[self._shipVO.groupId].add_get_value
			})
		end
	else
		setActive(self.newTF, false)

		local var_14_1 = arg_14_1:getReMetaSpecialItemVO()

		self:updateLockTF(var_14_1 ~= nil)

		if var_14_1 then
			local var_14_2 = self.metaRepeatTF:Find("Icon")

			setImageSprite(var_14_2, LoadSprite(var_14_1:getConfig("icon")))
			GetImageSpriteFromAtlasAsync(var_14_1:getConfig("icon"), "", var_14_2)
			setText(self.metaRepeatTF:Find("Count"), var_14_1.count)

			local var_14_3 = pg.ship_transform[self._shipVO.groupId].common_item[1][2]
			local var_14_4 = self.metaRepeatTF:Find("Commom")

			setActive(self.metaRepeatTF:Find("Special"), var_14_1.id == pg.ship_transform[self._shipVO.groupId].exclusive_item[1][2])
			setActive(var_14_4, var_14_1.id == var_14_3)
		else
			setActive(self.metaRepeatTF, false)
		end
	end

	setActive(self.audioBtn, not self.isRemoulded)
	self:UpdateLockButton(self._shipVO:GetLockState())

	local var_14_5 = self._shipVO:getConfigTable()

	if self.isRemoulded then
		setPaintingPrefabAsync(self._paintingTF, self._shipVO:getRemouldPainting(), "huode")
		setPaintingPrefabAsync(self._paintingShadowTF, self._shipVO:getRemouldPainting(), "huode")
	else
		setPaintingPrefabAsync(self._paintingTF, self._shipVO:getPainting(), "huode")
		setPaintingPrefabAsync(self._paintingShadowTF, self._shipVO:getPainting(), "huode")
	end

	self._shipType.text = pg.ship_data_by_type[self._shipVO:getShipType()].type_name
	self._shipName.text = arg_14_1:getName()

	local var_14_6 = arg_14_1:getRarity()
	local var_14_7 = pg.ship_data_template[var_14_5.id].star_max
	local var_14_8 = self._shipVO:getStar()

	if pg.ship_data_template[var_14_5.id].star_max % 2 ~= 0 or not (var_14_7 / 2) then
		local var_14_9 = math.floor(var_14_7 / 2) + 1
	end

	for iter_14_0 = 1, 6 do
		local var_14_11 = self.starsTF:Find("content/star_" .. iter_14_0)
		local var_14_12 = var_14_11:Find("star_empty")

		setActive(var_14_11:Find("star"), iter_14_0 <= var_14_8)
		setActive(var_14_12, var_14_8 < iter_14_0)

		if var_14_7 < iter_14_0 then
			setActive(var_14_11, false)
		end
	end

	local var_14_13 = self._shake:Find("rarity/nation")
	local var_14_14 = LoadSprite("prints/" .. nation2print(var_14_5.nationality) .. "_0")

	if not var_14_14 then
		warning("找不到印花, shipConfigId: " .. arg_14_1.configId)
		setActive(var_14_13, false)
	else
		setImageSprite(var_14_13, var_14_14, false)
	end

	local var_14_15 = self._shake:Find("rarity/type")
	local var_14_16 = self._shake:Find("rarity/type/rarLogo")

	if arg_14_1:isMetaShip() then
		LoadImageSpriteAsync("shiprarity/1" .. var_14_6 .. "m", var_14_15, true)
		LoadImageSpriteAsync("shiprarity/1" .. var_14_6 .. "s", var_14_16, true)
	else
		LoadImageSpriteAsync("shiprarity/" .. (var_14_0 and "0" or "") .. var_14_6 .. "m", var_14_15, true)
		LoadImageSpriteAsync("shiprarity/" .. (var_14_0 and "0" or "") .. var_14_6 .. "s", var_14_16, true)
	end

	setActive(var_14_13, false)
	setActive(self.rarityTF, false)
	setActive(self._shade, true)

	self.inAnimating = true

	self:AddLeanTween(function()
		return LeanTween.delayedCall(0.5, System.Action(function()
			setActive(var_14_13, true)
			setActive(self.rarityTF, true)
			self:starsAnimation()
		end))
	end)

	local var_14_17 = self._shake:Find("ship_type")
	local var_14_18 = var_14_17:Find("stars")
	local var_14_19 = var_14_17:Find("stars/startpl")

	setText(var_14_17:Find("english_name"), self._shipVO:getConfig("english_name"))

	local var_14_20 = self._shipVO:getStar()
	local var_14_21 = self._shipVO:getMaxStar()

	for iter_14_1 = var_14_18.childCount, var_14_21 - 1 do
		cloneTplTo(var_14_19, var_14_18)
	end

	for iter_14_2 = 0, var_14_18.childCount - 1 do
		local var_14_22 = var_14_18:GetChild(iter_14_2)

		var_14_22.gameObject:SetActive(iter_14_2 < var_14_21)
		setActive(var_14_22:Find("star"), iter_14_2 < var_14_20)
		setActive(var_14_22:Find("empty"), var_14_20 <= iter_14_2)
	end

	local var_14_23 = self._shipVO:getConfigTable()

	findTF(var_14_17, "type_bg/type"):GetComponent(typeof(Image)).sprite = GetSpriteFromAtlas("shiptype", tostring(self._shipVO:getShipType()))

	setScrollText(var_14_17:Find("name_bg/mask/Text"), self._shipVO:getName())

	if var_14_0 then
		var_14_6 = var_14_6 .. "_1"
	elseif arg_14_1:isMetaShip() then
		var_14_6 = var_14_6 .. "_2"
	end

	if not self.rarityEffect[var_14_6] then
		PoolMgr.GetInstance():GetUI("getrole_" .. var_14_6, true, function(arg_19_0)
			if IsNil(self._tf) then
				return
			end

			self.rarityEffect[var_14_6] = arg_19_0

			arg_19_0.transform:SetParent(self._tf, false)

			arg_19_0.transform.localPosition = Vector3(1, 1, 1)
			arg_19_0.transform.localScale = Vector3(1, 1, 1)

			arg_19_0.transform:SetSiblingIndex(1)

			if arg_14_1:isMetaShip() then
				local var_19_0 = tf(arg_19_0):Find("fire_ruchang")

				var_19_0:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_20_0)
					setActive(var_14_13, true)
					setActive(var_19_0, false)
				end)
			end

			setActive(var_14_13, false)

			self.effectObj = arg_19_0

			setActive(self.effectObj, self.isOpeningEnd)
		end)
	else
		self.effectObj = self.rarityEffect[var_14_6]

		setActive(self.effectObj, self.isOpeningEnd)
	end

	self:playOpening(function()
		self:ResumeAnimation()
		self:DisplayWord()
	end)
end

function NewShipLayer:PauseAnimation()
	self._canvasGroup.alpha = 0
	self._animator.enabled = false
end

function NewShipLayer:ResumeAnimation()
	self._canvasGroup.alpha = 1
	self._animator.enabled = true
	self.isOpeningEnd = true

	if self.effectObj then
		setActive(self.effectObj, true)
	end
end

function NewShipLayer:DisplayWord()
	local var_24_1 = ""
	local var_24_2

	if self.isRemoulded then
		local var_24_3 = self._shipVO:getRemouldSkinId()

		var_24_1 = ShipWordHelper.RawGetWord(var_24_3, ShipWordHelper.WORD_TYPE_UNLOCK)

		if var_24_1 == "" then
			local var_24_4

			var_24_4, var_24_2, var_24_1 = ShipWordHelper.GetWordAndCV(var_24_3, ShipWordHelper.WORD_TYPE_DROP)
		else
			local var_24_5

			var_24_5, var_24_2, var_24_1 = ShipWordHelper.GetWordAndCV(var_24_3, ShipWordHelper.WORD_TYPE_UNLOCK)
		end
	else
		local var_24_6

		var_24_6, var_24_2, var_24_1 = ShipWordHelper.GetWordAndCV(self._shipVO:getSkinId(), ShipWordHelper.WORD_TYPE_UNLOCK)
	end

	setWidgetText(self._dialogue, SwitchSpecialChar(var_24_1, true), "Text")

	self._dialogue.transform.localScale = Vector3(0, 1, 1)

	SetActive(self._dialogue, false)
	self:AddLeanTween(function()
		return LeanTween.delayedCall(0.5, System.Action(function()
			SetActive(self._dialogue, true)
			self:AddLeanTween(function()
				return LeanTween.scale(self._dialogue, Vector3(1, 1, 1), 0.1)
			end)
			self:voice(var_24_2)
		end))
	end)
end

function NewShipLayer:updateShip(arg_28_1)
	self._shipVO = arg_28_1
end

function NewShipLayer:switch2Property()
	setActive(self.newTF, false)
	setActive(self._dialogue, false)
	setActive(self.rarityTF, false)
	setActive(self._shake:Find("rarity/nation"), false)

	local var_29_0 = self._shake:Find("ship_type")

	setActive(var_29_0, true)
	self:AddLeanTween(function()
		return LeanTween.move(rtf(var_29_0), Vector3(0, -149.55, 0), 0.3)
	end)
	self:AddLeanTween(function()
		return LeanTween.move(rtf(self._paintingTF), Vector3(-59, 21, 0), 0.2)
	end)
	self:DisplayNewShipDocumentView()
end

function NewShipLayer:showExitTip(arg_32_1)
	local var_32_0 = getProxy(PlayerProxy):getRawData():GetCommonFlag(_G[pg.settings_other_template[22].name])

	if pg.settings_other_template[22].default == 1 then
		var_32_0 = not var_32_0
	end

	if self._shipVO.virgin and self._shipVO:GetLockState() == Ship.LOCK_STATE_UNLOCK and not var_32_0 then
		if self.effectObj then
			setActive(self.effectObj, false)
		end

		if self.effectLineObj then
			setActive(self.effectLineObj, false)
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			modal = true,
			content = i18n("ship_lock_tip"),
			onYes = function()
				triggerButton(self._lockBtn)

				if arg_32_1 then
					arg_32_1()
				else
					self:emit(NewShipMediator.ON_EXIT)
				end
			end,
			onNo = function()
				if arg_32_1 then
					arg_32_1()
				else
					self:emit(NewShipMediator.ON_EXIT)
				end
			end
		})
	elseif arg_32_1 then
		arg_32_1()
	else
		self:emit(NewShipMediator.ON_EXIT)
	end
end

function NewShipLayer:UpdateLockButton(arg_35_1)
	setActive(self._lockBtn, arg_35_1 ~= Ship.LOCK_STATE_LOCK)
	setActive(self._unlockBtn, arg_35_1 ~= Ship.LOCK_STATE_UNLOCK)
end

function NewShipLayer:updateLockTF(arg_36_1)
	setActive(self._lockTF, not arg_36_1)
end

function NewShipLayer:didEnter()
	onButton(self, self._lockBtn, function()
		self:StopAutoExitTimer()
		self:emit(NewShipMediator.ON_LOCK, {
			self._shipVO.id
		}, Ship.LOCK_STATE_LOCK)
	end, SFX_PANEL)
	onButton(self, self._unlockBtn, function()
		self:StopAutoExitTimer()
		self:emit(NewShipMediator.ON_LOCK, {
			self._shipVO.id
		}, Ship.LOCK_STATE_UNLOCK)
	end, SFX_PANEL)
	onButton(self, self._viewBtn, function()
		self:StopAutoExitTimer()

		self.isInView = true

		self:paintView()
		setActive(self.clickTF, false)
	end, SFX_PANEL)
	onButton(self, self._evaluationBtn, function()
		self:StopAutoExitTimer()
		self:emit(NewShipMediator.ON_EVALIATION, self._shipVO:getGroupId())
	end, SFX_PANEL)
	onButton(self, self._shareBtn, function()
		self:StopAutoExitTimer()
		pg.ShareMgr.GetInstance():Share(pg.ShareMgr.TypeNewShip)
	end, SFX_PANEL)
	onButton(self, self.clickTF, function()
		self:StopAutoExitTimer()

		if self.isInView or not self.isLoadBg then
			return
		end

		self:showExitTip()
	end, SFX_CANCEL)
	onButton(self, self.audioBtn, function()
		self:StopAutoExitTimer()

		if self.isInView then
			return
		end

		if not self.isOpenProperty then
			self:switch2Property()

			self.isOpenProperty = true
		end

		setActive(self.audioBtn, not self.isRemoulded and not self.isOpenProperty)
	end, SFX_PANEL)
	onButton(self, self._skipButton, function()
		self:showExitTip(function()
			self:emit(NewShipMediator.ON_SKIP_BATCH, self.contextData.skipBatchType or NewShipMediator.SKIP_TYPE.BUILD)
		end)
	end, SFX_PANEL)
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_DOCKYARD_CHARGET)
	pg.SystemGuideMgr.GetInstance():Play(self)
end

function NewShipLayer:onBackPressed()
	if self.inAnimating then
		return
	end

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)

	if self.isInView then
		self:hidePaintView(true)

		return
	end

	self:DestroyNewShipDocumentView()
	triggerButton(self.clickTF)
end

function NewShipLayer:paintView()
	local var_48_0 = {}

	while 0 < self._shake.childCount do
		local var_48_1 = self._shake:GetChild(0)

		if var_48_1.gameObject.activeSelf and var_48_1 ~= self._paintingTF and var_48_1 ~= self._bg and var_48_1 ~= self._drag then
			var_48_0[#var_48_0 + 1] = var_48_1

			setActive(var_48_1, false)
		end
	end

	setActive(self._paintingShadowTF, false)
	openPortrait()

	local var_48_3 = self._paintingTF
	local var_48_4 = self._paintingTF.anchoredPosition.x
	local var_48_5 = self._paintingTF.anchoredPosition.y
	local var_48_6 = self._tf.rect.width / UnityEngine.Screen.width
	local var_48_7 = self._tf.rect.height / UnityEngine.Screen.height
	local var_48_8 = self._paintingTF.rect.width / 2
	local var_48_9 = self._paintingTF.rect.height / 2
	local var_48_10
	local var_48_11

	if not LeanTween.isTweening(go(self._paintingTF)) then
		self:AddLeanTween(function()
			return LeanTween.moveX(rtf(var_48_3), 150, 0.5):setEase(LeanTweenType.easeInOutSine)
		end)
	end

	local var_48_12 = GetOrAddComponent(self._drag, "MultiTouchZoom")

	var_48_12:SetZoomTarget(self._paintingTF)

	local var_48_13 = GetOrAddComponent(self._drag, "EventTriggerListener")

	self.dragTrigger = var_48_13

	local var_48_14 = true

	var_48_12.enabled = true
	var_48_13.enabled = true

	local var_48_15 = false

	var_48_13:AddPointDownFunc(function(arg_50_0)
		if Input.touchCount == 1 or IsUnityEditor then
			var_48_15 = true
			var_48_14 = true
		elseif Input.touchCount >= 2 then
			var_48_14 = false
			var_48_15 = false
		end
	end)
	var_48_13:AddPointUpFunc(function(arg_51_0)
		if Input.touchCount <= 2 then
			var_48_14 = true
		end
	end)
	var_48_13:AddBeginDragFunc(function(arg_52_0, arg_52_1)
		var_48_15 = false
		var_48_10 = arg_52_1.position.x * var_48_6 - var_48_8 - tf(self._paintingTF).localPosition.x
		var_48_11 = arg_52_1.position.y * var_48_7 - var_48_9 - tf(self._paintingTF).localPosition.y
	end)
	var_48_13:AddDragFunc(function(arg_53_0, arg_53_1)
		if var_48_14 then
			local var_53_0 = tf(self._paintingTF).localPosition

			tf(self._paintingTF).localPosition = Vector3(arg_53_1.position.x * var_48_6 - var_48_8 - var_48_10, arg_53_1.position.y * var_48_7 - var_48_9 - var_48_11, -22)
		end
	end)
	onButton(self, self._drag, function()
		self:hidePaintView()
	end, SFX_CANCEL)

	function NewShipLayer:hidePaintView(arg_55_1)
		if not arg_55_1 and not var_48_15 then
			return
		end

		var_48_13.enabled = false
		var_48_12.enabled = false

		for iter_55_0, iter_55_1 in ipairs(var_48_0) do
			setActive(iter_55_1, true)
		end

		setActive(self._paintingShadowTF, true)
		closePortrait()
		LeanTween.cancel(go(self._paintingTF))

		self._paintingTF.localScale = Vector3(1, 1, 1)

		setAnchoredPosition(self._paintingTF, {
			x = var_48_4,
			y = var_48_5
		})

		self.isInView = false

		setActive(self.clickTF, true)
	end
end

function NewShipLayer:recyclePainting()
	if self._shipVO then
		retPaintingPrefab(self._paintingTF, self._shipVO:getPainting())
		retPaintingPrefab(self._paintingShadowTF, self._shipVO:getPainting())

		self._shipVO = nil
	end
end

function NewShipLayer:starsAnimation()
	self.inAnimating = true

	if self._shipVO:getMaxStar() >= 6 and PlayerPrefs.GetInt(RARE_SHIP_VIBRATE, 1) > 0 then
		LuaHelper.Vibrate()
	end

	setActive(self.starsCont, false)

	local var_57_0 = self._tf:GetComponent(typeof(DftAniEvent))

	var_57_0:SetTriggerEvent(function(arg_58_0)
		self:AddLeanTween(function()
			return LeanTween.scale(rtf(self.starsCont), Vector3.one, 0):setOnComplete(System.Action(function()
				setActive(self.starsCont, true)
			end))
		end)

		local var_58_0 = self.STAR_ANIMATION_DUR1

		for iter_58_0 = 0, self.starsCont.childCount - 1 do
			local var_58_1 = self.starsCont:GetChild(iter_58_0)
			local var_58_2 = var_58_1:Find("star_empty")
			local var_58_3 = var_58_1:Find("star")

			setActive(var_58_2, false)
			setActive(var_58_3, false)

			local var_58_4 = iter_58_0 * self.STAR_ANIMATION_DUR1

			self:AddLeanTween(function()
				return LeanTween.scale(rtf(var_58_2), Vector3(1.8, 1.8, 1.8), 0):setDelay(var_58_4):setOnComplete(System.Action(function()
					setActive(var_58_2, true)
					self:AddLeanTween(function()
						return LeanTween.scale(rtf(var_58_2), Vector3(1, 1, 1), var_58_0)
					end)
				end))
			end)
		end

		local var_58_5 = self.STAR_ANIMATION_DUR2
		local var_58_6 = self.STAR_ANIMATION_DUR3

		for iter_58_1 = 0, self._shipVO:getStar() - 1 do
			local var_58_7 = self.starsCont:GetChild(iter_58_1)
			local var_58_8 = var_58_7:Find("star_empty")
			local var_58_9 = var_58_7:Find("star")
			local var_58_10 = self.STAR_ANIMATION_DUR1 * self.starsCont.childCount + iter_58_1 * self.STAR_ANIMATION_DUR2

			self:AddLeanTween(function()
				return LeanTween.scale(rtf(var_58_9), Vector3(1.8, 1.8, 1.8), 0):setDelay(var_58_10):setOnStart(System.Action(function()
					pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_DOCKYARD_STAR)
				end)):setOnComplete(System.Action(function()
					setActive(var_58_8, false)
					setActive(var_58_9, true)
					self:AddLeanTween(function()
						return LeanTween.scale(rtf(var_58_9), Vector3(1, 1, 1), var_58_5)
					end)
				end))
			end)

			local var_58_11 = var_58_7:Find("light")

			if var_58_11 then
				self:AddLeanTween(function()
					return LeanTween.delayedCall(var_58_10, System.Action(function()
						if self.exited then
							return
						end

						setActive(var_58_11, true)
					end))
				end)
				self:AddLeanTween(function()
					return LeanTween.alpha(rtf(var_58_11), 0, var_58_6):setDelay(var_58_10):setOnComplete(System.Action(function()
						SetActive(var_58_11, false)
						LeanTween.alpha(rtf(var_58_11), 1, 0)
					end))
				end)

				var_58_11.transform.localScale = Vector3(1, 1, 1)

				self:AddLeanTween(function()
					return LeanTween.scale(rtf(var_58_11), Vector3(0.5, 1, 1), self.STAR_ANIMATION_DUR4):setDelay(var_58_10 + var_58_6 * 1 / 3)
				end)
			end
		end
	end)
	var_57_0:SetEndEvent(function(arg_73_0)
		if self._shipVO:getReMetaSpecialItemVO() then
			GetComponent(self.metaRepeatTF, "CanvasGroup").alpha = 1

			self:managedTween(LeanTween.value, function()
				setAnchoredPosition(self.metaRepeatTF, {
					x = 0
				})

				self.inAnimating = false

				setActive(self.npc, self._shipVO:isActivityNpc())
				setActive(self._shade, false)
			end, go(self.metaRepeatTF), self.metaRepeatTF.rect.width, 0, 1):setOnUpdate(System.Action_float(function(arg_75_0)
				setAnchoredPosition(self.metaRepeatTF, {
					x = arg_75_0
				})
			end))
			setAnchoredPosition(self.metaRepeatTF, {
				x = self.metaRepeatTF.rect.width
			})
			setActive(self.metaRepeatTF, true)
		else
			self.inAnimating = false

			setActive(self.npc, self._shipVO:isActivityNpc())
			setActive(self._shade, false)
		end
	end)
end

function NewShipLayer:playOpening(arg_76_1)
	if self._shipVO:isMetaShip() then
		if not getProxy(ContextProxy):getContextByMediator(BuildShipMediator) then
			if arg_76_1 then
				arg_76_1()
			end

			return
		end
	end

	if checkABExist("ui/skinunlockanim/" .. "star_level_unlock_anim_" .. (self._shipVO:isRemoulded() and ShipGroup.GetGroupConfig(self._shipVO:getGroupId()).trans_skin or ShipGroup.getDefaultSkin(self._shipVO:getGroupId()).id)) then
		pg.CpkPlayMgr.GetInstance():PlayCpkMovie(function()
			return
		end, function()
			if arg_76_1 then
				arg_76_1()
			end
		end, "ui/skinunlockanim", "star_level_unlock_anim_" .. (self._shipVO:isRemoulded() and ShipGroup.GetGroupConfig(self._shipVO:getGroupId()).trans_skin or ShipGroup.getDefaultSkin(self._shipVO:getGroupId()).id), true, false)
	elseif arg_76_1 then
		arg_76_1()
	end
end

function NewShipLayer:ClearTweens(arg_79_1)
	self:cleanManagedTween(true)
end

function NewShipLayer:willExit()
	pg.CpkPlayMgr.GetInstance():DisposeCpkMovie()
	self:StopAutoExitTimer()
	self:DestroyNewShipDocumentView()

	if self.designBg then
		PoolMgr.GetInstance():ReturnUI(self.designName, self.designBg)
	end

	if self.metaBg then
		PoolMgr.GetInstance():ReturnUI(self.metaName, self.metaBg)
	end

	for iter_80_0, iter_80_1 in pairs(self.rarityEffect) do
		if iter_80_1 then
			PoolMgr.GetInstance():ReturnUI("getrole_" .. iter_80_0, iter_80_1)
		end
	end

	if self.dragTrigger then
		ClearEventTrigger(self.dragTrigger)

		self.dragTrigger = nil
	end

	if not self.isRemoulded then
		pg.TipsMgr.GetInstance():ShowTips(i18n("ship_newShipLayer_get", pg.ship_data_by_type[self._shipVO:getShipType()].type_name, self._shipVO:getName()), COLOR_GREEN)
	end

	self:recyclePainting()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	self:stopVoice()

	if self.loadedCVBankName then
		pg.CriMgr.UnloadCVBank(self.loadedCVBankName)

		self.loadedCVBankName = nil
	end

	if LeanTween.isTweening(go(self.rarityTF)) then
		LeanTween.cancel(go(self.rarityTF))
	end

	cameraPaintViewAdjust(false)
end

function NewShipLayer:DisplayNewShipDocumentView()
	self.newShipDocumentView = NewShipDocumentView.New(self._shake:Find("ForNotch"), self.event, self.contextData)

	self.newShipDocumentView:Load()
	self.newShipDocumentView:ActionInvoke("SetParams", self._shipVO, function()
		if not self.isLoadBg then
			return
		end

		self:showExitTip()
	end)
	self.newShipDocumentView:ActionInvoke("RefreshUI")
end

function NewShipLayer:DestroyNewShipDocumentView()
	if self.newShipDocumentView and self.newShipDocumentView:CheckState(BaseSubView.STATES.INITED) then
		self.newShipDocumentView:Destroy()
	end
end

function NewShipLayer:StopAutoExitTimer()
	if not self.autoExitTimer then
		return
	end

	self.autoExitTimer:Stop()

	self.autoExitTimer = nil
end

return NewShipLayer
