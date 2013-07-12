import Data.Ratio ((%))
import System.IO
import XMonad
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowBringer
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Column
import XMonad.Layout.Combo
import XMonad.Layout.FixedColumn
import XMonad.Layout.IM
import XMonad.Layout.LayoutScreens
import XMonad.Layout.Magnifier
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.TwoPane
import XMonad.Util.EZConfig(additionalKeysP,removeKeysP)
import XMonad.Util.Run(spawnPipe)

import qualified XMonad.StackSet as W
import XMonad.Actions.CycleWS
--import XMonad.Util.Scratchpad
import XMonad.Util.WorkspaceCompare

myManageHook = composeAll
	[ className =? "Pinentry-x11" --> doFloat -- WM_CLASS(STRING) = "pinentry-x11", "Pinentry-x11"
	, className =? "Pinentry-gtk-2" --> doFloat
	, className =? "XMessage" --> doFloat
	, className =? "Spotify" --> doShift "+"
	]

myWorkspaces :: [WorkspaceId]
myWorkspaces = map show [1 .. 9 :: Int]

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

home = "/home/emil/"

myDMenuOpts =
	[ "-l", "20", "-i", "-nf", "#5a5a5a", "-nb", "#19191d", "-sb", "#19191d", "-sf", "#9fc439", "-fn", "-*-fixed-medium-r-*-*-10-*-*-*-*-*-iso8859-1"]

main = do
	xmproc <- spawnPipe "/usr/bin/xmobar /home/emil/.xmobarrc"
	trayproc <- spawnPipe "killall trayer; trayer --edge top --align right --monitor primary --SetDockType true --SetPartialStrut true --expand true --widthtype request --transparent true --tint 0x000000 --alpha 0 --distancefrom right --distance 380 --height 14"
	spawn "xsetroot -cursor_name arrow"
	xmonad $ ewmh defaultConfig
		{ manageHook = manageDocks <+> myManageHook <+> manageHook defaultConfig
		, layoutHook = myLayout
		, logHook = do
			dynamicLogWithPP $ xmobarPP
				{ ppOutput = hPutStrLn xmproc
				, ppTitle = xmobarColor "#9fc439" "" . shorten 80
				, ppCurrent = xmobarColor "#e08a1f" "" . wrap "[" "]"
				, ppUrgent = xmobarColor "#bd0d74" ""
				, ppSep = " | "
				}
			updatePointer (TowardsCentre 0.05 0.05) -- (Relative 0.5 0.5) is center
		, workspaces = myWorkspaces
		, modMask = mod4Mask     -- Rebind Mod to the Windows key
		, normalBorderColor = myNormalBorderColor
		, focusedBorderColor = myFocusedBorderColor
		, focusFollowsMouse = True
		, terminal = "uxterm" -- was "gnome-terminal"
		}
		`removeKeysP`
		[ "M-<Space>"
		, "M-S-<Space>"
		, "M-p"
		, "M-S-p"
		]
		`additionalKeysP`
		[ ("<xK_Print>", spawn "scrot")
		, ("M-i", gotoMenuArgs myDMenuOpts)
		, ("M-S-i", bringMenuArgs myDMenuOpts)
		, ("M-<Space>", spawn "dmenu_run")
		, ("M-S-<Space>", spawn "gmrun")
		, ("M-p", sendMessage NextLayout)
		--, ("M-S-p", setLayout $ XMonad.layoutHook conf)
		, ("M-<F7>", spawn "/home/emil/bin/spotify.sh previous")
		, ("M-<F8>", spawn "/home/emil/bin/spotify.sh playpause")
		, ("M-<F9>", spawn "/home/emil/bin/spotify.sh next")
		, ("M-C-l", spawn "gnome-screensaver-command -l")
		, ("M-x c", spawn "chromium-browser")
		, ("M-x m", spawn "xmutt")
		, ("M-x i", spawn "irc")
		, ("M-x s", spawn "spotify")
		--, ("M-<Space>", spawn "gnome-screensaver-command -l")
		, ("M-C-0", layoutScreens 2 (TwoPane 0.5 0.5))
		, ("M-C-9", rescreen)
		-- focus HiddenNonEmpty wss except scratchpad
		, ("M-<Right>",
			windows . W.greedyView =<< findWorkspace getSortByIndex Next HiddenNonEmptyWS 1)
		, ("M-<Left>",
			windows . W.greedyView =<< findWorkspace getSortByIndex Prev HiddenNonEmptyWS 1)
		-- http://www.haskell.org/haskellwiki/Xmonad/General_xmonad.hs_config_tips#Using_Next_Previous_Recent_Workspaces_rather_than_mod-n
		]
