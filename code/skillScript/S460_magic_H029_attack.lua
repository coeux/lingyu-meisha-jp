S460_magic_H029_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S460_magic_H029_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S460_magic_H029_attack.info_pool[effectScript.ID].Attacker)
        
		S460_magic_H029_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0292")
		PreLoadAvatar("S192_3")
		PreLoadAvatar("H029_shifa_2")
		PreLoadAvatar("H029_shouji_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgdfh" )
		effectScript:RegisterEvent( 6, "fdgdh" )
		effectScript:RegisterEvent( 45, "safdh" )
		effectScript:RegisterEvent( 81, "ghfjhgj" )
		effectScript:RegisterEvent( 82, "dgfh" )
		effectScript:RegisterEvent( 85, "sdfdsg" )
		effectScript:RegisterEvent( 90, "pkpook" )
	end,

	dgdfh = function( effectScript )
		SetAnimation(S460_magic_H029_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s0292")
	end,

	fdgdh = function( effectScript )
		end,

	safdh = function( effectScript )
		SetAnimation(S460_magic_H029_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ghfjhgj = function( effectScript )
		AttachAvatarPosEffect(false, S460_magic_H029_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 2, 100, "S192_3")
	end,

	dgfh = function( effectScript )
		AttachAvatarPosEffect(false, S460_magic_H029_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -20), 1.2, 100, "H029_shifa_2")
	end,

	sdfdsg = function( effectScript )
		AttachAvatarPosEffect(false, S460_magic_H029_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "H029_shouji_2")
	end,

	pkpook = function( effectScript )
			DamageEffect(S460_magic_H029_attack.info_pool[effectScript.ID].Attacker, S460_magic_H029_attack.info_pool[effectScript.ID].Targeter, S460_magic_H029_attack.info_pool[effectScript.ID].AttackType, S460_magic_H029_attack.info_pool[effectScript.ID].AttackDataList, S460_magic_H029_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
