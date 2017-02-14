S750_magic_H040_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S750_magic_H040_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S750_magic_H040_attack.info_pool[effectScript.ID].Attacker)
        
		S750_magic_H040_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S647_2")
		PreLoadAvatar("S362_2")
		PreLoadAvatar("H040_xuli_1")
		PreLoadSound("skill_04004")
		PreLoadAvatar("S750_1")
		PreLoadSound("skill_04003")
		PreLoadAvatar("S750_2")
		PreLoadAvatar("S750_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfhj" )
		effectScript:RegisterEvent( 14, "dgdhjj" )
		effectScript:RegisterEvent( 42, "fdgfdhj" )
		effectScript:RegisterEvent( 58, "gfdgfj" )
		effectScript:RegisterEvent( 60, "dsfhjh" )
		effectScript:RegisterEvent( 61, "dfdgh" )
		effectScript:RegisterEvent( 65, "efrdg" )
	end,

	dgfhj = function( effectScript )
		SetAnimation(S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dgdhjj = function( effectScript )
		AttachAvatarPosEffect(false, S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 30), 1, 100, "S647_2")
	AttachAvatarPosEffect(false, S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S362_2")
	AttachAvatarPosEffect(false, S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-25, 250), 1, 100, "H040_xuli_1")
		PlaySound("skill_04004")
	end,

	fdgfdhj = function( effectScript )
		SetAnimation(S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	gfdgfj = function( effectScript )
		AttachAvatarPosEffect(false, S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 0), 1.2, 100, "S750_1")
		PlaySound("skill_04003")
	end,

	dsfhjh = function( effectScript )
		AttachAvatarPosEffect(false, S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 0), 1, 100, "S750_2")
	end,

	dfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 10), 1, -100, "S750_4")
	end,

	efrdg = function( effectScript )
			DamageEffect(S750_magic_H040_attack.info_pool[effectScript.ID].Attacker, S750_magic_H040_attack.info_pool[effectScript.ID].Targeter, S750_magic_H040_attack.info_pool[effectScript.ID].AttackType, S750_magic_H040_attack.info_pool[effectScript.ID].AttackDataList, S750_magic_H040_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
