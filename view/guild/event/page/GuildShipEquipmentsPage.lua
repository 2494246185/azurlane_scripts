local GuildShipEquipmentsPage = class("GuildShipEquipmentsPage", import("....base.BaseSubView"))

function GuildShipEquipmentsPage:getUIName()
	return "GuildShipEquipmentsPage"
end

function GuildShipEquipmentsPage:getResource()
	return table.insertto({
		"shiptype",
		"weaponframes",
		"ui/iconcolorful"
	}, GuildShipEquipmentsPage.super.getResource(self))
end

function GuildShipEquipmentsPage:getEquipmentResList(arg_3_1)
	local var_3_0 = {}

	_.each(arg_3_1 and arg_3_1:getActiveEquipments() or {}, function(arg_4_0)
		if arg_4_0 then
			table.insert(var_3_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.Equipment.Equip, arg_4_0:getConfig("icon"))))
		end
	end)

	return var_3_0
end

function GuildShipEquipmentsPage:OnLoaded()
	self.shipNameTxt = self._tf:Find("frame/ship_info/shipname"):GetComponent(typeof(Text))
	self.userNameTxt = self._tf:Find("frame/ship_info/username"):GetComponent(typeof(Text))
	self.shipTypeIcon = self._tf:Find("frame/ship_info/ship_type"):GetComponent(typeof(Image))
	self.shipStarList = UIItemList.New(self._tf:Find("frame/ship_info/stars"), self._tf:Find("frame/ship_info/stars/star_tpl"))
	self.shipLvTxt = self._tf:Find("frame/ship_info/lv/Text"):GetComponent(typeof(Text))
	self.equipmentList = UIItemList.New(self._tf:Find("frame/equipemtns"), self._tf:Find("frame/equipemtns/equipment_tpl"))
	self.playerId = getProxy(PlayerProxy):getRawData().id
	self.nextBtn = self._tf:Find("frame/next")
	self.prevBtn = self._tf:Find("frame/prev")
end

function GuildShipEquipmentsPage:OnInit()
	onButton(self, self._tf, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.nextBtn, function()
		if self.onNext then
			self.onNext()
		end
	end, SFX_PANEL)
	onButton(self, self.prevBtn, function()
		if self.onPrev then
			self.onPrev()
		end
	end, SFX_PANEL)
end

function GuildShipEquipmentsPage:SetCallBack(arg_10_1, arg_10_2)
	self.onPrev = arg_10_1
	self.onNext = arg_10_2
end

function GuildShipEquipmentsPage:downloadEquipmentResList(arg_11_1, arg_11_2)
	SplitPackConst.DownloadByLuaArr(self:getEquipmentResList(arg_11_1), function()
		if self._state == GuildShipEquipmentsPage.STATES.DESTROY then
			return
		end

		arg_11_2()
	end)
end

function GuildShipEquipmentsPage:Show(arg_13_1, arg_13_2, arg_13_3, arg_13_4)
	self:downloadEquipmentResList(arg_13_1, function()
		GuildShipEquipmentsPage.super.Show(self)

		self.OnHide = arg_13_3

		if arg_13_4 then
			arg_13_4()
		end

		self:Flush(arg_13_1, arg_13_2)
		pg.UIMgr.GetInstance():BlurPanel(self._tf)
		setActive(self.nextBtn, self.onNext ~= nil)
		SetActive(self.prevBtn, self.onPrev ~= nil)
	end)
end

function GuildShipEquipmentsPage:Flush(arg_15_1, arg_15_2)
	self.ship = arg_15_1
	self.member = arg_15_2

	self:UpdateShipInfo()
	self:UpdateEquipments()
end

function GuildShipEquipmentsPage:Refresh(arg_16_1, arg_16_2)
	self:downloadEquipmentResList(arg_16_1, function()
		self:Flush(arg_16_1, arg_16_2)
	end)
end

function GuildShipEquipmentsPage:UpdateShipInfo()
	local var_18_0 = self.member

	self.shipNameTxt.text = self.ship:getName()
	self.userNameTxt.text = self.playerId == var_18_0.id and "" or i18n("guild_ship_from") .. var_18_0.name
	self.shipTypeIcon.sprite = GetSpriteFromAtlas("shiptype", shipType2print(pg.ship_data_statistics[self.ship.configId].type))

	local var_18_1 = self.ship:getStar()

	self.shipStarList:make(function(arg_19_0, arg_19_1, arg_19_2)
		if arg_19_0 == UIItemList.EventUpdate then
			setActive(arg_19_2:Find("star_tpl"), arg_19_1 <= var_18_1)
		end
	end)
	self.shipStarList:align((self.ship:getMaxStar()))

	self.shipLvTxt.text = self.ship.level
end

function GuildShipEquipmentsPage:UpdateEquipments()
	local var_20_0 = self.ship:getActiveEquipments()

	self.equipmentList:make(function(arg_21_0, arg_21_1, arg_21_2)
		if arg_21_0 == UIItemList.EventUpdate then
			setActive(arg_21_2:Find("info"), var_20_0[arg_21_1 + 1])
			setActive(arg_21_2:Find("empty"), not var_20_0[arg_21_1 + 1])

			if var_20_0[arg_21_1 + 1] then
				updateEquipment(arg_21_2:Find("info"), var_20_0[arg_21_1 + 1])
				setText(arg_21_2:Find("info/name_bg/Text"), shortenString(var_20_0[arg_21_1 + 1]:getConfig("name"), 5))
			end
		end
	end)
	self.equipmentList:align(5)
end

function GuildShipEquipmentsPage:Hide()
	GuildShipEquipmentsPage.super.Hide(self)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)

	if self.OnHide then
		self.OnHide()

		self.OnHide = nil
	end
end

function GuildShipEquipmentsPage:OnDestroy()
	self:Hide()
end

return GuildShipEquipmentsPage
