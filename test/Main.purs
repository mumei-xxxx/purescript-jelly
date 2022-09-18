module Test.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Prop (on, (:=))
import Jelly.Data.Signal (Signal, modifyAtom_, readSignal, signal, writeAtom)
import Jelly.El (docTypeHTML, el, el_, rawEl, signalC, text)
import Jelly.Hooks.UseInterval (useInterval)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Test.Context (Context)
import Web.DOM (Element)
import Web.Event.Event (target)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes (click, input)
import Web.HTML.HTMLSelectElement as Select

foreign import setInnerHTML :: String -> Element -> Effect Unit

rootComponent :: Component Context
rootComponent = do
  docTypeHTML
  el_ "html" do
    el_ "head" do
      el "script"
        [ "async" := true, "type" := "text/javascript", "src" := "./index.js" ]
        mempty
    el_ "body" do
      el_ "h1" do
        text $ pure "🍮Hello, Jelly!"
      el_ "p" do
        text $ pure "This is a Jelly test."
      withTitle (pure "SSG") ssg
      withTitle (pure "Timer") timer
      withTitle (pure "Counter") counter
      withTitle (pure "Mount / Unmount") mount
      withTitle (pure "Raw") raw

withTitle :: Signal String -> Component Context -> Component Context
withTitle titleSig component = el_ "div" do
  el_ "h2" $ text titleSig
  el "div" [ "style" := "padding: 10px" ] component

ssg :: Component Context
ssg = do
  el_ "p" do
    text $ pure
      "Jelly has SSG capabilities. This site intentionally delays client-side rendering by one second and displays server-side generated HTML for the first second. Therefore, buttons can be clicked after 1 second."

timer :: Component Context
timer = makeComponent do
  timeSig /\ timeAtom <- signal 0

  useInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  pure $ text $ show <$> timeSig

counter :: Component Context
counter = makeComponent do
  countSig /\ countAtom <- signal 0

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ countAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> countSig

mount :: Component Context
mount = makeComponent do
  cmpNameSig /\ cmpNameAtom <- signal "timer"
  logTextSig /\ logTextAtom <- signal ""

  let
    addLog :: String -> Effect Unit
    addLog str = modifyAtom_ logTextAtom \logText ->
      logText <> str <> "\n"

    handleChange :: Event -> Effect Unit
    handleChange e = case Select.fromEventTarget =<< target e of
      Nothing -> pure unit
      Just select -> do
        v <- Select.value select
        addLog $ "input: " <> v
        writeAtom cmpNameAtom =<< Select.value select

    withMountMessage :: Signal String -> Component Context -> Component Context
    withMountMessage nameSig component = makeComponent do
      liftEffect do
        name <- readSignal nameSig
        addLog $ "mount: " <> name

      useUnmountEffect do
        name <- readSignal nameSig
        addLog $ "unmounted: " <> name

      pure component

  pure $ el_ "div" do
    el_ "div" do
      el "select" [ on input handleChange ] do
        el "option" [ "value" := "timer" ] do
          text $ pure "Timer"
        el "option" [ "value" := "counter" ] do
          text $ pure "Counter"
    el "div" [ "style" := [ "border: 1px solid #ccc;", "padding: 10px;", "height: 50px;" ] ] do
      signalC do
        cmpName <- cmpNameSig
        pure $ case cmpName of
          "timer" -> withMountMessage (pure "Timer") timer
          "counter" -> withMountMessage (pure "Counter") counter
          _ -> mempty
    el_ "pre" do
      text logTextSig

raw :: Component Context
raw = rawEl "div" [] $ pure "<p>Raw HTML</p>"
