S351_magic_H012_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S351_magic_H012_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S351_magic_H012_attack.info_pool[effectScript.ID].Attacker)
        
		S351_magic_H012_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01201")
		PreLoadAvatar("H012_xuli")
		PreLoadSound("skill_01206")
		PreLoadSound("skill_01201")
		PreLoadSound("atalk_01201")
		PreLoadSound("skill_01204")
		PreLoadAvatar("S350_1")
		PreLoadSound("slill_01205")
		PreLoadSound("skill_01204")
		PreLoadAvatar("S350_2")
		PreLoadSound("skill_01205")
		PreLoadSound("skill_01204")
		PreLoadSound("skill_01205")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "b" )
		effectScript:RegisterEvent( 1, "dfdg" )
		effectScript:RegisterEvent( 4, "ghgj" )
		effectScript:RegisterEvent( 18, "gfdh" )
		effectScript:RegisterEvent( 19, "wer" )
		effectScript:RegisterEvent( 40, "a" )
		effectScript:RegisterEvent( 68, "gfdj" )
		effectScript:RegisterEvent( 70, "ewfef" )
		effectScript:RegisterEvent( 72, "bgfdh" )
		effectScript:RegisterEvent( 73, "hgkk" )
		effectScript:RegisterEvent( 74, "dfsg" )
		effectScript:RegisterEvent( 75, "c" )
		effectScript:RegisterEvent( 77, "hgfhgjkhk" )
		effectScript:RegisterEvent( 78, "fgdsh" )
		effectScript:RegisterEvent( 80, "sfdghhj" )
		effectScript:RegisterEvent( 82, "jhgjk" )
		effectScript:RegisterEvent( 83, "dgfhj" )
		effectScript:RegisterEvent( 85, "gfdg" )
		effectScript:RegisterEvent( 86, "dgfh" )
		effectScript:RegisterEvent( 88, "fdhgj" )
	end,

	b = function( effectScript )
		SetAnimation(S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01201")
	end,

	dfdg = function( effectScript )
		AttachAvatarPosEffect(false, S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H012_xuli")
	end,

	ghgj = function( effectScript )
			PlaySound("skill_01206")
	end,

	gfdh = function( effectScript )
			PlaySound("skill_01201")
	end,

	wer = function( effectScript )
		end,

	a = function( effectScript )
		SetAnimation(S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("atalk_01201")
	end,

	gfdj = function( effectScript )
			PlaySound("skill_01204")
	end,

	ewfef = function( effectScript )
		AttachAvatarPosEffect(false, S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S350_1")
	end,

	bgfdh = function( effectScript )
			PlaySound("slill_01205")
	end,

	hgkk = function( effectScript )
		CameraShake()
	end,

	dfsg = function( effectScript )
			PlaySound("skill_01204")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-100, 0), 1.3, 100, "S350_2")
	end,

	hgfhgjkhk = function( effectScript )
			DamageEffect(S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, S351_magic_H012_attack.info_pool[effectScript.ID].Targeter, S351_magic_H012_attack.info_pool[effectScript.ID].AttackType, S351_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S351_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fgdsh = function( effectScript )
			PlaySound("skill_01205")
	end,

	sfdghhj = function( effectScript )
			DamageEffect(S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, S351_magic_H012_attack.info_pool[effectScript.ID].Targeter, S351_magic_H012_attack.info_pool[effectScript.ID].AttackType, S351_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S351_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	jhgjk = function( effectScript )
			PlaySound("skill_01204")
	end,

	dgfhj = function( effectScript )
			DamageEffect(S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, S351_magic_H012_attack.info_pool[effectScript.ID].Targeter, S351_magic_H012_attack.info_pool[effectScript.ID].AttackType, S351_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S351_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gfdg = function( effectScript )
			PlaySound("skill_01205")
	end,

	dgfh = function( effectScript )
			DamageEffect(S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, S351_magic_H012_attack.info_pool[effectScript.ID].Targeter, S351_magic_H012_attack.info_pool[effectScript.ID].AttackType, S351_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S351_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fdhgj = function( effectScript )
			DamageEffect(S351_magic_H012_attack.info_pool[effectScript.ID].Attacker, S351_magic_H012_attack.info_pool[effectScript.ID].Targeter, S351_magic_H012_attack.info_pool[effectScript.ID].AttackType, S351_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S351_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
