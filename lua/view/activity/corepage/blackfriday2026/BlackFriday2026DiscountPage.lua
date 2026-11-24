local BlackFriday2026DiscountPage = class("BlackFriday2026DiscountPage", import("view.activity.CorePage.PSS.PSSHei5DiscountPage"))

function BlackFriday2026DiscountPage:GetGiftShopType()
	return ChargeScene.TYPE_PICK
end

return BlackFriday2026DiscountPage
