AuctionGameMainEventLayer = import("view.activity.AuctionGame.game.event.AuctionGameMainEventLayer")

local AuctionGameMainEventGuideLayer = class("AuctionGameMainEventGuideLayer", AuctionGameMainEventLayer)

function AuctionGameMainEventGuideLayer:init()
	AuctionGameMainEventGuideLayer.super.init(self)
	onButton(self, self.uiBgBtn, function()
		if getProxy(AuctionGameProxy):GetPersonalEventSelectedID() ~= 0 then
			self:closeView()
		end
	end, SOUND_BACK)
	onButton(self, self.uiOkBtn, function()
		if getProxy(AuctionGameProxy):GetPersonalEventSelectedID() ~= 0 then
			return
		end

		if self.selectedID == 0 then
			return
		end

		AuctionGameTools.GuideSelectedEvent(self.selectedID)
	end, SFX_CONFIRM)
end

return AuctionGameMainEventGuideLayer
