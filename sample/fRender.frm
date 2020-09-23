VERSION 5.00
Begin VB.Form fRender 
   Caption         =   "Form1"
   ClientHeight    =   6750
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8205
   LinkTopic       =   "Form1"
   ScaleHeight     =   6750
   ScaleWidth      =   8205
   StartUpPosition =   3  'Windows Default
End
Attribute VB_Name = "fRender"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim iR          As New iR_Engine
' Input engine. Gives access to keyboard and mouse
Dim Control     As New iR_Control
' Every 3D Application needs this class
Dim Camera      As New iR_Camera
' MD2 Actor
Dim Actor       As New iR_ActorMD2

' BSP class to load and render level
Dim Level       As New iR_BSPTree
' Some maths routines
Dim Maths       As New iR_Maths

' Light class to make scene more realistic
Dim Light       As New iR_LightEngine


Private Sub Form_Load()
    ' Tell engine that we want to write log file
    iR.SetLogging 1
    
    ' Show initialization dialog. You can use iR.Initialize
    ' to init screen with you oun settings.
    If Not iR.InitWithDialog(Me.hWnd) Then End
    ' Show this form
    Me.Show
    
    
    ' We want to see fps on the screen
    iR.SetDisplayFPS 1
    
    ' Set up our view frustum
    iR.SetViewFrustum 5000, 90, 1
    
    ' Enable stencil buffer to render shadow
    iR.SetStencilEnable True
    
    ' We will have gray background
    iR.SetBackGroundColor RGB(55, 55, 55)
    
    ' Enable filtering
    iR.SetTextureFilter iR_Filter_Bilinear
    
    ' Load our level
    Level.LoadBSP "maps\level.bsp", 8
    
    ' Load actor from file
    Actor.LoadActor "actor\mesh.md2"
    ' Load texture inture engine memory and set texture index to actor
    Actor.SetTextureID iR.LoadTexture("actor\skin.jpg")
    ' Set position for actor
    Actor.SetPosition iR.CreateVec3(0, 340, 0)
    ' Scale actor to be the same size as map
    Actor.SetScale iR.CreateVec3(3, 3, 3)
    ' Enables shadow rendering
    Actor.SetShadowEnable True
    ' Set up directtion for shadow (note: the y value should be
    ' like the distance between actor position and floor
    Actor.SetShadowDirection iR.CreateVec3(50, 100, 50)
    ' Uncomment this line if you want shadow on the model
    'Actor.SetShadowItSelfEnable True
    

    ' This routine adds light to the scene
    Dim c As iR_ColorValue, ldir As iR_Vector3D
    
    c.Blue = 0.7: c.Green = 0.7: c.Red = 0.7: c.alpha = 1
    
    ldir.y = -1: ldir.x = -1: ldir.z = -1
    
    Light.Light_EnableLighting 1
    Light.Light_CreateDirectional ldir, c
    
    Dim Mat As iR_Material
    
    c.Blue = 1: c.Green = 1: c.Red = 1: Mat.Diffuse = c
    c.Blue = 0.3: c.Green = 0.3: c.Red = 0.3: Mat.Emissive = c

    ' Set material for model
    Actor.SetMaterial Mat

    ' Put camera in this position
    Camera.SetPosition iR.CreateVec3(0, 450, 0)
    
    ' General loop where scene is rendered
    Do
        DoEvents
        
        ' Start rendering and clear screen
        iR.BeginScene
        iR.Clear
        
        
        
        ' If Esc is pressed then quit
        If Control.CheckKBKeyPressed(iR_Key_Escape) Then End
        
        ' Rotate camera around the model
        Dim RotAngle As Single
        RotAngle = iR.GetTickPassed / 1000
        Camera.SetPosition iR.CreateVec3(Sin(RotAngle) * 100, 450, Cos(RotAngle) * 100)
        Camera.SetLookAt Actor.GetPosition
        
        ' Updates matrices
        Camera.Update
        
        ' Render our level
        Level.Render
    
        Light.Light_EnableLighting 1
        ' Render actor
        Actor.Render
    
        ' Flips buffers and finishes rendering
        iR.Present
        iR.EndScene
    Loop
    
End Sub



