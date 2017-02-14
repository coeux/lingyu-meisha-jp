S461_magic_H029_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S461_magic_H029_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S461_magic_H029_attack.info_pool[effectScript.ID].Attacker)
        
		S461_magic_H029_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 33, "safdh" )
		effectScript:RegisterEvent( 70, "dgfhj" )
		effectScript:RegisterEvent( 71, "dgfh" )
		effectScript:RegisterEvent( 74, "sdfdsg" )
		effectScript:RegisterEvent( 77, "pkpook" )
	end,

	dgdfh = function( effectScript )
		SetAnimation(S461_magic_H029_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s0292")
	end,

	fdgdh = function( effectScript )
		end,

	safdh = function( effectScript )
		SetAnimation(S461_magic_H029_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S461_magic_H029_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 2, 100, "S192_3")
	end,

	dgfh = function( effectScript )
		AttachAvatarPosEffect(false, S461_magic_H029_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -20), 1.2, 100, "H029_shifa_2")
	end,

	sdfdsg = function( effectScript )
		AttachAvatarPosEffect(false, S461_magic_H029_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "H029_shouji_2")
	end,

	pkpook = function( effectScript )
			DamageEffect(S461_magic_H029_attack.info_pool[effectScript.ID].Attacker, S461_magic_H029_attack.info_pool[effectScript.ID].Targeter, S461_magic_H029_attack.info_pool[effectScript.ID].AttackType, S461_magic_H029_attack.info_pool[effectScript.ID].AttackDataList, S461_magic_H029_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
