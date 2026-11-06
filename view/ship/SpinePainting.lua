local SpinePainting = class("SpinePainting")
local PoolUtil = require("Mgr/Pool/PoolUtil")

function SpinePainting:GenerateData()
	local var_1_0 = {
		SetData = function(self, arg_2_1)
			self.ship = arg_2_1.ship
			self.parent = arg_2_1.parent
			self.effectParent = arg_2_1.effectParent

			local var_2_0 = self:GetShipSkinConfig()
			local var_2_2 = arg_2_1.offset and #arg_2_1.offset >= 4 and arg_2_1.offset[4] or var_2_0.spine_offset and #var_2_0.spine_offset >= 4 and var_2_0.spine_offset[4] or 1

			self.pos = arg_2_1.position + (arg_2_1.offset and #arg_2_1.offset >= 3 and BuildVector3({
				arg_2_1.offset[1],
				arg_2_1.offset[2],
				arg_2_1.offset[3]
			}) or var_2_0.spine_offset and #var_2_0.spine_offset >= 3 and BuildVector3({
				var_2_0.spine_offset[1],
				var_2_0.spine_offset[2],
				var_2_0.spine_offset[3]
			}) or BuildVector3({
				0,
				0,
				0
			}))
			self.scale = Vector3(var_2_2, var_2_2, var_2_2)

			if #var_2_0.special_effects > 0 then
				self.bgEffectName = var_2_0.special_effects[1]
				self.bgEffectPos = arg_2_1.position + BuildVector3(var_2_0.special_effects[2])
				self.bgEffectScale = Vector3(var_2_0.special_effects[3][1], var_2_0.special_effects[3][1], var_2_0.special_effects[3][1])
			end
		end,
		GetShipName = function(self)
			return self.ship:getPainting()
		end,
		GetShipSkinConfig = function(self)
			return self.ship:GetSkinConfig()
		end,
		GetShipId = function(self)
			return self.ship.id
		end,
		isEmpty = function(self)
			return self.ship == nil
		end,
		Clear = function(arg_7_0)
			arg_7_0.ship = nil
			arg_7_0.parent = nil
			arg_7_0.scale = nil
			arg_7_0.pos = nil
			arg_7_0.bgEffectName = nil
			arg_7_0.bgEffectPos = nil
			arg_7_0.bgEffectScale = nil
			arg_7_0.effectParent = nil
		end
	}

	var_1_0:SetData(self)

	return var_1_0
end

function SpinePainting:Ctor(arg_8_1, arg_8_2)
	self._spinePaintingData = arg_8_1
	self._loadSpineDic = {}
	self._loadUIDic = {}
	self._initCallback = {}
	self.loadSheets = {}
	self._visible = true

	parallelAsync({
		function(arg_9_0)
			local var_9_0 = self._spinePaintingData:GetShipName()

			PoolMgr.GetInstance():GetSpinePainting(var_9_0, true, function(arg_10_0)
				self._loadSpineDic[var_9_0] = arg_10_0

				self:init(arg_10_0)
				self:UpdateGraphic()
				self:applyVisible(false)
				arg_9_0()
			end)
		end,
		function(arg_11_0)
			local var_11_0 = self._spinePaintingData.bgEffectName

			if self._spinePaintingData.bgEffectName ~= nil then
				PoolMgr.GetInstance():GetUI(self._spinePaintingData.bgEffectName, true, function(arg_12_0)
					self._loadUIDic[var_11_0] = arg_12_0

					self:initBgEffect(arg_12_0)
					arg_11_0()
				end)
			else
				arg_11_0()
			end
		end
	}, function()
		setActive(self._spinePaintingData.parent, true)
		setActive(self._spinePaintingData.effectParent, true)

		self._initFlag = true

		self:updateLink()

		for iter_13_0, iter_13_1 in ipairs(self._initCallback) do
			iter_13_1()
		end

		self._initCallback = {}
		self._pendingVisible = nil
		self._visibleReady = true

		self:applyVisible(self._pendingVisible ~= false)

		if arg_8_2 then
			arg_8_2(self)
		end
	end)
end

function SpinePainting:init(arg_14_1)
	self._go = arg_14_1
	self._tf = tf(arg_14_1)

	HotfixHelper.SetLayerRecursively(self._go, LayerMask.NameToLayer("UI"))
	self._tf:SetParent(self._spinePaintingData.parent, true)

	self._tf.localScale = self._spinePaintingData.scale
	self._tf.localPosition = self._spinePaintingData.pos
	self.spineAnimList = {}

	for iter_14_0, iter_14_1 in ipairs((self._tf:GetComponent(typeof(ItemList)).prefabItem:ToTable())) do
		self.spineAnimList[#self.spineAnimList + 1] = GetOrAddComponent(iter_14_1, "SpineAnimUI")
	end

	local var_14_0 = #self.spineAnimList

	assert(#self.spineAnimList > 0, "动态立绘至少要保证有一个spine动画，请检查" .. self._spinePaintingData:GetShipName())

	self.mainSpineAnim = var_14_0 == 1 and self.spineAnimList[1] or self.spineAnimList[#self.spineAnimList]
	self._skeletonGraphic = self.mainSpineAnim:GetComponent("SkeletonGraphic")

	function self.updateLocal()
		self:onUpdateLocal()
	end

	self._skeletonGraphic.UpdateLocal = self._skeletonGraphic.UpdateLocal + self.updateLocal
	self._baseMaterial = self._skeletonGraphic.material
	self._idleName = self:getNormalIdleName()
	self.shipDragData = SpinePaintingConst.ship_drag_datas[self._spinePaintingData:GetShipName()]
	self.dragShipFlag = false
	self.lockLayer = false

	if self.shipDragData then
		self.dragShipFlag = self.shipDragData.drag_data and self.shipDragData.drag_data.type
		self.lockLayer = self.shipDragData.drag_data.lock_layer
		self.replaceWord = self.shipDragData.replace_word
		self.dragDataConfigClient = self.shipDragData.drag_data.config_client
	end

	self.multipleFaceFlag = false

	if self.shipDragData and self.shipDragData.multiple_face and self.shipDragData.multiple_face ~= "" then
		self.multipleFaceFlag = table.contains(self.shipDragData.multiple_face.name, self.mainSpineAnim.name)
		self.multipleFaceData = self.shipDragData.multiple_face.data
	end

	self.shipEffectActionAble = SpinePaintingConst.ship_effect_action_able[self._spinePaintingData:GetShipName()]
	self._effectsTf = findTF(self._tf, "effects")
	self._effectShowFlag = true
	self._dragPassFlag = true
	self._lightTf = findTF(self._tf, "light")

	if self._lightTf then
		self._lightAnimator = self._lightTf:GetComponent(typeof(Animator))
		self._lightAnimationName = self._lightAnimator.runtimeAnimatorController.animationClips[0].name

		self._lightAnimator:Play(self._lightAnimationName, -1, SpinePaintingConst.painting_lit_value)
	end

	self:playPaintingInitIdle()
	self:playPaintingInitSkin()

	self.slotDic = {}
	self.stepSlotAlpha = {}
	self._slotAlphaTimer = Timer.New(function()
		self:updateSlotAlpha()
		self:updateLight()
	end, 0.016666666666666666, -1)

	self._slotAlphaTimer:Start()
	self:UpdateGraphic()
end

function SpinePainting:initBgEffect(arg_17_1)
	self._bgEffectGo = arg_17_1
	self._bgEffectTf = tf(arg_17_1)

	HotfixHelper.SetLayerRecursively(self._bgEffectGo, LayerMask.NameToLayer("UI"))
	self._bgEffectTf:SetParent(self._spinePaintingData.effectParent, true)

	self._bgEffectTf.localScale = self._spinePaintingData.bgEffectScale
	self._bgEffectTf.localPosition = self._spinePaintingData.bgEffectPos
end

function SpinePainting:getInitFlag()
	return self._initFlag
end

function SpinePainting:getNormalIdleName()
	if HXSet.isHx() and self.shipDragData and self.shipDragData.hx_idle then
		return self.shipDragData.hx_idle
	end

	return "normal"
end

function SpinePainting:updateLink()
	self.slotOverride = {}

	local var_20_0 = ChangeSkinLink.CHANGE_SKIN_LINK_DATA[self._spinePaintingData.ship:getSkinId()]

	if var_20_0 then
		if var_20_0.link_type == ChangeSkinLink.L2D_TYPE then
			local var_20_1 = PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1) == 1 and ChangeSkinLink.GetSaveL2dData(self._spinePaintingData.ship.id, var_20_0.link_id) or ChangeSkinLink.L2D_PARAMETER_DIC[self._spinePaintingData.ship.id]

			var_20_1 = var_20_1 or {}

			for iter_20_0, iter_20_1 in ipairs(var_20_0.relations) do
				if iter_20_1.type == ChangeSkinLink.change_parameter_link_slot then
					local var_20_2 = true

					for iter_20_2, iter_20_3 in ipairs(iter_20_1.link_parameter) do
						if var_20_1[iter_20_3.name] then
							if (var_20_1[iter_20_3.name] or 0) ~= iter_20_3.num then
								var_20_2 = false
							end
						end
					end

					if var_20_2 then
						for iter_20_4, iter_20_5 in ipairs(iter_20_1.slot_list) do
							table.insert(self.slotOverride, iter_20_5)
						end
					end
				elseif iter_20_1.type == ChangeSkinLink.change_parameter_link_skin then
					local var_20_4 = true

					for iter_20_6, iter_20_7 in ipairs(iter_20_1.link_parameter) do
						if var_20_1[iter_20_7.name] then
							if (var_20_1[iter_20_7.name] or 0) ~= iter_20_7.num then
								var_20_4 = false
							end
						end
					end

					if var_20_4 then
						self:SetSkeletonSkin(iter_20_1.skeleton_skin)
					end
				end
			end
		end
	end
end

function SpinePainting:setL2dSlot(arg_21_1, arg_21_2)
	self._skeletonGraphic.Skeleton:SetAttachment(arg_21_1, arg_21_2)
end

function SpinePainting:onUpdateLocal()
	if self.slotOverride then
		for iter_22_0, iter_22_1 in ipairs(self.slotOverride) do
			self:setL2dSlot(iter_22_1[1], iter_22_1[2])
		end
	end
end

function SpinePainting:UpdateGraphic()
	if self._isDisposed then
		return
	end

	print("spine update graphic Time")
	self._skeletonGraphic:UpdateMesh()
	Canvas.ForceUpdateCanvases()
end

function SpinePainting:SetVisible(arg_24_1)
	if self._isDisposed then
		return
	end

	if not self._visibleReady then
		self._pendingVisible = arg_24_1

		return
	end

	self:applyVisible(arg_24_1)
end

function SpinePainting:applyVisible(arg_25_1)
	if self._isDisposed then
		return
	end

	self._tf.localPosition = arg_25_1 and self._spinePaintingData.pos or Vector2(100000, 0)

	if not arg_25_1 and self.dragDataConfigClient then
		local var_25_0 = self:getIdleName()

		for iter_25_0, iter_25_1 in ipairs(self.dragDataConfigClient) do
			if iter_25_1.idle == var_25_0 and iter_25_1.lit_start and iter_25_1.lit_start >= 0 then
				SpinePaintingConst.painting_lit_value = iter_25_1.lit_start

				if PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1) == 1 then
					SpinePaintingDrag.SetPaintingLite(self._spinePaintingData:GetShipName(), self._spinePaintingData:GetShipId(), SpinePaintingConst.painting_lit_value)
				else
					SpinePaintingDrag.SetPaintingLite(self._spinePaintingData:GetShipName(), self._spinePaintingData:GetShipId(), 0)
				end
			end
		end
	end

	SpinePaintingConst.spine_painting_action = false

	if arg_25_1 then
		if self._slotAlphaTimer and not self._slotAlphaTimer.running then
			self._slotAlphaTimer:Start()
		end
	elseif self._slotAlphaTimer and self._slotAlphaTimer.running then
		self._slotAlphaTimer:Stop()
	end

	self._visible = arg_25_1

	if self._isDisposed then
		return
	end

	if self._lightTf then
		setActive(self._lightTf, self._visible)
	end

	if self._spinePaintingData.effectParent then
		setActive(self._spinePaintingData.effectParent, self._visible)
		setActiveViaLayer(self._spinePaintingData.effectParent, self._visible)
	end

	if not IsNil(self._tf) then
		pg.ViewUtils.SetLayer(self._tf, (self._visible or nil) and (Layer.UI or Layer.UIHidden))
	end

	self._lightValue = nil
	self._effectShowFlag = true
	self._dragPassFlag = true

	if self._skeletonGraphic then
		self._skeletonGraphic.timeScale = self._visible and 1 or 0
	end

	if not self._visible then
		self.mainSpineAnim:SetActionCallBack(nil)
		self:changeInAction(false)

		self.clickActionList = {}

		if LeanTween.isTweening(go(self._tf)) then
			LeanTween.cancel(go(self._tf))
		end

		if self._baseShader then
			if self._skeletonGraphic then
				self._skeletonGraphic.material.shader = self._baseShader
			end

			self._baseShader = nil
		end

		self._displayWord = false
	else
		self._skeletonGraphic:Update(Time.deltaTime)
	end

	self:playPaintingInitIdle()
	self:playPaintingInitSkin()
	self:updateLink()

	if not arg_25_1 then
		self:unloadCueSheet()
		pg.CriMgr.GetInstance():DisposePaintingBgm()
	end
end

function SpinePainting:playPaintingInitIdle()
	local var_26_0 = SpinePaintingDrag.GetPaintingInitIdle(self.mainSpineAnim.name, self._spinePaintingData.ship.id)
	local var_26_1 = self:getNormalIdleName()

	if var_26_0 then
		local var_26_2 = PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1)

		if var_26_2 == 1 and self._idleName ~= var_26_0 then
			var_26_1 = var_26_0
		elseif var_26_2 ~= 1 and self._idleName ~= self:getNormalIdleName() then
			var_26_1 = self:getNormalIdleName()
		end
	else
		var_26_1 = self:getNormalIdleName()
	end

	if var_26_1 then
		self:setIdleName(var_26_1)
		self:SetActionWithFinishCallback(self._idleName, 0, nil, true, nil)
		self:changeInAction(false)
	end
end

function SpinePainting:changeInAction(arg_27_1)
	self.inAction = arg_27_1
	SpinePaintingConst.spine_painting_action = arg_27_1

	if SpinePaintingConst.painting_lit_action_callback then
		SpinePaintingConst.painting_lit_action_callback(arg_27_1)
	end
end

function SpinePainting:playPaintingInitSkin()
	local var_28_0 = SpinePaintingDrag.GetPaintingInitSkin(self.mainSpineAnim.name, self._spinePaintingData.ship.id)
	local var_28_1 = self:GetDefaultSkeletonSkin()

	if var_28_0 then
		if PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1) == 1 and self:GetDefaultSkeletonSkin() ~= var_28_0 then
			var_28_1 = var_28_0
		elseif PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1) ~= 1 and self._skeletonSkin ~= self:GetDefaultSkeletonSkin() then
			var_28_1 = self:GetDefaultSkeletonSkin()
		end
	else
		var_28_1 = self:GetDefaultSkeletonSkin()
	end

	if var_28_1 then
		if self._skeletonGraphic and self._skeletonGraphic.SkeletonData then
			if self._skeletonGraphic.SkeletonData:FindSkin(var_28_1) ~= nil then
				self:SetSkeletonSkin(var_28_1)
			elseif self._skeletonGraphic.SkeletonData:FindSkin("default") ~= nil then
				self:SetSkeletonSkin("default")
			end
		end
	else
		self:SetDefaultSkeletonSkin()
	end
end

function SpinePainting:getIdleName()
	return self._idleName
end

function SpinePainting:setIdleName(arg_30_1)
	self._idleName = arg_30_1

	self:updateHitArea()
end

function SpinePainting:getReplaceWord()
	if self.replaceWord and table.contains(self.replaceWord, self._idleName) then
		return true
	end

	return false
end

function SpinePainting:updateHitArea()
	if self.dragShipFlag then
		if self.shipDragData.drag_data.type == SpinePaintingConst.drag_type_normal then
			for iter_32_0 = 1, #self.shipDragData.drag_data.config_client do
				local var_32_0 = self.shipDragData.drag_data.config_client[iter_32_0]

				if self.shipDragData.drag_data.config_client[iter_32_0].hit and not self.shipDragData.drag_data.config_client[iter_32_0].active then
					local var_32_1 = findTF(self._tf, "hitArea/" .. self.shipDragData.drag_data.config_client[iter_32_0].hit)

					if var_32_1 then
						local var_32_2 = true
						local var_32_3 = true

						if var_32_0.idle and type(var_32_0.idle) == "string" then
							var_32_2 = var_32_0.idle == self._idleName
						elseif var_32_0.idle and type(var_32_0.idle) == "table" then
							var_32_2 = table.contains(var_32_0.idle, self._idleName)
						end

						if var_32_0.skin and type(var_32_0.skin) == "string" then
							var_32_3 = var_32_0.skin == self._skeletonSkin
						elseif var_32_0.skin and type(var_32_0.skin) == "table" then
							var_32_3 = table.contains(var_32_0.skin, self._skeletonSkin)
						end

						setActive(var_32_1, var_32_2 and var_32_3)
					else
						print("hit area " .. self.shipDragData.drag_data.config_client[iter_32_0].hit .. "is not exist")
					end
				end
			end
		end
	end
end

function SpinePainting:checkListAction()
	if #self.clickActionList > 0 then
		self:SetActionWithFinishCallback(table.remove(self.clickActionList, 1), 0, function()
			self:checkListAction()
		end, true)
	else
		self:SetAction(self:getNormalIdleName(), 0, true)
		self:changeInAction(false)
	end
end

function SpinePainting:displayWord(arg_35_1)
	self._displayWord = arg_35_1
end

function SpinePainting:readyDragAction(arg_36_1, arg_36_2)
	if self.inAction or self._displayWord then
		return false
	end

	if self.dragShipFlag then
		return self:startDragAction(arg_36_1, arg_36_2)
	end

	return false
end

function SpinePainting:SetSkeletonSkin(arg_37_1)
	self._skeletonSkin = arg_37_1

	self:SetSkin(arg_37_1)
	self:updateSkeletonGraphicTime()
	self:updateHitArea()
end

function SpinePainting:SetDefaultSkeletonSkin()
	self:SetSkeletonSkin(self:GetDefaultSkeletonSkin())
end

function SpinePainting:GetDefaultSkeletonSkin()
	local var_39_0 = self._spinePaintingData:GetShipSkinConfig().skeleton_default_skin

	if not var_39_0 or var_39_0 == "" then
		var_39_0 = self._skeletonGraphic.SkeletonData:FindSkin("1") and "1" or "default"
	end

	return var_39_0
end

function SpinePainting:startDragAction(arg_40_1, arg_40_2)
	if self.shipDragData.drag_data.type == SpinePaintingConst.drag_type_normal then
		return self:changePaintingNormal(self.shipDragData.drag_data, arg_40_1, arg_40_2)
	elseif self.shipDragData.drag_data.type == SpinePaintingConst.drag_type_list then
		self.clickActionList = Clone(self.shipDragData.drag_data.config_client)

		return self:checkListAction()
	end

	return false
end

function SpinePainting:GetDragDataConfig(arg_41_1)
	if self.shipDragData then
		return self.shipDragData[arg_41_1]
	end

	return nil
end

function SpinePainting:setEventTriggerCallback(arg_42_1)
	self._eventTriggerCall = arg_42_1
end

function SpinePainting:changePaintingNormal(arg_43_1, arg_43_2, arg_43_3)
	for iter_43_0, iter_43_1 in ipairs(arg_43_1.config_client) do
		if self:matchDragFlag(arg_43_2, iter_43_1, arg_43_3) then
			return self:doDragAction(arg_43_1.type, arg_43_1, iter_43_1, arg_43_3)
		end
	end

	return false
end

function SpinePainting:doDragAction(arg_44_1, arg_44_2, arg_44_3, arg_44_4)
	local var_44_0 = arg_44_3.fold
	local var_44_1

	if arg_44_3.fold_chat then
		var_44_1 = arg_44_3.fold_chat or nil
	end

	local var_44_2 = arg_44_3.effect_hide
	local var_44_3 = arg_44_3.action_cv
	local var_44_4 = arg_44_3.finish_cv
	local var_44_5

	if arg_44_3.alpha_data then
		var_44_5 = arg_44_3.alpha_data or nil

		local var_44_6

		if arg_44_3.skin_change then
			var_44_6 = arg_44_3.skin_change or nil

			local var_44_7

			if arg_44_3.clear_track then
				var_44_7 = arg_44_3.clear_track or nil

				local var_44_8

				if arg_44_3.idle then
					var_44_8 = arg_44_3.idle or nil
				end
			end
		end
	end

	local var_44_9 = arg_44_3.change_idle
	local var_44_10 = arg_44_3.action
	local var_44_11 = arg_44_3.event
	local var_44_12 = var_44_6
	local var_44_13
	local var_44_14
	local var_44_15

	if type(arg_44_3.change_idle) == "table" and type(var_44_10) == "table" then
		local var_44_16 = math.random(1, #var_44_10)

		var_44_13 = var_44_10[var_44_16]
		var_44_15 = var_44_9[var_44_16]
	elseif type(var_44_8) == "table" and type(var_44_10) == "table" then
		local var_44_17 = table.indexof(var_44_8, self:getIdleName())

		var_44_13 = var_44_10[var_44_17]

		if type(var_44_9) == "table" then
			var_44_15 = var_44_9[var_44_17]
		end
	end

	if not var_44_13 then
		if type(var_44_10) == "string" then
			var_44_13 = var_44_10
		elseif type(var_44_10) == "table" then
			var_44_13 = var_44_10[math.random(1, #var_44_10)]
		end
	end

	if not var_44_15 then
		if type(var_44_9) == "string" then
			var_44_15 = var_44_9
		elseif type(var_44_9) == "table" then
			var_44_15 = var_44_9[math.random(1, #var_44_9)]
		end
	end

	if not var_44_14 then
		if type(var_44_11) == "string" then
			var_44_14 = var_44_11
		elseif type(var_44_11) == "table" then
			var_44_14 = var_44_11[math.random(1, #var_44_11)]
		end
	end

	if arg_44_1 == SpinePaintingConst.drag_type_normal then
		if var_44_5 and #var_44_5 > 0 then
			self:SetAlphaData(var_44_5)
		end

		if arg_44_3.material then
			local var_44_18 = arg_44_3.material or nil

			if arg_44_3.material_time then
				local var_44_19 = arg_44_3.material_time or nil

				if var_44_18 then
					if LeanTween.isTweening(go(self._tf)) then
						return false
					end

					self:getSpineMaterial(var_44_18, function(arg_45_0)
						self._skeletonGraphic.material = arg_45_0

						if var_44_19 then
							LeanTween.delayedCall(go(self._tf), var_44_19, System.Action(function()
								self._skeletonGraphic.material = self._baseMaterial

								self:changePaintingIdle(var_44_15)
							end))
						end
					end)
				end

				if var_44_7 and #var_44_7 > 0 then
					for iter_44_0, iter_44_1 in ipairs(var_44_7) do
						self:SetEmptyAction(iter_44_1)
					end
				end

				if var_44_13 and var_44_13 ~= "" and self:checkActionPlayAble(var_44_13, false, 0) then
					print("播放动作 .." .. var_44_13 .. "下一个待机动作 .. " .. var_44_15)

					if arg_44_3.fold then
						pg.m02:sendNotification(NewMainMediator.HIDE_PANEL, {
							flag = true,
							content = {
								chat = var_44_1
							}
						})
					end

					self:setEffectVisible(var_44_2, false)
					self:SetActionWithFinishCallback(var_44_13, 0, function()
						if var_44_12 and var_44_12 ~= "" then
							self:changeSkeletonSkin(var_44_12)
						end

						if var_44_0 then
							pg.m02:sendNotification(NewMainMediator.HIDE_PANEL, {
								flag = false,
								content = {
									chat = var_44_1
								}
							})

							local var_47_0

							if var_44_15 then
								var_47_0 = var_44_15 or self:getIdleName()
							end
						end

						self:changePaintingIdle(var_47_0)
						self:setEffectVisible(var_44_2, true)

						if var_44_4 and var_44_4 ~= "" then
							self:PlayCv(var_44_4)
						end
					end, false, function()
						if var_44_3 and var_44_3 ~= "" then
							self:PlayCv(var_44_3)
						end

						if var_44_14 and type(var_44_14) == "string" and self._eventTriggerCall then
							self._eventTriggerCall(var_44_14)
						end
					end)
				end

				if not var_44_13 or var_44_13 == "" then
					if var_44_12 and var_44_12 ~= "" then
						self:changeSkeletonSkin(var_44_12)
					end

					if var_44_15 and var_44_15 ~= "" then
						self:changePaintingIdle(var_44_15)
					end

					if var_44_14 and type(var_44_14) == "string" and self._eventTriggerCall then
						self._eventTriggerCall(var_44_14)
					end

					return false
				end
			end
		end
	end

	return true
end

function SpinePainting:SetAlphaData(arg_49_1)
	for iter_49_0, iter_49_1 in ipairs(arg_49_1) do
		local var_49_0 = self:getSlotAlpha(iter_49_1[1])

		if not self:getStepSlotAlpha(iter_49_1[1]) and var_49_0 then
			local var_49_1

			for iter_49_2, iter_49_3 in ipairs(iter_49_1[2]) do
				if ((math.abs(var_49_0 - iter_49_3) <= 0.1 or nil) and iter_49_2 + 1) == iter_49_2 then
					var_49_1 = iter_49_3
				end
			end

			var_49_1 = var_49_1 or iter_49_1[2][1]

			if var_49_1 then
				self:setStepSlotAlpha(iter_49_1[1], var_49_1, iter_49_1[3])
			end
		end
	end
end

function SpinePainting:PlayCv(arg_50_1)
	local var_50_0 = self._spinePaintingData.ship:getSkinId()
	local var_50_1 = pg.CriMgr.GetCVBankName(ShipWordHelper.RawGetCVKey(var_50_0))

	print("try playing cv" .. var_50_1 .. ":" .. arg_50_1 .. "_" .. pg.ship_skin_template[var_50_0].group_index)
	pg.CriMgr.GetInstance():playCueSheetVoice(var_50_1, arg_50_1 .. "_" .. pg.ship_skin_template[var_50_0].group_index, true, function(arg_51_0)
		if arg_51_0 then
			print("播放的语音长度为 = " .. arg_51_0:GetLength())
		end
	end)
end

function SpinePainting:changeSkeletonSkin(arg_52_1)
	if self._skeletonSkin == arg_52_1 then
		self:SetDefaultSkeletonSkin()
	else
		self:SetSkeletonSkin(arg_52_1)
	end

	SpinePaintingDrag.SetPaintingInitSkin(self.mainSpineAnim.name, self._spinePaintingData.ship.id, self._skeletonSkin)
end

function SpinePainting:setEffectVisible(arg_53_1, arg_53_2)
	if not arg_53_1 or #arg_53_1 == 0 then
		return
	end

	for iter_53_0 = 1, #arg_53_1 do
		local var_53_0 = findTF(self._tf, arg_53_1[iter_53_0])

		if var_53_0 then
			setActive(var_53_0, arg_53_2)
		end
	end
end

function SpinePainting:matchDragFlag(arg_54_1, arg_54_2, arg_54_3)
	if arg_54_2.hit and arg_54_2.hit ~= arg_54_1 then
		return false
	end

	local var_54_0 = arg_54_2.skin

	if arg_54_2.skin and var_54_0 ~= "" and self._skeletonSkin ~= var_54_0 then
		return false
	end

	local var_54_1 = arg_54_2.idle

	if arg_54_2.idle and type(var_54_1) == "string" and self:getIdleName() ~= var_54_1 then
		return false
	elseif var_54_1 and type(var_54_1) == "table" and not table.contains(var_54_1, self:getIdleName()) then
		return false
	end

	local var_54_2 = arg_54_2.favor

	if arg_54_2.favor and var_54_2 >= 0 then
		local var_54_3 = self._spinePaintingData.ship:getCVIntimacy()

		if var_54_3 and var_54_3 < var_54_2 then
			return false
		end
	end

	if arg_54_2.click and arg_54_2.click == tobool(arg_54_3) then
		return false
	end

	return true
end

function SpinePainting:OnDragMove(arg_55_1, arg_55_2)
	return
end

function SpinePainting:getSpineMaterial(arg_56_1, arg_56_2)
	self._materialDic = self._materialDic or {}

	if self._materialDic[arg_56_1] then
		arg_56_2(self._materialDic[arg_56_1])
	else
		self._materialDic[arg_56_1] = LoadAny("spinematerials", arg_56_1, typeof(Material))

		arg_56_2(self._materialDic[arg_56_1])
	end
end

function SpinePainting:changePaintingIdle(arg_57_1)
	self:setIdleName(arg_57_1)
	self:SetAction(arg_57_1, 0, true)
	SpinePaintingDrag.SetPaintingInitIdle(self.mainSpineAnim.name, self._spinePaintingData.ship.id, arg_57_1)
	self:changeInAction(false)
end

function SpinePainting:SetShopHx(arg_58_1)
	if arg_58_1 and HXSet.isHx() then
		if self:getAnimationExist("shop_hx", self._skeletonGraphic) then
			self:setIdleName("shop_hx")
			self:SetAction(self._idleName, 0, true)

			self._tf.localPosition = Vector2(100000, 0)

			self:updateSkeletonGraphicTime()
			onDelayTick(function()
				self._tf.localPosition = self._spinePaintingData.pos
			end, 0.05)
		end
	else
		self:setIdleName(self:getNormalIdleName())
		self:SetAction(self._idleName, 0, true)
	end
end

function SpinePainting:SetAction(arg_60_1, arg_60_2, arg_60_3)
	if not self:checkActionPlayAble(arg_60_1, arg_60_3, arg_60_2) then
		return false
	end

	if arg_60_2 and arg_60_2 == 0 then
		self.lastPlayAction = arg_60_1
	end

	if arg_60_2 == 0 and arg_60_1 ~= self:getIdleName() then
		self:changeInAction(true)
	end

	if self.multipleFaceFlag and not self.inAction then
		arg_60_1 = self:getMultipFaceAction(arg_60_1)
	end

	local var_60_0 = self._spinePaintingData.ship:getSkinId()

	if arg_60_2 == 0 and pg.ship_skin_template[var_60_0].voice_lang and #pg.ship_skin_template[var_60_0].voice_lang > 0 then
		local var_60_1 = ShipWordHelper.GetLanguageSetting(var_60_0)

		if var_60_1 <= 0 then
			var_60_1 = 1
		end

		local var_60_2 = self:GetVoiceLandAction(arg_60_1, pg.ship_skin_template[var_60_0].voice_lang[var_60_1])

		arg_60_1 = self:getAnimationExist(var_60_2, self._skeletonGraphic) and var_60_2 or arg_60_1
	end

	self:updateEffectVisible(arg_60_1)

	if HXSet.isHx() and self:getAnimationExist(arg_60_1 .. "_hx") then
		arg_60_1 = arg_60_1 .. "_hx"
	elseif HXSet.isHx() and self:getAnimationExist("hx/" .. arg_60_1 .. "_hx") then
		arg_60_1 = "hx/" .. arg_60_1 .. "_hx"
	end

	for iter_60_0, iter_60_1 in ipairs(self.spineAnimList) do
		if self:getAnimationExist(arg_60_1, (iter_60_1:GetComponent("SkeletonGraphic"))) then
			iter_60_1:SetAction(arg_60_1, arg_60_2)
		end

		if iter_60_1:GetAnimationState() then
			GetComponent(iter_60_1.transform, "SkeletonGraphic"):Update(Time.deltaTime)
		end
	end

	return true
end

function SpinePainting:GetVoiceLandAction(arg_61_1, arg_61_2)
	local var_61_0 = ""

	if arg_61_2 == ShipSkin.VOICE_LANG_JP then
		var_61_0 = "_jp"
	elseif arg_61_2 == ShipSkin.VOICE_LANG_CN then
		var_61_0 = "_cn"
	end

	return arg_61_1 .. var_61_0
end

function SpinePainting:checkActionPlayAble(arg_62_1, arg_62_2, arg_62_3)
	if arg_62_3 and arg_62_3 == 0 and self.inAction and not arg_62_2 then
		return false
	end

	if self.lockLayer and not arg_62_2 and self.inAction and arg_62_3 and arg_62_3 > 0 then
		return false
	end

	if self.lastPlayAction and self.lastPlayAction ~= self._idleName and arg_62_3 and arg_62_3 > 0 then
		return false
	end

	if self._idleName ~= self:getNormalIdleName() and arg_62_1 == "login" then
		return false
	end

	if not self._dragPassFlag then
		return false
	end

	if self.dragShipFlag and self.shipDragData.action_enable then
		for iter_62_0 = 1, #self.shipDragData.action_enable do
			if self.shipDragData.action_enable[iter_62_0].name == self._idleName and table.contains(self.shipDragData.action_enable[iter_62_0].ignore, arg_62_1) then
				return false
			end
		end
	end

	return true
end

function SpinePainting:ClearAction()
	self:changeInAction(false)
end

function SpinePainting:getSlotAlpha(arg_64_1)
	local var_64_0 = self._skeletonGraphic.Skeleton:FindSlot(arg_64_1)

	if var_64_0 then
		return ReflectionHelp.RefGetProperty(typeof("Spine.Slot"), "A", var_64_0)
	end

	return nil
end

function SpinePainting:setSlotAlpha(arg_65_1, arg_65_2)
	ReflectionHelp.RefSetProperty(typeof("Spine.Slot"), "A", arg_65_1, arg_65_2)
end

function SpinePainting:setStepSlotAlpha(arg_66_1, arg_66_2, arg_66_3)
	self.slotDic[arg_66_1] = self.slotDic[arg_66_1] or self._skeletonGraphic.Skeleton:FindSlot(arg_66_1)

	if self.slotDic[arg_66_1] then
		if not arg_66_3 or arg_66_3 <= 0 then
			print("设置插槽 " .. arg_66_1 .. " alpha = " .. arg_66_2)
			self:setSlotAlpha(self.slotDic[arg_66_1], arg_66_2)
		else
			local var_66_0 = {
				smooth = 0,
				name = arg_66_1,
				slot = self.slotDic[arg_66_1]
			}

			var_66_0.current = self:getSlotAlpha(arg_66_1)
			var_66_0.target = arg_66_2
			var_66_0.time = arg_66_3

			table.insert(self.stepSlotAlpha, var_66_0)
		end
	end
end

function SpinePainting:getStepSlotAlpha(arg_67_1)
	for iter_67_0, iter_67_1 in ipairs(self.stepSlotAlpha) do
		if iter_67_1.name == arg_67_1 then
			return iter_67_1
		end
	end

	return nil
end

function SpinePainting:updateSlotAlpha()
	for iter_68_0 = #self.stepSlotAlpha, 1, -1 do
		local var_68_0 = self.stepSlotAlpha[iter_68_0]

		var_68_0.current, var_68_0.smooth = Mathf.SmoothDamp(self.stepSlotAlpha[iter_68_0].current, self.stepSlotAlpha[iter_68_0].target, self.stepSlotAlpha[iter_68_0].smooth, self.stepSlotAlpha[iter_68_0].time)

		if math.abs(self.stepSlotAlpha[iter_68_0].target - self.stepSlotAlpha[iter_68_0].current) <= 0.02 then
			print("设置插槽 " .. self.stepSlotAlpha[iter_68_0].name .. " alpha = " .. self.stepSlotAlpha[iter_68_0].target)
			self:setSlotAlpha(self.stepSlotAlpha[iter_68_0].slot, self.stepSlotAlpha[iter_68_0].target)

			table.remove(self.stepSlotAlpha, iter_68_0).slot = nil
		else
			print("设置插槽 " .. self.stepSlotAlpha[iter_68_0].name .. " alpha = " .. self.stepSlotAlpha[iter_68_0].current)
			self:setSlotAlpha(self.stepSlotAlpha[iter_68_0].slot, self.stepSlotAlpha[iter_68_0].current)
		end
	end
end

function SpinePainting:updateLight()
	if self._lightAnimator and self._lightAnimationName and (not self._lightValue or math.abs(self._lightValue - SpinePaintingConst.painting_lit_value) > 0.001) then
		self._lightAnimator:Play(self._lightAnimationName, -1, SpinePaintingConst.painting_lit_value)

		self._lightValue = SpinePaintingConst.painting_lit_value
	end

	self._paintingLitOpening = SpinePaintingConst.painting_lit_opening

	if self._paintingLitOpening and self.dragDataConfigClient and #self.dragDataConfigClient > 0 and not self:isInAction() then
		for iter_69_0, iter_69_1 in ipairs(self.dragDataConfigClient) do
			if iter_69_1.lit and #iter_69_1.lit > 0 and SpinePaintingConst.painting_lit_value >= iter_69_1.lit[1] and SpinePaintingConst.painting_lit_value <= iter_69_1.lit[2] then
				local var_69_0 = self:startDragAction(iter_69_1.hit, not iter_69_1.click)
			end
		end
	end
end

function SpinePainting:updateEffectVisible(arg_70_1)
	if not self._effectsTf then
		return
	end

	if isActive(self._effectsTf) ~= self._effectShowFlag then
		setActive(self._effectsTf, self._effectShowFlag)
	end

	if self.shipEffectActionAble then
		if table.contains(self.shipEffectActionAble, arg_70_1) then
			if self._effectsTf and isActive(self._effectsTf) then
				setActive(self._effectsTf, false)
			end

			if self._lightEffects and isActive(self._lightEffects) then
				setActive(self._lightEffects, false)
			end
		else
			if self._effectsTf and not isActive(self._effectsTf) then
				setActive(self._effectsTf, true)
			end

			if self._lightEffects and not isActive(self._lightEffects) then
				setActive(self._lightEffects, true)
			end
		end
	end
end

function SpinePainting:isInAction()
	return self.inAction
end

function SpinePainting:SetActionWithFinishCallback(arg_72_1, arg_72_2, arg_72_3, arg_72_4, arg_72_5)
	if not self:checkActionPlayAble(arg_72_1, arg_72_4, arg_72_2) then
		return
	end

	if self.mainSpineAnim then
		self.mainSpineAnim:SetActionCallBack(nil)
		self.mainSpineAnim:SetActionCallBack(function(arg_73_0)
			if arg_73_0 == "finish" and arg_72_3 then
				self:changeInAction(false)
				arg_72_3()

				arg_72_3 = nil
			elseif arg_73_0 == "action" and arg_72_5 then
				arg_72_5()

				arg_72_5 = nil
			elseif string.match(arg_73_0, "^bgm_") or string.match(arg_73_0, "^bgmsingle_") then
				if self._visible then
					local var_73_0 = string.split(string.match(arg_73_0, "^bgm_(.*)$") or string.match(arg_73_0, "^bgmsingle_(.*)$"), "_")

					pg.CriMgr.GetInstance():PlayPaintingBgm("se-skin", var_73_0[1] .. "_" .. var_73_0[2], string.match(arg_73_0, "^bgm_(.*)$") and true or false, var_73_0[3] and tonumber(var_73_0[3]) or 1, Live2dConst.GetPaintingBgmVolume(self._spinePaintingData.ship:getSkinId()))
				end
			elseif string.match(arg_73_0, "^effect_") then
				if string.match(arg_73_0, "^effect_on") then
					self._effectShowFlag = false
				elseif string.match(arg_73_0, "^effect_off") then
					self._effectShowFlag = true
				end

				self:updateEffectVisible(arg_72_1)
				print("change effect " .. tostring(self._effectShowFlag))
			elseif string.match(arg_73_0, "^drag_") then
				if string.match(arg_73_0, "^drag_on") then
					self._dragPassFlag = false
				elseif string.match(arg_73_0, "^drag_off") then
					self._dragPassFlag = true
				end

				print("change drag pass " .. tostring(self._dragPassFlag))
			end
		end)
	end

	self:SetAction(arg_72_1, arg_72_2, arg_72_4)
end

function SpinePainting:SetOnceAction(arg_74_1, arg_74_2, arg_74_3, arg_74_4)
	if not self:checkActionPlayAble(arg_74_1, arg_74_4, 0) then
		return
	end

	self:SetActionWithFinishCallback(arg_74_1, 0, function()
		self:SetAction(self:getIdleName(), 0)

		if arg_74_2 then
			arg_74_2()

			arg_74_2 = nil
		end
	end, arg_74_4, function()
		if arg_74_3 then
			arg_74_3()

			arg_74_3 = nil
		end
	end)
end

function SpinePainting:pullInitCallback(arg_77_1)
	table.insert(self._initCallback, arg_77_1)
end

function SpinePainting:getAnimationExist(arg_78_1, arg_78_2)
	arg_78_2 = arg_78_2 or self._skeletonGraphic

	return (arg_78_2 or nil) and arg_78_2.Skeleton.Data:FindAnimation(arg_78_1)
end

function SpinePainting:SetEmptyAction(arg_79_1)
	if not self.spineAnimList then
		return
	end

	for iter_79_0, iter_79_1 in ipairs(self.spineAnimList) do
		local var_79_0 = iter_79_1:GetAnimationState()

		if var_79_0 then
			var_79_0:SetEmptyAnimation(arg_79_1, 0)
			GetComponent(iter_79_1.transform, "SkeletonGraphic"):Update(Time.deltaTime)
		end
	end
end

function SpinePainting:GetSpineTransform()
	return self._tf
end

function SpinePainting:SetSkin(arg_81_1)
	if self._skeletonGraphic and self._skeletonGraphic.SkeletonData and self._skeletonGraphic.SkeletonData:FindSkin(arg_81_1) ~= nil then
		self._skeletonGraphic.Skeleton:SetSkin(arg_81_1)
		self._skeletonGraphic.Skeleton:SetSlotsToSetupPose()
	end
end

function SpinePainting:updateSkeletonGraphicTime()
	if self._skeletonGraphic then
		self._skeletonGraphic:Update(Time.deltaTime)
	end
end

function SpinePainting:getMultipFaceAction(arg_83_1)
	if self.multipleFaceFlag then
		local var_83_0 = tonumber(arg_83_1)

		if var_83_0 and var_83_0 >= 0 then
			for iter_83_0, iter_83_1 in ipairs(self.multipleFaceData) do
				if iter_83_1[1] == self:getIdleName() then
					return tostring(var_83_0 + iter_83_1[2])
				end
			end
		end
	end

	return arg_83_1
end

function SpinePainting:unloadCueSheet()
	if not self.loadSheets then
		return
	end

	for iter_84_0, iter_84_1 in ipairs(self.loadSheets) do
		pg.CriMgr.GetInstance():UnloadCueSheet(iter_84_1)
	end

	self.loadSheets = {}
end

function SpinePainting:Dispose()
	self._isDisposed = true
	self._materialDic = {}

	if self.updateLocal then
		self._skeletonGraphic.UpdateLocal = self._skeletonGraphic.UpdateLocal - self.updateLocal
		self.updateLocal = nil
	end

	if self._spinePaintingData then
		self._spinePaintingData:Clear()
	end

	for iter_85_0, iter_85_1 in pairs(self._loadSpineDic) do
		PoolMgr.GetInstance():ReturnSpinePainting(iter_85_0, iter_85_1)
	end

	for iter_85_2, iter_85_3 in pairs(self._loadUIDic) do
		PoolMgr.GetInstance():ReturnUI(iter_85_2, iter_85_3)
	end

	self._loadSpineDic = {}
	self._loadUIDic = {}

	self:unloadCueSheet()

	if self._go ~= nil then
		PoolUtil.Destroy(self._go)
	end

	if self._bgEffectGo ~= nil then
		PoolUtil.Destroy(self._bgEffectGo)
	end

	self._go = nil
	self._tf = nil
	self._bgEffectGo = nil
	self._bgEffectTf = nil

	if self.spineAnim then
		self.spineAnim:SetActionCallBack(nil)
	end

	if self._slotAlphaTimer and self._slotAlphaTimer.running then
		self._slotAlphaTimer:Stop()
	end

	self._slotAlphaTimer = nil

	if self.stepSlotAlpha and #self.stepSlotAlpha > 0 then
		for iter_85_4, iter_85_5 in ipairs(self.stepSlotAlpha) do
			iter_85_5.slot = nil
		end

		self.stepSlotAlpha = {}
	end
end

function SpinePainting:getPaintingName()
	return self._spinePaintingData:GetShipName()
end

return SpinePainting
