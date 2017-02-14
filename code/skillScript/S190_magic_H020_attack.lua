S190_magic_H020_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S190_magic_H020_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S190_magic_H020_attack.info_pool[effectScript.ID].Attacker)
        
		S190_magic_H020_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_02001")
		PreLoadSound("skill_02003")
		PreLoadAvatar("S190_fazhen")
		PreLoadAvatar("S190_shifa")
		PreLoadSound("skill_02003")
		PreLoadSound("skill_02004")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aaa" )
		effectScript:RegisterEvent( 10, "safsdg" )
		effectScript:RegisterEvent( 16, "asdas" )
		effectScript:RegisterEvent( 23, "dsfdh" )
		effectScript:RegisterEvent( 42, "dfdh" )
		effectScript:RegisterEvent( 45, "dsfdg" )
	end,

	aaa = function( effectScript )
		SetAnimation(S190_magic_H020_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_02001")
	end,

	safsdg = function( effectScript )
			PlaySound("skill_02003")
	end,

	asdas = function( effectScript )
		AttachAvatarPosEffect(false, S190_magic_H020_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 2.5, -100, "S190_fazhen")
	AttachAvatarPosEffect(false, S190_magic_H020_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(35, 80), 3, 100, "S190_shifa")
	end,

	dsfdh = function( effectScript )
			PlaySound("skill_02003")
	end,

	dfdh = function( effectScript )
			PlaySound("skill_02004")
	end,

	dsfdg = function( effectScript )
			DamageEffect(S190_magic_H020_attack.info_pool[effectScript.ID].Attacker, S190_magic_H020_attack.info_pool[effectScript.ID].Targeter, S190_magic_H020_attack.info_pool[effectScript.ID].AttackType, S190_magic_H020_attack.info_pool[effectScript.ID].AttackDataList, S190_magic_H020_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
