H011_auto92_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H011_auto92_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H011_auto92_attack.info_pool[effectScript.ID].Attacker)
        
		H011_auto92_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01101")
		PreLoadSound("skill_01101")
		PreLoadAvatar("S250_1")
		PreLoadAvatar("S250_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 19, "jhgk" )
		effectScript:RegisterEvent( 20, "s" )
		effectScript:RegisterEvent( 25, "adad" )
		effectScript:RegisterEvent( 26, "sadwd" )
		effectScript:RegisterEvent( 29, "h" )
		effectScript:RegisterEvent( 32, "gdhjhk" )
		effectScript:RegisterEvent( 34, "tghjgk" )
		effectScript:RegisterEvent( 37, "jhkl" )
	end,

	d = function( effectScript )
		SetAnimation(H011_auto92_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_01101")
	end,

	jhgk = function( effectScript )
			PlaySound("skill_01101")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, H011_auto92_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 85), 2, 100, "S250_1")
	end,

	adad = function( effectScript )
		AttachAvatarPosEffect(false, H011_auto92_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.2, 100, "S250_2")
	end,

	sadwd = function( effectScript )
			DamageEffect(H011_auto92_attack.info_pool[effectScript.ID].Attacker, H011_auto92_attack.info_pool[effectScript.ID].Targeter, H011_auto92_attack.info_pool[effectScript.ID].AttackType, H011_auto92_attack.info_pool[effectScript.ID].AttackDataList, H011_auto92_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	h = function( effectScript )
			DamageEffect(H011_auto92_attack.info_pool[effectScript.ID].Attacker, H011_auto92_attack.info_pool[effectScript.ID].Targeter, H011_auto92_attack.info_pool[effectScript.ID].AttackType, H011_auto92_attack.info_pool[effectScript.ID].AttackDataList, H011_auto92_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gdhjhk = function( effectScript )
			DamageEffect(H011_auto92_attack.info_pool[effectScript.ID].Attacker, H011_auto92_attack.info_pool[effectScript.ID].Targeter, H011_auto92_attack.info_pool[effectScript.ID].AttackType, H011_auto92_attack.info_pool[effectScript.ID].AttackDataList, H011_auto92_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	tghjgk = function( effectScript )
			DamageEffect(H011_auto92_attack.info_pool[effectScript.ID].Attacker, H011_auto92_attack.info_pool[effectScript.ID].Targeter, H011_auto92_attack.info_pool[effectScript.ID].AttackType, H011_auto92_attack.info_pool[effectScript.ID].AttackDataList, H011_auto92_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	jhkl = function( effectScript )
			DamageEffect(H011_auto92_attack.info_pool[effectScript.ID].Attacker, H011_auto92_attack.info_pool[effectScript.ID].Targeter, H011_auto92_attack.info_pool[effectScript.ID].AttackType, H011_auto92_attack.info_pool[effectScript.ID].AttackDataList, H011_auto92_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
