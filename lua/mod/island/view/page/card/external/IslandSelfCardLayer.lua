local IslandSelfCardLayer = class("IslandSelfCardLayer", import("view.base.BaseUI"))

IslandSelfCardLayer.LABEL_SHOW_CNT = 2
IslandSelfCardLayer.ACHV_SHOW_CNT = 4
IslandSelfCardLayer.COLORS = {
	"#A38759",
	"#AB7B7B",
	"#B1B284",
	"#8B99AC",
	"#8AAD8B",
	"#9D87A9"
}

function IslandSelfCardLayer:getUIName()
	return "IslandSelfCardUI"
end

function IslandSelfCardLayer:preload(arg_2_1)
	local var_2_0 = getProxy(PlayerProxy):getData().id

	seriesAsync({
		function(arg_3_0)
			local var_3_0 = getProxy(IslandProxy):GetIsland()

			if var_3_0 then
				self.island = var_3_0

				arg_3_0()
			else
				pg.m02:sendNotification(GAME.ISLAND_GET_DATA, {
					isCardRequest = true,
					id = var_2_0,
					list = {},
					callback = function()
						self.island = getProxy(IslandProxy):GetIsland()

						arg_3_0()
					end
				})
			end
		end,
		function(arg_5_0)
			pg.m02:sendNotification(GAME.ISLAND_GET_CARD_DATA, {
				userId = var_2_0,
				callback = function(arg_6_0)
					self.card = arg_6_0

					arg_5_0()
				end
			})
		end
	}, function()
		arg_2_1()
	end)
end

function IslandSelfCardLayer:getResource()
	local var_8_0 = IslandSelfCardLayer.super.getResource(self)

	for iter_8_0, iter_8_1 in ipairs({
		"islandachievement",
		"islandphoto",
		"ui/islandcardui_atlas"
	} or {}) do
		if not table.contains(var_8_0, iter_8_1) then
			table.insert(var_8_0, iter_8_1)
		end
	end

	return var_8_0
end

function IslandSelfCardLayer:init()
	self.uiAnim = self._tf:GetComponent(typeof(Animation))
	self.uiAnimEvent = self._tf:GetComponent(typeof(DftAniEvent))

	self.uiAnimEvent:SetEndEvent(function()
		self.playingHideAnim = false

		self.closeView(self, self)
	end)
	setText(self._tf:Find("tip"), i18n("island_card_close"))

	local var_9_0 = self._tf:Find("panel")

	self.photoTF = var_9_0:Find("photo/Image")
	self.photoSwitchBtn = var_9_0:Find("photo/switch")
	self.likeTF = var_9_0:Find("photo/like")
	self.labelsTF = var_9_0:Find("labels")
	self.visitTF = var_9_0:Find("btns/visit/Text")
	self.diyBtn = var_9_0:Find("btns/diy")
	self.whitelistBtn = var_9_0:Find("btns/whitelist")
	self.blacklistBtn = var_9_0:Find("btns/blacklist")
	self.levelTF = var_9_0:Find("level")
	self.wordTF = var_9_0:Find("word")
	self.nameTF = var_9_0:Find("name")
	self.addBtn = self.nameTF:Find("add")
	self.removeBtn = self.nameTF:Find("remove")
	self.editBtn = self.nameTF:Find("edit")
	self.editPanel = self._tf:Find("editPanel")
	self.editNameBtn = self.editPanel:Find("content/name")

	setText(self.editNameBtn:Find("Text"), i18n("island_card_edit_name"))

	self.editWordBtn = self.editPanel:Find("content/word")

	setText(self.editWordBtn:Find("Text"), i18n("island_card_edit_word"))

	self.shipTF = var_9_0:Find("counts/ship/Text")
	self.achvTF = var_9_0:Find("counts/achv/Text")
	self.bookTF = var_9_0:Find("counts/book/Text")
	self.achvUIList = UIItemList.New(var_9_0:Find("achvs"), var_9_0:Find("achvs/tpl"))

	setText(var_9_0:Find("achvs/tpl/empty/Text"), i18n("island_card_no_achv_self"))
	self:InitBoxs()
end

function IslandSelfCardLayer:InitBoxs()
	self.editNameBox = IslandEditCardNameBox.New(self._tf, self.event)
	self.editWordBox = IslandEditCardWordBox.New(self._tf, self.event)
	self.setPhotoBox = IslandSetCardPhotoBox.New(self._tf, self.event)
	self.setAchvsBox = IslandSetCardAchvsBox.New(self._tf, self.event)
	self.showLabelBox = IslandShowCardLabelBox.New(self._tf, self.event)
end

function IslandSelfCardLayer:didEnter()
	if not self.contextData.isIslandPage then
		pg.UIMgr.GetInstance():BlurPanel(self._tf)
	end

	onButton(self, self._tf:Find("panel/help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.island_helpbtn_card.tip
		})
	end, SFX_PANEL)
	onButton(self, self._tf:Find("close"), function()
		self:PlayHideAnim()
	end, SFX_PANEL)
	onButton(self, self.photoSwitchBtn, function()
		self.setPhotoBox:ExecuteAction("Show", self.island:GetCardDiyAgency():GetIds(), self.photoId)
	end, SFX_PANEL)
	onButton(self, self.editBtn, function()
		self:ShowEditPanel()
	end, SFX_PANEL)
	onButton(self, self.editPanel:Find("close"), function()
		self:HideEditPanel()
	end, SFX_PANEL)
	onButton(self, self.editNameBtn, function()
		self.editNameBox:ExecuteAction("Show")
	end, SFX_PANEL)
	onButton(self, self.editWordBtn, function()
		self.editWordBox:ExecuteAction("Show")
	end, SFX_PANEL)
	self:InitAchvUIList()
	self:Flush()
end

function IslandSelfCardLayer:InitAchvUIList()
	self.achvUIList:make(function(arg_21_0, arg_21_1, arg_21_2)
		if arg_21_0 == UIItemList.EventInit then
			onButton(self, arg_21_2, function()
				self.setAchvsBox:ExecuteAction("Show", self.island:GetAchievementAgency():GetGotGroupMaxStageList(), Clone(self.card.achvList))
			end, SFX_PANEL)
		elseif arg_21_0 == UIItemList.EventUpdate then
			self:UpdataAchvItem(arg_21_1, arg_21_2)
		end
	end)
end

function IslandSelfCardLayer:ShowEditPanel()
	setAnchoredPosition(self.editPanel:Find("content"), (self._tf:InverseTransformPoint(self.editBtn.position)))
	setActive(self.editPanel, true)
end

function IslandSelfCardLayer:HideEditPanel()
	setActive(self.editPanel, false)
end

function IslandSelfCardLayer:UpdataAchvItem(arg_25_1, arg_25_2)
	setActive(arg_25_2:Find("empty"), not self.card.achvList[arg_25_1 + 1])
	setActive(arg_25_2:Find("content"), self.card.achvList[arg_25_1 + 1])

	if self.card.achvList[arg_25_1 + 1] then
		LoadImageSpriteAtlasAsync("islandachievement", "achv_stage_" .. pg.island_achievement[self.card.achvList[arg_25_1 + 1]].stage, arg_25_2:Find("content/Image"), true)
		setText(arg_25_2:Find("content/Text"), pg.island_achievement[self.card.achvList[arg_25_1 + 1]].name)
	end
end

function IslandSelfCardLayer:Flush()
	self.card.achvList = getProxy(IslandProxy):GetIsland():GetAchievementAgency():UpdataAchLv(self.card.achvList)

	self:UpdataPhoto()
	self:UpdataLabels()
	self:UpdataInfos()
end

function IslandSelfCardLayer:UpdataPhoto()
	self.photoId = tonumber(self.card.photoStr)

	if self.photoId then
		LoadImageSpriteAsync(pg.island_card_diy[self.photoId].resource, self.photoTF, true)
	end
end

function IslandSelfCardLayer:UpdataLabels()
	self.labels = self.card:GetLabelList()

	table.sort(self.labels, CompareFuncs({
		function(arg_29_0)
			return -arg_29_0.num
		end,
		function(arg_30_0)
			return arg_30_0.id
		end
	}))

	for iter_28_0 = 1, IslandSelfCardLayer.LABEL_SHOW_CNT + 1 do
		local var_28_0 = self.labelsTF:GetChild(iter_28_0 - 1)
		local var_28_1 = iter_28_0 <= #self.labels + 1

		setActive(var_28_0, iter_28_0 <= #self.labels + 1)

		if var_28_1 then
			if iter_28_0 <= #self.labels then
				self:UpdateNoramlLabel(var_28_0, self.labels[iter_28_0])
			else
				self:UpdateGrayLabel(var_28_0)
			end
		end
	end
end

function IslandSelfCardLayer:UpdateNoramlLabel(arg_31_1, arg_31_2)
	LoadImageSpriteAtlasAsync("ui/islandcardui_atlas", "label_bg_" .. pg.island_card_label[arg_31_2.id].color, arg_31_1, true)
	setTextColor(arg_31_1:Find("name"), Color.NewHex(IslandSelfCardLayer.COLORS[pg.island_card_label[arg_31_2.id].color]))
	setTextColor(arg_31_1:Find("value"), Color.NewHex(IslandSelfCardLayer.COLORS[pg.island_card_label[arg_31_2.id].color]))
	setText(arg_31_1:Find("name"), pg.island_card_label[arg_31_2.id].name)
	setText(arg_31_1:Find("value"), arg_31_2.num)
	removeOnButton(arg_31_1)
end

function IslandSelfCardLayer:UpdateGrayLabel(arg_32_1)
	LoadImageSpriteAtlasAsync("ui/islandcardui_atlas", "bg_label_gray", arg_32_1, true)

	local var_32_0 = #self.labels == 0

	setTextColor(arg_32_1:Find("name"), Color.NewHex("#F7F7F7"))
	setText(arg_32_1:Find("name"), var_32_0 and i18n("island_card_no_label") or i18n("island_card_view_detaills"))
	setText(arg_32_1:Find("value"), "")

	if not var_32_0 then
		onButton(self, arg_32_1, function()
			self.showLabelBox:ExecuteAction("Show", self.labels)
		end, SFX_PANEL)
	else
		removeOnButton(arg_32_1)
	end
end

function IslandSelfCardLayer:UpdataInfos()
	setText(self.nameTF, self.card.name)
	setText(self.levelTF, "Lv." .. self.card.level)
	setText(self.wordTF, self.card.word)
	setText(self.likeTF, self.card.likeCnt)
	setText(self.visitTF, self.card.visitCnt)
	setText(self.shipTF, self.card.shipCnt)
	setText(self.achvTF, self.card.achvCnt)
	setText(self.bookTF, self.card.bookCnt)
	self.achvUIList:align(IslandSelfCardLayer.ACHV_SHOW_CNT)
end

function IslandSelfCardLayer:OnSetNameDone(arg_35_1)
	self:HideEditPanel()
	self.editNameBox:ExecuteAction("Hide")

	self.card.name = arg_35_1

	setText(self.nameTF, self.card.name)
end

function IslandSelfCardLayer:OnSetWordDone(arg_36_1)
	self:HideEditPanel()
	self.editWordBox:ExecuteAction("Hide")

	self.card.word = arg_36_1

	setText(self.wordTF, self.card.word)
end

function IslandSelfCardLayer:OnSetPhotoDone(arg_37_1)
	self.setPhotoBox:ExecuteAction("Hide")

	self.card.photoStr = arg_37_1

	self:UpdataPhoto()
end

function IslandSelfCardLayer:OnSetAchvsDone(arg_38_1)
	self.setAchvsBox:ExecuteAction("Hide")

	self.card.achvList = getProxy(IslandProxy):GetIsland():GetAchievementAgency():UpdataAchLv(arg_38_1)

	self.achvUIList:align(IslandSelfCardLayer.ACHV_SHOW_CNT)

	local var_38_0 = {}

	self.achvUIList:eachActive(function(arg_39_0, arg_39_1)
		if self.card.achvList[arg_39_0 + 1] then
			local var_39_0 = arg_39_1:Find("content/Image")

			var_39_0:GetComponent(typeof(CanvasGroup)).alpha = 0

			table.insert(var_38_0, function(arg_40_0)
				arg_39_1:GetComponent(typeof(Animation)):Play()

				var_39_0:GetComponent(typeof(CanvasGroup)).alpha = 1

				self:managedTween(LeanTween.delayedCall, function()
					arg_40_0()
				end, 0.08, nil)
			end)
		end
	end)
	seriesAsync(var_38_0)
end

function IslandSelfCardLayer:PlayHideAnim()
	if self.playingHideAnim then
		return
	end

	self.uiAnim:Play("anim_IslandSelfCardUI_out")

	self.playingHideAnim = true
end

function IslandSelfCardLayer:willExit()
	self.uiAnimEvent:SetEndEvent(nil)

	if not self.contextData.isIslandPage then
		pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	end

	if self.editNameBox then
		self.editNameBox:Destroy()

		self.editNameBox = nil
	end

	if self.editWordBox then
		self.editWordBox:Destroy()

		self.editWordBox = nil
	end

	if self.setPhotoBox then
		self.setPhotoBox:Destroy()

		self.setPhotoBox = nil
	end

	if self.setAchvsBox then
		self.setAchvsBox:Destroy()

		self.setAchvsBox = nil
	end

	if self.showLabelBox then
		self.showLabelBox:Destroy()

		self.showLabelBox = nil
	end
end

return IslandSelfCardLayer
