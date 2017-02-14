Buff_518_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_518_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_518_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_518_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e518_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsf" )
	end,

	dsf = function( effectScript )
			AttachBuffEffect( true, Buff_518_fire.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "e518_2",  effectScript)
	end,

}
