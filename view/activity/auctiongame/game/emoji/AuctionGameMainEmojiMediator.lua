local AuctionGameMainEmojiMediator = class("AuctionGameMainEmojiMediator", import("view.base.ContextMediator"))

AuctionGameMainEmojiMediator.ON_CLICK_EMOJI = "AuctionGameMainEmojiMediator::ON_CLICK_EMOJI"
AuctionGameMainEmojiMediator.ON_CLICK_EMOJI_SWITCH = "AuctionGameMainEmojiMediator::ON_CLICK_EMOJI_SWITCH"

function AuctionGameMainEmojiMediator:register()
	self:bind(AuctionGameMainEmojiMediator.ON_CLICK_EMOJI, function(arg_2_0, arg_2_1)
		self:sendNotification(GAME.AUCTION_GAME_EMOJI, arg_2_1)
	end)
	self:bind(AuctionGameMainEmojiMediator.ON_CLICK_EMOJI_SWITCH, function(arg_3_0, arg_3_1)
		self:sendNotification(GAME.AUCTION_GAME_SWITCH_EMOJI, arg_3_1)
	end)
end

function AuctionGameMainEmojiMediator:initNotificationHandleDic()
	self.handleDic = {
		[GAME.AUCTION_GAME_EMOJI_DONE] = function(arg_5_0, arg_5_1)
			arg_5_0.viewComponent:closeView()
		end,
		[GAME.AUCTION_GAME_SWITCH_EMOJI_DONE] = function(arg_6_0, arg_6_1)
			arg_6_0.viewComponent:OnRefreshSwitchEmojiBtn()
		end
	}
end

function AuctionGameMainEmojiMediator:remove()
	return
end

return AuctionGameMainEmojiMediator
