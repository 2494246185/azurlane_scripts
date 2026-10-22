local WorldMediaCollectionScene = class("WorldMediaCollectionScene", require("view.base.BaseUI"))

WorldMediaCollectionScene.PAGE_MEMORTY = 1
WorldMediaCollectionScene.PAGE_FILE = 2
WorldMediaCollectionScene.PAGE_RECORD = 3
WorldMediaCollectionScene.PAGE_ALBUM = 4
WorldMediaCollectionScene.PAGE_SHIP = 5

function WorldMediaCollectionScene:getUIName()
	return "WorldMediaCollectionUI"
end

function WorldMediaCollectionScene:getBGM()
	self.contextData.revertBgm = nil

	if self.contextData.revertBgm then
		return self.contextData.revertBgm
	else
		return WorldMediaCollectionScene.super.getBGM(self)
	end
end

function WorldMediaCollectionScene:getResource()
	return ResPathSupport.UniqueLuaArr(ResPathSupport.MergeLuaArr(WorldMediaCollectionScene.super.getResource(self), {
		"ui/worldmediacollectionui",
		"ui/worldmediacollectionmemoryui_atlas",
		"ui/worldmediacollectionfileui_atlas",
		"ui/worldmediacollectionfiledetailui_atlas",
		"ui/worldmediacollectionrecordui_atlas",
		"memoryicon/memory_dashijie"
	}, (function()
		local var_4_0 = {}

		for iter_4_0, iter_4_1 in ipairs(pg.memory_storyline.all) do
			if pg.memory_storyline[iter_4_1].icon ~= "" then
				table.insert(var_4_0, "memorystoryline/" .. pg.memory_storyline[iter_4_1].icon)
			end
		end

		for iter_4_2, iter_4_3 in ipairs(pg.memory_group.all) do
			if pg.memory_group[iter_4_3].icon ~= "" then
				table.insert(var_4_0, "memoryicon/" .. pg.memory_group[iter_4_3].icon)
			end
		end

		return ResPathSupport.UniqueLuaArr(var_4_0)
	end)(), (function()
		local var_5_0 = {}

		_.each(pg.world_collection_file_group.all, function(arg_6_0)
			if pg.world_collection_file_group[arg_6_0].name_abbreviate then
				table.insert(var_5_0, "CollectionFileTitle/" .. pg.world_collection_file_group[arg_6_0].name_abbreviate)
			end
		end)
		_.each(pg.world_collection_file_template.all, function(arg_7_0)
			if pg.world_collection_file_template[arg_7_0].pic then
				table.insert(var_5_0, "CollectionFileIllustration/" .. pg.world_collection_file_template[arg_7_0].pic)
			end
		end)

		return var_5_0
	end)(), (function()
		local var_8_0 = {}

		_.each(pg.memory_template.all, function(arg_9_0)
			if pg.memory_template[arg_9_0].icon then
				table.insert(var_8_0, "memoryicon/" .. pg.memory_template[arg_9_0].icon)
			end
		end)

		return ResPathSupport.UniqueLuaArr(var_8_0)
	end)(), (function()
		local var_10_0 = {}

		_.each(pg.memory_group.all, function(arg_11_0)
			if pg.memory_group[arg_11_0] and pg.memory_group[arg_11_0].type == 3 and pg.memory_group[arg_11_0].ship_group and pg.memory_group[arg_11_0].ship_group ~= 0 then
				local var_11_0 = ShipGroup.getDefaultShipConfig(pg.memory_group[arg_11_0].ship_group)

				if noEmptyStr(var_11_0 and pg.ship_skin_template[var_11_0.skin_id] and (var_11_0 and pg.ship_skin_template[var_11_0.skin_id]).painting) then
					table.insertto(var_10_0, ResPathSupport.GetPaintingListByPaintingName(var_11_0 and pg.ship_skin_template[var_11_0.skin_id] and (var_11_0 and pg.ship_skin_template[var_11_0.skin_id]).painting))
				end
			end
		end)

		return ResPathSupport.UniqueLuaArr(var_10_0)
	end)(), (function()
		local var_13_0 = {}
		local var_13_1 = {}
		local var_13_2 = {}

		for iter_13_0, iter_13_1 in ipairs(pg.lover_character_template.all) do
			if pg.lover_character_template[iter_13_1].exp_up and pg.lover_character_template[iter_13_1].exp_up > 0 and pg.lover_character_template[iter_13_1].exp_upper_limit and pg.lover_character_template[iter_13_1].exp_upper_limit > 0 then
				for iter_13_2 = 1, math.floor((math.floor(pg.lover_character_template[iter_13_1].exp_upper_limit / pg.lover_character_template[iter_13_1].exp_up) - 1) / 10) + 1 do
					table.insert(var_13_0, "lovelettermedal/default_" .. iter_13_2)
				end
			end
		end

		for iter_13_3, iter_13_4 in ipairs(getProxy(LoveLetterProxy):GetDisplayGroupList()) do
			table.insertto(var_13_1, ResPathSupport.GetPaintingShipYardIconListByPaintingName(iter_13_4:getPainting()))
			table.insert(var_13_2, string.format(ResPathSupport.ConstPath.BG.ShipCard, iter_13_4:rarity2bgPrint()))
		end

		return ResPathSupport.MergeLuaArr(var_13_1, var_13_0, var_13_2)
	end)(), (function()
		local var_12_0 = {}

		for iter_12_0, iter_12_1 in ipairs(pg.activity_medal_group.all) do
			if pg.activity_medal_group[iter_12_1] and pg.activity_medal_group[iter_12_1].entrance_picture and pg.activity_medal_group[iter_12_1].entrance_picture ~= "" then
				table.insert(var_12_0, pg.activity_medal_group[iter_12_1].entrance_picture)
			end

			for iter_12_2, iter_12_3 in ipairs(pg.activity_medal_template.get_id_list_by_group[iter_12_1] or {}) do
				table.insert(var_12_0, "activitymedal/" .. iter_12_3)
				table.insert(var_12_0, "activitymedal/" .. iter_12_3 .. "_l")
			end
		end

		return ResPathSupport.UniqueLuaArr(var_12_0)
	end)()))
end

function WorldMediaCollectionScene:init()
	self.top = self._tf:Find("Top")
	self.viewContainer = self._tf:Find("Main")
	self.subViews = {}

	self:OverlayPanel(self.top)
end

local var_0_1 = {
	import(".WorldMediaCollectionMemoryLayer"),
	import(".WorldMediaCollectionRecordLayer"),
	import(".WorldMediaCollectionFileLayer"),
	import(".WorldMediaCollectionAlbumLayer"),
	import(".NewWorldMediaCollectionMemoryLayer")
}

function WorldMediaCollectionScene:GetCurrentPage()
	return self.contextData.page and self.subViews[self.contextData.page]
end

function WorldMediaCollectionScene:didEnter()
	onButton(self, self.top:Find("blur_panel/adapt/top/option"), function()
		self:quickExitFunc()
	end, SFX_PANEL)
	onButton(self, self.top:Find("blur_panel/adapt/top/back_btn"), function()
		self:Backward()
	end, SFX_UI_CANCEL)

	self.contextData.page = nil

	self:EnterPage(self.contextData.page or WorldMediaCollectionScene.PAGE_MEMORTY)
	self:UpdateView()
end

function WorldMediaCollectionScene:EnterPage(arg_19_1)
	local var_19_0 = arg_19_1 == self.contextData.page
	local var_19_1 = self.subViews[arg_19_1]

	if not self.subViews[arg_19_1] then
		if not var_0_1[arg_19_1] then
			return
		end

		self.contextData[var_0_1[arg_19_1]] = self.contextData[var_0_1[arg_19_1]] or {}
		var_19_1 = var_0_1[arg_19_1].New(self, self.viewContainer, self.event, self.contextData)

		var_19_1:RegisterView(self)
		var_19_1:Load()
	end

	if self.contextData.page and self.subViews[self.contextData.page] and not var_19_0 then
		self.subViews[self.contextData.page].buffer:OnDeselected()
	end

	self.contextData.page = arg_19_1
	self.subViews[arg_19_1] = var_19_1

	if not var_19_0 then
		var_19_1.buffer:OnSelected()
	else
		var_19_1.buffer:OnReselected()
	end
end

function WorldMediaCollectionScene:WarpToRecord(arg_20_1, arg_20_2, arg_20_3)
	self.contextData.recordGroup = arg_20_1
	self.contextData.storyNodeID = arg_20_3

	self:EnterPage(WorldMediaCollectionScene.PAGE_FILE)
end

function WorldMediaCollectionScene:WarpToStoryNode(arg_21_1)
	self:EnterPage(WorldMediaCollectionScene.PAGE_MEMORTY)
	self.subViews[WorldMediaCollectionScene.PAGE_MEMORTY]:WrapToStoryLine(arg_21_1)
end

function WorldMediaCollectionScene:Backward()
	local var_22_0 = self.subViews[self.contextData.page] and self.subViews[self.contextData.page]:OnBackward()

	if var_22_0 then
		return var_22_0
	end

	self:closeView()
end

function WorldMediaCollectionScene:onBackPressed()
	self:Backward()
end

function WorldMediaCollectionScene.WorldRecordLock()
	return LOCK_WORLD_COLLECTION or not (function()
		return pg.SystemOpenMgr.GetInstance():isOpenSystem(getProxy(PlayerProxy):getRawData().level, "WorldMediaCollectionRecordMediator")
	end)()
end

function WorldMediaCollectionScene:UpdateView()
	if not self.subViews[self.contextData.page] then
		return
	end

	self.subViews[self.contextData.page].buffer:UpdateView()
end

function WorldMediaCollectionScene:willExit()
	local var_27_0 = self:GetCurrentPage()

	if var_27_0 then
		var_27_0.buffer:Hide()
	end

	for iter_27_0, iter_27_1 in pairs(self.subViews) do
		iter_27_1:Destroy()
	end

	table.clear(self.subViews)
	self:UnOverlayPanel(self.top, self._tf)
end

return WorldMediaCollectionScene
