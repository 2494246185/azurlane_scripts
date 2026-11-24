local MainTipActivityRemasterSequence = class("MainTipActivityRemasterSequence")

MainTipActivityRemasterSequence.isTip = false

function MainTipActivityRemasterSequence:Execute(arg_1_1)
	if MainTipActivityRemasterSequence.isTip then
		arg_1_1()

		return
	end

	if not getProxy(ActivityRemasterProxy):ShouldShowActiveBtn() then
		arg_1_1()

		return
	end

	self:ShowTips(arg_1_1)
end

function MainTipActivityRemasterSequence:ShowTips(arg_2_1)
	MainTipActivityRemasterSequence.isTip = true

	pg.m02:sendNotification(GAME.GO_SCENE, SCENE.ACTREMASTE)
end

return MainTipActivityRemasterSequence
