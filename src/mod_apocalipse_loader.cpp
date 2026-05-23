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

void Addapocalipse_wow_moduleScripts()
{
    AddModApocalipseScripts();
    AddModSpellScalingScripts();
    AddModApocalipsePvPScripts();
}
