S852_magic_H050_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S852_magic_H050_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S852_magic_H050_attack.info_pool[effectScript.ID].Attacker)
        
		S852_magic_H050_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05001")
		PreLoadAvatar("H050_4_1")
		PreLoadSound("skill_05002")
		PreLoadAvatar("H050_4_2")
		PreLoadSound("skill_05003")
		PreLoadAvatar("H050_4_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddc" )
		effectScript:RegisterEvent( 17, "drf" )
		effectScript:RegisterEvent( 35, "cfgtryg" )
		effectScript:RegisterEvent( 38, "xds" )
		effectScript:RegisterEvent( 41, "bbs" )
	end,

	ddc = function( effectScript )
		SetAnimation(S852_magic_H050_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_05001")
	end,

	drf = function( effectScript )
		AttachAvatarPosEffect(false, S852_magic_H050_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(155, 220), 1.3, 100, "H050_4_1")
		PlaySound("skill_05002")
	end,

	cfgtryg = function( effectScript )
		AttachAvatarPosEffect(false, S852_magic_H050_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 170), 1.5, 100, "H050_4_2")
		PlaySound("skill_05003")
	end,

	xds = function( effectScript )
		AttachAvatarPosEffect(false, S852_magic_H050_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(85, 185), 1.5, 100, "H050_4_3")
	end,

	bbs = function( effectScript )
			DamageEffect(S852_magic_H050_attack.info_pool[effectScript.ID].Attacker, S852_magic_H050_attack.info_pool[effectScript.ID].Targeter, S852_magic_H050_attack.info_pool[effectScript.ID].AttackType, S852_magic_H050_attack.info_pool[effectScript.ID].AttackDataList, S852_magic_H050_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
