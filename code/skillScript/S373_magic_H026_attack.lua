S373_magic_H026_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S373_magic_H026_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S373_magic_H026_attack.info_pool[effectScript.ID].Attacker)
        
		S373_magic_H026_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S372_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddfgfh" )
		effectScript:RegisterEvent( 25, "safsdgh" )
		effectScript:RegisterEvent( 27, "gjghk" )
	end,

	ddfgfh = function( effectScript )
		SetAnimation(S373_magic_H026_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	safsdgh = function( effectScript )
		AttachAvatarPosEffect(false, S373_magic_H026_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S372_1")
	end,

	gjghk = function( effectScript )
			DamageEffect(S373_magic_H026_attack.info_pool[effectScript.ID].Attacker, S373_magic_H026_attack.info_pool[effectScript.ID].Targeter, S373_magic_H026_attack.info_pool[effectScript.ID].AttackType, S373_magic_H026_attack.info_pool[effectScript.ID].AttackDataList, S373_magic_H026_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
