S873_magic_H052_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S873_magic_H052_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S873_magic_H052_attack.info_pool[effectScript.ID].Attacker)
        
		S873_magic_H052_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05201")
		PreLoadAvatar("H052_4_1")
		PreLoadSound("skill_05203")
		PreLoadAvatar("H052_4_1")
		PreLoadAvatar("H052_4_2")
		PreLoadAvatar("H052_4_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fvgb" )
		effectScript:RegisterEvent( 13, "humk" )
		effectScript:RegisterEvent( 15, "vgbh" )
		effectScript:RegisterEvent( 16, "vgb" )
		effectScript:RegisterEvent( 18, "zsdrft" )
	end,

	fvgb = function( effectScript )
		SetAnimation(S873_magic_H052_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_05201")
	end,

	humk = function( effectScript )
		AttachAvatarPosEffect(false, S873_magic_H052_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(90, 130), 1, 100, "H052_4_1")
		PlaySound("skill_05203")
	end,

	vgbh = function( effectScript )
		AttachAvatarPosEffect(false, S873_magic_H052_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(70, 120), 0.7, 100, "H052_4_1")
	end,

	vgb = function( effectScript )
		AttachAvatarPosEffect(false, S873_magic_H052_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -30), 1.3, 100, "H052_4_2")
	AttachAvatarPosEffect(false, S873_magic_H052_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.3, -100, "H052_4_3")
	end,

	zsdrft = function( effectScript )
			DamageEffect(S873_magic_H052_attack.info_pool[effectScript.ID].Attacker, S873_magic_H052_attack.info_pool[effectScript.ID].Targeter, S873_magic_H052_attack.info_pool[effectScript.ID].AttackType, S873_magic_H052_attack.info_pool[effectScript.ID].AttackDataList, S873_magic_H052_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
