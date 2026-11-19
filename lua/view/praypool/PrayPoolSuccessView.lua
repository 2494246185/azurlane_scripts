local PrayPoolSuccessView = class("PrayPoolSuccessView", import("..base.BaseSubView"))

function PrayPoolSuccessView:getResource()
	local var_1_0 = {}

	for iter_1_0, iter_1_1 in ipairs(getProxy(PrayProxy):getSelectedShipIDList() or {}) do
		table.insertto(var_1_0, ResPathSupport.GetPaintingListByPaintingName(Ship.getPaintingName(iter_1_1)))
	end

	return table.insertto(var_1_0, PrayPoolSuccessView.super.getResource(self))
end

function PrayPoolSuccessView:getUIName()
	return "PrayPoolSuccessView"
end

function PrayPoolSuccessView:OnInit()
	self:initData()
	self:initUI()
	self:updateUI()
	self:Show()
end

function PrayPoolSuccessView:OnDestroy()
	self.buildMsgBox:hide()
end

function PrayPoolSuccessView:OnBackPress()
	if self:GetLoaded() and isActive(self.boxTF) then
		self.buildMsgBox:hide()

		return true
	end
end

function PrayPoolSuccessView:initData()
	self.prayProxy = getProxy(PrayProxy)
	self.poolType = self.prayProxy:getSelectedPoolType()
	self.playerProxy = getProxy(PlayerProxy)
	self.bagProxy = getProxy(BagProxy)
	self.useItem = pg.ship_data_create_material[1].use_item

	print("useitem " .. self.useItem)

	self.buildShipProxy = getProxy(BuildShipProxy)
end

function PrayPoolSuccessView:initUI()
	self.shipTF = {
		self._tf:Find("Ship1"),
		(self._tf:Find("Ship2"))
	}
	self.shipRarityTF = {
		self._tf:Find("Rarity1"),
		(self._tf:Find("Rarity2"))
	}
	self.boxTF = self._tf:Find("build_msg")
	self.buildMsgBox = PrayPoolSuccessView.MsgBox(self.boxTF)
	self.buildBtn = self._tf:Find("BuildBtn")
	self.buildCubeNumText = self._tf:Find("BuildInfo/CubeNum")
	self.buildGoldNumText = self._tf:Find("BuildInfo/GoldNum")
	self.curCubeNumText = self._tf:Find("CubeImg/NumText")
	self.material1 = self._tf:Find("material1")
	self.material2 = self._tf:Find("material2")
	self.ratioSpriteMap = {}

	local var_7_0 = self._tf:Find("Ratio")

	for iter_7_0 = 2, 6 do
		self.ratioSpriteMap[iter_7_0] = getImageSprite(var_7_0:Find(tostring(iter_7_0)))
	end

	self.raritySpriteMap = {
		Normal = {
			Light1 = getImageSprite(self._tf:Find("Light/Normal/Light1")),
			Light2 = getImageSprite(self._tf:Find("Light/Normal/Light2")),
			Light2_2 = getImageSprite(self._tf:Find("Light/Normal/Light2_2")),
			Light3 = getImageSprite(self._tf:Find("Light/Normal/Light3")),
			RarityBG = getImageSprite(self._tf:Find("RarityBG/Normal"))
		},
		UR = {
			Light1 = getImageSprite(self._tf:Find("Light/UR/Light1")),
			Light2 = getImageSprite(self._tf:Find("Light/UR/Light2")),
			Light2_2 = getImageSprite(self._tf:Find("Light/UR/Light2_2")),
			Light3 = getImageSprite(self._tf:Find("Light/UR/Light3")),
			RarityBG = getImageSprite(self._tf:Find("RarityBG/UR"))
		}
	}

	onButton(self, self.buildBtn, function()
		local var_8_0 = pg.ship_data_create_material[pg.activity_ship_create[self.poolType].create_id]
		local var_8_1 = self.playerProxy:getData()
		local var_8_2 = self.bagProxy:getItemCountById(self.useItem)
		local var_8_3 = math.max(1, (_.min({
			math.floor(var_8_1.gold / pg.ship_data_create_material[pg.activity_ship_create[self.poolType].create_id].use_gold),
			math.floor(var_8_2 / pg.ship_data_create_material[pg.activity_ship_create[self.poolType].create_id].number_1),
			MAX_BUILD_WORK_COUNT - table.getCount((self.buildShipProxy:getRawData()))
		})))

		local function var_8_4(arg_9_0)
			if arg_9_0 > var_8_3 or var_8_1.gold < arg_9_0 * var_8_0.use_gold or var_8_2 < arg_9_0 * var_8_0.number_1 then
				return false
			end

			return true
		end

		self.buildMsgBox:show(var_8_3, var_8_4, function(arg_10_0)
			self:emit(PrayPoolConst.START_BUILD_SHIP_EVENT, var_8_0.id, arg_10_0, 0)
		end, function(arg_11_0)
			return i18n("build_ship_tip", arg_11_0, var_8_0.name, arg_11_0 * var_8_0.use_gold, arg_11_0 * var_8_0.number_1, (var_8_4(arg_11_0) or nil) and (COLOR_GREEN or COLOR_RED))
		end)
	end, SFX_UI_BUILDING_STARTBUILDING)
end

function PrayPoolSuccessView:updateUI()
	self:updatePaint((self.prayProxy:getSelectedShipIDList()))

	local var_12_0 = self.bagProxy:getItemById(self.useItem) or {
		count = 0
	}

	setText(self.curCubeNumText, (nil).count)
	setText(self.buildCubeNumText, pg.ship_data_create_material[pg.activity_ship_create[self.poolType].create_id].number_1)
	setText(self.buildGoldNumText, pg.ship_data_create_material[pg.activity_ship_create[self.poolType].create_id].use_gold)
end

function PrayPoolSuccessView:updatePaint(arg_13_1)
	for iter_13_0 = 1, 2 do
		local var_13_0 = pg.ship_data_statistics[arg_13_1[iter_13_0]].name
		local var_13_1 = pg.ship_data_statistics[arg_13_1[iter_13_0]].english_name
		local var_13_2 = pg.ship_data_statistics[arg_13_1[iter_13_0]].rarity
		local var_13_3 = pg.ship_data_statistics[arg_13_1[iter_13_0]].rarity == ShipRarity.SSR
		local var_13_4 = self.shipTF[iter_13_0]
		local var_13_5 = self.shipTF[iter_13_0]:Find("Mask/Paint")

		setPaintingPrefabAsync(var_13_5, Ship.getPaintingName(arg_13_1[iter_13_0]), "build", function()
			local var_14_0 = GetComponent(var_13_5:Find("fitter"):GetChild(0), "MeshImage")
			local var_14_1 = ((iter_13_0 == 2 or nil) and (self.material2 or self.material1)):GetComponent(typeof(Image)).material

			var_14_1:SetFloat("_Range", iter_13_0 == 2 and 0.9 or -0.57)
			var_14_1:SetFloat("_Degree", iter_13_0 == 2 and -50 or 50)

			var_14_0.material = var_14_1
		end)

		local var_13_6 = var_13_4:Find("Light1")
		local var_13_7 = var_13_4:Find("Light2")
		local var_13_8 = var_13_7:Find("Light2_2")
		local var_13_9 = var_13_4:Find("Light3")

		if not var_13_3 then
			setImageSprite(var_13_6, self.raritySpriteMap.Normal.Light1)
			setImageSprite(var_13_7, self.raritySpriteMap.Normal.Light2)
			setImageSprite(var_13_8, self.raritySpriteMap.Normal.Light2_2)
			setImageSprite(var_13_9, self.raritySpriteMap.Normal.Light3)
			setImageColor(var_13_6, PrayPoolSuccessView.Rarity_To_Light_Color_1[var_13_2])
			setImageColor(var_13_7, PrayPoolSuccessView.Rarity_To_Light_Color_1[var_13_2])
			setImageColor(var_13_8, PrayPoolSuccessView.Rarity_To_Light_Color_1[var_13_2])
			setImageColor(var_13_9, PrayPoolSuccessView.Rarity_To_Light_Color_2[var_13_2])
		else
			setImageSprite(var_13_6, self.raritySpriteMap.UR.Light1)
			setImageSprite(var_13_7, self.raritySpriteMap.UR.Light2)
			setImageSprite(var_13_8, self.raritySpriteMap.UR.Light2_2)
			setImageSprite(var_13_9, self.raritySpriteMap.UR.Light3)
		end

		local var_13_10 = self.shipRarityTF[iter_13_0]

		setImageSprite(var_13_10, (var_13_3 or nil) and (self.raritySpriteMap.UR.RarityBG or self.raritySpriteMap.Normal.RarityBG))
		setText(var_13_4:Find("NameText"), var_13_0)
		setText(var_13_4:Find("NameEngText"), var_13_1)
		setImageSprite(var_13_10:Find("NumImg"), self.ratioSpriteMap[var_13_2], true)
	end
end

function PrayPoolSuccessView:MsgBox()
	local var_15_0 = {
		_go = self
	}

	var_15_0.__cname = "buildmsgbox"
	var_15_0._tf = tf(self)
	var_15_0.inited = false
	var_15_0.cancenlBtn = findTF(var_15_0._go, "window/btns/cancel_btn")
	var_15_0.confirmBtn = findTF(var_15_0._go, "window/btns/confirm_btn")
	var_15_0.closeBtn = findTF(var_15_0._go, "window/close_btn")
	var_15_0.count = 1
	var_15_0.minusBtn = findTF(var_15_0._go, "window/content/calc_panel/minus")
	var_15_0.addBtn = findTF(var_15_0._go, "window/content/calc_panel/add")
	var_15_0.maxBtn = findTF(var_15_0._go, "window/content/max")
	var_15_0.valueTxt = findTF(var_15_0._go, "window/content/calc_panel/Text"):GetComponent(typeof(Text))
	var_15_0.text = findTF(var_15_0._go, "window/content/Text"):GetComponent(typeof(Text))
	var_15_0.buildUI = self.parent
	var_15_0.active = false

	pg.DelegateInfo.New(var_15_0)
	setText(findTF(var_15_0.cancenlBtn, "Image/Image (1)"), i18n("text_cancel"))
	setText(findTF(var_15_0.confirmBtn, "Image/Image (1)"), i18n("text_confirm"))

	local function var_15_1(arg_16_0, arg_16_1)
		var_15_0.valueTxt.text = arg_16_0
		var_15_0.text.text = arg_16_1 and arg_16_1(arg_16_0) or ""
	end

	function var_15_0:init()
		self.inited = true

		onButton(self, self._tf, function()
			self:hide()
		end, SFX_PANEL)
		onButton(self, self.cancenlBtn, function()
			self:hide()
		end, SFX_PANEL)
		onButton(self, self.confirmBtn, function()
			if self.onConfirm then
				self.onConfirm(self.count)
			end

			self:hide()
		end, SFX_PANEL)
		onButton(self, self.closeBtn, function()
			self:hide()
		end, SFX_PANEL)
		onButton(self, self.minusBtn, function()
			if self:verifyCount(self.count - 1) then
				self.count = math.max(self.count - 1, 1)

				var_15_1(self.count, self.updateText)
			end
		end, SFX_PANEL)
		onButton(self, self.addBtn, function()
			if self:verifyCount(self.count + 1) then
				self.count = math.min(self.count + 1, self.max)

				var_15_1(self.count, self.updateText)
			end
		end, SFX_PANEL)
		onButton(self, self.maxBtn, function()
			if self:verifyCount(self.max) then
				self.count = self.max

				var_15_1(self.count, self.updateText)
			end
		end, SFX_PANEL)
	end

	function var_15_0:verifyCount(arg_25_1)
		if self.verify then
			return self.verify(arg_25_1)
		end

		return true
	end

	function var_15_0:isActive()
		return self.active
	end

	function var_15_0:show(arg_27_1, arg_27_2, arg_27_3, arg_27_4)
		self.verify = arg_27_2
		self.onConfirm = arg_27_3
		self.active = true
		self.max = arg_27_1 or 1
		self.count = 1
		self.updateText = arg_27_4

		var_15_1(self.count, arg_27_4)
		setActive(var_15_0._go, true)

		if not self.inited then
			self:init()
		end

		pg.UIMgr.GetInstance():BlurPanel(self._tf)
	end

	function var_15_0:hide()
		if self:isActive() then
			self.onConfirm = nil
			self.active = false
			self.updateText = nil
			self.count = 1
			self.max = 1
			self.verify = nil

			setActive(var_15_0._go, false)
			pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self.buildUI)
		end
	end

	function var_15_0:close()
		self:hide()
		pg.DelegateInfo.Dispose(self)
	end

	return var_15_0
end

PrayPoolSuccessView.Rarity_To_Light_Color_1 = {
	[2] = Color(0.5568627450980392, 0.5568627450980392, 0.5568627450980392, 1),
	[3] = Color(0.1568627450980392, 0.26666666666666666, 0.615686274509804, 1),
	[4] = Color(0.32941176470588235, 0.1568627450980392, 0.615686274509804, 1),
	[5] = Color(1, 0.8313725490196079, 0.3137254901960784, 1)
}
PrayPoolSuccessView.Rarity_To_Light_Color_2 = {
	[2] = Color(0.6235294117647059, 0.6549019607843137, 0.7411764705882353, 1),
	[3] = Color(0.34901960784313724, 0.5294117647058824, 0.996078431372549, 1),
	[4] = Color(0.9058823529411765, 0.615686274509804, 0.996078431372549, 1),
	[5] = Color(0.996078431372549, 0.8705882352941177, 0.3215686274509804, 1)
}

return PrayPoolSuccessView
