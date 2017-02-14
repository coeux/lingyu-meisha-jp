Buff_401_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_401_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_401_cast.info_pool[effectScript.ID].Attacker)
		Buff_401_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e401")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ada" )
	end,

	ada = function( effectScript )
			AttachBuffEffect( false, Buff_401_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 0.5, 100, "e401",  effectScript)
	end,

}
