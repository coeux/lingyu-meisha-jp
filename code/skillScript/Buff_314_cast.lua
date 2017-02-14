Buff_314_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_314_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_314_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_314_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e314")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sadf" )
	end,

	sadf = function( effectScript )
			AttachBuffEffect( false, Buff_314_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e314",  effectScript)
	end,

}
