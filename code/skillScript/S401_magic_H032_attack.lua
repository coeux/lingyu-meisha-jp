S401_magic_H032_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S401_magic_H032_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S401_magic_H032_attack.info_pool[effectScript.ID].Attacker)
        
		S401_magic_H032_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03202")
		PreLoadSound("atalk_03201")
		PreLoadAvatar("S360_9")
		PreLoadSound("attack_03201")
		PreLoadAvatar("S360_3")
		PreLoadSound("attack_03201")
		PreLoadAvatar("S360_3")
		PreLoadSound("attack_03201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fcsg" )
		effectScript:RegisterEvent( 25, "fgdg" )
		effectScript:RegisterEvent( 33, "dfg" )
		effectScript:RegisterEvent( 39, "fhj" )
		effectScript:RegisterEvent( 40, "fgj" )
		effectScript:RegisterEvent( 47, "fh" )
		effectScript:RegisterEvent( 48, "gjj" )
	end,

	fcsg = function( effectScript )
		SetAnimation(S401_magic_H032_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_03202")
		PlaySound("atalk_03201")
	end,

	fgdg = function( effectScript )
		SetAnimation(S401_magic_H032_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfg = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_H032_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(420, -80), 1, 100, "S360_9")
		PlaySound("attack_03201")
	end,

	fhj = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_H032_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S360_3")
		PlaySound("attack_03201")
	end,

	fgj = function( effectScript )
		end,

	fh = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_H032_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S360_3")
		PlaySound("attack_03201")
	end,

	gjj = function( effectScript )
			DamageEffect(S401_magic_H032_attack.info_pool[effectScript.ID].Attacker, S401_magic_H032_attack.info_pool[effectScript.ID].Targeter, S401_magic_H032_attack.info_pool[effectScript.ID].AttackType, S401_magic_H032_attack.info_pool[effectScript.ID].AttackDataList, S401_magic_H032_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
