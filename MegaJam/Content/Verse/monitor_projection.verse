using { /Verse.org/Input }
using { /Verse.org/Simulation }
using { /Verse.org/SpatialMath }

# Projects a flat, upright rectangle in the world (like Room_Monitor) onto the player's
# viewport, as fractions of the screen (0..1 from the top-left), for canvas anchors. Kept apart
# from the UI code because /Verse.org/SpatialMath and the UI's
# /UnrealEngine.com/Temporary/SpatialMath both define vector2 and vector3.
#
# ProjectWorldToViewport answers in physical screen centimeters (1920 px at 96 per inch is
# 50.8 cm wide), so the viewport's size in those units changes with the display. Each call
# measures it by projecting a point far down the desk camera's axis (eye (-140, -287, 134),
# looking down -X, 5 degrees down), which lands in the screen's centre at any aspect ratio. The
# eye that DeprojectViewportToWorld returns is off (it made the screen 12% too small), so it
# isn't used.

# Room_Monitor: an 80 cm plane at (-235, -243, 119), facing the camera (yaw -90). Moved up from
# Z 115 (Chip, 2026-11-13); Room_MonitorGlass and the DreamDebuggerScreen entity moved with it.
MakeMonitorPanel()<transacts>:world_panel =
    world_panel:
        CentreX := -235.0
        CentreY := -243.0
        CentreZ := 119.0
        HalfWidth := 40.0
        HalfHeight := 40.0
        AxisX := 0.0
        AxisY := 1.0

monitor_rect := struct:
    Left:float
    Top:float
    Width:float
    Height:float
    # The viewport's width over its height, to turn the fractions into a shape.
    ViewAspect:float = 16.0 / 9.0

world_panel := class:
    # Centre in engine coordinates (cm), half width and height, and the in-plane horizontal
    # axis in engine X and Y.
    CentreX:float
    CentreY:float
    CentreZ:float
    HalfWidth:float
    HalfHeight:float
    AxisX:float
    AxisY:float

    # The camera's fixed orientation in engine coordinates (yaw 180, pitch -5): forward and up.
    # Right is (0, -1, 0).
    FwdX:float = -0.99619
    FwdZ:float = -0.08716
    UpX:float = -0.08716
    UpZ:float = 0.99619
    # The camera's eye in engine coordinates (CO Desk Camera).
    EyeX:float = -140.0
    EyeY:float = -287.0
    EyeZ:float = 134.0

    # The rectangle around the panel's four projected corners, as screen fractions. Fails if a
    # corner is behind the camera.
    ProjectRect(Player:player)<transacts><decides>:monitor_rect =
        Size := ViewportSize[Player]
        A := Project[Player, -HalfWidth, HalfHeight]
        B := Project[Player, HalfWidth, HalfHeight]
        C := Project[Player, -HalfWidth, -HalfHeight]
        D := Project[Player, HalfWidth, -HalfHeight]
        L := Min(Min(A.Left, B.Left), Min(C.Left, D.Left)) / Size.Left
        R := Max(Max(A.Left, B.Left), Max(C.Left, D.Left)) / Size.Left
        T := Min(Min(-A.Up, -B.Up), Min(-C.Up, -D.Up)) / Size.Up
        Bt := Max(Max(-A.Up, -B.Up), Max(-C.Up, -D.Up)) / Size.Up
        monitor_rect{Left := L, Top := T, Width := R - L, Height := Bt - T, ViewAspect := Size.Left / Size.Up}

    # The viewport's width (Left) and height (Up) in the projection's units: twice where a point
    # far down the camera's axis lands, since that point is always the screen's centre. No field
    # of view or aspect ratio comes into it, and at 100 m a few cm of error in the eye don't
    # matter. (Two earlier versions solved it from the eye and the FOV: the first assumed 90
    # degrees across, wrong outside 16:9 since Fortnite keeps the vertical FOV; the second fitted
    # the FOV from two points near the eye, and still landed the debugger short of the glass to
    # the right and below, play test 2026-11-14.)
    ViewportSize(Player:player)<transacts><decides>:vector3 =
        Far := 10000.0
        P := Player.ProjectWorldToViewport[vector3{Forward := EyeX + Far * FwdX, Left := -EyeY, Up := EyeZ + Far * FwdZ}]
        W := 2.0 * P.Left
        H := 2.0 * (-P.Up)
        W > 0.0
        H > 0.0
        vector3{Left := W, Up := H}

    # For diagnosis: the eye DeprojectViewportToWorld reports, as engine X, Y, Z.
    ReportedEye(Player:player)<transacts>:[]float =
        Eye := Player.DeprojectViewportToWorld(vector3{}).Origin
        array{Eye.Forward, -Eye.Left, Eye.Up}

    # One corner, H across and V up from the centre. Engine (X forward, Y right, Z up) is
    # Verse (Forward, Left = -Y, Up).
    Project(Player:player, H:float, V:float)<transacts><decides>:vector3 =
        X := CentreX + H * AxisX
        Y := CentreY + H * AxisY
        Z := CentreZ + V
        Player.ProjectWorldToViewport[vector3{Forward := X, Left := -Y, Up := Z}]
