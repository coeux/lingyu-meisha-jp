Buff_507_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_507_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_507_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_507_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e507")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sad" )
	end,

	sad = function( effectScript )
			AttachBuffEffect( true, Buff_507_fire.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 0.7, 100, "e507",  effectScript)
	end,

}
