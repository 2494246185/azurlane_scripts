local TianYuTianYuanMedalAlbumView = class("TianYuTianYuanMedalAlbumView", import(".MedalAlbumTemplateView"))

TianYuTianYuanMedalAlbumView.GROUP_ID = 50136
TianYuTianYuanMedalAlbumView.MEDAL_COUNT = 8
TianYuTianYuanMedalAlbumView.ICON_SCALE = 1

function TianYuTianYuanMedalAlbumView:getUIName()
	return "MedalAlbumTianYuTianYuanPage"
end

function TianYuTianYuanMedalAlbumView:didEnter()
	TianYuTianYuanMedalAlbumView.super.didEnter(self)
end

return TianYuTianYuanMedalAlbumView
