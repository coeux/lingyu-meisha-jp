Buff_605_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_605_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_605_cast.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S605")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "S" )
	end,

	S = function( effectScript )
		AttachBuffEffect( false, Buff_605_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "S605",  effectScript)
	end,

}
