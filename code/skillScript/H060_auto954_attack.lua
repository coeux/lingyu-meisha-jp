H060_auto954_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H060_auto954_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H060_auto954_attack.info_pool[effectScript.ID].Attacker)
        
		H060_auto954_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_06003")
		PreLoadSound("atalk_06001")
		PreLoadAvatar("H060_3_1")
		PreLoadAvatar("H060_3_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "jszf" )
		effectScript:RegisterEvent( 17, "fvr" )
		effectScript:RegisterEvent( 19, "hb" )
		effectScript:RegisterEvent( 21, "io" )
	end,

	jszf = function( effectScript )
		SetAnimation(H060_auto954_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("skill_06003")
		PlaySound("atalk_06001")
	end,

	fvr = function( effectScript )
		AttachAvatarPosEffect(false, H060_auto954_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 80), 1.3, 100, "H060_3_1")
	end,

	hb = function( effectScript )
		AttachAvatarPosEffect(false, H060_auto954_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 60), 1.5, 100, "H060_3_2")
	end,

	io = function( effectScript )
			DamageEffect(H060_auto954_attack.info_pool[effectScript.ID].Attacker, H060_auto954_attack.info_pool[effectScript.ID].Targeter, H060_auto954_attack.info_pool[effectScript.ID].AttackType, H060_auto954_attack.info_pool[effectScript.ID].AttackDataList, H060_auto954_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
