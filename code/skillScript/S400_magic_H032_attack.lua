S400_magic_H032_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S400_magic_H032_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S400_magic_H032_attack.info_pool[effectScript.ID].Attacker)
        
		S400_magic_H032_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03201")
		PreLoadSound("stalk_03201")
		PreLoadAvatar("S360_9")
		PreLoadSound("attack_03201")
		PreLoadAvatar("S360_3")
		PreLoadSound("attack_03201")
		PreLoadAvatar("S360_3")
		PreLoadSound("attack_03201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fcsg" )
		effectScript:RegisterEvent( 45, "fgdg" )
		effectScript:RegisterEvent( 53, "dfg" )
		effectScript:RegisterEvent( 59, "fhj" )
		effectScript:RegisterEvent( 60, "fgj" )
		effectScript:RegisterEvent( 67, "fh" )
		effectScript:RegisterEvent( 68, "gjj" )
	end,

	fcsg = function( effectScript )
		SetAnimation(S400_magic_H032_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_03201")
		PlaySound("stalk_03201")
	end,

	fgdg = function( effectScript )
		SetAnimation(S400_magic_H032_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfg = function( effectScript )
		AttachAvatarPosEffect(false, S400_magic_H032_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(420, -80), 1, 100, "S360_9")
		PlaySound("attack_03201")
	end,

	fhj = function( effectScript )
		AttachAvatarPosEffect(false, S400_magic_H032_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S360_3")
		PlaySound("attack_03201")
	end,

	fgj = function( effectScript )
		end,

	fh = function( effectScript )
		AttachAvatarPosEffect(false, S400_magic_H032_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S360_3")
		PlaySound("attack_03201")
	end,

	gjj = function( effectScript )
			DamageEffect(S400_magic_H032_attack.info_pool[effectScript.ID].Attacker, S400_magic_H032_attack.info_pool[effectScript.ID].Targeter, S400_magic_H032_attack.info_pool[effectScript.ID].AttackType, S400_magic_H032_attack.info_pool[effectScript.ID].AttackDataList, S400_magic_H032_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
