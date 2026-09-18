/*
 * mod_apocalipse_loader.cpp
 *
 * AzerothCore module entry-point.
 * The build system converts the folder name (apocalipse-wow-module) -
 * dashes become underscores - so this function MUST match exactly.
 */

void AddModApocalipseScripts();
void AddModSpellScalingScripts();
void AddModApocalipsePvPScripts();
void AddModApocalipseMageSpellScripts();
void AddModApocalipseMagePyroclasticChainReactionScripts();
void AddModApocalipseMageMissileBarrageOverloadScripts();
void AddModApocalipseMageHypernovaScripts();
void AddModApocalipseMagePrismaticBarrierScripts();
void AddModApocalipseMageFrostBombScripts();
void AddModApocalipseMageAutomaticIceLanceScripts();
void AddModApocalipseMageFrozenRetaliationScripts();
void AddModApocalipseBattlegroundStaminaScripts();

void Addapocalipse_wow_moduleScripts()
{
    AddModApocalipseScripts();
    AddModSpellScalingScripts();
    AddModApocalipsePvPScripts();
    AddModApocalipseMageSpellScripts();
    AddModApocalipseMagePyroclasticChainReactionScripts();
    AddModApocalipseMageMissileBarrageOverloadScripts();
    AddModApocalipseMageHypernovaScripts();
    AddModApocalipseMagePrismaticBarrierScripts();
    AddModApocalipseMageFrostBombScripts();
    AddModApocalipseMageAutomaticIceLanceScripts();
    AddModApocalipseMageFrozenRetaliationScripts();
    AddModApocalipseBattlegroundStaminaScripts();
}
