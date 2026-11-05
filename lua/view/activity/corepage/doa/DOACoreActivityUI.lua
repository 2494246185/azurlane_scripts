local DOACoreActivityUI = class("DOACoreActivityUI", import("view.activity.CorePage.MoscowUR.MoscowURCoreActivityUI"))

function DOACoreActivityUI:getUIName()
	return "DOACoreActivityUI"
end

function DOACoreActivityUI:loadingQueue()
	local var_2_0 = "play_jiarihangxianshanyaohaibin" .. getProxy(PlayerProxy):getPlayerId()

	if PlayerPrefs.GetInt(var_2_0, 0) == 1 then
		return nil
	else
		return function(arg_3_0)
			pg.SceneAnimMgr.GetInstance():CommonSceneChange("jiarihangxianshanyaohaibin", function(arg_4_0)
				return arg_3_0(function()
					PlayerPrefs.SetInt(var_2_0, 1)
					existCall(arg_4_0)
				end)
			end)
		end
	end
end

function DOACoreActivityUI:OnAnimations(arg_6_1, arg_6_2)
	SetActive(self._tf:Find("adapt/logo2"), arg_6_2.id == 6032 or arg_6_2.id == 6028)
	SetActive(self._tf:Find("adapt/logo"), arg_6_2.id ~= 6032 and arg_6_2.id ~= 6028)
	SetActive(self._tf:Find("left_bg"), arg_6_2.id == 6025)
	SetActive(self._tf:Find("decorate"), arg_6_2.id == 6025)
end

function DOACoreActivityUI:OnToggleName(arg_7_1, arg_7_2)
	return
end

return DOACoreActivityUI
