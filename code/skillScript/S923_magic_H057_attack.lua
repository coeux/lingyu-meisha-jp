S923_magic_H057_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S923_magic_H057_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S923_magic_H057_attack.info_pool[effectScript.ID].Attacker)
        
		S923_magic_H057_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05701")
		PreLoadSound("skill_05702")
		PreLoadAvatar("H057_4_2")
		PreLoadAvatar("H057_4_1")
		PreLoadSound("skill_05701")
		PreLoadAvatar("H057_4_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfr" )
		effectScript:RegisterEvent( 36, "hjk" )
		effectScript:RegisterEvent( 37, "huiu" )
		effectScript:RegisterEvent( 40, "yui" )
	end,

	dfr = function( effectScript )
		SetAnimation(S923_magic_H057_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_05701")
		PlaySound("skill_05702")
	end,

	hjk = function( effectScript )
		AttachAvatarPosEffect(false, S923_magic_H057_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(240, 0), 1, 100, "H057_4_2")
	AttachAvatarPosEffect(false, S923_magic_H057_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, -10), 1, 100, "H057_4_1")
		PlaySound("skill_05701")
	end,

	huiu = function( effectScript )
		AttachAvatarPosEffect(false, S923_magic_H057_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.15, 100, "H057_4_3")
	end,

	yui = function( effectScript )
			DamageEffect(S923_magic_H057_attack.info_pool[effectScript.ID].Attacker, S923_magic_H057_attack.info_pool[effectScript.ID].Targeter, S923_magic_H057_attack.info_pool[effectScript.ID].AttackType, S923_magic_H057_attack.info_pool[effectScript.ID].AttackDataList, S923_magic_H057_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
