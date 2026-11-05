local AuctionGameMainEventItem = class("AuctionGameMainEventItem", import("view.base.BasePanel"))

AuctionGameMainEventItem.AUCTION_GAME_SELECTED_EVENT = "AuctionGameMainEventItem::AUCTION_GAME_SELECTED_EVENT"

function AuctionGameMainEventItem:Ctor(arg_1_1, arg_1_2)
	self._go = arg_1_1.gameObject

	AuctionGameMainEventItem.super.Ctor(self, self._go)

	self._parentClass = arg_1_2

	self:attach(arg_1_2)
	self:Init()
end

function AuctionGameMainEventItem:Init()
	onButton(self, self.uiBtn, function()
		if getProxy(AuctionGameProxy):GetPersonalEventSelectedID() ~= 0 then
			return
		end

		self:emit(AuctionGameMainEventItem.AUCTION_GAME_SELECTED_EVENT, self.id)
	end, SFX_CONFIRM)
end

function AuctionGameMainEventItem:didEnter(arg_4_1)
	self.id = arg_4_1

	setText(self.uiNameText, shortenString(pg.auction_event[arg_4_1].name, 9))
	setText(self.uiDescText, pg.auction_event[arg_4_1].describe)
	LoadSpriteAsync(pg.auction_event[arg_4_1].icon, function(arg_5_0)
		if IsNil(self.uiIconImage) then
			return
		end

		self.uiIconImage.sprite = arg_5_0
	end)
end

function AuctionGameMainEventItem:SetSelected(arg_6_1)
	setActive(self.uiSelectedGo, self.id == arg_6_1)
end

function AuctionGameMainEventItem:willExit()
	self:detach()
end

return AuctionGameMainEventItem
