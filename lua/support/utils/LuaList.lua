local LuaList = class("LuaList")

function LuaList:Ctor(arg_1_1, arg_1_2, arg_1_3, arg_1_4)
	self.parentClass_ = arg_1_1
	self.uiListGo_ = arg_1_3.gameObject
	self.itemClass_ = arg_1_4
	self.itemRenderer_ = arg_1_2
	self.itemOfInstanceID_ = {}
	self.itemOfIndex_ = {}

	self:InitUI()
	self:AddListeners()
end

function LuaList:InitUI()
	self.uiList_ = self.uiListGo_:GetComponent(typeof(UIList))
end

function LuaList:AddListeners()
	if self.uiList_ ~= nil then
		self.uiList_:SetItemRenderer(handler(self, self.ItemRenderer))
		self.uiList_:SetItemRecycleHandler(handler(self, self.ItemRecycleHandler))
		self.uiList_:SetPageChangeHandler(handler(self, self.PageChangeHandler))
		self.uiList_:SetHeadTailChangeHandler(handler(self, self.HeadTailChangeHandler))
	end
end

function LuaList:RemoveListeners()
	if self.uiList_ ~= nil then
		self.uiList_:SetItemRenderer(nil)
		self.uiList_:SetItemRecycleHandler(nil)
		self.uiList_:SetPageChangeHandler(nil)
		self.uiList_:SetHeadTailChangeHandler(nil)
	end
end

function LuaList:HeadTailChangeHandler(arg_5_1, arg_5_2)
	if self.headTailChangeHandler_ ~= nil then
		self.headTailChangeHandler_(arg_5_1, arg_5_2)
	end
end

function LuaList:ItemRenderer(arg_6_1, arg_6_2)
	local var_6_0 = arg_6_2:GetInstanceID()
	local var_6_1

	if self.itemOfInstanceID_[var_6_0] then
		var_6_1 = self.itemOfInstanceID_[var_6_0]
	else
		var_6_1 = self.itemClass_.New(arg_6_2.transform, self.parentClass_)
		self.itemOfInstanceID_[var_6_0] = var_6_1
	end

	self.itemOfIndex_[arg_6_1 + 1] = var_6_1

	if arg_6_1 + 1 > self.num_ then
		return
	end

	if self.itemRenderer_ then
		self.itemRenderer_(arg_6_1 + 1, var_6_1)
	end
end

function LuaList:GetItemByIndex(arg_7_1)
	local var_7_0, var_7_1 = self:GetHeadAndTail()

	if var_7_0 == 0 then
		return
	end

	if arg_7_1 < var_7_0 or var_7_1 < arg_7_1 then
		return nil
	end

	return self.itemOfIndex_[arg_7_1]
end

function LuaList:ItemRecycleHandler(arg_8_1, arg_8_2)
	if self.itemRecycleHandler_ then
		self.itemRecycleHandler_(arg_8_1, arg_8_2)
	end
end

function LuaList:SetItemRecycleHandler(arg_9_1)
	self.itemRecycleHandler_ = arg_9_1
end

function LuaList:SetPageChangeHandler(arg_10_1)
	self.pageChangeHandler_ = arg_10_1
end

function LuaList:SetHeadTailChangeHandler(arg_11_1)
	self.headTailChangeHandler_ = arg_11_1
end

function LuaList:PageChangeHandler(arg_12_1)
	if self.pageChangeHandler_ ~= nil then
		self.pageChangeHandler_(arg_12_1 + 1)
	end
end

function LuaList:ScrollToIndex(arg_13_1, arg_13_2, arg_13_3, arg_13_4)
	arg_13_2 = arg_13_2 or false
	arg_13_3 = arg_13_3 or false
	arg_13_4 = arg_13_4 or -1

	self.uiList_:ScrollToIndex(arg_13_1 - 1, arg_13_2, arg_13_3, arg_13_4)
end

function LuaList:RemoveTween()
	self.uiList_:RemoveTween()
end

function LuaList:SwitchToPage(arg_15_1)
	self.uiList_:SwitchToPageIndex(arg_15_1 - 1)
end

function LuaList:GetItemList()
	local var_16_0 = {}
	local var_16_1, var_16_2 = self:GetHeadAndTail()

	if var_16_1 == 0 then
		return {}
	end

	for iter_16_0 = var_16_1, var_16_2 do
		var_16_0[iter_16_0] = self.itemOfIndex_[iter_16_0]
	end

	return var_16_0
end

function LuaList:GetHeadAndTail()
	local var_17_0 = self.uiList_:GetHeadAndTail()

	return var_17_0.x + 1, var_17_0.y + 1
end

function LuaList:SetAlignment(arg_18_1)
	self.uiList_:SetAlignment(arg_18_1)
end

function LuaList:StartScroll(arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5)
	arg_19_2 = arg_19_2 or 0
	arg_19_5 = arg_19_5 or -1

	local var_19_0 = arg_19_2 - 1

	self.num_ = arg_19_1

	self:UpdateUIList(arg_19_1)

	if var_19_0 >= 0 then
		self.uiList_:ScrollToIndex(var_19_0, arg_19_3, arg_19_4, arg_19_5)
	end
end

function LuaList:StartScrollWithoutAnimator(arg_20_1, arg_20_2)
	self.num_ = arg_20_1

	self.uiList_:SetNumItems(arg_20_1, true)

	if arg_20_2 then
		self.uiList_:SetScrolledPosition(arg_20_2)
	end
end

function LuaList:Refresh()
	local var_21_0, var_21_1 = self:GetHeadAndTail()

	if var_21_0 == 0 then
		return
	end

	for iter_21_0 = var_21_0, var_21_1 do
		if self.itemRenderer_ then
			if self.itemOfIndex_[iter_21_0] then
				self.itemRenderer_(iter_21_0, self.itemOfIndex_[iter_21_0])
			end
		end
	end
end

function LuaList:SetScrolledPosition(arg_22_1)
	self.uiList_:SetScrolledPosition(arg_22_1)
end

function LuaList:GetScrolledPosition()
	return self.uiList_:GetScrolledPosition()
end

function LuaList:StartScrollByPosition(arg_24_1, arg_24_2)
	self.num_ = arg_24_1

	self:UpdateUIList(arg_24_1)
	self:SetScrolledPosition(arg_24_2 or Vector2.zero)
end

function LuaList:UpdateUIList(arg_25_1)
	self.uiList_:SetNumItems(arg_25_1)
end

function LuaList:StopRender()
	if self.uiList_ then
		self.uiList_:StopRender()
	end
end

function LuaList:Dispose()
	self:RemoveListeners()

	if self.uiList_ ~= nil then
		self:RemoveTween()
		self.uiList_:StopRender()
		self.uiList_:HideBlock()

		self.uiList_ = nil
	end

	if self.itemOfInstanceID_ then
		for iter_27_0, iter_27_1 in pairs(self.itemOfInstanceID_) do
			iter_27_1:willExit()
		end

		self.itemOfInstanceID_ = nil
	end

	self.pageChangeHandler_ = nil
	self.itemRecycleHandler_ = nil
end

function LuaList:SetOrientation(arg_28_1)
	if arg_28_1 == 0 then
		self.uiList_:SetOrientation(Orientation.Horizontal)
	else
		self.uiList_:SetOrientation(Orientation.Vertical)
	end
end

function LuaList:GetNum()
	return self.num_
end

function LuaList:SetAppearType(arg_30_1)
	self.uiList_:SetAppearType(arg_30_1)
end

return LuaList
