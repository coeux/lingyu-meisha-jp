S341_magic_H022_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S341_magic_H022_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S341_magic_H022_attack.info_pool[effectScript.ID].Attacker)
        
		S341_magic_H022_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0222")
		PreLoadAvatar("S340_fazhen")
		PreLoadAvatar("S340_shifa")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "af" )
		effectScript:RegisterEvent( 23, "asfd" )
		effectScript:RegisterEvent( 34, "das" )
		effectScript:RegisterEvent( 35, "ad" )
		effectScript:RegisterEvent( 60, "sfdsg" )
	end,

	af = function( effectScript )
		SetAnimation(S341_magic_H022_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s0222")
	end,

	asfd = function( effectScript )
		SetAnimation(S341_magic_H022_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	das = function( effectScript )
		AttachAvatarPosEffect(false, S341_magic_H022_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 2, -100, "S340_fazhen")
	end,

	ad = function( effectScript )
		AttachAvatarPosEffect(false, S341_magic_H022_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(25, 125), 1.2, -100, "S340_shifa")
	end,

	sfdsg = function( effectScript )
			DamageEffect(S341_magic_H022_attack.info_pool[effectScript.ID].Attacker, S341_magic_H022_attack.info_pool[effectScript.ID].Targeter, S341_magic_H022_attack.info_pool[effectScript.ID].AttackType, S341_magic_H022_attack.info_pool[effectScript.ID].AttackDataList, S341_magic_H022_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
