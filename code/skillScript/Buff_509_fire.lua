Buff_509_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_509_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_509_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_509_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e509")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ad" )
	end,

	ad = function( effectScript )
			AttachBuffEffect( true, Buff_509_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, -100, "e509",  effectScript)
	end,

}
