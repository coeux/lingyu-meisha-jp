Buff_520_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_520_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_520_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_520_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e520")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdg" )
	end,

	sfdg = function( effectScript )
			AttachBuffEffect( true, Buff_520_fire.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "e520",  effectScript)
	end,

}
