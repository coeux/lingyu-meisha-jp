H008_auto233_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H008_auto233_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H008_auto233_attack.info_pool[effectScript.ID].Attacker)
        
		H008_auto233_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S234_3")
		PreLoadAvatar("S234_2")
		PreLoadAvatar("S234_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asdaf" )
		effectScript:RegisterEvent( 19, "adffsf" )
		effectScript:RegisterEvent( 22, "dgrgd" )
		effectScript:RegisterEvent( 25, "asfsd" )
		effectScript:RegisterEvent( 26, "adfsfdsg" )
	end,

	asdaf = function( effectScript )
		SetAnimation(H008_auto233_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	adffsf = function( effectScript )
		AttachAvatarPosEffect(false, H008_auto233_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S234_3")
	end,

	dgrgd = function( effectScript )
		AttachAvatarPosEffect(false, H008_auto233_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 70), 1.2, 100, "S234_2")
	end,

	asfsd = function( effectScript )
		AttachAvatarPosEffect(false, H008_auto233_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2.3, 100, "S234_1")
	end,

	adfsfdsg = function( effectScript )
			DamageEffect(H008_auto233_attack.info_pool[effectScript.ID].Attacker, H008_auto233_attack.info_pool[effectScript.ID].Targeter, H008_auto233_attack.info_pool[effectScript.ID].AttackType, H008_auto233_attack.info_pool[effectScript.ID].AttackDataList, H008_auto233_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
