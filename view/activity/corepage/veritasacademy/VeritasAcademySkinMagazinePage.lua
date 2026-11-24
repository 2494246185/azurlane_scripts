local VeritasAcademySkinMagazinePage = class("VeritasAcademySkinMagazinePage", import("view.activity.CorePage.CorSkinMagazineTemplatePage"))

VeritasAcademySkinMagazinePage.EXPAND_WIDTH = 975
VeritasAcademySkinMagazinePage.CLOSE_WIDTH = 221
VeritasAcademySkinMagazinePage.DURATION_PARAMETER = 2500

function VeritasAcademySkinMagazinePage:OnFirstFlush()
	self.super.OnFirstFlush(self)
	setText(self._tf:Find("AD/Text"), i18n("black5_bundle_desc"))
	setText(self._tf:Find("AD/btn/name"), i18n("black5_bundle_button"))
	onButton(self, self._tf:Find("AD/btn"), function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.SKINSHOP)
	end, SFX_PANEL)

	if not self.activity:GetConfigClientSetting("packageID") then
		return false
	end

	local var_1_0 = Goods.Create({
		shop_id = self.activity:GetConfigClientSetting("packageID")
	}, Goods.TYPE_GIFT_PACKAGE_ACT)

	SetActive(self._tf:Find("AD/btn/red"), var_1_0:isTip())
	SetActive(self._tf:Find("AD/btn"), var_1_0:getBuyCount() ~= 1)
	SetActive(self._tf:Find("AD/Text"), var_1_0:getBuyCount() ~= 1)
	SetActive(self._tf:Find("AD/Image"), var_1_0:getBuyCount() ~= 1)
end

return VeritasAcademySkinMagazinePage
