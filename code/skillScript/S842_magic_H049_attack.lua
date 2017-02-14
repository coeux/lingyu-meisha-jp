S842_magic_H049_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S842_magic_H049_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S842_magic_H049_attack.info_pool[effectScript.ID].Attacker)
        
		S842_magic_H049_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_04903")
		PreLoadSound("stalk_04901")
		PreLoadAvatar("H049_dd1")
		PreLoadAvatar("H049_dd2")
		PreLoadAvatar("H049_dd3")
		PreLoadSound("skill_04901")
		PreLoadAvatar("H049_dd4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ge4twerr" )
		effectScript:RegisterEvent( 8, "ghkrwrwe" )
		effectScript:RegisterEvent( 18, "fwefsef" )
		effectScript:RegisterEvent( 22, "frwfgehew" )
		effectScript:RegisterEvent( 24, "rghrthr" )
	end,

	ge4twerr = function( effectScript )
		SetAnimation(S842_magic_H049_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_04903")
		PlaySound("stalk_04901")
	end,

	ghkrwrwe = function( effectScript )
		AttachAvatarPosEffect(false, S842_magic_H049_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 80), 3, -100, "H049_dd1")
	end,

	fwefsef = function( effectScript )
		AttachAvatarPosEffect(false, S842_magic_H049_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(190, 1), 1, 100, "H049_dd2")
	end,

	frwfgehew = function( effectScript )
		AttachAvatarPosEffect(false, S842_magic_H049_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -20), 2, -100, "H049_dd3")
		PlaySound("skill_04901")
	end,

	rghrthr = function( effectScript )
			DamageEffect(S842_magic_H049_attack.info_pool[effectScript.ID].Attacker, S842_magic_H049_attack.info_pool[effectScript.ID].Targeter, S842_magic_H049_attack.info_pool[effectScript.ID].AttackType, S842_magic_H049_attack.info_pool[effectScript.ID].AttackDataList, S842_magic_H049_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	AttachAvatarPosEffect(false, S842_magic_H049_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -40), 3, 100, "H049_dd4")
	end,

}
