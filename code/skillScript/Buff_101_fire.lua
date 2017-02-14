Buff_101_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_101_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_101_fire.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S101_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
	end,

	s = function( effectScript )
		AttachBuffEffect( true, Buff_101_fire.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "S101_3",  effectScript)
	end,

}
