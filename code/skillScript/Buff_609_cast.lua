Buff_609_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_609_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_609_cast.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S609")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "W" )
	end,

	W = function( effectScript )
		AttachBuffEffect( false, Buff_609_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "S609",  effectScript)
	end,

}
