H042_auto775_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H042_auto775_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H042_auto775_attack.info_pool[effectScript.ID].Attacker)
        
		H042_auto775_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H042_xuli_1")
		PreLoadAvatar("H042_xuli_2")
		PreLoadAvatar("H042_xuli_3")
		PreLoadSound("skill_04202")
		PreLoadAvatar("S774_1")
		PreLoadAvatar("H042_xuli_2")
		PreLoadAvatar("S362_2")
		PreLoadSound("skill_04203")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdgh" )
		effectScript:RegisterEvent( 6, "fghfjgjk" )
		effectScript:RegisterEvent( 20, "dsfdgdfh" )
		effectScript:RegisterEvent( 23, "fgfhfjhj" )
	end,

	dsfdgh = function( effectScript )
		SetAnimation(H042_auto775_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	fghfjgjk = function( effectScript )
		AttachAvatarPosEffect(false, H042_auto775_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 0), 0.8, 100, "H042_xuli_1")
	AttachAvatarPosEffect(false, H042_auto775_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H042_xuli_2")
	AttachAvatarPosEffect(false, H042_auto775_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H042_xuli_3")
		PlaySound("skill_04202")
	end,

	dsfdgdfh = function( effectScript )
		AttachAvatarPosEffect(false, H042_auto775_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 0.75, 100, "S774_1")
	AttachAvatarPosEffect(false, H042_auto775_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H042_xuli_2")
	AttachAvatarPosEffect(false, H042_auto775_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, -100, "S362_2")
		PlaySound("skill_04203")
	end,

	fgfhfjhj = function( effectScript )
			DamageEffect(H042_auto775_attack.info_pool[effectScript.ID].Attacker, H042_auto775_attack.info_pool[effectScript.ID].Targeter, H042_auto775_attack.info_pool[effectScript.ID].AttackType, H042_auto775_attack.info_pool[effectScript.ID].AttackDataList, H042_auto775_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
