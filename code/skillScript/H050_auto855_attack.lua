H050_auto855_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H050_auto855_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H050_auto855_attack.info_pool[effectScript.ID].Attacker)
        
		H050_auto855_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05001")
		PreLoadAvatar("H050_3_1")
		PreLoadAvatar("H050_3_2")
		PreLoadAvatar("H050_3_2")
		PreLoadSound("skill_05001")
		PreLoadAvatar("H050_3_3")
		PreLoadAvatar("H050_3_3")
		PreLoadAvatar("H050_3_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "H050_1" )
		effectScript:RegisterEvent( 13, "adsa" )
		effectScript:RegisterEvent( 14, "dadc" )
		effectScript:RegisterEvent( 16, "adf" )
		effectScript:RegisterEvent( 19, "sgb" )
	end,

	H050_1 = function( effectScript )
		SetAnimation(H050_auto855_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_05001")
	end,

	adsa = function( effectScript )
		AttachAvatarPosEffect(false, H050_auto855_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 70), 1.5, 100, "H050_3_1")
	AttachAvatarPosEffect(false, H050_auto855_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(215, 50), 1.9, 100, "H050_3_2")
	AttachAvatarPosEffect(false, H050_auto855_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(230, 60), 1.9, -100, "H050_3_2")
		PlaySound("skill_05001")
	end,

	dadc = function( effectScript )
		AttachAvatarPosEffect(false, H050_auto855_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(50, 105), 0.95, 100, "H050_3_3")
	AttachAvatarPosEffect(false, H050_auto855_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(35, 30), 1.2, 100, "H050_3_3")
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, H050_auto855_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-10, 80), 1.5, 100, "H050_3_3")
	end,

	sgb = function( effectScript )
			DamageEffect(H050_auto855_attack.info_pool[effectScript.ID].Attacker, H050_auto855_attack.info_pool[effectScript.ID].Targeter, H050_auto855_attack.info_pool[effectScript.ID].AttackType, H050_auto855_attack.info_pool[effectScript.ID].AttackDataList, H050_auto855_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
