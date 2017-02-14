Buff_402_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_402_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_402_cast.info_pool[effectScript.ID].Attacker)
		Buff_402_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e402")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adff" )
	end,

	adff = function( effectScript )
			AttachBuffEffect( false, Buff_402_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 0.5, 100, "e402",  effectScript)
	end,

}
