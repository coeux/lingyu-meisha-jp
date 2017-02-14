Buff_312_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_312_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_312_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_312_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e312")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsf" )
	end,

	dsf = function( effectScript )
			AttachBuffEffect( false, Buff_312_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e312",  effectScript)
	end,

}
