Buff_502_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_502_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_502_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_502_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e502")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asdff" )
	end,

	asdff = function( effectScript )
			AttachBuffEffect( true, Buff_502_fire.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "e502",  effectScript)
	end,

}
