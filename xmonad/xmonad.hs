import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Layout.IM
import XMonad.Layout.Magnifier
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Column
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.Reflect
import XMonad.Layout.Combo
import XMonad.Layout.Tabbed
import XMonad.Layout.TwoPane
import XMonad.Layout.LayoutScreens
import XMonad.Layout.FixedColumn
import Data.Ratio ((%))
import System.IO

myManageHook = composeAll
	[ ]

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myLayout = toggleLayouts Full perWS 
	where
		perWS = onWorkspace "9" (highScreen) $
								(wideScreen)

		highScreen = avoidStruts $ myColumns ||| Column 1 ||| tallMirror ||| Full
		wideScreen = avoidStruts $ tall ||| tallReflect ||| myColumns ||| myTabbed ||| Full
	
		tallReflect = reflectHoriz $ Tall nmaster delta ratio
			where
				nmaster = 1
				delta = 3/100
				ratio = 1/2

		tallMirror = reflectVert $ Mirror $ Tall nmaster delta ratio
			where
				nmaster = 1
				delta = 3/100
				ratio = 1/2
		
		tall =  Tall nmaster delta ratio
			where
				nmaster = 1
				delta = 3/100
				ratio = 1/2

		myColumns = Mirror $ Column 1

		myTabbed = combineTwo (reflectHoriz $ TwoPane 0.03 0.5) (simpleTabbed) (simpleTabbed)

myNormalBorderColor = "#101010"
myFocusedBorderColor = "#707280"

main = do
	xmproc <- spawnPipe "/usr/bin/xmobar /home/emil/.xmobarrc"
	xmonad $ defaultConfig
		{ manageHook = manageDocks <+> myManageHook <+> manageHook defaultConfig
		, layoutHook = myLayout
		, logHook = dynamicLogWithPP $ xmobarPP
			{ ppOutput = hPutStrLn xmproc
			, ppTitle = xmobarColor "green" "" . shorten 50
			}
		, workspaces = myWorkspaces
		, modMask = mod4Mask     -- Rebind Mod to the Windows key
		, normalBorderColor = myNormalBorderColor
		, focusedBorderColor = myFocusedBorderColor
		, focusFollowsMouse = True
		, terminal = "gnome-terminal"
		} `additionalKeysP`
		[
		  ("<xK_Print>", spawn "scrot")
		, ("M1-C-l", spawn "gnome-screensaver-command -l")
		, ("M1-C-0", layoutScreens 3 (combineTwo (TwoPane 0 0.6313) (TwoPane 0 0.4157) (Full)))
		, ("M1-C-9", rescreen)
		]
