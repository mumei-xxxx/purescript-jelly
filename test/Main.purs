module Test.Main where

import Prelude

import Effect (Effect)
import Jelly.SSG.Generator (GeneratorSettings(..), generate)
import Test.RootComponent (rootComponent)

generatorSettings :: GeneratorSettings
generatorSettings = GeneratorSettings
  { clientMain: "Test.ClientMain"
  , output: "public"
  , component: rootComponent
  }

main :: Effect Unit
main = generate generatorSettings
