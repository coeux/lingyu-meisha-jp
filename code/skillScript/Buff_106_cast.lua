Buff_106_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_106_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_106_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_106_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e106")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsf" )
	end,

	dsf = function( effectScript )
			AttachBuffEffect( false, Buff_106_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e106",  effectScript)
	end,

}
