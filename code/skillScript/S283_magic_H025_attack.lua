S283_magic_H025_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S283_magic_H025_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S283_magic_H025_attack.info_pool[effectScript.ID].Attacker)
        
		S283_magic_H025_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S402_1")
		PreLoadAvatar("S402_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfbgfh" )
		effectScript:RegisterEvent( 28, "fdgfh" )
		effectScript:RegisterEvent( 45, "gbfhgj" )
		effectScript:RegisterEvent( 47, "sgfdh" )
	end,

	dfbgfh = function( effectScript )
		SetAnimation(S283_magic_H025_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S283_magic_H025_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S402_1")
	end,

	gbfhgj = function( effectScript )
		AttachAvatarPosEffect(false, S283_magic_H025_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S402_2")
	end,

	sgfdh = function( effectScript )
			DamageEffect(S283_magic_H025_attack.info_pool[effectScript.ID].Attacker, S283_magic_H025_attack.info_pool[effectScript.ID].Targeter, S283_magic_H025_attack.info_pool[effectScript.ID].AttackType, S283_magic_H025_attack.info_pool[effectScript.ID].AttackDataList, S283_magic_H025_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
