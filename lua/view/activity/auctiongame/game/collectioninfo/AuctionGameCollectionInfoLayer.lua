local AuctionGameCollectionInfoLayer = class("AuctionGameCollectionInfoLayer", import("view.base.BaseUI"))

function AuctionGameCollectionInfoLayer:getUIName()
	return "AuctionGameCollectionInfoUI"
end

function AuctionGameCollectionInfoLayer:init()
	self:OverlayPanel(self._tf, {
		pbList = {
			self.uiBgBtn
		}
	})
	setText(self.uiCancelText, i18n("auction_cancel"))
	setText(self.uiConfirmText, i18n("auction_confirm"))
	onButton(self, self.uiCloseBtn, function()
		self:closeView()
	end, SOUND_BACK)
	onButton(self, self.uiBgBtn, function()
		self:closeView()
	end, SOUND_BACK)
	onButton(self, self.uiCancelBtn, function()
		self:closeView()
	end, SOUND_BACK)
	onButton(self, self.uiConfirmBtn, function()
		self:closeView()
	end, SFX_PANEL)
end

function AuctionGameCollectionInfoLayer:didEnter()
	self.auctionGameCollectionItem = AuctionGameCollectionItem.New(self.uiItemTf, self)

	self.auctionGameCollectionItem:didEnter(self.contextData.id)
end

function AuctionGameCollectionInfoLayer:willExit()
	self:UnOverlayPanel(self._tf)
	self.auctionGameCollectionItem:willExit()

	self.auctionGameCollectionItem = nil
end

return AuctionGameCollectionInfoLayer
