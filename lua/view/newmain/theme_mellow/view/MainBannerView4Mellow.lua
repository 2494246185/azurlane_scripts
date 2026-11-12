local MainBannerView4Mellow = class("MainBannerView4Mellow", import("...theme_classic.view.MainBannerView"))

function MainBannerView4Mellow:Ctor(arg_1_1, arg_1_2)
	MainBannerView4Mellow.super.Ctor(self, arg_1_1, arg_1_2)

	self.scrollSnap = BannerScrollRect4Mellow.New(findTF(arg_1_1, "mask/content"), findTF(arg_1_1, "dots"))
end

function MainBannerView4Mellow:LayoutBannerItem(arg_2_1)
	local var_2_0 = arg_2_1:GetComponent(typeof(Image))

	if IsNil(var_2_0) or IsNil(var_2_0.sprite) then
		return
	end

	arg_2_1.transform.localScale = Vector3.one
	arg_2_1.transform.anchorMin = Vector2(0.5, 0.5)
	arg_2_1.transform.anchorMax = Vector2(0.5, 0.5)
	arg_2_1.transform.anchoredPosition = Vector2.zero

	var_2_0:SetNativeSize()

	if arg_2_1.transform.parent.rect.width <= 0 or arg_2_1.transform.parent.rect.height <= 0 or arg_2_1.transform.rect.width <= 0 or arg_2_1.transform.rect.height <= 0 then
		return
	end

	local var_2_1 = math.max(arg_2_1.transform.parent.rect.width / arg_2_1.transform.rect.width, arg_2_1.transform.parent.rect.height / arg_2_1.transform.rect.height)

	arg_2_1.transform.localScale = Vector3(var_2_1, var_2_1, 1)
end

function MainBannerView4Mellow:WhenRecycleBanner(arg_3_1)
	arg_3_1.transform.localScale = Vector3.one
	arg_3_1.transform.anchorMin = Vector2(0.5, 0.5)
	arg_3_1.transform.anchorMax = Vector2(0.5, 0.5)
	arg_3_1.transform.anchoredPosition = Vector2.zero
end

function MainBannerView4Mellow:GetDirection()
	return Vector2.zero
end

return MainBannerView4Mellow
