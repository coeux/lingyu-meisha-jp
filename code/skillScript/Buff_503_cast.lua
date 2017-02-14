Buff_503_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_503_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_503_cast.info_pool[effectScript.ID].Attacker)
		Buff_503_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e503")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "wd" )
	end,

	wd = function( effectScript )
			AttachBuffEffect( false, Buff_503_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1.2, 100, "e503",  effectScript)
	end,

}
