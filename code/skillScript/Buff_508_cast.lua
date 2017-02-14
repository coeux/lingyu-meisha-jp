Buff_508_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_508_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_508_cast.info_pool[effectScript.ID].Attacker)
		Buff_508_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e508_1")
		PreLoadAvatar("e508_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ad" )
	end,

	ad = function( effectScript )
			AttachBuffEffect( false, Buff_508_cast.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, -100, "e508_1",  effectScript)
		AttachBuffEffect( false, Buff_508_cast.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "e508_2",  effectScript)
	end,

}
