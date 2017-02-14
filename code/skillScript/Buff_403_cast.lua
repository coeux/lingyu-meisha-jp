Buff_403_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_403_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_403_cast.info_pool[effectScript.ID].Attacker)
		Buff_403_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e403")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "awf" )
	end,

	awf = function( effectScript )
			AttachBuffEffect( false, Buff_403_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 0.5, 100, "e403",  effectScript)
	end,

}
