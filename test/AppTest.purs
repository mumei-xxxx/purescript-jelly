module Test.AppTest where

import Prelude

import Data.Char (fromCharCode, toCharCode)
import Data.Maybe (fromMaybe)
import Data.String.CodeUnits (singleton)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.HookM (HookM)
import Jelly.Hooks.DOM (text)
import Jelly.Hooks.UseState (useState)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Test.AppState (AppState)
import Web.DOM (Node)

appTest :: HookM AppState Node
appTest = do
  getState /\ modifyState <- useState $ toCharCode 'a'

  let
    txt = singleton <<< fromMaybe 'a' <<< fromCharCode <$> getState

  id <- liftEffect $ setInterval 200 do
    modifyState (_ + 1)

  useUnmountEffect do
    liftEffect $ clearInterval id

  text txt
