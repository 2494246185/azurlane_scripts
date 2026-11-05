local EighthHotSpringScene = class("EighthHotSpringScene", import("view.activity.BackHills.NewYearFestival.NewYearHotSpringScene"))

function EighthHotSpringScene:getUIName()
	return "EighthHotSpringUI"
end

function EighthHotSpringScene:init()
	EighthHotSpringScene.super.init(self)
end

function EighthHotSpringScene:didEnter()
	EighthHotSpringScene.super.didEnter(self)
	onButton(self, self._tf:Find("Top/Help"), function()
		MsgboxMediator.ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.eighth_tip_spring.tip,
			contextSprites = {
				{
					path = "props/eighthwenquanshoupai",
					name = "eighthwenquanshoupai"
				}
			}
		})
	end, SFX_PANEL)
	setImageSprite(self.top:Find("Ticket/Icon"), LoadSprite("props/eighthwenquanshoupai", "eighthwenquanshoupai"))
end

function EighthHotSpringScene:willExit()
	EighthHotSpringScene.super.willExit(self)
end

return EighthHotSpringScene
