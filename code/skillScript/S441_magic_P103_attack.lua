S441_magic_P103_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S441_magic_P103_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S441_magic_P103_attack.info_pool[effectScript.ID].Attacker)
        
		S441_magic_P103_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S440_1")
		PreLoadAvatar("S440_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgf" )
		effectScript:RegisterEvent( 46, "sfdg" )
		effectScript:RegisterEvent( 51, "dgfdgh" )
		effectScript:RegisterEvent( 64, "sdfdg" )
		effectScript:RegisterEvent( 86, "dgh" )
	end,

	dsgf = function( effectScript )
		SetAnimation(S441_magic_P103_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sfdg = function( effectScript )
		SetAnimation(S441_magic_P103_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dgfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S441_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -20), 1.1, 100, "S440_1")
	end,

	sdfdg = function( effectScript )
		AttachAvatarPosEffect(false, S441_magic_P103_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S440_2")
	end,

	dgh = function( effectScript )
			DamageEffect(S441_magic_P103_attack.info_pool[effectScript.ID].Attacker, S441_magic_P103_attack.info_pool[effectScript.ID].Targeter, S441_magic_P103_attack.info_pool[effectScript.ID].AttackType, S441_magic_P103_attack.info_pool[effectScript.ID].AttackDataList, S441_magic_P103_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
