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

		onNextTick(function()
			self._pendingVisible = nil
			self._visibleReady = true

			self:applyVisible(self._pendingVisible ~= false)

			if arg_8_2 then
				arg_8_2(self)
			end
		end)
	end)
end

function SpinePainting:init(arg_15_1)
	self._go = arg_15_1
	self._tf = tf(arg_15_1)

	HotfixHelper.SetLayerRecursively(self._go, LayerMask.NameToLayer("UI"))
	self._tf:SetParent(self._spinePaintingData.parent, true)

	self._tf.localScale = self._spinePaintingData.scale
	self._tf.localPosition = self._spinePaintingData.pos
	self.spineAnimList = {}

	for iter_15_0, iter_15_1 in ipairs((self._tf:GetComponent(typeof(ItemList)).prefabItem:ToTable())) do
		self.spineAnimList[#self.spineAnimList + 1] = GetOrAddComponent(iter_15_1, "SpineAnimUI")
	end

	local var_15_0 = #self.spineAnimList

	assert(#self.spineAnimList > 0, "动态立绘至少要保证有一个spine动画，请检查" .. self._spinePaintingData:GetShipName())

	self.mainSpineAnim = var_15_0 == 1 and self.spineAnimList[1] or self.spineAnimList[#self.spineAnimList]
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
end

function SpinePainting:initBgEffect(arg_18_1)
	self._bgEffectGo = arg_18_1
	self._bgEffectTf = tf(arg_18_1)

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

	local var_21_0 = ChangeSkinLink.CHANGE_SKIN_LINK_DATA[self._spinePaintingData.ship:getSkinId()]

	if var_21_0 then
		if var_21_0.link_type == ChangeSkinLink.L2D_TYPE then
			local var_21_1 = PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1) == 1 and ChangeSkinLink.GetSaveL2dData(self._spinePaintingData.ship.id, var_21_0.link_id) or ChangeSkinLink.L2D_PARAMETER_DIC[self._spinePaintingData.ship.id]

			var_21_1 = var_21_1 or {}

			for iter_21_0, iter_21_1 in ipairs(var_21_0.relations) do
				if iter_21_1.type == ChangeSkinLink.change_parameter_link_slot then
					local var_21_2 = true

					for iter_21_2, iter_21_3 in ipairs(iter_21_1.link_parameter) do
						if var_21_1[iter_21_3.name] then
							if (var_21_1[iter_21_3.name] or 0) ~= iter_21_3.num then
								var_21_2 = false
							end
						end
					end

					if var_21_2 then
						for iter_21_4, iter_21_5 in ipairs(iter_21_1.slot_list) do
							table.insert(self.slotOverride, iter_21_5)
						end
					end
				elseif iter_21_1.type == ChangeSkinLink.change_parameter_link_skin then
					local var_21_4 = true

					for iter_21_6, iter_21_7 in ipairs(iter_21_1.link_parameter) do
						if var_21_1[iter_21_7.name] then
							if (var_21_1[iter_21_7.name] or 0) ~= iter_21_7.num then
								var_21_4 = false
							end
						end
					end

					if var_21_4 then
						self:SetSkeletonSkin(iter_21_1.skeleton_skin)
					end
				end
			end
		end
	end
end

function SpinePainting:setL2dSlot(arg_22_1, arg_22_2)
	self._skeletonGraphic.Skeleton:SetAttachment(arg_22_1, arg_22_2)
end

function SpinePainting:onUpdateLocal()
	if self.slotOverride then
		for iter_23_0, iter_23_1 in ipairs(self.slotOverride) do
			self:setL2dSlot(iter_23_1[1], iter_23_1[2])
		end
	end
end

function SpinePainting:UpdateGraphic()
	if self._isDisposed then
		return
	end

	self._skeletonGraphic:UpdateMesh()
	Canvas.ForceUpdateCanvases()
end

function SpinePainting:SetVisible(arg_25_1)
	if self._isDisposed then
		return
	end

	if not self._visibleReady then
		self._pendingVisible = arg_25_1

		return
	end

	self:applyVisible(arg_25_1)
end

function SpinePainting:applyVisible(arg_26_1)
	if self._isDisposed then
		return
	end

	self._tf.localPosition = arg_26_1 and self._spinePaintingData.pos or Vector2(100000, 0)

	if not arg_26_1 and self.dragDataConfigClient then
		local var_26_0 = self:getIdleName()

		for iter_26_0, iter_26_1 in ipairs(self.dragDataConfigClient) do
			if iter_26_1.idle == var_26_0 and iter_26_1.lit_start and iter_26_1.lit_start >= 0 then
				SpinePaintingConst.painting_lit_value = iter_26_1.lit_start

				if PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1) == 1 then
					SpinePaintingDrag.SetPaintingLite(self._spinePaintingData:GetShipName(), self._spinePaintingData:GetShipId(), SpinePaintingConst.painting_lit_value)
				else
					SpinePaintingDrag.SetPaintingLite(self._spinePaintingData:GetShipName(), self._spinePaintingData:GetShipId(), 0)
				end
			end
		end
	end

	SpinePaintingConst.spine_painting_action = false

	if arg_26_1 then
		if self._slotAlphaTimer and not self._slotAlphaTimer.running then
			self._slotAlphaTimer:Start()
		end
	elseif self._slotAlphaTimer and self._slotAlphaTimer.running then
		self._slotAlphaTimer:Stop()
	end

	self._visible = arg_26_1

	onNextTick(function()
		if self._isDisposed then
			return
		end

		if self._lightTf then
			setActive(self._lightTf, self._visible)
		end

		if self._spinePaintingData.effectParent then
			setActive(self._spinePaintingData.effectParent, self._visible)
		end

		pg.ViewUtils.SetLayer(self._tf, (self._visible or nil) and (Layer.UI or Layer.UIHidden))
		setActiveViaLayer(self._spinePaintingData.effectParent, self._visible)

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

		if not arg_26_1 then
			self:unloadCueSheet()
			pg.CriMgr.GetInstance():DisposePaintingBgm()
		end
	end)
end

function SpinePainting:playPaintingInitIdle()
	local var_28_0 = SpinePaintingDrag.GetPaintingInitIdle(self.mainSpineAnim.name, self._spinePaintingData.ship.id)
	local var_28_1 = self:getNormalIdleName()

	if var_28_0 then
		local var_28_2 = PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1)

		if var_28_2 == 1 and self._idleName ~= var_28_0 then
			var_28_1 = var_28_0
		elseif var_28_2 ~= 1 and self._idleName ~= self:getNormalIdleName() then
			var_28_1 = self:getNormalIdleName()
		end
	else
		var_28_1 = self:getNormalIdleName()
	end

	if var_28_1 then
		self:setIdleName(var_28_1)
		self:SetActionWithFinishCallback(self._idleName, 0, nil, true, nil)
		self:changeInAction(false)
	end
end

function SpinePainting:changeInAction(arg_29_1)
	self.inAction = arg_29_1
	SpinePaintingConst.spine_painting_action = arg_29_1

	if SpinePaintingConst.painting_lit_action_callback then
		SpinePaintingConst.painting_lit_action_callback(arg_29_1)
	end
end

function SpinePainting:playPaintingInitSkin()
	local var_30_0 = SpinePaintingDrag.GetPaintingInitSkin(self.mainSpineAnim.name, self._spinePaintingData.ship.id)
	local var_30_1 = self:GetDefaultSkeletonSkin()

	if var_30_0 then
		if PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1) == 1 and self:GetDefaultSkeletonSkin() ~= var_30_0 then
			var_30_1 = var_30_0
		elseif PlayerPrefs.GetInt(LIVE2D_STATUS_SAVE, 1) ~= 1 and self._skeletonSkin ~= self:GetDefaultSkeletonSkin() then
			var_30_1 = self:GetDefaultSkeletonSkin()
		end
	else
		var_30_1 = self:GetDefaultSkeletonSkin()
	end

	if var_30_1 then
		if self._skeletonGraphic and self._skeletonGraphic.SkeletonData then
			if self._skeletonGraphic.SkeletonData:FindSkin(var_30_1) ~= nil then
				self:SetSkeletonSkin(var_30_1)
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

function SpinePainting:setIdleName(arg_32_1)
	self._idleName = arg_32_1

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
			for iter_34_0 = 1, #self.shipDragData.drag_data.config_client do
				local var_34_0 = self.shipDragData.drag_data.config_client[iter_34_0]

				if self.shipDragData.drag_data.config_client[iter_34_0].hit and not self.shipDragData.drag_data.config_client[iter_34_0].active then
					local var_34_1 = findTF(self._tf, "hitArea/" .. self.shipDragData.drag_data.config_client[iter_34_0].hit)

					if var_34_1 then
						local var_34_2 = true
						local var_34_3 = true

						if var_34_0.idle and type(var_34_0.idle) == "string" then
							var_34_2 = var_34_0.idle == self._idleName
						elseif var_34_0.idle and type(var_34_0.idle) == "table" then
							var_34_2 = table.contains(var_34_0.idle, self._idleName)
						end

						if var_34_0.skin and type(var_34_0.skin) == "string" then
							var_34_3 = var_34_0.skin == self._skeletonSkin
						elseif var_34_0.skin and type(var_34_0.skin) == "table" then
							var_34_3 = table.contains(var_34_0.skin, self._skeletonSkin)
						end

						setActive(var_34_1, var_34_2 and var_34_3)
					else
						print("hit area " .. self.shipDragData.drag_data.config_client[iter_34_0].hit .. "is not exist")
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

function SpinePainting:displayWord(arg_37_1)
	self._displayWord = arg_37_1
end

function SpinePainting:readyDragAction(arg_38_1, arg_38_2)
	if self.inAction or self._displayWord then
		return false
	end

	if self.dragShipFlag then
		return self:startDragAction(arg_38_1, arg_38_2)
	end

	return false
end

function SpinePainting:SetSkeletonSkin(arg_39_1)
	self._skeletonSkin = arg_39_1

	self:SetSkin(arg_39_1)
	self:updateSkeletonGraphicTime()
	self:updateHitArea()
end

function SpinePainting:SetDefaultSkeletonSkin()
	self:SetSkeletonSkin(self:GetDefaultSkeletonSkin())
end

function SpinePainting:GetDefaultSkeletonSkin()
	local var_41_0 = self._spinePaintingData:GetShipSkinConfig().skeleton_default_skin

	if not var_41_0 or var_41_0 == "" then
		var_41_0 = self._skeletonGraphic.SkeletonData:FindSkin("1") and "1" or "default"
	end

	return var_41_0
end

function SpinePainting:startDragAction(arg_42_1, arg_42_2)
	if self.shipDragData.drag_data.type == SpinePaintingConst.drag_type_normal then
		return self:changePaintingNormal(self.shipDragData.drag_data, arg_42_1, arg_42_2)
	elseif self.shipDragData.drag_data.type == SpinePaintingConst.drag_type_list then
		self.clickActionList = Clone(self.shipDragData.drag_data.config_client)

		return self:checkListAction()
	end

	return false
end

function SpinePainting:GetDragDataConfig(arg_43_1)
	if self.shipDragData then
		return self.shipDragData[arg_43_1]
	end

	return nil
end

function SpinePainting:setEventTriggerCallback(arg_44_1)
	self._eventTriggerCall = arg_44_1
end

function SpinePainting:changePaintingNormal(arg_45_1, arg_45_2, arg_45_3)
	for iter_45_0, iter_45_1 in ipairs(arg_45_1.config_client) do
		if self:matchDragFlag(arg_45_2, iter_45_1, arg_45_3) then
			return self:doDragAction(arg_45_1.type, arg_45_1, iter_45_1, arg_45_3)
		end
	end

	return false
end

function SpinePainting:doDragAction(arg_46_1, arg_46_2, arg_46_3, arg_46_4)
	local var_46_0 = arg_46_3.fold
	local var_46_1

	if arg_46_3.fold_chat then
		var_46_1 = arg_46_3.fold_chat or nil
	end

	local var_46_2 = arg_46_3.effect_hide
	local var_46_3 = arg_46_3.action_cv
	local var_46_4 = arg_46_3.finish_cv
	local var_46_5

	if arg_46_3.alpha_data then
		var_46_5 = arg_46_3.alpha_data or nil

		local var_46_6

		if arg_46_3.skin_change then
			var_46_6 = arg_46_3.skin_change or nil

			local var_46_7

			if arg_46_3.clear_track then
				var_46_7 = arg_46_3.clear_track or nil

				local var_46_8

				if arg_46_3.idle then
					var_46_8 = arg_46_3.idle or nil
				end
			end
		end
	end

	local var_46_9 = arg_46_3.change_idle
	local var_46_10 = arg_46_3.action
	local var_46_11 = arg_46_3.event
	local var_46_12 = var_46_6
	local var_46_13
	local var_46_14
	local var_46_15

	if type(arg_46_3.change_idle) == "table" and type(var_46_10) == "table" then
		local var_46_16 = math.random(1, #var_46_10)

		var_46_13 = var_46_10[var_46_16]
		var_46_15 = var_46_9[var_46_16]
	elseif type(var_46_8) == "table" and type(var_46_10) == "table" then
		local var_46_17 = table.indexof(var_46_8, self:getIdleName())

		var_46_13 = var_46_10[var_46_17]

		if type(var_46_9) == "table" then
			var_46_15 = var_46_9[var_46_17]
		end
	end

	if not var_46_13 then
		if type(var_46_10) == "string" then
			var_46_13 = var_46_10
		elseif type(var_46_10) == "table" then
			var_46_13 = var_46_10[math.random(1, #var_46_10)]
		end
	end

	if not var_46_15 then
		if type(var_46_9) == "string" then
			var_46_15 = var_46_9
		elseif type(var_46_9) == "table" then
			var_46_15 = var_46_9[math.random(1, #var_46_9)]
		end
	end

	if not var_46_14 then
		if type(var_46_11) == "string" then
			var_46_14 = var_46_11
		elseif type(var_46_11) == "table" then
			var_46_14 = var_46_11[math.random(1, #var_46_11)]
		end
	end

	if arg_46_1 == SpinePaintingConst.drag_type_normal then
		if var_46_5 and #var_46_5 > 0 then
			self:SetAlphaData(var_46_5)
		end

		if arg_46_3.material then
			local var_46_18 = arg_46_3.material or nil

			if arg_46_3.material_time then
				local var_46_19 = arg_46_3.material_time or nil

				if var_46_18 then
					if LeanTween.isTweening(go(self._tf)) then
						return false
					end

					self:getSpineMaterial(var_46_18, function(arg_47_0)
						self._skeletonGraphic.material = arg_47_0

						if var_46_19 then
							LeanTween.delayedCall(go(self._tf), var_46_19, System.Action(function()
								self._skeletonGraphic.material = self._baseMaterial

								self:changePaintingIdle(var_46_15)
							end))
						end
					end)
				end

				if var_46_7 and #var_46_7 > 0 then
					for iter_46_0, iter_46_1 in ipairs(var_46_7) do
						self:SetEmptyAction(iter_46_1)
					end
				end

				if var_46_13 and var_46_13 ~= "" and self:checkActionPlayAble(var_46_13, false, 0) then
					print("播放动作 .." .. var_46_13 .. "下一个待机动作 .. " .. var_46_15)

					if arg_46_3.fold then
						pg.m02:sendNotification(NewMainMediator.HIDE_PANEL, {
							flag = true,
							content = {
								chat = var_46_1
							}
						})
					end

					self:setEffectVisible(var_46_2, false)
					self:SetActionWithFinishCallback(var_46_13, 0, function()
						if var_46_12 and var_46_12 ~= "" then
							self:changeSkeletonSkin(var_46_12)
						end

						if var_46_0 then
							pg.m02:sendNotification(NewMainMediator.HIDE_PANEL, {
								flag = false,
								content = {
									chat = var_46_1
								}
							})

							local var_49_0

							if var_46_15 then
								var_49_0 = var_46_15 or self:getIdleName()
							end
						end

						self:changePaintingIdle(var_49_0)
						self:setEffectVisible(var_46_2, true)

						if var_46_4 and var_46_4 ~= "" then
							self:PlayCv(var_46_4)
						end
					end, false, function()
						if var_46_3 and var_46_3 ~= "" then
							self:PlayCv(var_46_3)
						end

						if var_46_14 and type(var_46_14) == "string" and self._eventTriggerCall then
							self._eventTriggerCall(var_46_14)
						end
					end)
				end

				if not var_46_13 or var_46_13 == "" then
					if var_46_12 and var_46_12 ~= "" then
						self:changeSkeletonSkin(var_46_12)
					end

					if var_46_15 and var_46_15 ~= "" then
						self:changePaintingIdle(var_46_15)
					end

					if var_46_14 and type(var_46_14) == "string" and self._eventTriggerCall then
						self._eventTriggerCall(var_46_14)
					end

					return false
				end
			end
		end
	end

	return true
end

function SpinePainting:SetAlphaData(arg_51_1)
	for iter_51_0, iter_51_1 in ipairs(arg_51_1) do
		local var_51_0 = self:getSlotAlpha(iter_51_1[1])

		if not self:getStepSlotAlpha(iter_51_1[1]) and var_51_0 then
			local var_51_1

			for iter_51_2, iter_51_3 in ipairs(iter_51_1[2]) do
				if ((math.abs(var_51_0 - iter_51_3) <= 0.1 or nil) and iter_51_2 + 1) == iter_51_2 then
					var_51_1 = iter_51_3
				end
			end

			var_51_1 = var_51_1 or iter_51_1[2][1]

			if var_51_1 then
				self:setStepSlotAlpha(iter_51_1[1], var_51_1, iter_51_1[3])
			end
		end
	end
end

function SpinePainting:PlayCv(arg_52_1)
	local var_52_0 = self._spinePaintingData.ship:getSkinId()
	local var_52_1 = pg.CriMgr.GetCVBankName(ShipWordHelper.RawGetCVKey(var_52_0))

	print("try playing cv" .. var_52_1 .. ":" .. arg_52_1 .. "_" .. pg.ship_skin_template[var_52_0].group_index)
	pg.CriMgr.GetInstance():playCueSheetVoice(var_52_1, arg_52_1 .. "_" .. pg.ship_skin_template[var_52_0].group_index, true, function(arg_53_0)
		if arg_53_0 then
			print("播放的语音长度为 = " .. arg_53_0:GetLength())
		end
	end)
end

function SpinePainting:changeSkeletonSkin(arg_54_1)
	if self._skeletonSkin == arg_54_1 then
		self:SetDefaultSkeletonSkin()
	else
		self:SetSkeletonSkin(arg_54_1)
	end

	SpinePaintingDrag.SetPaintingInitSkin(self.mainSpineAnim.name, self._spinePaintingData.ship.id, self._skeletonSkin)
end

function SpinePainting:setEffectVisible(arg_55_1, arg_55_2)
	if not arg_55_1 or #arg_55_1 == 0 then
		return
	end

	for iter_55_0 = 1, #arg_55_1 do
		local var_55_0 = findTF(self._tf, arg_55_1[iter_55_0])

		if var_55_0 then
			setActive(var_55_0, arg_55_2)
		end
	end
end

function SpinePainting:matchDragFlag(arg_56_1, arg_56_2, arg_56_3)
	if arg_56_2.hit and arg_56_2.hit ~= arg_56_1 then
		return false
	end

	local var_56_0 = arg_56_2.skin

	if arg_56_2.skin and var_56_0 ~= "" and self._skeletonSkin ~= var_56_0 then
		return false
	end

	local var_56_1 = arg_56_2.idle

	if arg_56_2.idle and type(var_56_1) == "string" and self:getIdleName() ~= var_56_1 then
		return false
	elseif var_56_1 and type(var_56_1) == "table" and not table.contains(var_56_1, self:getIdleName()) then
		return false
	end

	local var_56_2 = arg_56_2.favor

	if arg_56_2.favor and var_56_2 >= 0 then
		local var_56_3 = self._spinePaintingData.ship:getCVIntimacy()

		if var_56_3 and var_56_3 < var_56_2 then
			return false
		end
	end

	if arg_56_2.click and arg_56_2.click == tobool(arg_56_3) then
		return false
	end

	return true
end

function SpinePainting:OnDragMove(arg_57_1, arg_57_2)
	return
end

function SpinePainting:getSpineMaterial(arg_58_1, arg_58_2)
	self._materialDic = self._materialDic or {}

	if self._materialDic[arg_58_1] then
		arg_58_2(self._materialDic[arg_58_1])
	else
		self._materialDic[arg_58_1] = LoadAny("spinematerials", arg_58_1, typeof(Material))

		arg_58_2(self._materialDic[arg_58_1])
	end
end

function SpinePainting:changePaintingIdle(arg_59_1)
	self:setIdleName(arg_59_1)
	self:SetAction(arg_59_1, 0, true)
	SpinePaintingDrag.SetPaintingInitIdle(self.mainSpineAnim.name, self._spinePaintingData.ship.id, arg_59_1)
	self:changeInAction(false)
end

function SpinePainting:SetShopHx(arg_60_1)
	if arg_60_1 and HXSet.isHx() then
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

function SpinePainting:SetAction(arg_62_1, arg_62_2, arg_62_3)
	if not self:checkActionPlayAble(arg_62_1, arg_62_3, arg_62_2) then
		return false
	end

	if arg_62_2 and arg_62_2 == 0 then
		self.lastPlayAction = arg_62_1
	end

	if arg_62_2 == 0 and arg_62_1 ~= self:getIdleName() then
		self:changeInAction(true)
	end

	if self.multipleFaceFlag and not self.inAction then
		arg_62_1 = self:getMultipFaceAction(arg_62_1)
	end

	local var_62_0 = self._spinePaintingData.ship:getSkinId()

	if arg_62_2 == 0 and pg.ship_skin_template[var_62_0].voice_lang and #pg.ship_skin_template[var_62_0].voice_lang > 0 then
		local var_62_1 = ShipWordHelper.GetLanguageSetting(var_62_0)

		if var_62_1 <= 0 then
			var_62_1 = 1
		end

		local var_62_2 = self:GetVoiceLandAction(arg_62_1, pg.ship_skin_template[var_62_0].voice_lang[var_62_1])

		arg_62_1 = self:getAnimationExist(var_62_2, self._skeletonGraphic) and var_62_2 or arg_62_1
	end

	self:updateEffectVisible(arg_62_1)

	if HXSet.isHx() and self:getAnimationExist(arg_62_1 .. "_hx") then
		arg_62_1 = arg_62_1 .. "_hx"
	elseif HXSet.isHx() and self:getAnimationExist("hx/" .. arg_62_1 .. "_hx") then
		arg_62_1 = "hx/" .. arg_62_1 .. "_hx"
	end

	for iter_62_0, iter_62_1 in ipairs(self.spineAnimList) do
		if self:getAnimationExist(arg_62_1, (iter_62_1:GetComponent("SkeletonGraphic"))) then
			iter_62_1:SetAction(arg_62_1, arg_62_2)
		end

		if iter_62_1:GetAnimationState() then
			GetComponent(iter_62_1.transform, "SkeletonGraphic"):Update(Time.deltaTime)
		end
	end

	return true
end

function SpinePainting:GetVoiceLandAction(arg_63_1, arg_63_2)
	local var_63_0 = ""

	if arg_63_2 == ShipSkin.VOICE_LANG_JP then
		var_63_0 = "_jp"
	elseif arg_63_2 == ShipSkin.VOICE_LANG_CN then
		var_63_0 = "_cn"
	end

	return arg_63_1 .. var_63_0
end

function SpinePainting:checkActionPlayAble(arg_64_1, arg_64_2, arg_64_3)
	if arg_64_3 and arg_64_3 == 0 and self.inAction and not arg_64_2 then
		return false
	end

	if self.lockLayer and not arg_64_2 and self.inAction and arg_64_3 and arg_64_3 > 0 then
		return false
	end

	if self.lastPlayAction and self.lastPlayAction ~= self._idleName and arg_64_3 and arg_64_3 > 0 then
		return false
	end

	if self._idleName ~= self:getNormalIdleName() and arg_64_1 == "login" then
		return false
	end

	if not self._dragPassFlag then
		return false
	end

	if self.dragShipFlag and self.shipDragData.action_enable then
		for iter_64_0 = 1, #self.shipDragData.action_enable do
			if self.shipDragData.action_enable[iter_64_0].name == self._idleName and table.contains(self.shipDragData.action_enable[iter_64_0].ignore, arg_64_1) then
				return false
			end
		end
	end

	return true
end

function SpinePainting:ClearAction()
	self:changeInAction(false)
end

function SpinePainting:getSlotAlpha(arg_66_1)
	local var_66_0 = self._skeletonGraphic.Skeleton:FindSlot(arg_66_1)

	if var_66_0 then
		return ReflectionHelp.RefGetProperty(typeof("Spine.Slot"), "A", var_66_0)
	end

	return nil
end

function SpinePainting:setSlotAlpha(arg_67_1, arg_67_2)
	ReflectionHelp.RefSetProperty(typeof("Spine.Slot"), "A", arg_67_1, arg_67_2)
end

function SpinePainting:setStepSlotAlpha(arg_68_1, arg_68_2, arg_68_3)
	self.slotDic[arg_68_1] = self.slotDic[arg_68_1] or self._skeletonGraphic.Skeleton:FindSlot(arg_68_1)

	if self.slotDic[arg_68_1] then
		if not arg_68_3 or arg_68_3 <= 0 then
			print("设置插槽 " .. arg_68_1 .. " alpha = " .. arg_68_2)
			self:setSlotAlpha(self.slotDic[arg_68_1], arg_68_2)
		else
			local var_68_0 = {
				smooth = 0,
				name = arg_68_1,
				slot = self.slotDic[arg_68_1]
			}

			var_68_0.current = self:getSlotAlpha(arg_68_1)
			var_68_0.target = arg_68_2
			var_68_0.time = arg_68_3

			table.insert(self.stepSlotAlpha, var_68_0)
		end
	end
end

function SpinePainting:getStepSlotAlpha(arg_69_1)
	for iter_69_0, iter_69_1 in ipairs(self.stepSlotAlpha) do
		if iter_69_1.name == arg_69_1 then
			return iter_69_1
		end
	end

	return nil
end

function SpinePainting:updateSlotAlpha()
	for iter_70_0 = #self.stepSlotAlpha, 1, -1 do
		local var_70_0 = self.stepSlotAlpha[iter_70_0]

		var_70_0.current, var_70_0.smooth = Mathf.SmoothDamp(self.stepSlotAlpha[iter_70_0].current, self.stepSlotAlpha[iter_70_0].target, self.stepSlotAlpha[iter_70_0].smooth, self.stepSlotAlpha[iter_70_0].time)

		if math.abs(self.stepSlotAlpha[iter_70_0].target - self.stepSlotAlpha[iter_70_0].current) <= 0.02 then
			print("设置插槽 " .. self.stepSlotAlpha[iter_70_0].name .. " alpha = " .. self.stepSlotAlpha[iter_70_0].target)
			self:setSlotAlpha(self.stepSlotAlpha[iter_70_0].slot, self.stepSlotAlpha[iter_70_0].target)

			table.remove(self.stepSlotAlpha, iter_70_0).slot = nil
		else
			print("设置插槽 " .. self.stepSlotAlpha[iter_70_0].name .. " alpha = " .. self.stepSlotAlpha[iter_70_0].current)
			self:setSlotAlpha(self.stepSlotAlpha[iter_70_0].slot, self.stepSlotAlpha[iter_70_0].current)
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
		for iter_71_0, iter_71_1 in ipairs(self.dragDataConfigClient) do
			if iter_71_1.lit and #iter_71_1.lit > 0 and SpinePaintingConst.painting_lit_value >= iter_71_1.lit[1] and SpinePaintingConst.painting_lit_value <= iter_71_1.lit[2] then
				local var_71_0 = self:startDragAction(iter_71_1.hit, not iter_71_1.click)
			end
		end
	end
end

function SpinePainting:updateEffectVisible(arg_72_1)
	if not self._effectsTf then
		return
	end

	if isActive(self._effectsTf) ~= self._effectShowFlag then
		setActive(self._effectsTf, self._effectShowFlag)
	end

	if self.shipEffectActionAble then
		if table.contains(self.shipEffectActionAble, arg_72_1) then
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

function SpinePainting:SetActionWithFinishCallback(arg_74_1, arg_74_2, arg_74_3, arg_74_4, arg_74_5)
	if not self:checkActionPlayAble(arg_74_1, arg_74_4, arg_74_2) then
		return
	end

	if self.mainSpineAnim then
		self.mainSpineAnim:SetActionCallBack(nil)
		self.mainSpineAnim:SetActionCallBack(function(arg_75_0)
			if arg_75_0 == "finish" and arg_74_3 then
				self:changeInAction(false)
				arg_74_3()

				arg_74_3 = nil
			elseif arg_75_0 == "action" and arg_74_5 then
				arg_74_5()

				arg_74_5 = nil
			elseif string.match(arg_75_0, "^bgm_") or string.match(arg_75_0, "^bgmsingle_") then
				if self._visible then
					local var_75_0 = string.split(string.match(arg_75_0, "^bgm_(.*)$") or string.match(arg_75_0, "^bgmsingle_(.*)$"), "_")

					pg.CriMgr.GetInstance():PlayPaintingBgm("se-skin", var_75_0[1] .. "_" .. var_75_0[2], string.match(arg_75_0, "^bgm_(.*)$") and true or false, var_75_0[3] and tonumber(var_75_0[3]) or 1, Live2dConst.GetPaintingBgmVolume(self._spinePaintingData.ship:getSkinId()))
				end
			elseif string.match(arg_75_0, "^effect_") then
				if string.match(arg_75_0, "^effect_on") then
					self._effectShowFlag = false
				elseif string.match(arg_75_0, "^effect_off") then
					self._effectShowFlag = true
				end

				self:updateEffectVisible(arg_74_1)
				print("change effect " .. tostring(self._effectShowFlag))
			elseif string.match(arg_75_0, "^drag_") then
				if string.match(arg_75_0, "^drag_on") then
					self._dragPassFlag = false
				elseif string.match(arg_75_0, "^drag_off") then
					self._dragPassFlag = true
				end

				print("change drag pass " .. tostring(self._dragPassFlag))
			end
		end)
	end

	self:SetAction(arg_74_1, arg_74_2, arg_74_4)
end

function SpinePainting:SetOnceAction(arg_76_1, arg_76_2, arg_76_3, arg_76_4)
	if not self:checkActionPlayAble(arg_76_1, arg_76_4, 0) then
		return
	end

	self:SetActionWithFinishCallback(arg_76_1, 0, function()
		self:SetAction(self:getIdleName(), 0)

		if arg_76_2 then
			arg_76_2()

			arg_76_2 = nil
		end
	end, arg_76_4, function()
		if arg_76_3 then
			arg_76_3()

			arg_76_3 = nil
		end
	end)
end

function SpinePainting:pullInitCallback(arg_79_1)
	table.insert(self._initCallback, arg_79_1)
end

function SpinePainting:getAnimationExist(arg_80_1, arg_80_2)
	arg_80_2 = arg_80_2 or self._skeletonGraphic

	return (arg_80_2 or nil) and arg_80_2.Skeleton.Data:FindAnimation(arg_80_1)
end

function SpinePainting:SetEmptyAction(arg_81_1)
	if not self.spineAnimList then
		return
	end

	for iter_81_0, iter_81_1 in ipairs(self.spineAnimList) do
		local var_81_0 = iter_81_1:GetAnimationState()

		if var_81_0 then
			var_81_0:SetEmptyAnimation(arg_81_1, 0)
			GetComponent(iter_81_1.transform, "SkeletonGraphic"):Update(Time.deltaTime)
		end
	end
end

function SpinePainting:GetSpineTransform()
	return self._tf
end

function SpinePainting:SetSkin(arg_83_1)
	if self._skeletonGraphic and self._skeletonGraphic.SkeletonData and self._skeletonGraphic.SkeletonData:FindSkin(arg_83_1) ~= nil then
		self._skeletonGraphic.Skeleton:SetSkin(arg_83_1)
		self._skeletonGraphic.Skeleton:SetSlotsToSetupPose()
	end
end

function SpinePainting:updateSkeletonGraphicTime()
	if self._skeletonGraphic then
		self._skeletonGraphic:Update(Time.deltaTime)
	end
end

function SpinePainting:getMultipFaceAction(arg_85_1)
	if self.multipleFaceFlag then
		local var_85_0 = tonumber(arg_85_1)

		if var_85_0 and var_85_0 >= 0 then
			for iter_85_0, iter_85_1 in ipairs(self.multipleFaceData) do
				if iter_85_1[1] == self:getIdleName() then
					return tostring(var_85_0 + iter_85_1[2])
				end
			end
		end
	end

	return arg_85_1
end

function SpinePainting:unloadCueSheet()
	if not self.loadSheets then
		return
	end

	for iter_86_0, iter_86_1 in ipairs(self.loadSheets) do
		pg.CriMgr.GetInstance():UnloadCueSheet(iter_86_1)
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

	for iter_87_0, iter_87_1 in pairs(self._loadSpineDic) do
		PoolMgr.GetInstance():ReturnSpinePainting(iter_87_0, iter_87_1)
	end

	for iter_87_2, iter_87_3 in pairs(self._loadUIDic) do
		PoolMgr.GetInstance():ReturnUI(iter_87_2, iter_87_3)
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
		for iter_87_4, iter_87_5 in ipairs(self.stepSlotAlpha) do
			iter_87_5.slot = nil
		end

		self.stepSlotAlpha = {}
	end
end

function SpinePainting:getPaintingName()
	return self._spinePaintingData:GetShipName()
end

return SpinePainting
