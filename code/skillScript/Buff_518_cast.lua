Buff_518_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_518_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_518_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_518_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e518_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdh" )
	end,

	sfdh = function( effectScript )
			AttachBuffEffect( false, Buff_518_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "e518_1",  effectScript)
	end,

}
