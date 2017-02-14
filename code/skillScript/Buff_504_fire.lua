Buff_504_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_504_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_504_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_504_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e504")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adsf" )
	end,

	adsf = function( effectScript )
			AttachBuffEffect( true, Buff_504_fire.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "e504",  effectScript)
	end,

}
