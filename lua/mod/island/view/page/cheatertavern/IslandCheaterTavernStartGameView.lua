local IslandCheaterTavernStartGameView = class("IslandCheaterTavernStartGameView", import(".IslandCheaterTavernBaseView"))

function IslandCheaterTavernStartGameView:Show()
	self.startCardList = pg.gameset.bar_card.description

	self.cardItemList:align(#self.startCardList)

	if not self.cheaterTavernAgency:GetMainPlayer():IsOut() then
		IslandCheaterTavernRecordTools.AddTurnCnt()
	end
end

function IslandCheaterTavernStartGameView:Init()
	self.uiParent_ = self._tf.parent

	self.super.Init(self)

	self.cardItemList = UIItemList.New(self.uiStartGameItemList, self.uiStartGameItem)

	self.cardItemList:make(function(arg_3_0, arg_3_1, arg_3_2)
		if arg_3_0 == UIItemList.EventUpdate then
			self:OnUpdateItem(arg_3_1, arg_3_2)
		end
	end)
end

function IslandCheaterTavernStartGameView:OnCheaterEveryRoundStart()
	self:SetActiveState(true)
	self:Show()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function IslandCheaterTavernStartGameView:OnCheaterEveryRoundStartDone()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self.uiParent_)
	self:SetActiveState(false)
end

function IslandCheaterTavernStartGameView:OnUpdateItem(arg_6_1, arg_6_2)
	local var_6_0 = tf(arg_6_2)
	local var_6_1 = self.startCardList[arg_6_1 + 1][1]

	GetImageSpriteFromAtlasAsync("Island/IslandCheaterTavernIcon/" .. pg.bar_card[self.startCardList[arg_6_1 + 1][1]].card_res, "", var_6_0:Find("cardImage"))
	setText(var_6_0:Find("numBg/numText"), "x" .. self.startCardList[arg_6_1 + 1][2])
	setActive(var_6_0:Find("selected"), self.cheaterTavernAgency:GetRealCard() == var_6_1)
end

function IslandCheaterTavernStartGameView:OnInit()
	return
end

function IslandCheaterTavernStartGameView:OnHide()
	if self._tf.parent ~= self.uiParent_ then
		pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self.uiParent_)
	end
end

return IslandCheaterTavernStartGameView
