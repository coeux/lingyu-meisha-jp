S91_magic_H012_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S91_magic_H012_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S91_magic_H012_attack.info_pool[effectScript.ID].Attacker)
        
		S91_magic_H012_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01201")
		PreLoadAvatar("S352_4")
		PreLoadSound("skill_01201")
		PreLoadAvatar("S352_3")
		PreLoadAvatar("S352_1")
		PreLoadSound("skill_01202")
		PreLoadAvatar("S352_2")
		PreLoadSound("skill_01203")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfdgdh" )
		effectScript:RegisterEvent( 1, "dsgdfhh" )
		effectScript:RegisterEvent( 18, "fdgfhj" )
		effectScript:RegisterEvent( 22, "dsgdfh" )
		effectScript:RegisterEvent( 24, "fdgfj" )
		effectScript:RegisterEvent( 27, "dsgfdhj" )
		effectScript:RegisterEvent( 31, "gfjk" )
		effectScript:RegisterEvent( 34, "gfhk" )
	end,

	dgfdgdh = function( effectScript )
		SetAnimation(S91_magic_H012_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01201")
	end,

	dsgdfhh = function( effectScript )
		AttachAvatarPosEffect(false, S91_magic_H012_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S352_4")
		PlaySound("skill_01201")
	end,

	fdgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S91_magic_H012_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S352_3")
	end,

	dsgdfh = function( effectScript )
		AttachAvatarPosEffect(false, S91_magic_H012_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S352_1")
		PlaySound("skill_01202")
	end,

	fdgfj = function( effectScript )
		AttachAvatarPosEffect(false, S91_magic_H012_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S352_2")
		PlaySound("skill_01203")
	end,

	dsgfdhj = function( effectScript )
			DamageEffect(S91_magic_H012_attack.info_pool[effectScript.ID].Attacker, S91_magic_H012_attack.info_pool[effectScript.ID].Targeter, S91_magic_H012_attack.info_pool[effectScript.ID].AttackType, S91_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S91_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gfjk = function( effectScript )
			DamageEffect(S91_magic_H012_attack.info_pool[effectScript.ID].Attacker, S91_magic_H012_attack.info_pool[effectScript.ID].Targeter, S91_magic_H012_attack.info_pool[effectScript.ID].AttackType, S91_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S91_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gfhk = function( effectScript )
			DamageEffect(S91_magic_H012_attack.info_pool[effectScript.ID].Attacker, S91_magic_H012_attack.info_pool[effectScript.ID].Targeter, S91_magic_H012_attack.info_pool[effectScript.ID].AttackType, S91_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S91_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
