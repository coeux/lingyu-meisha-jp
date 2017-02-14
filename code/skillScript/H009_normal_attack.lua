H009_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H009_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H009_normal_attack.info_pool[effectScript.ID].Attacker)
       	if H009_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H009_normal_attack.info_pool[effectScript.ID].Effect1);H009_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		H009_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0901")
		PreLoadAvatar("H009_pugong_3")
		PreLoadAvatar("H009_pugong_1")
		PreLoadAvatar("H009_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 27, "dsgdhj" )
		effectScript:RegisterEvent( 28, "dd" )
		effectScript:RegisterEvent( 29, "f" )
		effectScript:RegisterEvent( 30, "g" )
		effectScript:RegisterEvent( 31, "d" )
		effectScript:RegisterEvent( 32, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H009_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_0901")
	end,

	dsgdhj = function( effectScript )
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, H009_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 85), 3, 100, "H009_pugong_3")
	end,

	f = function( effectScript )
		H009_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H009_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 80), 2, 1500, 300, 4, H009_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, -20), "H009_pugong_1", effectScript)
	end,

	g = function( effectScript )
		if H009_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H009_normal_attack.info_pool[effectScript.ID].Effect1);H009_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H009_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -3, 100, "H009_pugong_2")
	end,

	ss = function( effectScript )
			DamageEffect(H009_normal_attack.info_pool[effectScript.ID].Attacker, H009_normal_attack.info_pool[effectScript.ID].Targeter, H009_normal_attack.info_pool[effectScript.ID].AttackType, H009_normal_attack.info_pool[effectScript.ID].AttackDataList, H009_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
