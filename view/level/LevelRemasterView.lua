local LevelRemasterView = class("LevelRemasterView", import("..base.BaseSubView"))

function LevelRemasterView:getUIName()
	return "LevelRemasterView"
end

function LevelRemasterView:getResource()
	local var_2_0 = {}

	local function var_2_1(arg_3_0, arg_3_1)
		local var_3_0 = Drop.New({
			type = arg_3_0,
			id = arg_3_1
		}):getIcon()

		if noEmptyStr(var_3_0) then
			table.insert(var_2_0, var_3_0)
		end
	end

	local function var_2_2(arg_4_0, arg_4_1)
		if arg_4_0 ~= DROP_TYPE_SHIP then
			return
		end

		table.insertto(var_2_0, ResPathSupport.GetPaintingSquareIconListByPaintingName((Ship.getPaintingName(arg_4_1))))
	end

	local function var_2_3(arg_5_0)
		if arg_5_0 == nil then
			return
		end

		table.insert(var_2_0, ResPathSupport.ConstPath.LevelMap .. "/" .. arg_5_0)
	end

	local function var_2_4(arg_6_0)
		if arg_6_0 == nil then
			return
		end

		table.insert(var_2_0, "ui/" .. arg_6_0)
	end

	_.each(pg.re_map_template.all, function(arg_7_0)
		if pg.re_map_template[arg_7_0] and noEmptyStr(pg.re_map_template[arg_7_0].bg) then
			table.insert(var_2_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.ActivityBanner, pg.re_map_template[arg_7_0].bg)))
		end

		_.each(pg.re_map_template[arg_7_0].drop_gain or {}, function(arg_8_0)
			if #arg_8_0 > 0 then
				var_2_1(arg_8_0[2], arg_8_0[3])
				var_2_2(arg_8_0[2], arg_8_0[3])
			end
		end)
		_.each(pg.re_map_template[arg_7_0].drop_display or {}, function(arg_9_0)
			if arg_9_0[1] then
				var_2_1(arg_9_0[1][1], arg_9_0[1][2])
				var_2_2(arg_9_0[1][1], arg_9_0[1][2])
			end
		end)
		_.each(pg.re_map_template[arg_7_0].drop_display_sp or {}, function(arg_10_0)
			if arg_10_0[1] then
				var_2_1(arg_10_0[1][1], arg_10_0[1][2])
				var_2_2(arg_10_0[1][1], arg_10_0[1][2])
			end
		end)
		_.each(pg.re_map_template[arg_7_0].config_data, function(arg_11_0)
			if pg.chapter_template[arg_11_0] then
				if pg.expedition_data_by_map[pg.chapter_template[arg_11_0].map] then
					var_2_3(pg.expedition_data_by_map[pg.chapter_template[arg_11_0].map].bg)
					var_2_4(pg.expedition_data_by_map[pg.chapter_template[arg_11_0].map].ani_name)
				end
			end
		end)
	end)

	return ResPathSupport.UniqueLuaArr(table.insertto(var_2_0, LevelRemasterView.super.getResource(self)))
end

function LevelRemasterView:OnInit()
	self.content = self._tf:Find("list/content")
	self.item = self.content:Find("item")
	self.numsTxt = self._tf:Find("nums/text")
	self.helpBtn = self._tf:Find("help")

	setActive(self.item, false)

	self.getRemasterTF = self._tf:Find("getBtn/state_before")
	self.gotRemasterTF = self._tf:Find("getBtn/state_after")
	self.exToggle = self._tf:Find("toggles/EX")
	self.spToggle = self._tf:Find("toggles/SP")

	self:bind(LevelUIConst.FLUSH_REMASTER_INFO, function(arg_13_0)
		if not self:isShowing() then
			return
		end

		self:flushOnly()
	end)
	self:bind(LevelUIConst.FLUSH_REMASTER_TICKET, function(arg_14_0)
		if not self:isShowing() then
			return
		end

		self:updateTicketDisplay()
	end)

	local var_12_0 = getProxy(ChapterProxy)
	local var_12_1 = pg.TimeMgr.GetInstance()

	self.itemList = UIItemList.New(self.content, self.item)

	self.itemList:make(function(arg_15_0, arg_15_1, arg_15_2)
		arg_15_1 = arg_15_1 + 1

		if arg_15_0 == UIItemList.EventUpdate then
			local var_15_0 = self.temp[arg_15_1]

			setActive(arg_15_2:Find("right"), arg_15_1 % 2 > 0)

			local var_15_1 = arg_15_2:Find("bg/icon")
			local var_15_2 = arg_15_2:Find("bg/lock")
			local var_15_3 = arg_15_2:Find("bg/wait")
			local var_15_4 = arg_15_2:Find("bg/tip")

			setActive(var_15_1, false)
			setActive(var_15_2, false)
			setActive(var_15_3, false)
			setActive(var_15_4, false)

			if not var_15_0 then
				setActive(var_15_3, true)
				onButton(self, var_15_3, function()
					pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_remaster_do_not_open"))
				end, SFX_PANEL)
			elseif not var_12_1:inTime(var_15_0.time) then
				setActive(var_15_2, true)
				onButton(self, var_15_2, function()
					pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_remaster_do_not_open"))
				end, SFX_PANEL)
			else
				setActive(var_15_1, true)
				GetImageSpriteFromAtlasAsync("activitybanner/" .. var_15_0.bg, "", var_15_1)

				local var_15_5 = var_15_1:Find("info")

				setText(var_15_5:Find("dec1/index"), (arg_15_1 < 10 or nil) and ("0" .. arg_15_1 or arg_15_1))
				setText(var_15_5:Find("progress/Text"), BossRushChapterRemasterHelper.GetProgress(var_15_0.id) .. "%")
				onButton(self, var_15_1, function()
					if BossRushChapterRemasterHelper.IsRemasterByActivity(var_15_0.id) then
						self:HandleActTypeRemaster(var_15_0)

						return
					end

					local var_18_0 = (function()
						for iter_19_0, iter_19_1 in ipairs({
							PlayerPrefs.GetInt("remaster_lastmap_" .. var_15_0.id, pg.chapter_template[var_15_0.config_data[1]].map),
							pg.chapter_template[var_15_0.config_data[1]].map
						}) do
							if var_12_0:getMapById(iter_19_1):isUnlock() then
								return iter_19_1
							end
						end
					end)()

					if var_18_0 then
						self.onSelectMap(var_18_0)
						self:Hide()
					end
				end, SFX_PANEL)

				local var_15_7 = BossRushChapterRemasterHelper.ChapterAwardInfo(var_15_0.id)
				local var_15_8 = underscore.to_array(var_15_0.drop_display)

				if var_15_7 then
					table.insert(var_15_8, 1, var_15_7)
				elseif #var_15_0.drop_display_sp > 0 then
					var_15_8 = table.mergeArray(var_15_0.drop_display_sp, var_15_8)
				end

				local var_15_9 = var_15_5:Find("content")

				eachChild(var_15_9, function(arg_20_0)
					setActive(arg_20_0, false)
				end)

				for iter_15_0, iter_15_1 in ipairs(var_15_8) do
					local var_15_10 = iter_15_0 > var_15_9.childCount and cloneTplTo(var_15_9:GetChild(0), var_15_9) or var_15_9:GetChild(iter_15_0 - 1)

					setActive(var_15_10, true)

					if var_15_7 and iter_15_0 == 1 then
						local var_15_11 = var_15_7[1]
						local var_15_12, var_15_13, var_15_14, var_15_15, var_15_16 = unpack(var_15_7[2])
						local var_15_17 = var_15_7[3]
						local var_15_18 = var_12_0:getRemasterInfo(var_15_7[3], var_15_12, var_15_7[1])

						setActive(var_15_4, var_15_15 <= var_15_18.count)
						setActive(var_15_10:Find("mark"), var_15_15 > var_15_18.count)
						setActive(var_15_10:Find("Slider"), var_15_15 > var_15_18.count)
						setActive(var_15_10:Find("achieve"), var_15_15 <= var_15_18.count)
						setSlider(var_15_10:Find("Slider"), 0, var_15_15, var_15_18.count)

						local var_15_19 = {
							type = var_15_13,
							id = var_15_14
						}

						updateDrop(var_15_10:Find("IconTpl"), var_15_19)
						onButton(self, var_15_10:Find("IconTpl"), function()
							pg.MsgboxMgr.GetInstance():ShowMsgBox({
								hideYes = true,
								hideNo = true,
								type = MSGBOX_TYPE_SINGLE_ITEM,
								drop = var_15_19,
								remaster = {
									word = i18n("level_remaster_tip4", (BossRushChapterRemasterHelper.GetAwardName(var_15_17, var_15_12))),
									number = var_15_18.count .. "/" .. var_15_15,
									btn_text = i18n(var_15_18.count < var_15_15 and "level_remaster_tip2" or "level_remaster_tip3"),
									btn_call = function()
										if var_15_18.count < var_15_15 then
											if var_15_17 and var_15_17 > 0 then
												self:emit(LevelMediator2.ON_BOSSRUSH_REMASTER_ACTIVITY, var_15_17)
												self:Hide()

												return
											end

											local var_22_0 = pg.chapter_template[var_15_12].map
											local var_22_1, var_22_2 = var_12_0:getMapById(pg.chapter_template[var_15_12].map):isUnlock()

											if not var_22_1 then
												pg.TipsMgr.GetInstance():ShowTips(var_22_2)
											else
												self.onSelectMap(var_22_0)
												self:Hide()
											end
										else
											self:emit(LevelMediator2.ON_CHAPTER_REMASTER_AWARD, var_15_12, var_15_11, var_15_17)
										end
									end
								}
							})
						end, SFX_PANEL)
					else
						local var_15_20 = {
							type = iter_15_1[1][1],
							id = iter_15_1[1][2]
						}

						updateDrop(var_15_10:Find("IconTpl"), var_15_20)
						onButton(self, var_15_10:Find("IconTpl"), function()
							pg.MsgboxMgr.GetInstance():ShowMsgBox({
								hideYes = true,
								hideNo = true,
								type = MSGBOX_TYPE_SINGLE_ITEM,
								drop = var_15_20,
								remaster = {
									word = i18n("level_remaster_tip1") .. iter_15_1[2],
									btn_text = i18n("text_confirm")
								}
							})
						end, SFX_PANEL)
						setActive(var_15_10:Find("mark"), false)
						setActive(var_15_10:Find("Slider"), false)
						setActive(var_15_10:Find("achieve"), false)
					end
				end
			end
		end
	end)
	onButton(self, self.getRemasterTF, function()
		if var_12_0.remasterTickets + pg.gameset.reactivity_ticket_daily.key_value > pg.gameset.reactivity_ticket_max.key_value then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("tack_tickets_max_warning", math.max(pg.gameset.reactivity_ticket_max.key_value - var_12_0.remasterTickets, 0)),
				onYes = function()
					self:emit(LevelMediator2.ON_CLICK_RECEIVE_REMASTER_TICKETS_BTN)
				end
			})

			return
		end

		self:emit(LevelMediator2.ON_CLICK_RECEIVE_REMASTER_TICKETS_BTN)
	end, SFX_PANEL)
end

function LevelRemasterView:HandleActTypeRemaster(arg_26_1)
	local var_26_0 = arg_26_1.activity_id
	local var_26_1 = getProxy(ActivityPermanentProxy)
	local var_26_2 = var_26_1:GetActivityTypeById(arg_26_1.activity_id)
	local var_26_3 = var_26_2 and var_26_1:getDoingActivityId(var_26_2)

	local function var_26_4()
		self:emit(LevelMediator2.ON_BOSSRUSH_REMASTER_ACTIVITY, var_26_0)
	end

	if var_26_3 and var_26_3 ~= arg_26_1.activity_id then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("bossrush_act_remaster_close_prev_one_tip"),
			onYes = var_26_4
		})

		return
	end

	var_26_4()
end

function LevelRemasterView:OnDestroy()
	self.onItem = nil

	if self:isShowing() then
		self:Hide()
	end
end

function LevelRemasterView:Show()
	LevelRemasterView.super.Show(self)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function LevelRemasterView:Hide()
	LevelRemasterView.super.Hide(self)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
end

function LevelRemasterView:set(arg_31_1, arg_31_2)
	self.templates = {}

	for iter_31_0, iter_31_1 in ipairs(pg.re_map_template.all) do
		table.insert(self.templates, pg.re_map_template[iter_31_1])
	end

	self.onSelectMap = arg_31_1

	self:flush(arg_31_2)
end

function LevelRemasterView:flush(arg_32_1)
	onButton(self, self._tf:Find("bg"), function()
		self:Hide()
	end, SFX_CANCEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("levelScene_remaster_help_tip")
		})
	end, SFX_PANEL)
	self:updateTicketDisplay()

	local var_32_0 = {
		self.exToggle,
		self.spToggle
	}
	local var_32_1 = getProxy(ChapterProxy)

	for iter_32_0, iter_32_1 in ipairs(var_32_0) do
		onToggle(self, iter_32_1, function(arg_35_0)
			if arg_35_0 then
				self.temp = underscore.filter(self.templates, function(arg_36_0)
					return BossRushChapterRemasterHelper.GetExOrSp4Filter(arg_36_0.activity_type) == iter_32_0
				end)

				local var_35_0 = {}

				for iter_35_0, iter_35_1 in ipairs(self.temp) do
					var_35_0[iter_35_1.id] = BossRushChapterRemasterHelper.ExistCanGetAward(iter_35_1.id) and 0 or 1
				end

				table.sort(self.temp, CompareFuncs({
					function(arg_37_0)
						return var_35_0[arg_37_0.id] or 1
					end,
					function(arg_38_0)
						return arg_38_0.order
					end
				}))
				self.itemList:align(math.max(math.ceil(#self.temp / 2) * 2, 4))
			end
		end, SFX_PANEL)
	end

	triggerToggle(var_32_0[arg_32_1 and 2 or 1], true)
end

function LevelRemasterView:MatchType(arg_39_1, arg_39_2)
	return arg_39_1 == arg_39_2
end

function LevelRemasterView:flushOnly()
	self.itemList:align(math.max(math.ceil(#self.temp / 2) * 2, 4))
end

function LevelRemasterView:updateTicketDisplay()
	local var_41_0 = getProxy(ChapterProxy)
	local var_41_1 = var_41_0.remasterDailyCount > 0

	SetActive(self.getRemasterTF, not (var_41_0.remasterDailyCount > 0))
	SetActive(self.gotRemasterTF, var_41_1)
	setText(self.numsTxt, var_41_0.remasterTickets .. "/" .. pg.gameset.reactivity_ticket_max.key_value)
end

return LevelRemasterView
