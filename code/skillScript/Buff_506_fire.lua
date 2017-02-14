Buff_506_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_506_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_506_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_506_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e506")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adasd" )
	end,

	adasd = function( effectScript )
			AttachBuffEffect( true, Buff_506_fire.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "e506",  effectScript)
	end,

}
