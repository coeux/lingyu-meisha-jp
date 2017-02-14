Buff_504_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_504_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_504_cast.info_pool[effectScript.ID].Attacker)
		Buff_504_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e504")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aD" )
	end,

	aD = function( effectScript )
			AttachBuffEffect( false, Buff_504_cast.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "e504",  effectScript)
	end,

}
