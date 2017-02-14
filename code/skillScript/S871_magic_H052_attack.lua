S871_magic_H052_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S871_magic_H052_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S871_magic_H052_attack.info_pool[effectScript.ID].Attacker)
        
		S871_magic_H052_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05201")
		PreLoadAvatar("H050_1_1")
		PreLoadSound("skill_05202")
		PreLoadAvatar("H052_3_2")
		PreLoadAvatar("H052_3_1")
		PreLoadSound("skill_05201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "rtgyh" )
		effectScript:RegisterEvent( 11, "gfh" )
		effectScript:RegisterEvent( 40, "atgyh" )
		effectScript:RegisterEvent( 58, "drftgy" )
		effectScript:RegisterEvent( 60, "dfbg" )
	end,

	rtgyh = function( effectScript )
		SetAnimation(S871_magic_H052_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_05201")
	end,

	gfh = function( effectScript )
		AttachAvatarPosEffect(false, S871_magic_H052_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 50), 0.7, 100, "H050_1_1")
		PlaySound("skill_05202")
	end,

	atgyh = function( effectScript )
		SetAnimation(S871_magic_H052_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	drftgy = function( effectScript )
		AttachAvatarPosEffect(false, S871_magic_H052_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(55, 13), 0.9, 100, "H052_3_2")
	AttachAvatarPosEffect(false, S871_magic_H052_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H052_3_1")
		PlaySound("skill_05201")
	end,

	dfbg = function( effectScript )
			DamageEffect(S871_magic_H052_attack.info_pool[effectScript.ID].Attacker, S871_magic_H052_attack.info_pool[effectScript.ID].Targeter, S871_magic_H052_attack.info_pool[effectScript.ID].AttackType, S871_magic_H052_attack.info_pool[effectScript.ID].AttackDataList, S871_magic_H052_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
