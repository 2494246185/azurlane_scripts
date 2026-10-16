local GameHallContainerUI = class("GameHallContainerUI")
local var_0_1 = 4
local var_0_2 = Vector3(0.7, 0.7, 0.7)
local var_0_3 = "mingshi"
local var_0_4 = 0.1
local var_0_5 = 100
local var_0_6 = 4
local var_0_7
local var_0_8
local var_0_9 = 3256
local var_0_10 = 1920
local var_0_11 = {
	{
		"item3",
		"item3/spine"
	}
}
local var_0_12 = {
	{
		bound = "item1/spine/bound",
		pos = "item1/spine/pos",
		spine = "item1/spine"
	},
	{
		bound = "item2/spine2/bound",
		pos = "item2/spine2/pos",
		spine = "item2/spine2"
	},
	{
		bound = "item2/spine3/bound",
		pos = "item2/spine3/pos",
		spine = "item2/spine3"
	},
	{
		bound = "item4/spine1/bound",
		pos = "item4/spine1/pos",
		spine = "item4/spine1"
	},
	{
		bound = "item4/spine2/bound",
		pos = "item4/spine2/pos",
		spine = "item4/spine2"
	},
	{
		bound = "item6/spine1/bound",
		pos = "item6/spine1/pos",
		spine = "item6/spine1"
	},
	{
		bound = "item6/spine2/bound",
		pos = "item6/spine2/pos",
		spine = "item6/spine2"
	}
}

function GameHallContainerUI:Ctor()
	local var_1_0 = getProxy(BayProxy):getShips()

	self.shipNames = {}

	for iter_1_0 = 1, #var_1_0 do
		if not table.contains(self.shipNames, var_1_0[iter_1_0].name) then
			table.insert(self.shipNames, var_1_0[iter_1_0]:getPrefab())
		end
	end

	if var_0_1 > #self.shipNames then
		var_0_1 = #self.shipNames
	end
end

function GameHallContainerUI:InitUI(arg_2_1)
	self.container = arg_2_1
	var_0_7 = {
		var_0_10 - var_0_9 + (pg.UIMgr.GetInstance().uiCamera.gameObject.transform:Find("Canvas").sizeDelta.x - var_0_10),
		0
	}
	var_0_8 = {
		0,
		0
	}
	self.container = arg_2_1
	self.content = findTF(self.container, "content")
	self.pos = findTF(self.content, "pos")
	self.boundContainer = findTF(self.content, "bound")
	self.charContentEvents = {}
	self.charContentCollider = {}
	self.items = {}

	for iter_2_0 = 0, self.pos.childCount - 1 do
		table.insert(self.items, self.pos:GetChild(iter_2_0))
	end

	self.sitItems = {}

	for iter_2_1 = 1, #var_0_12 do
		local var_2_0 = GetComponent(findTF(self.pos, var_0_12[iter_2_1].bound), typeof(BoxCollider2D))

		table.insert(self.sitItems, {
			sit = false,
			pos = findTF(self.pos, var_0_12[iter_2_1].pos),
			min = self.pos:InverseTransformPoint(var_2_0.bounds.min),
			max = self.pos:InverseTransformPoint(var_2_0.bounds.max),
			anim = GetComponent(findTF(self.pos, var_0_12[iter_2_1].spine), typeof(SpineAnimUI))
		})
	end

	self.chars = {}

	for iter_2_2 = 1, var_0_1 do
		local var_2_1 = iter_2_2
		local var_2_2 = SpineAnimChar.New()

		var_2_2:SetPaint((table.remove(self.shipNames, math.random(1, #self.shipNames))))
		var_2_2:Load(true, function(arg_3_0)
			arg_3_0:SetAction("stand2", 0)
			arg_3_0:SetParent(self.pos)
			arg_3_0:SetLocalScale(var_0_2)

			local var_3_0 = GetComponent(findTF(self.boundContainer, tostring(var_2_1)), typeof(BoxCollider2D))
			local var_3_1 = self.pos:InverseTransformPoint(var_3_0.bounds.min)
			local var_3_2 = self.pos:InverseTransformPoint(var_3_0.bounds.max)

			arg_3_0:SetAnchoredPosition(self:getTargetPos(var_3_1, var_3_2))
			table.insert(self.chars, {
				model = arg_3_0,
				vel = Vector2(0, 0),
				bound = {
					var_3_1.x,
					var_3_1.y,
					var_3_2.x,
					var_3_2.y
				},
				min = var_3_1,
				max = var_3_2,
				pos = arg_3_0:GetAnchoredPosition(),
				curScale = arg_3_0:GetLocalScale()
			})
			table.insert(self.items, tf(arg_3_0:GetModel()))
		end)
	end

	self.bataiTf = findTF(self.pos, "batai")
	self.coinChar = nil

	PoolMgr.GetInstance():GetSpineChar(var_0_3, true, function(arg_4_0)
		self.coinChar = tf(arg_4_0)

		tf(arg_4_0):GetComponent(typeof(SpineAnimUI)):SetAction("stand2", 0)
		setParent(tf(arg_4_0), findTF(self.bataiTf, "char"))
		setLocalScale(arg_4_0, var_0_2)
	end)

	self.content.anchoredPosition = Vector2(0, 0)

	local var_2_3 = GetOrAddComponent(self.content, typeof(EventTriggerListener))

	self.velocityXSmoothing = Vector2(0, 0)
	self.offsetPosition = self.content.anchoredPosition

	var_2_3:AddBeginDragFunc(function(arg_5_0, arg_5_1)
		self.prevPosition = arg_5_1.position
		self.scenePosition = self.content.anchoredPosition
		self.velocityXSmoothing = Vector2(0, 0)
		self.offsetPosition = self.content.anchoredPosition
	end)
	var_2_3:AddDragFunc(function(arg_6_0, arg_6_1)
		self.offsetPosition.x = arg_6_1.position.x - self.prevPosition.x + self.scenePosition.x
		self.offsetPosition.y = arg_6_1.position.y - self.prevPosition.y + self.scenePosition.y

		if self.offsetPosition.x > var_0_7[2] then
			self.offsetPosition.x = var_0_7[2] or self.offsetPosition.x
		end

		if self.offsetPosition.x < var_0_7[1] then
			self.offsetPosition.x = var_0_7[1] or self.offsetPosition.x
		end

		if self.offsetPosition.y > var_0_8[2] then
			self.offsetPosition.y = var_0_8[2] or self.offsetPosition.y
		end

		if self.offsetPosition.y < var_0_8[1] then
			self.offsetPosition.y = var_0_8[1] or self.offsetPosition.y
		end
	end)
	var_2_3:AddDragEndFunc(function(arg_7_0, arg_7_1)
		return
	end)

	self.clickItems = {}

	for iter_2_3 = 1, #var_0_11 do
		local var_2_4 = findTF(self.pos, var_0_11[iter_2_3][1])
		local var_2_5 = GetComponent(findTF(self.pos, var_0_11[iter_2_3][2]), typeof(SpineAnimUI))

		table.insert(self.clickItems, {
			time = 0,
			tf = var_2_4,
			anim = var_2_5
		})
		onButton(self._event, var_2_4, function()
			if self:checkClickTime(var_2_5) then
				self:setAnimAction(var_2_5, "action", 1, "normal")
			end
		end)
	end
end

function GameHallContainerUI:setCharSit(arg_9_1, arg_9_2)
	if arg_9_1.sitFlag or arg_9_2.sitFlag then
		return
	end

	local var_9_0 = arg_9_1.model

	arg_9_1.model:SetLocalScale(var_0_2)
	self:setCharAction(var_9_0, "sit", 0, nil)
	self:setAnimAction(arg_9_2.anim, "sit", 0, nil)

	arg_9_1.curAction = "sit"
	arg_9_2.curAction = "sit"
	arg_9_1.target = nil
	arg_9_1.sitItem = arg_9_2
	arg_9_1.sitFlag = true
	arg_9_1.time = math.random(10, 20)
	arg_9_1.vel = Vector2(0, 0)
	arg_9_2.sitFlag = true

	arg_9_1.model:SetParent(arg_9_2.pos)
	arg_9_1.model:SetAnchoredPosition(Vector2(0, 0))
end

function GameHallContainerUI:stopCharSit(arg_10_1)
	arg_10_1.sitItem.sitFlag = false

	self:setCharAction(arg_10_1.model, "walk", 0, nil)
	self:setAnimAction(arg_10_1.sitItem.anim, "normal", 0, nil)

	arg_10_1.sitItem = nil
	arg_10_1.sitFlag = false

	arg_10_1.model:SetParent(self.pos)
	arg_10_1.model:SetAnchoredPosition(arg_10_1.pos)
end

function GameHallContainerUI:checkClickTime(arg_11_1)
	for iter_11_0 = 1, #self.clickItems do
		if self.clickItems[iter_11_0].anim == arg_11_1 and (self.clickItems[iter_11_0].time == 0 or Time.realtimeSinceStartup > self.clickItems[iter_11_0].time) then
			self.clickItems[iter_11_0].time = Time.realtimeSinceStartup + 2

			return true
		end
	end

	return false
end

function GameHallContainerUI:step()
	self.content.anchoredPosition, self.velocityXSmoothing = Vector2.SmoothDamp(self.content.anchoredPosition, self.offsetPosition, self.velocityXSmoothing, var_0_4)

	for iter_12_0 = 1, #self.chars do
		local var_12_0 = self.chars[iter_12_0]

		if not self.chars[iter_12_0].time or self.chars[iter_12_0].time <= 0 then
			if var_12_0.sitFlag then
				self:stopCharSit(var_12_0)
			elseif math.random(1, 10) > 5 then
				local var_12_1 = self:getTargetPos(var_12_0.min, var_12_0.max)

				var_12_0.vel, var_12_0.target = self:getVel(self.chars[iter_12_0].pos, var_12_1), var_12_1
			end

			var_12_0.time = math.random(1, var_0_6)
		end

		if var_12_0.target and not var_12_0.sitFlag then
			local var_12_2 = {
				var_12_0.vel.x * var_0_5 * Time.deltaTime,
				var_12_0.vel.y * var_0_5 * Time.deltaTime
			}

			if var_12_2[1] ~= 0 then
				var_12_0.pos.x = var_12_0.pos.x + var_12_2[1]
			end

			if var_12_2[2] ~= 0 then
				var_12_0.pos.y = var_12_0.pos.y + var_12_2[2]
			end

			local var_12_3 = var_12_0.bound

			if var_12_0.pos.x < var_12_0.bound[1] then
				var_12_0.pos.x = var_12_3[1]
				var_12_0.vel.x = 0
			end

			if var_12_0.pos.x > var_12_3[3] then
				var_12_0.pos.x = var_12_3[3]
				var_12_0.vel.x = 0
			end

			if var_12_0.pos.y < var_12_3[2] then
				var_12_0.pos.y = var_12_3[2]
				var_12_0.vel.y = 0
			end

			if var_12_0.pos.y > var_12_3[4] then
				var_12_0.pos.y = var_12_3[4]
				var_12_0.vel.y = 0
			end

			var_12_0.model:SetAnchoredPosition(var_12_0.pos)

			if math.abs(var_12_0.target.x - var_12_0.pos.x) < 10 then
				var_12_0.vel.x = 0
			end

			if math.abs(var_12_0.target.y - var_12_0.pos.y) < 10 then
				var_12_0.vel.y = 0
			end
		end

		local var_12_5 = true

		if var_12_0.vel.x == 0 and var_12_0.vel.y == 0 then
			var_12_0.time = var_12_0.time - Time.deltaTime
			var_12_5 = false
		end

		if not var_12_5 and var_12_0.target then
			var_12_0.target = nil
		end

		if not var_12_0.sitFlag and not var_12_5 then
			var_12_0.ableSit = true
		end

		if var_12_0.vel.x ~= 0 then
			if math.sign(var_12_0.curScale.x) ~= (var_12_0.vel.x > 0 and 1 or -1) then
				var_12_0.curScale.x = (var_12_0.vel.x > 0 and 1 or -1) * var_0_2.x

				var_12_0.model:SetLocalScale(var_12_0.curScale)
			end
		end

		if var_12_5 then
			if var_12_0.curAction ~= "walk" then
				var_12_0.curAction = "walk"

				var_12_0.model:SetAction("walk", 0)
			end
		elseif var_12_0.sitFlag then
			if var_12_0.curAction ~= "sit" then
				var_12_0.curAction = "sit"

				var_12_0.model:SetAction("sit", 0)
			end
		elseif var_12_0.curAction ~= "stand2" then
			var_12_0.curAction = "stand2"

			var_12_0.model:SetAction("stand2", 0)
		end

		if var_12_5 then
			self:checkCharSit(var_12_0)
		end
	end

	table.sort(self.items, function(arg_13_0, arg_13_1)
		if arg_13_0.anchoredPosition.y < arg_13_1.anchoredPosition.y then
			return true
		end
	end)

	for iter_12_1, iter_12_2 in ipairs(self.items) do
		iter_12_2:SetAsFirstSibling()
	end
end

function GameHallContainerUI:checkCharSit(arg_14_1)
	if not arg_14_1.ableSit then
		return
	end

	local var_14_0 = arg_14_1.pos

	for iter_14_0 = 1, #self.sitItems do
		if var_14_0.x > self.sitItems[iter_14_0].min.x and var_14_0.x < self.sitItems[iter_14_0].max.x and var_14_0.y > self.sitItems[iter_14_0].min.y and var_14_0.y < self.sitItems[iter_14_0].max.y then
			if math.random(1, 10) > 7 then
				print("角色想坐下")
				self:setCharSit(arg_14_1, self.sitItems[iter_14_0])
			else
				arg_14_1.ableSit = false

				print("角色不想坐下")
			end
		end
	end
end

function GameHallContainerUI:getVel(arg_15_1, arg_15_2)
	local var_15_0 = math.atan(math.abs(arg_15_2.y - arg_15_1.y) / math.abs(arg_15_2.x - arg_15_1.x))

	return Vector2(math.cos(var_15_0) * (arg_15_2.x > arg_15_1.x and 1 or -1), math.sin(var_15_0) * (arg_15_2.y > arg_15_1.y and 1 or -1))
end

function GameHallContainerUI:setCharAction(arg_16_1, arg_16_2, arg_16_3, arg_16_4)
	arg_16_1:SetActionCallBack(nil)
	arg_16_1:SetAction(arg_16_2, 0)
	arg_16_1:SetActionCallBack(function(arg_17_0)
		if arg_17_0 == "finish" and arg_16_3 == 1 then
			arg_16_1:SetActionCallBack(nil)
			arg_16_1:SetAction(arg_16_4, 0)
		end
	end)
end

function GameHallContainerUI:setAnimAction(arg_18_1, arg_18_2, arg_18_3, arg_18_4)
	arg_18_1:SetActionCallBack(nil)
	arg_18_1:SetAction(arg_18_2, 0)
	arg_18_1:SetActionCallBack(function(arg_19_0)
		if arg_19_0 == "finish" and arg_18_3 == 1 then
			arg_18_1:SetActionCallBack(nil)
			arg_18_1:SetAction(arg_18_4, 0)
		end
	end)
end

function GameHallContainerUI:getTargetPos(arg_20_1, arg_20_2)
	return Vector2(arg_20_1.x + math.random(1, tonumber(arg_20_2.x) - tonumber(arg_20_1.x)), arg_20_1.y + math.random(1, tonumber(arg_20_2.y) - tonumber(arg_20_1.y)))
end

function GameHallContainerUI:isPointInMatrix(arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5)
	return self:getCross(arg_21_1, arg_21_2, arg_21_5) * self:getCross(arg_21_3, arg_21_4, arg_21_5) >= 0 and self:getCross(arg_21_2, arg_21_3, arg_21_5) * self:getCross(arg_21_4, arg_21_1, arg_21_5) >= 0
end

function GameHallContainerUI:Dispose()
	if self.coinChar then
		PoolMgr.GetInstance():ReturnSpineChar(var_0_3, go(self.coinChar))

		self.coinChar = nil
	end

	if self.chars and #self.chars > 0 then
		for iter_22_0 = 1, #self.chars do
			self.chars[iter_22_0].model:Dispose()
		end

		self.chars = nil
	end
end

return GameHallContainerUI
