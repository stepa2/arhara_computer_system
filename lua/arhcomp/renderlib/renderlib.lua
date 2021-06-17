--[[
    Based on WireGPU lib, https://github.com/wiremod/wire/blob/master/lua/wire/gpulib.lua
]]

AddCSLuaFile()
AddCSLuaFile("renderlib_cl.lua")

ArhComp.RenderLib = {}

include("renderlib_objects.lua")

if CLIENT then
   include("renderlib_cl.lua")
end
if SERVER then
   include("renderlib_sv.lua")
end

local SurfaceTemplates = {}

function ArhComp.RenderLib.RegisterSurfaceTemplate(templateName, shader, opaque, matFactory)
   local template = {
      Shader = shader,
      MaterialTableFactory = matFactory,
      Opaque = opaque,
      Name = templateName
   }

   SurfaceTemplates[templateName] = template

   if CLIENT then
      ArhComp.RenderLib.ImplCl_RegisterSurfaceTemplate(templateName, template)
   end

   return template
end

function ArhComp.RenderLib.GetTemplateByName(templateName)
   return SurfaceTemplates[templateName]
end