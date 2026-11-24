local PlayerVitaeScene = class("PlayerVitaeScene", import("..base.BaseUI"))

PlayerVitaeScene.ON_PAGE_SWTICH = "PlayerVitaeScene:ON_PAGE_SWTICH"
PlayerVitaeScene.PAGE_DEFAULT = 1
PlayerVitaeScene.PAGE_NATIVE_SHIPS = 2
PlayerVitaeScene.PAGE_RANDOM_SHIPS = 3

function PlayerVitaeScene:getUIName()
	return "PlayerVitaeUI"
end

function PlayerVitaeScene:getResource(arg_2_1)
	return ResPathSupport.MergeLuaArr({
		"ui/playervitaeui",
		"ui/share/btn_l2d_atlas",
		"commonbg/bg_admiral",
		"ui/shareui",
		"ui/admiralui_atlas",
		"ui/playervitaeshipspage"
	}, (function()
		local var_3_0 = {}
		local var_3_1 = getProxy(MilitaryExerciseProxy):RawGetSeasonInfo()
		local var_3_2 = SeasonInfo.getEmblem(var_3_1.score, var_3_1.rank)

		table.insert(var_3_0, "emblem/" .. var_3_2)
		table.insert(var_3_0, "emblem/n_" .. var_3_2)

		return var_3_0
	end)(), (function()
		local var_4_0 = {}
		local var_4_1 = self:GetFlagShip()
		local var_4_2 = getProxy(ShipSkinProxy):GetAllSkinForShip(var_4_1)

		table.insertto(var_4_2, (_.map(getProxy(ShipSkinProxy):GetShareSkinsForShip(var_4_1), function(arg_5_0)
			return pg.ship_skin_template[arg_5_0.id]
		end)))

		for iter_4_0, iter_4_1 in ipairs(var_4_2) do
			if iter_4_1 then
				local var_4_3 = iter_4_1.painting or "unknown"

				if var_4_3 ~= "unknown" then
					table.insertto(var_4_0, (ResPathSupport.GetPaintingListByPaintingName(var_4_3)))
				end
			end
		end

		return var_4_0
	end)(), (function()
		return {}
	end)(), ((function()
		local var_6_0 = {}

		for iter_6_0, iter_6_1 in ipairs(self:GetPlayer().displayTrophyList) do
			local var_6_1 = iter_6_1 > 1000000000 and LoveLetterTrophy.New({
				id = iter_6_1
			}) or Trophy.New({
				id = iter_6_1
			})

			if var_6_1:isLoverLetter() then
				table.insert(var_6_0, var_6_1:GetPrefabName())
				table.insert(var_6_0, "SquareIcon/" .. var_6_1:GetPainting())
			else
				table.insert(var_6_0, "medal/s_" .. var_6_1:getConfig("icon"))
			end
		end

		return var_6_0
	end)()))
end

function PlayerVitaeScene:GetBGM()
	local var_8_0 = self:GetFlagShip()

	if var_8_0:IsBgmSkin() and getProxy(SettingsProxy):IsBGMEnable() then
		return var_8_0:GetSkinBgm()
	else
		return "main"
	end
end

function PlayerVitaeScene:OnPlayerNameChange()
	if self.detailPage and self.detailPage:GetLoaded() then
		self.detailPage:OnPlayerNameChange(self:GetPlayer())
	end
end

function PlayerVitaeScene:OnShipSkinChanged(arg_10_1)
	self:UpdatePainting()

	if self.shipsPage and self.shipsPage:isShowing() then
		self.shipsPage:UpdateCard(arg_10_1)
	end
end

function PlayerVitaeScene:ReloadPanting(arg_11_1)
	if self.displaySkinID and self.displaySkinID == arg_11_1 then
		self:ReturnPainting()

		local var_11_0 = self:GetFlagShip():getPainting()

		setPaintingPrefabAsync(self.painting, var_11_0, "kanban")

		self.paintingName = var_11_0
	end
end

function PlayerVitaeScene:RefreshShips()
	if self.shipsPage and self.shipsPage:GetLoaded() and self.shipsPage:isShowing() then
		self.shipsPage:RefreshShips()
	end
end

function PlayerVitaeScene:GetPlayer()
	return getProxy(PlayerProxy):getRawData()
end

function PlayerVitaeScene:GetFlagShip()
	return (self:GetPlayer():GetFlagShip())
end

function PlayerVitaeScene:init()
	self.bg = self._tf:Find("bg")
	self.backBtn = self._tf:Find("top/frame/back")
	self.mainViewCg = self._tf:Find("adapt"):GetComponent(typeof(CanvasGroup))
	self.mainTr = self.mainViewCg.gameObject.transform
	self.painting = self._tf:Find("adapt/paint")
	self.btnContainer = self._tf:Find("adapt/btns")
	self.switchSkinBtn = self._tf:Find("adapt/btns/swichSkin_btn")
	self.replaceBtn = self._tf:Find("adapt/btns/replace_btn")
	self.replaceBtnTip = self.replaceBtn:Find("tip")
	self.cryptolaliaBtn = self._tf:Find("adapt/btns/cryptolalia_btn")
	self.switchSkinBtnTag = self.switchSkinBtn:Find("Tag")
	self.titlt = self._tf:Find("top/frame/title")
	self.titltNative = self._tf:Find("top/frame/title_native")
	self.titltRandom = self._tf:Find("top/frame/title_random")

	local var_15_0 = self._tf:Find("detail")

	self.detailCg = GetOrAddComponent(var_15_0, typeof(CanvasGroup))

	local var_15_1 = self._tf:Find("adapt/tpl")

	setActive(var_15_1, false)

	self.btns = {
		PlayerVitaeSpineBtn.New(var_15_1, PlayerVitaeBaseBtn.HRZ_TYPE),
		PlayerVitaeBGBtn.New(var_15_1, PlayerVitaeBaseBtn.HRZ_TYPE),
		PlayerVitaeBMGBtn.New(var_15_1, PlayerVitaeBaseBtn.HRZ_TYPE),
		PlayerVitaeLive2dBtn.New(var_15_1, PlayerVitaeBaseBtn.HRZ_TYPE)
	}

	for iter_15_0 = 1, #self.btns do
		self.btns[iter_15_0]:setParent(self._tf:Find("adapt/toggleBtns"), #self.btns - iter_15_0)
	end

	self.btnLive2dReset = self._tf:Find("adapt/btnLive2dReset")

	GetComponent(findTF(self.btnLive2dReset, "img"), typeof(Image)):SetNativeSize()
	GetComponent(self.btnLive2dReset, typeof(Image)):SetNativeSize()
	SetParent(self.btnLive2dReset, self._tf:Find("adapt/toggleBtns"))

	self.shipsPage = PlayerVitaeShipsPage.New(self._tf, self.event, self.contextData)
	self.detailPage = PlayerVitaeDetailPage.New(var_15_0, self.event, self.contextData)

	setParent(self._tf:Find("adapt/toggleBtns"), self._tf:Find("detail"), true)

	self.contextData.renamePage = PlayerVitaeRenamePage.New(self._tf, self.event)
	self.topFrame = self._tf:Find("top/frame")
	self.detailPosx = self._tf.rect.width * 0.5 - 937 * PlayerVitaeDetailPage.PreCalcAspect(var_15_0, 1080)

	LoadSpriteAsync("CommonBG/bg_admiral", function(arg_16_0)
		if IsNil(self.bg) then
			return
		end

		local var_16_0 = self.bg:GetComponent(typeof(Image))

		var_16_0.sprite = arg_16_0
		var_16_0.color = Color.New(1, 1, 1, 1)
	end)
end

function PlayerVitaeScene:didEnter()
	onButton(self, self.backBtn, function()
		if self.shipsPage:GetLoaded() and self.shipsPage:isShowing() then
			self.shipsPage:Hide()
			self:ShowOrHideMainView(true)
		else
			self:emit(PlayerVitaeScene.ON_BACK)
		end
	end, SFX_CANCEL)
	onButton(self, self.switchSkinBtn, function()
		self:emit(PlayerVitaeMediator.CHANGE_SKIN, (self:GetFlagShip()))
	end, SFX_PANEL)
	onButton(self, self.replaceBtn, function()
		self.shipsPage:ExecuteAction("Update")
		self:ShowOrHideMainView(false)
	end, SFX_PANEL)
	onButton(self, self.cryptolaliaBtn, function()
		self:emit(PlayerVitaeMediator.OPEN_CRYPTOLALIA, self:GetFlagShip():getGroupId())
	end, SFX_PANEL)
	self:bind(PlayerVitaeScene.ON_PAGE_SWTICH, function(arg_22_0, arg_22_1)
		setActive(self.titlt, arg_22_1 == PlayerVitaeScene.PAGE_DEFAULT)
		setActive(self.titltNative, arg_22_1 == PlayerVitaeScene.PAGE_NATIVE_SHIPS)
		setActive(self.titltRandom, arg_22_1 == PlayerVitaeScene.PAGE_RANDOM_SHIPS)
	end)

	local var_17_0 = false

	if self.contextData.showSelectCharacters then
		self.contextData.showSelectCharacters = nil

		triggerButton(self.replaceBtn)
	else
		self:DoEnterAnimation()

		var_17_0 = true
	end

	self:UpdatePainting()
	self:UpdateReplaceTip()
	self.detailPage:ExecuteAction("Show", self:GetPlayer(), var_17_0)
	self:emit(PlayerVitaeScene.ON_PAGE_SWTICH, PlayerVitaeScene.PAGE_DEFAULT)
	self:checkShowResetL2dBtn()
end

function PlayerVitaeScene:UpdateReplaceTip()
	local var_23_0 = getProxy(SettingsProxy):ShouldEducateCharTip()

	var_23_0 = var_23_0 or getProxy(ActivityProxy):IsTipLoveLetterMail()

	setActive(self.replaceBtnTip, var_23_0)
end

function PlayerVitaeScene:DoEnterAnimation()
	local function var_24_0(arg_25_0)
		local var_25_0 = arg_25_0.anchoredPosition3D

		arg_25_0.anchoredPosition3D = Vector3(arg_25_0.anchoredPosition3D.x - 1200, arg_25_0.anchoredPosition3D.y, 0)

		LeanTween.value(arg_25_0.gameObject, arg_25_0.anchoredPosition3D.x - 1200, arg_25_0.anchoredPosition3D.x, 0.2):setOnUpdate(System.Action_float(function(arg_26_0)
			arg_25_0.anchoredPosition3D = Vector3(arg_26_0, var_25_0.y, 0)
		end)):setDelay(0.1):setEase(LeanTweenType.easeInOutSine)
	end

	for iter_24_0, iter_24_1 in ipairs({
		self.btnContainer,
		self.painting
	}) do
		var_24_0(iter_24_1)
	end

	;(function(arg_27_0)
		arg_27_0.localPosition = Vector3(arg_27_0.localPosition.x, arg_27_0.localPosition.y + 150, 0)

		LeanTween.moveLocalY(arg_27_0.gameObject, arg_27_0.localPosition.y, 0.2):setDelay(0.1):setEase(LeanTweenType.easeInOutSine)
	end)(self.topFrame)
end

function PlayerVitaeScene:ShowOrHideMainView(arg_28_1)
	self.mainViewCg.alpha = arg_28_1 and 1 or 0
	self.mainViewCg.blocksRaycasts = arg_28_1
	self.detailCg.alpha = arg_28_1 and 1 or 0
	self.detailCg.blocksRaycasts = arg_28_1

	if arg_28_1 then
		self:UpdatePainting()
		self:UpdateReplaceTip()
	end
end

function PlayerVitaeScene:UpdatePainting(arg_29_1)
	local var_29_0 = self:GetFlagShip()
	local var_29_1 = false
	local var_29_2 = {}

	for iter_29_0, iter_29_1 in ipairs(self.btns) do
		local var_29_3 = iter_29_1:IsActive(var_29_0)

		if var_29_3 then
			table.insert(var_29_2, iter_29_1)
		end

		iter_29_1:Update(var_29_3, #var_29_2, var_29_0)

		if var_29_3 and not var_29_1 and iter_29_1:IsOverlap(self.detailPosx) then
			var_29_1 = true
		end
	end

	if var_29_1 then
		for iter_29_2, iter_29_3 in ipairs(var_29_2) do
			iter_29_3:SwitchToVecLayout()
		end
	end

	if not self.displaySkinID or self.displaySkinID ~= var_29_0:getSkinId() or arg_29_1 then
		self:ReturnPainting()

		local var_29_4 = var_29_0:getPainting()

		setPaintingPrefabAsync(self.painting, var_29_4, "kanban")

		self.paintingName = var_29_4

		setActive(self.switchSkinBtn, not HXSet.isHxSkin() and getProxy(ShipSkinProxy):HasFashion(var_29_0) and not isa(var_29_0, VirtualEducateCharShip))

		self.displaySkinID = var_29_0:getSkinId()
	end

	setActive(self.cryptolaliaBtn, getProxy(PlayerProxy):getRawData():ExistCryptolalia((var_29_0:getGroupId())))
	self:updateSwitchSkinBtnTag()
	self:checkShowResetL2dBtn()
end

function PlayerVitaeScene:ReturnPainting()
	if self.paintingName then
		retPaintingPrefab(self.painting, self.paintingName)
	end

	self.paintingName = nil
end

function PlayerVitaeScene:updateSwitchSkinBtnTag()
	setActive(self.switchSkinBtnTag, #PaintingGroupConst.GetPaintingNameListByShipVO((self:GetFlagShip())) > 0)
end

function PlayerVitaeScene:onBackPressed()
	if self.shipsPage and self.shipsPage:GetLoaded() and self.shipsPage:isShowing() then
		triggerButton(self.backBtn)

		return
	end

	if self.contextData.renamePage and self.contextData.renamePage:GetLoaded() and self.contextData.renamePage:isShowing() then
		self.contextData.renamePage:Hide()

		return
	end

	PlayerVitaeScene.super.onBackPressed(self)
end

function PlayerVitaeScene:checkShowResetL2dBtn()
	local var_33_0 = self:GetFlagShip()

	if var_33_0 and var_33_0:GetSkinConfig().spine_use_live2d == 1 then
		setActive(self.btnLive2dReset, false)

		return
	end

	if not checkABExist((HXSet.autoHxShiftPath("live2d/" .. string.lower(var_33_0:getPainting()), nil, true))) then
		setActive(self.btnLive2dReset, false)

		return
	end

	setActive(self.btnLive2dReset, true)
	onButton(self, self.btnLive2dReset, function()
		if self:GetFlagShip() then
			local var_34_0 = self:GetFlagShip()

			Live2dConst.ClearLive2dSave(var_34_0:getSkinId(), var_34_0.id)
			Live2dConst.SetLive2dDirty(var_34_0:getSkinId(), var_34_0.id)
		end
	end, SFX_CONFIRM)
end

function PlayerVitaeScene:willExit()
	self:ReturnPainting()

	if LeanTween.isTweening(self.painting.gameObject) then
		LeanTween.cancel(self.painting.gameObject)
	end

	for iter_35_0, iter_35_1 in ipairs(self.btns) do
		iter_35_1:Dispose()
	end

	self.btns = nil

	if self.shipsPage then
		self.shipsPage:Destroy()

		self.shipsPage = nil
	end

	if self.detailPage then
		self.detailPage:Destroy()

		self.detailPage = nil
	end

	if self.contextData.renamePage then
		self.contextData.renamePage:Destroy()

		self.contextData.renamePage = nil
	end
end

return PlayerVitaeScene
